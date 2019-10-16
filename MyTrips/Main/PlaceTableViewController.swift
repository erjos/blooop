//
//  PlaceTableViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 4/30/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseUI

enum TableListView {
    //simple just the name
    case Compact
    
    //expanded with photo and additional info
    case Expanded
}

protocol PlaceTableDelegate: class {
    func didSelectPlace(place: SubLocation, indexPath: IndexPath)
    func didTapPlaceholder()
}

class PlaceTableViewController: UIViewController {

    
    @IBOutlet weak var placeHolderView: UIView!
    @IBOutlet weak var placeTableView: UITableView!
    
    //TODO:can we use a didSet here to deal with the image placeholder change?
    var trip: PrimaryLocation?
    var tableListState: TableListView = .Compact
    var tableHeader: PlaceTableHeaderView?
    weak var placeTableDelegate: PlaceTableDelegate?
    lazy var firebaseInteractor: FirebaseAuthProtocol = FirebaseInteractor()
    
    @IBAction func didTapPlaceholder(_ sender: Any) {
        placeTableDelegate?.didTapPlaceholder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Table view setup
        let nib = UINib(nibName: "PlaceListTableViewCell", bundle: Bundle.main)
        self.placeTableView.register(nib, forCellReuseIdentifier: "placeCell")
        let expandedNib = UINib(nibName: "ListTableViewCell", bundle: Bundle.main)
        self.placeTableView.register(expandedNib, forCellReuseIdentifier: "listCell")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        //checks to make sure editing is off - keeps edit button working if user swipes to delete
        self.placeTableView.setEditing(false, animated: animated)
        self.placeTableView.setEditing(editing, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TripMenuTableViewController {
            destination.delegate = self
        }
    }
}

extension PlaceTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip?.subLocations.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let placeID = trip?.getSubLocationPlaceID(from: indexPath) else {
            return UITableViewCell()
        }
        //TODO: This is needed if we want to fetch photos later on - its not very intuitive how this works right now - might be able to clean it up or at least make it easier to understand
        GooglePhotoManager.loadMetaDataList(placeID: placeID, success: { list in
            GoogleResourceManager.sharedInstance.addPhotoMetaData(metaData: (placeID, list))
        }) { error in
            //TODO: ERROR
        }
        
        let place = trip?.getSubLocation(from: indexPath)
        
        if(tableListState == .Compact){
            let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell") as! PlaceListTableViewCell
            
            cell.placeNameLabel.text = place?.label
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListTableViewCell
            
            GooglePhotoManager.getFirstPhoto(placeID: placeID, success: { (image, attr) in
                cell.setThumbnailImage(image: image)
            }) { error in
                cell.handleFailedImage()
            }
            
            //TODO: do we want to move these a prepare for reuse method?
            cell.dateLabel.isHidden = true
            cell.notesLabel.isHidden = true
            
            //show date if it is set
            if let date = place?.date {
                cell.dateLabel.text = date.formatDateAsString()
                cell.dateLabel.isHidden = false
            }
            
            if place?.notes != "" {
                cell.notesLabel.text = place?.notes
                cell.notesLabel.isHidden = false
            }
            
            //cell.activityLabel.isHidden = true
            
            //if let label = trip?.getSubLocation(from: indexPath).label {
            //cell.activityLabel.isHidden = false
            //cell.activityLabel.text = label
            //}
            let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: placeID)
            cell.locationLabel.text = gms?.name
            cell.selectionStyle = .none
            return cell
        }
    }
    
    //warned to make this func private - not sure if it still does what we want - make sure this is ok
    private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
}

extension PlaceTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = Bundle.main.loadNibNamed("PlaceTableHeaderView", owner: self, options: nil)?.first as?
        PlaceTableHeaderView
        
        guard let name = trip?.locationName else {
            view?.setLabel(name: "Search for a place")
            return view
        }
        
        //Setup for existing trip
        view?.setLabel(name: name)
        //view?.editButton.isHidden = false
        //view?.listButton.isHidden = false
        view?.delegate = self
        
        self.tableHeader = view
        return view
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete) {
            guard let location = trip else {
                return
            }
            
            //TODO: should we use a delegate here?
            guard let mainVC = self.parent as? MainViewController else {
                fatalError("You messed up the tables parent View Controller")
            }
            mainVC.deleteMapMarker(indexPath: indexPath)
            
            RealmManager.deleteSubLocation(city: location, indexPath: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableListState == .Expanded){
            return 145.00
        } else {
            return 44.00
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sublocation = self.trip?.getSubLocation(from: indexPath) else {
            return
        }
        
        self.placeTableDelegate?.didSelectPlace(place: sublocation, indexPath: indexPath)
    }
}

//delegate to handle trip menu selections
extension PlaceTableViewController: TripMenuDelegate {
    func didSelectEdit(shouldEdit: Bool) {
        setEditing(shouldEdit, animated: true)
        if let header = self.tableHeader {
            header.moreButton.isHidden = shouldEdit
            header.doneButton.isHidden = !shouldEdit
        }
    }
    
    func didSelectSave() {
        //need to check if user is logged in and save a custom object if they are with a unique user identifier
        Auth.auth().addStateDidChangeListener { (auth, user) in
            //check if user is signed in
            guard user != nil else {
                guard let authVC = self.firebaseInteractor.getAuthViewController(delegate: self) else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.present(authVC, animated: true, completion: nil)
                }
                print("send to sign in")
                return
            }
            
            //if user is signed in save the current trip to the firestore
            
            //TODO: figure out setting and getting of user trip objects including authentication for retrieving when permissions are granted
            //this data doesnt need to be the same as the stored object
            
            //create dictionary of sublocation data
            
            var subs = [[String : Any]]()
            if let sublocations = self.trip?.subLocations {
                
                for sublocation in sublocations {
                    let locationData = ["label" : sublocation.label as Any,
                                        "date" : sublocation.date as Any,
                                        "placeId" : sublocation.placeID,
                                        "notes" : sublocation.notes] as [String : Any]
                    
                    subs.append(locationData)
                }
            }
            
            let docData : [String : Any] = ["owner" : user?.uid,
                                            "placeId" : self.trip?.placeID,
                                            "label" : self.trip?.label,
                                            "locationId" : self.trip?.locationId,
                                            "subLocations" : subs]
            
            Firestore.firestore().collection("trips").addDocument(data: docData)
        }
    }
}

extension PlaceTableViewController: FUIAuthDelegate {
    //TODO: investigate what needs to be done with refresh token and checking if we are authenticated etc...
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        //recieve sign in callback
        
        //use the user id to associate with other data that we store on the backend
        //ie. trips contain a user id -
        
    }
}

//delegate to handle actions for the table header
extension PlaceTableViewController: PlaceTableHeaderDelegate {
    
    func didSelectMore() {
        self.performSegue(withIdentifier: "showTripMenu", sender: self)
    }
    
    func didSelectDone() {
        setEditing(false, animated: true)
        if let header = self.tableHeader {
            header.moreButton.isHidden = false
            header.doneButton.isHidden = true
        }
    }
}



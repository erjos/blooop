//
//  PlaceTableViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 4/30/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit

enum TableListView {
    //simple just the name
    case Compact
    
    //expanded with photo and additional info
    case Expanded
}

protocol PlaceTableDelegate: class {
    func didSelectPlace(place: SubLocation)
}

class PlaceTableViewController: UIViewController {

    @IBOutlet weak var placeTableView: UITableView!
    
    var trip: PrimaryLocation?
    var tableListState: TableListView = .Compact
    weak var placeTableDelegate: PlaceTableDelegate?
    
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
        
        if(tableListState == .Compact){
            let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell") as! PlaceListTableViewCell
            
            cell.placeNameLabel.text = trip?.getSubLocation(from: indexPath).label
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListTableViewCell
            
            GooglePhotoManager.getFirstPhoto(placeID: placeID, success: { (image, attr) in
                cell.setThumbnailImage(image: image)
            }) { error in
                cell.handleFailedImage()
            }
            
            //cell.activityLabel.isHidden = true
            //cell.dateLabel.isHidden = true
            //if let label = trip?.getSubLocation(from: indexPath).label {
            //cell.activityLabel.isHidden = false
            //cell.activityLabel.text = label
            //}
            //            if let date = city.getSubLocation(from: indexPath).date?.formatDateAsString() {
            //                cell.dateLabel.isHidden = false
            //                cell.dateLabel.text = date
            //            }
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
        view?.editButton.isHidden = false
        view?.delegate = self
        
        return view
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
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
            return 130.00
        } else {
            return 44.00
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sublocation = self.trip?.getSubLocation(from: indexPath) else {
            return
        }
        
        self.placeTableDelegate?.didSelectPlace(place: sublocation)
    }
}

extension PlaceTableViewController: PlaceTableHeaderDelegate {
    func didSelectEdit(shouldEdit: Bool) {
        setEditing(shouldEdit, animated: true)
    }
    
    func didChangeListView() {
        //switch the table state
        self.tableListState = (self.tableListState == .Compact) ? .Expanded : .Compact
        self.placeTableView.reloadData()
    }
}



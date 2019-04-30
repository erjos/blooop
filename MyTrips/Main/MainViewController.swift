//
//  MainViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 1/13/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//
import UIKit
import GoogleMaps
import GooglePlaces

//TODO:

//Next Release:
//Theme: Clean functionality

//>change scroll indicator insets
//> When click on a place - highlight it on the map and open the new place controller below the map where the table is
//> Let menu close when we pan swipe it
//> make menu prettier
//> could put a pop out button on the map so users can view the map as a full screen if they want

//> Currently user is allowed to add multiple of the same location to the trip - would be nice to have an alert asking if this is intentional... but not necessarily a requirement
//> Maybe we only show existing trips in the menu for this first version - not sure if we have any other needed functionality
//> Image or animation or something to put in the table when theres no items listed
//> Add a loading state to the main page for loading trips and loading the autocomplete vc
//> Do we want to add zoom buttons to the map?

//Stretch goals
//> Feature: Need to do something when we click on a place after we start planning - open a new screen or initiate a way to input more data specific to that place (notes, dates times, etc.) - start simple

//> Create a protocol that can abstract out the mechanism of saving the realm data

enum TripSaveStatus {
    //trip exists and is saved
    case Saved
    
    //trip doesnt exist
    case Empty
}

enum TableListView {
    //simple just the name
    case Compact
    
    //expanded with photo and additional info
    case Expanded
}

class MainViewController: UIViewController {
    @IBOutlet weak var clearDrawerView: UIView!
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var menuCoverWidth: NSLayoutConstraint!
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    @IBOutlet weak var mapContainer: GMSMapView!
    @IBOutlet weak var placeTableView: UITableView!
    @IBOutlet weak var resetMap: UIButton!
    
    //prob want to pull this out and manage the location via a delegate
    var locationManager: CLLocationManager!
    
    //**ViewModel stuff**
    var trip: PrimaryLocation?
    var currentTripStatus: TripSaveStatus = .Empty
    var tableListState: TableListView = .Compact
    //used to restrict search results
    var coordinateBounds: GMSCoordinateBounds?
    //TODO: do we want to create a class to handle all the map stuff or keep in on this viewController? - could embed one using a child view controller
    var mapMarkers:[GMSMarker]?
    
    @IBAction func menuButton(_ sender: Any) {
        view.bringSubview(toFront: drawerView)
        view.bringSubview(toFront: clearDrawerView)
        UIView.animate(withDuration: 0.3) {
            //TODO: remove these hardcoded values and derive from screen width
            self.menuWidth.constant = (self.menuWidth.constant == 0) ? 300 : 0
            let constant = UIScreen.main.bounds.width - 300
            self.menuCoverWidth.constant = (self.menuCoverWidth.constant == 0) ? constant : 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func tapReset(_ sender: Any) {
        //get place for id
        guard let id = self.trip?.placeID else {
            return
        }
        let place = GoogleResourceManager.sharedInstance.getPlaceForId(ID: id)
        
        handleMapSetup(for: place)
    }
    
    @IBAction func tapMenuCover(_ sender: Any) {
        closeMenu()
    }
    
    @IBAction func tapSearch(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.autocompleteBoundsMode = .restrict
        
        if let _ = trip {
            autocompleteController.autocompleteBounds = self.coordinateBounds
        }
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        locationManager.startUpdatingLocation()
        menuWidth.constant = 0
        menuCoverWidth.constant = 0
        
        //Table view setup
        let nib = UINib(nibName: "PlaceListTableViewCell", bundle: Bundle.main)
        self.placeTableView.register(nib, forCellReuseIdentifier: "placeCell")
        let expandedNib = UINib(nibName: "ListTableViewCell", bundle: Bundle.main)
        self.placeTableView.register(expandedNib, forCellReuseIdentifier: "listCell")
        
        self.resetMap.isHidden = true
    }
    
    @objc func closeMenu() {
        UIView.animate(withDuration: 0.3) {
            self.menuWidth.constant = 0
            self.menuCoverWidth.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        #if DEBUG
        guard let _ = trip else {
            //Portland coordinate - test location
            let coordinate = CLLocationCoordinate2D(latitude: 45.523450, longitude: -122.678897)
            setupMapView(for: coordinate)
            return
        }
        #endif
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    
    private func handleMapSetup(for place: GMSPlace?){
        //check to see if a marker exists - make sure we use the existing marker to setup the view so its more relevant to the user
        if let firstMarker = self.mapMarkers?.first {
            self.setupMapView(for: firstMarker.position)
        } else {
            self.setupMapView(for:place?.coordinate)
        }
    }
    
    private func setupMapView(for coordinate: CLLocationCoordinate2D?) {
        if let target = coordinate {
            let camera = GMSCameraPosition.camera(withTarget: target, zoom: 10)
            mapContainer.camera = camera
            locationManager.stopUpdatingLocation()
        }
        if trip != nil {
            coordinateBounds = LocationManager.getLocationBoundsFromMap(map: mapContainer)
            mapContainer?.delegate = self
        }
        self.mapContainer.bringSubview(toFront: self.resetMap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "drawerEmbedSegue"){
            let drawerVC = segue.destination as! DrawerViewController
            drawerVC.menuDelegate = self
        }
    }
    
    func saveTrip(){
        if let primaryLocation = trip {
            RealmManager.storeData(object: primaryLocation)
            self.currentTripStatus = .Saved
        }
    }
    
    func handlePlaceResultReturned(place: GMSPlace, tripState: TripSaveStatus){
        switch tripState {
        case .Empty:
            self.trip = PrimaryLocation()
            
            //TODO:could we just move the implementation of adding the place to the resource manager  to the setCity method or would this couple things together too much?
            self.trip?.setCity(place: place)
            //save the trip automatically
            self.saveTrip()
            //caches the places when we fetch them so we only have to get them once per session
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            
            placeTableView.reloadData()
            setupMapView(for: place.coordinate)
        case .Saved:
            guard let savedTrip = trip else {
                return
            }
            let location = SubLocation()
            location.placeID = place.placeID
            location.label = place.name
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            RealmManager.addSublocationsToCity(city: savedTrip, location: location)
            
            let marker = mapContainer.addMapMarker(for: place, label: place.name)
            //add new marker to the list
            mapMarkers?.append(marker)
            placeTableView.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        //checks to make sure editing is off - keeps edit button working if user swipes to delete
        self.placeTableView.setEditing(false, animated: animated)
        self.placeTableView.setEditing(editing, animated: animated)
    }
    
    func deleteMapMarker(indexPath: IndexPath){
        let marker = mapMarkers?.remove(at: indexPath.row)
        marker?.map = nil
    }
}

extension MainViewController: MenuDelegate {
    
    func shouldCloseMenu(menu: DrawerViewController) {
        self.closeMenu()
        menu.tableState = .Menu
        menu.menuTableView.reloadData()
    }
    
    //Used to clear the map when user wants to create a new trip
    func shouldClearMap() {
        self.mapContainer.clear()
        
        //maybe combine these into a method so that they occur at the same time?
        //would be the benefit of moving them to a viewModel object so that we can make these private and only accessible via methods that make sense
        self.trip = nil
        self.currentTripStatus = .Empty
        
        placeTableView.reloadData()
        closeMenu()
        resetMap.isHidden = true
    }
    
    func shouldShowAboutApp() {
        self.performSegue(withIdentifier: "showAboutApp", sender: self)
    }
    
    func shouldLoadTrip(trip: PrimaryLocation) {
        self.trip = trip
        self.currentTripStatus = .Saved
        
        //fetches the place and adds it to the resource cache - I hate how this works
        trip.fetchGMSPlace { complete in }
        
        trip.fetchGmsPlacesForCity { complete in
            if complete {
                self.placeTableView.reloadData()
                //create and set map markers
                self.mapMarkers = self.mapContainer.createMapMarkers(for: trip)
                //TODO: get rid of this singleton, improve how this works
                let place = GoogleResourceManager.sharedInstance.getPlaceForId(ID: trip.placeID)
                //sets the view of the map
                
                self.handleMapSetup(for: place)
                
                
                self.closeMenu()
            }
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip?.subLocations.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableListState == .Compact){
            let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell") as! PlaceListTableViewCell
            
            cell.placeNameLabel.text = trip?.getSubLocation(from: indexPath).label
            return cell
        } else {
            //Not registered with the table
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListTableViewCell
            guard let placeID = trip?.getSubLocationPlaceID(from: indexPath) else {
                return cell
            }
            
            GooglePhotoManager.loadMetaDataList(placeID: placeID, success: { list in
                GoogleResourceManager.sharedInstance.addPhotoMetaData(metaData: (placeID, list))
            }) { error in
                //TODO: ERROR
            }
            
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
}

extension MainViewController: UITableViewDelegate {
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
            self.deleteMapMarker(indexPath: indexPath)
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
}

extension MainViewController: PlaceTableHeaderDelegate {
    func didSelectEdit(shouldEdit: Bool) {
        setEditing(shouldEdit, animated: true)
    }
    
    func didChangeListView() {
        //switch the table state
        self.tableListState = (self.tableListState == .Compact) ? .Expanded : .Compact
        self.placeTableView.reloadData()
    }
}

extension MainViewController: CLLocationManagerDelegate {
    //TODO: test this on physical device - I think it is used to determine the starting location when a user first loads the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        setupMapView(for: locations.last?.coordinate)
    }
}

extension MainViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //TODO: Improve coordinate bounds to only expand past the initial zoom if we zoom out - dont want to shrink the search space, because users might zoom in and not know where things are they want to search for are - keep the initial bounds though as a good starting point
        if let _ = trip {
            self.coordinateBounds = LocationManager.getLocationBoundsFromMap(map: mapView)
            self.resetMap.isHidden = false
        }
    }
}

extension MainViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        handlePlaceResultReturned(place: place, tripState: self.currentTripStatus)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        //Handle error
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

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
//Next Release 2.0:
//> Add a loading state to the main page for loading trips and loading the autocomplete vc **
//> add those things to the info pList

//Next Release 2.1:
//> Allow users to click on places on the map to pull up temp place details and decide if they want to add it to the trip...
//> Create a way for the app to function offline - handle sessions better
//> should probably ensure there is a cache in place for the pictures that we've already loaded on the table view

//Stretch goals:
//> Create a protocol that can abstract out the mechanism of saving the realm data
//> Put a pop out button on the map so users can view the map as a full screen if they want
//> Do we want to add zoom buttons to the map?

enum TripSaveStatus {
    //trip exists and is saved
    case Saved
    //trip doesnt exist
    case Empty
}

class MainViewController: UIViewController {
    @IBOutlet weak var clearDrawerView: UIView!
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var menuCoverWidth: NSLayoutConstraint!
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    @IBOutlet weak var mapContainer: GMSMapView!
    @IBOutlet weak var resetMap: UIButton!
    
    //only exists in short height variant - aka landscape views
    @IBOutlet weak var containerLandscapeWidth: NSLayoutConstraint!
    
    //only exists in normal height variant - aka portrait
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //prob want to pull this out and manage the location via a delegate
    var locationManager: CLLocationManager!
    
    //**ViewModel stuff**
    var trip: PrimaryLocation? {
        didSet {
            self.placeTableViewController?.trip = self.trip
            placeTableViewController?.placeHolderView.isHidden = true
        }
    }
    var currentTripStatus: TripSaveStatus = .Empty
    //used to restrict search results
    var coordinateBounds: GMSCoordinateBounds?
    let maxBoundingZoom: Float = 10.0
    
    var mapMarkers:[GMSMarker]?
    
    var placeTableViewController: PlaceTableViewController?
    var placeDetailsViewController: PlaceDetailsViewController?
    var tableLandscapeWidth: CGFloat = 300
    
    @IBAction func menuButton(_ sender: Any) {
        view.bringSubview(toFront: drawerView)
        view.bringSubview(toFront: clearDrawerView)
        UIView.animate(withDuration: 0.2) {
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
        self.resetMap.isHidden = true
        
        //add pan gesture to view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGesture)
        self.drawerView.translatesAutoresizingMaskIntoConstraints = false
        //set table width value in case we change the storyboard
        self.tableLandscapeWidth = self.containerLandscapeWidth.constant
        
        self.activityIndicator.isHidden = true
    }
    
    //consider combining these two methods
    func openMenu() {
        UIView.animate(withDuration: 0.2) {
            self.menuWidth.constant = 300
            self.menuCoverWidth.constant = UIScreen.main.bounds.width - 300
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func closeMenu() {
        UIView.animate(withDuration: 0.2) {
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
    
    
    private func handleMapSetup(for place: GMSPlace?) {
        //check to see if a marker exists - make sure we use the existing marker to setup the view so its more relevant to the user
        if let firstMarker = self.mapMarkers?.first {
            self.setupMapView(for: firstMarker.position)
        } else {
            self.setupMapView(for:place?.coordinate)
        }
    }
    
    private func setupMapView(for coordinate: CLLocationCoordinate2D?) {
        mapContainer?.delegate = self
        
        if let target = coordinate {
            let camera = GMSCameraPosition.camera(withTarget: target, zoom: maxBoundingZoom)
            mapContainer.camera = camera
            locationManager.stopUpdatingLocation()
        }
        
        if trip != nil {
            coordinateBounds = LocationManager.getLocationBoundsFromMap(map: mapContainer)
        }
        self.mapContainer.bringSubview(toFront: self.resetMap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "drawerEmbedSegue") {
            let drawerVC = segue.destination as! DrawerViewController
            drawerVC.menuDelegate = self
        }
        if(segue.identifier == "placeTableEmbed") {
            guard let placeTableVC = segue.destination as? PlaceTableViewController else {
                fatalError("You messed up casting this view controller")
            }
            self.placeTableViewController = placeTableVC
            self.placeTableViewController?.placeTableDelegate = self
            
            //TODO: do we need this if we use the did set? Are both in use?
            placeTableViewController?.trip = self.trip
        }
    }
    
    func saveTrip() {
        if let primaryLocation = trip {
            RealmManager.storeData(object: primaryLocation)
            self.currentTripStatus = .Saved
        }
    }
    
    func handlePlaceResultReturned(place: GMSPlace, tripState: TripSaveStatus) {
        switch tripState {
        case .Empty:
            self.trip = PrimaryLocation()
            
            //TODO:could we just move the implementation of adding the place to the resource manager  to the setCity method or would this couple things together too much?
            self.trip?.setCity(place: place)
            //save the trip automatically
            self.saveTrip()
            //caches the places when we fetch them so we only have to get them once per session
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            
            placeTableViewController?.placeTableView.reloadData()
            setupMapView(for: place.coordinate)
        case .Saved:
            guard let savedTrip = trip else {
                return
            }
            let location = SubLocation()
            location.placeID = place.placeID ?? "No ID found"
            location.label = place.name
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            RealmManager.addSublocationsToCity(city: savedTrip, location: location)
            
            let marker = mapContainer.addMapMarker(for: place, label: place.name)
            //add new marker to the list
            mapMarkers?.append(marker)
            placeTableViewController?.placeTableView.reloadData()
        }
    }
    
    func deleteMapMarker(indexPath: IndexPath) {
        let marker = mapMarkers?.remove(at: indexPath.row)
        marker?.map = nil
    }
    
    func closePlaceDetails() {
        if let placeDetails = placeDetailsViewController {
            removeContentController(viewController: placeDetails)
            UIView.animate(withDuration: 0.2) {
                //set priority back to low priority
                self.containerHeightConstraint.priority = UILayoutPriority.init(rawValue: 997)
                //idk if we need to do this - could keep the other width and remove this hardcoded value or at least store it dynamically...
                self.containerLandscapeWidth.constant = self.tableLandscapeWidth
                self.view.layoutIfNeeded()
            }
            //de-select map marker
            self.mapContainer.selectedMarker = nil
            self.placeTableViewController?.placeTableView.reloadData()
        }
    }
}

extension MainViewController: MenuDelegate {
    
    func shouldCloseMenu(menu: DrawerViewController) {
        self.closeMenu()
        menu.tableState = .Menu
        menu.menuTableView.reloadData()
    }
    
    //Used to clear the map when user wants to create a new trip
    func shouldClearMap(trip: PrimaryLocation?) {
        //block to check if the trip we deleted is invalidated -
        //TODO: could probably pass something other than the trip - we dont need it, we just need to know to check invalidation
        if let _ = trip {
            guard self.trip?.isInvalidated ?? false else {
                return
            }
        }
        self.closePlaceDetails()
        self.mapContainer.clear()
        self.trip = nil
        self.currentTripStatus = .Empty
        self.placeTableViewController?.placeTableView.reloadData()
        resetMap.isHidden = true
    }
    
    func shouldShowAboutApp() {
        self.performSegue(withIdentifier: "showAboutApp", sender: self)
    }
    
    func shouldLoadTrip(trip: PrimaryLocation) {
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.isHidden = false
        
        closePlaceDetails()
        
        self.trip = trip
        self.currentTripStatus = .Saved
        
        //fetches the place and adds it to the resource cache - I hate how this works
        trip.fetchGMSPlace { complete in }
        
        trip.fetchGmsPlacesForCity { complete in
            if complete {
                self.placeTableViewController?.placeTableView.reloadData()
                //create and set map markers
                self.mapMarkers = self.mapContainer.createMapMarkers(for: trip)
                //TODO: get rid of this singleton, improve how this works
                let place = GoogleResourceManager.sharedInstance.getPlaceForId(ID: trip.placeID)
                //sets the view of the map
                self.handleMapSetup(for: place)
                self.closeMenu()
                self.activityIndicator.isHidden = true
            }
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    
    //TODO: not sure what this does - I think a blank map just initializes over 0,0 coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        setupMapView(for: locations.last?.coordinate)
    }
}

extension MainViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if trip != nil {
            
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if let _ = trip {
            let zoom = mapView.camera.zoom
            //if zoom is <= to maxBoundingZoom we know we either zoomed out or moved camera position and should update search to contain new bounds
            if(zoom <= self.maxBoundingZoom) {
                //reset restriction bounds to new camera view
                self.coordinateBounds = LocationManager.getLocationBoundsFromMap(map: mapView)
            }
            self.resetMap.isHidden = false
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        //TODO: implement this on the map to allow easier retrieval of places
        //can be used to retrieve interactions from the map
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        closePlaceDetails()
        let marker = mapMarkers?
            .enumerated()
            .first{$0.element == marker}
        guard let markerIndex = marker?.offset else {
            return false
        }
        let indexPath = IndexPath(row: markerIndex, section: 0)
        guard let subLocation = trip?.getSubLocation(from: indexPath) else {
            return false
        }
        self.didSelectPlace(place: subLocation, indexPath: indexPath)
        return true
    }
}

extension MainViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        closePlaceDetails()
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

extension MainViewController: PlaceDetailsDelegate {
    
    func shouldCloseDetails() {
        closePlaceDetails()
    }
}

extension MainViewController : PlaceTableDelegate {
    func didSelectPlace(place: SubLocation, indexPath: IndexPath) {
        guard let detailsVC = UIStoryboard(name: "MyTrip", bundle: Bundle.main).instantiateViewController(withIdentifier: "placeDetailsVC") as? PlaceDetailsViewController else {
            return
        }
        //need to set the place before we add the veiwController
        detailsVC.place = place
        detailsVC.delegate = self
        addContentController(viewController: detailsVC, container: containerView)
        
        UIView.animate(withDuration: 0.2, animations: {
            //change priority to higher than equal-heights constraint
            self.containerHeightConstraint.priority = UILayoutPriority.init(rawValue: 999)
            self.containerHeightConstraint.constant = detailsVC.getContentHeight()
            self.containerLandscapeWidth.constant = detailsVC.getContentWidth()
            self.view.layoutIfNeeded()
        }) { (isComplete) in
            //select the correct marker - needs to happen after the animation
            self.mapContainer.selectedMarker = self.mapMarkers?[indexPath.row]
        }
        
        placeDetailsViewController = detailsVC
    }
}

extension MainViewController : UIGestureRecognizerDelegate {
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        //might not need this bool - but I could see it being useful in other situations
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        
        switch recognizer.state {
            
        case .began:
            //bring to front
            view.bringSubview(toFront: drawerView)
            view.bringSubview(toFront: clearDrawerView)
            
            //probably dont need this here
            if gestureIsDraggingFromLeftToRight {
                //addLeftPanelViewController()
            } else {
                //addRightPanelViewController()
            }
            
            //showShadowForCenterViewController(true)
            //}
            
        case .changed:
            if let rview = recognizer.view {
                //UIView.animate(withDuration: 0) {
                self.menuWidth.constant = self.menuWidth.constant + recognizer.translation(in: self.view).x
                
                self.menuCoverWidth.constant = UIScreen.main.bounds.width - self.menuWidth.constant
                    //self.view.layoutIfNeeded()
                //}
                
                //let panValue = rview.center.x + recognizer.translation(in: view).x
                //print("value: \(recognizer.translation(in: view))")
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
            
        case .ended:
            if gestureIsDraggingFromLeftToRight {
                let hasMovedGreaterThanHalfway = menuWidth.constant > 150
                
                if (hasMovedGreaterThanHalfway) {
                    self.openMenu()
                } else {
                    self.closeMenu()
                }
            } else {
                let hasMovedGreaterThanHalfway = menuWidth.constant < 150
                if (hasMovedGreaterThanHalfway) {
                    self.closeMenu()
                } else {
                    self.openMenu()
                }
            }
        default:
            break
        }
    }
}

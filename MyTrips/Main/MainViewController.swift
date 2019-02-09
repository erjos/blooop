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

//> Need to do something when we click on a place after we start planning - open a new screen or initiate a way to input more data specific to that place (notes, dates times, etc.) - start simple

//> Create a protocol that can abstract out the mechanism of saving the realm data

//> Provide warning if user selects to view a saved trip while there is unsaved data on the page

class MainViewController: UIViewController {
    @IBOutlet weak var clearDrawerView: UIView!
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var menuCoverWidth: NSLayoutConstraint!
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    @IBOutlet weak var mapContainer: GMSMapView!
    @IBOutlet weak var placeTableView: UITableView!
    
    //prob want to pull this out and manage the location via a delegate
    var locationManager: CLLocationManager!
    
    //viewModel variables (move to an object a little later)
    var trip: PrimaryLocation?
    var coordinateBounds: GMSCoordinateBounds?
    
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
    
    //TODO: migt be able to remove this
    @IBAction func tapMenu(_ sender: Any) {
        closeMenu()
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
        
        let nib = UINib(nibName: "PlaceListTableViewCell", bundle: Bundle.main)
        self.placeTableView.register(nib, forCellReuseIdentifier: "placeCell")
    }
    
    func toggleMenu(isHidden: Bool) {
        
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
            //Portland coordinate - good for test
            let coordinate = CLLocationCoordinate2D(latitude: 45.523450, longitude: -122.678897)
            setupMapView(coordinate: coordinate)
            return
        }
        #endif
    }
    
    private func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    private func setupMapView(coordinate: CLLocationCoordinate2D?) {
        //TODO: add method to load trips for when adding trips from storage
        if let target = coordinate {
            let camera = GMSCameraPosition.camera(withTarget: target, zoom: 10)
            mapContainer.camera = camera
            locationManager.stopUpdatingLocation()
        }
        
        if trip != nil {
            coordinateBounds = LocationManager.getLocationBoundsFromMap(map: mapContainer)
            mapContainer?.delegate = self
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "drawerEmbedSegue"){
            let drawerVC = segue.destination as! DrawerViewController
            drawerVC.menuDelegate = self
        }
    }
}

extension MainViewController: MenuDelegate {
    func shouldCloseMenu() {
        self.closeMenu()
        //menu.tableState = .Menu
    }
    
    func shouldClearMap() {
        //TODO: add an are you sure alert if there is unsaved data on the map
        self.mapContainer.clear()
        self.trip = nil
        placeTableView.reloadData()
        closeMenu()
    }
    
    func shouldSaveTrip() {
        if let primaryLocation = trip {
            RealmManager.storeData(object: primaryLocation)
        }
        
        //TODO:else -- display a message indicating the user must choose a location first
    }
    
    func shouldLoadTrip(trip: PrimaryLocation) {
        self.trip = trip
        
        //fetches the place and adds it to the resource cache - I hate how this works
        trip.fetchGMSPlace { complete in }
        
        trip.fetchGmsPlacesForCity { complete in
            if complete {
                self.placeTableView.reloadData()
                self.mapContainer.createMapMarkers(for: trip, map: self.mapContainer)
                //TODO: get rid of this singleton shit and fix how this works
                let place = GoogleResourceManager.sharedInstance.getPlaceForId(ID: trip.placeID)
                self.setupMapView(coordinate:place?.coordinate)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell") as! PlaceListTableViewCell
        
        cell.placeNameLabel.text = trip?.getSubLocation(from: indexPath).label
        return cell
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
        
        view?.setLabel(name: name)
        return view
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        setupMapView(coordinate: locations.last?.coordinate)
        //TODO: consider providing a location refresh mechanism on the page
    }
}

extension MainViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //TODO: Improve coordinate bounds to only expand past the initial zoom if we zoom out - dont want to shrink the search space, because users might zoom in and not know where things are they want to search for are - keep the initial bounds though as a good starting point
        if let _ = trip {
            self.coordinateBounds = LocationManager.getLocationBoundsFromMap(map: mapView)
        }
    }
}

extension MainViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if let _ = self.trip {
            let location = SubLocation()
            //do we want to use a similar setPlace method that we use for Primary?
            location.placeID = place.placeID
            location.label = place.name
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            self.trip?.subLocations.append(location)
            mapContainer.addMapMarker(for: location, map: mapContainer)
            placeTableView.reloadData()
        } else {
            //create the trip
            self.trip = PrimaryLocation()
            self.trip?.setCity(place: place)
            //could we just move the implementation of setCity tp add the GmsPlace to the resource manager?
            //Also why did I need the resource manager to begin with?
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            placeTableView.reloadData()
            setupMapView(coordinate: place.coordinate)
        }
        
        //TODO: consdier rewriting how the RealmManager works
        //Gonna need to add this in there when we fix the realm interactions
        //append the new location to the end of the list at the appropriate index
            //RealmManager.addSublocationsToCity(city: city, location: location)
            //trip.cities[cityIndex].locations.append(location)
        //}
        
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

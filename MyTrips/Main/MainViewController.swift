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


class MainViewController: UIViewController {
    @IBOutlet weak var clearDrawerView: UIView!
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var menuCoverWidth: NSLayoutConstraint!
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    @IBOutlet weak var mapContainer: GMSMapView!
    @IBOutlet weak var placeTableView: UITableView!
    
    var locationManager: CLLocationManager!
    var map: GMSMapView?
    
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
    
    @IBAction func tapMenu(_ sender: Any) {
        closeMenu()
    }
    @IBAction func tapMenuCover(_ sender: Any) {
        closeMenu()
    }
    @IBAction func tapSearch(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.autocompleteBoundsMode = .restrict
        
        //TODO: this should only be set if the user has already chosen a main location
        //autocompleteController.autocompleteBounds = self.coordinateBounds
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        locationManager.startUpdatingLocation()
        menuWidth.constant = 0
        menuCoverWidth.constant = 0
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeMenu))
        //self.clearDrawerView.addGestureRecognizer(tapGesture)
        
        let nib = UINib(nibName: "PlaceListTableViewCell", bundle: Bundle.main)
        self.placeTableView.register(nib, forCellReuseIdentifier: "placeCell")
    }
    
    func toggleMenu(isHidden: Bool){
        
    }
    
    @objc func closeMenu(){
        UIView.animate(withDuration: 0.3) {
            self.menuWidth.constant = 0
            self.menuCoverWidth.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        #if DEBUG
        //Portland coordinate - good for test
        let coordinate = CLLocationCoordinate2D(latitude: 45.523450, longitude: -122.678897)
        setupMapView(coordinate: coordinate)
        #endif
    }
    
    private func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    private func setupMapView(coordinate: CLLocationCoordinate2D?){
        //TODO: add method to load trips for when adding trips from storage
        if let target = coordinate {
            let camera = GMSCameraPosition.camera(withTarget: target, zoom: 10)
            mapContainer.camera = camera
            locationManager.stopUpdatingLocation()
        }
        
        ///TODO: we only want to set the coordinate bounds after the user chooses a central location
        //coordinateBounds = LocationManager.getLocationBoundsFromMap(map: map!)
        
        //map?.delegate = self
        //self.mapContainer.addSubview(map!)
        
        //map?.createMapMarkers(for: trip, map: map)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell") as! PlaceListTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = Bundle.main.loadNibNamed("PlaceTableHeaderView", owner: self, options: nil)?.first as?
        UIView
        return view
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //set map with the intial location
        setupMapView(coordinate: locations.last?.coordinate)
        //TODO: provide a location refresh mechanism on the page
    }
}

extension MainViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //if(!isSubLocation){
            //set city data using place data
            //city.setCity(place: place)
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            
            //TODO: test what happens when a user selects a city multiple times from the builder - does it change or update the model correctly?
        //} else {
            let location = SubLocation()
            location.placeID = place.placeID
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            //append the new location to the end of the list at the appropriate index
            //RealmManager.addSublocationsToCity(city: city, location: location)
            //trip.cities[cityIndex].locations.append(location)
        //}
        //set the text field for location
        //searchText.text = place.name
        //searchText.textColor = UIColor.black
        
        //show the other fields
        //locationDivider.isHidden = false
        //nameView.isHidden = false
        //dateView.isHidden = false
        //doneButton.isHidden = false
        
        dismiss(animated: true, completion: nil)
        UIView.animate(withDuration: 1.0 , animations: {
            //
            //self.nameViewHeight.constant = 120
            //self.dateViewHeight.constant = 100
            //TODO: set height of done button back to normal, if it is collapsed
        }) { (complete) in
            //
        }
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

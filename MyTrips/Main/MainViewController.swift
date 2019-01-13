//
//  MainViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 1/13/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit
import GoogleMaps


class MainViewController: UIViewController {
    @IBOutlet weak var mapContainer: UIView!
    var locationManager: CLLocationManager!
    
    var map: GMSMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        locationManager.startUpdatingLocation()
    }
    
    private func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        
    }
    
    private func setupMapView(target: CLLocationCoordinate2D){
        //TODO: add method to load trips for when adding trips from storage
        
        var camera = GMSCameraPosition.camera(withTarget: target, zoom: 10)
        map = GMSMapView.map(withFrame: mapContainer.bounds, camera: camera)
        //map?.delegate = self
        self.mapContainer.addSubview(map!)
        
        //map?.createMapMarkers(for: trip, map: map)
    }
}

extension MainViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //set map with the intial location
        if let coordinate = locations.last?.coordinate {
            setupMapView(target: coordinate)
        }
        //call this when running on simulator from view did load
        else {
            let coordinate = CLLocationCoordinate2D(latitude: 45.523450, longitude: -122.678897)
            setupMapView(target: coordinate)
        }
        //stop updating location after that
        //provide a refresh to start it up again
    }
}

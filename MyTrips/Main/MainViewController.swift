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
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    @IBOutlet weak var mapContainer: UIView!
    var locationManager: CLLocationManager!
    
    var map: GMSMapView?

    @IBAction func menuButton(_ sender: Any) {
        view.bringSubview(toFront: drawerView)
        UIView.animate(withDuration: 0.3) {
            
            //TODO: remove these hardcoded values and derive from screen width
            self.menuWidth.constant = (self.menuWidth.constant == 0) ? 300 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        locationManager.startUpdatingLocation()
        menuWidth.constant = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeMenu))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func toggleMenu(isHidden: Bool){
        
    }
    
    @objc func closeMenu(){
        UIView.animate(withDuration: 0.3) {
            self.menuWidth.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        #if DEBUG
        let coordinate = CLLocationCoordinate2D(latitude: 45.523450, longitude: -122.678897)
        setupMapView(target: coordinate)
        #endif
    }
    
    private func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
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
        } else {
            //provides default map location of
            let coordinate = CLLocationCoordinate2D(latitude: 45.523450, longitude: -122.678897)
            setupMapView(target: coordinate)
        }
        //stop updating location after that
        //provide a refresh to start it up again
    }
}

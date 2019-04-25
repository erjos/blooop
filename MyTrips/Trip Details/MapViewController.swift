//
//  MapViewController.swift
//  JustGoWithIt
//
//  Created by Ethan Joseph on 7/26/18.
//  Copyright © 2018 Joseph, Ethan. All rights reserved.
//

import UIKit
import GoogleMaps

//TODO: determine if this class is even in use anymore
class MapViewController: UIViewController {
    var city: PrimaryLocation?
    var map: GMSMapView?
    var markers: [GMSMarker]?
    
    @IBOutlet weak var mapContainer: UIView!
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //TODO: try this again in the view did load method?
        setupMapView()
    }
    
    //figure out what information we need to pass to delete the marker
    //they will be in the same order as the places
    //more accurate to use the coordinate on the marker perhaps
    func removeMarker(){
        
    }
    
    private func setupMapView() {
        guard let trip = city else {
            return
        }
        let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: trip.placeID)
        let target = gms?.coordinate
        let camera = GMSCameraPosition.camera(withTarget: target!, zoom: 10)
        map = GMSMapView.map(withFrame: mapContainer.bounds, camera: camera)
        map?.delegate = self
        self.mapContainer.addSubview(map!)
        self.markers = map?.createMapMarkers(for: trip)
    }
}

//no idea why I created this
extension MapViewController: GMSMapViewDelegate {
}

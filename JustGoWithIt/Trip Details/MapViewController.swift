//
//  MapViewController.swift
//  JustGoWithIt
//
//  Created by Ethan Joseph on 7/26/18.
//  Copyright © 2018 Joseph, Ethan. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    var city: PrimaryLocation?
    var map: GMSMapView?
    
    @IBOutlet weak var mapContainer: UIView!
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //TODO: try this again in the view did load method
        setupMapView()
    }
    
    private func setupMapView(){
        guard let trip = city else {
            return
        }
        let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: trip.placeID)
        let target = gms?.coordinate
        var camera = GMSCameraPosition.camera(withTarget: target!, zoom: 10)
        map = GMSMapView.map(withFrame: mapContainer.bounds, camera: camera)
        map?.delegate = self
        self.mapContainer.addSubview(map!)
        map?.createMapMarkers(for: trip, map: map)
    }
}

extension MapViewController: GMSMapViewDelegate {
}

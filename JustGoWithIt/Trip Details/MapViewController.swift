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
    
    private func setupMapView(){
        //mapView.isHidden = false
        //mapLabel.isHidden = false
        guard let id = city?.placeID else {
            return
        }
        let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: id)
        let target = gms?.coordinate
        var camera = GMSCameraPosition.camera(withTarget: target!, zoom: 10)
        map = GMSMapView.map(withFrame: mapContainer.bounds, camera: camera)
        map?.delegate = self
        //coordinateBounds = LocationManager.getLocationBoundsFromMap(map: map!)
        self.mapContainer.addSubview(map!)
        //createMapMarkers(for: self.city, map: map)
    }
}

extension MapViewController: GMSMapViewDelegate {
}

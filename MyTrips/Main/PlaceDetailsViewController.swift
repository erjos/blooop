//
//  PlaceDetailsViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 4/30/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit

class PlaceDetailsViewController: UIViewController {
    
    var place: SubLocation!
    weak var delegate: PlaceDetailsDelegate?
    lazy var gmsPlace = GoogleResourceManager.sharedInstance.getPlaceForId(ID: place.placeID)

    @IBOutlet weak var placeLabel: UILabel!
    
    @IBAction func didPressClose(_ sender: Any) {
        delegate?.shouldClose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //TODO: we have some inconsistencies with how we label things right now - between the place label and the gms name (right now they're the same but wont always be)
        placeLabel.text = place?.label
    }

}

protocol PlaceDetailsDelegate: class {
    func shouldClose()
}

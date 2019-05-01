//
//  PlaceDetailsViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 4/30/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit

class PlaceDetailsViewController: UIViewController {
    
    var place: SubLocation?
    weak var delegate: PlaceDetailsDelegate?

    @IBAction func didPressClose(_ sender: Any) {
        delegate?.shouldClose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

protocol PlaceDetailsDelegate: class {
    func shouldClose()
}

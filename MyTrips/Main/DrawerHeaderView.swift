//
//  DrawerHeaderView.swift
//  MyTrips
//
//  Created by Ethan Joseph on 1/27/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit

class DrawerHeaderView: UIView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    weak var delegate: HeaderViewDelegate?
    
    @IBAction func backButtonPressed(_ sender: Any) {
        delegate?.didPressBack()
    }
}

protocol HeaderViewDelegate: class {
    func didPressBack()
}

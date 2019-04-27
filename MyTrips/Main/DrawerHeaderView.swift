//
//  DrawerHeaderView.swift
//  MyTrips
//
//  Created by Ethan Joseph on 1/27/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit

class DrawerHeaderView: UIView {

    @IBOutlet weak var headerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    weak var delegate: HeaderViewDelegate?
    let MENU_LABEL = "Menu"
    let TRIPS_LABEL = "My Trips"
    
    @IBAction func backButtonPressed(_ sender: Any) {
        delegate?.didPressBack()
    }
    
    func hideBackButton(shouldHide: Bool) {
        self.backButton.isHidden = shouldHide
        self.headerLeadingConstraint.constant = shouldHide ? 15 : 39
    }
    
    func setupHeaderView(tableState: DrawerTableState) {
        self.backgroundColor = UIColor.lightGray
        self.hideBackButton(shouldHide: (tableState == .Menu))
        
        switch tableState {
        case .Menu:
            self.headerLabel.text = MENU_LABEL
        case .TripList:
            self.headerLabel.text = TRIPS_LABEL
        }
    }
}

protocol HeaderViewDelegate: class {
    func didPressBack()
}

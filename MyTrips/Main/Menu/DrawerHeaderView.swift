//
//  DrawerHeaderView.swift
//  MyTrips
//
//  Created by Ethan Joseph on 1/27/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit

class DrawerHeaderView: UIView {

    @IBOutlet weak var editDoneButton: UIButton!
    @IBOutlet weak var headerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    weak var delegate: HeaderViewDelegate?
    let MENU_LABEL = "Menu"
    let TRIPS_LABEL = "My Trips"
    let SHARED_LABEL = "Shared with me"
    
    let EDIT_LABEL = "Edit"
    let DONE_LABEL = "Done"
    
    @IBAction func backButtonPressed(_ sender: Any) {
        delegate?.didPressBack()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        let isEdit = self.editDoneButton.currentTitle == EDIT_LABEL
        let title = isEdit ? DONE_LABEL : EDIT_LABEL
        self.editDoneButton.setTitle(title, for: .normal)
        
        //Handle button delegate action
        self.delegate?.didPressEdit(shouldEdit: isEdit)
    }
    
    func hideBackButton(shouldHide: Bool) {
        self.backButton.isHidden = shouldHide
        self.headerLeadingConstraint.constant = shouldHide ? 15 : 39
    }
    
    func hideEditButton(shouldHide: Bool) {
        self.editDoneButton.isHidden = shouldHide
    }
    
    //Is this logic best contained in a method here? - gets more complex with multiple sections
    func setupHeaderView(tableState: DrawerTableState) {
        
        self.hideBackButton(shouldHide: (tableState == .Menu))
        self.hideEditButton(shouldHide: (tableState == .Menu))
        
        switch tableState {
        case .Menu:
            self.headerLabel.text = MENU_LABEL
        case .MyTrips:
            self.headerLabel.text = TRIPS_LABEL
        case .SharedTrips:
            self.headerLabel.text = SHARED_LABEL
        }
    }
}

protocol HeaderViewDelegate: class {
    func didPressBack()
    func didPressEdit(shouldEdit: Bool)
}

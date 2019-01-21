//
//  PlaceTableHeaderView.swift
//  MyTrips
//
//  Created by Ethan Joseph on 1/21/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit

class PlaceTableHeaderView: UIView {

    @IBOutlet weak var placeLabel: UILabel!
    
    func setLabel(name: String){
        self.placeLabel.text = name
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

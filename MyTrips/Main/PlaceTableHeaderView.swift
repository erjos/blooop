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
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    weak var delegate: PlaceTableHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doneButton.isHidden = true
    }
    
    func setLabel(name: String){
        self.placeLabel.text = name
    }
    
    @IBAction func tapMore(_ sender: Any) {
        self.delegate?.didSelectMore()
    }
    
    @IBAction func tapDone(_ sender: Any) {
        self.delegate?.didSelectDone()
    }
}

protocol PlaceTableHeaderDelegate: class {
    func didSelectMore()
    func didSelectDone()
}

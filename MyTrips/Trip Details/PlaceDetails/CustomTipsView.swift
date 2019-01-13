//
//  CustomTipsView.swift
//  JustGoWithIt
//
//  Created by Ethan Joseph on 8/3/18.
//  Copyright © 2018 Joseph, Ethan. All rights reserved.
//

import UIKit

class CustomTipsView: UIView {
    
    weak var delegate: CustomTipsViewDelegate?
    
    
    
    
    @IBAction func pressButton(_ sender: Any) {
        let p = "herro"
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}

protocol CustomTipsViewDelegate: class {
    func didTap()
}

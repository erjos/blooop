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
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    let EDIT_LABEL = "Edit"
    let DONE_LABEL = "Done"
    
    weak var delegate: PlaceTableHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.editButton.isHidden = true
    }
    
    func setLabel(name: String){
        self.placeLabel.text = name
    }
    
    @IBAction func tapEdit(_ sender: Any) {
        //Handle button title change
        let isEdit = self.editButton.currentTitle == EDIT_LABEL
        let title = isEdit ? DONE_LABEL : EDIT_LABEL
        self.editButton.setTitle(title, for: .normal)
        
        //Handle button delegate action
        self.delegate?.didSelectEdit(shouldEdit: isEdit)
    }
    
    @IBAction func tapViewList(_ sender: Any) {
        //TODO: do we need anything else here?
        self.delegate?.didChangeListView()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

protocol PlaceTableHeaderDelegate: class {
    func didSelectEdit(shouldEdit: Bool)
    
    //TODO:pass in an enum to define the list views
    func didChangeListView()
}

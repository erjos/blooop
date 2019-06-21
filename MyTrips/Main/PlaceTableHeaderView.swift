//
//  PlaceTableHeaderView.swift
//  MyTrips
//
//  Created by Ethan Joseph on 1/21/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import UIKit

class PlaceTableHeaderView: UIView {

    //TODO: new more button is responsible for:
    //> editing trip
    //> controlling default table cell options (compact/expanded)
    //> sharing with new users and adding collaborators
    //> controlling share and collab settings (who can edit/view) - if public will only show who can edit
    //> eventually making trips public or private (trips will be public by default)
    
    @IBOutlet weak var placeLabel: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    //TODO: remove these two - will be handled by different delegate and passed back from more menu
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    let EDIT_LABEL = "Edit"
    let DONE_LABEL = "Done"
    
    weak var delegate: PlaceTableHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.editButton.isHidden = true
        //self.listButton.isHidden = true
    }
    
    func setLabel(name: String){
        self.placeLabel.text = name
    }
    
    @IBAction func tapMore(_ sender: Any) {
        self.delegate?.didSelectMore()
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
    //TODO: remove this - will be handled by different delegate and passed back from more menu
    func didSelectEdit(shouldEdit: Bool)
    
    //TODO: remove this - will be handled by different delegate and passed back from more menu
    func didChangeListView()
    
    func didSelectMore()
}

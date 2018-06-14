import UIKit

class TripCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var city: UILabel!
    
    override func awakeFromNib() {
        dropShadow()
        roundCorners()
        //bottomView.layer.cornerRadius = 5.0
    }
    
    func setLabel(name: String){
        label.text = name
    }
    
    func roundCorners() {
        self.layer.cornerRadius = 5.0
    }
    
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 4.0
        self.layer.cornerRadius = 5.0
    }
}

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
    
    func setLabels(city: PrimaryLocation){
        //change trip.name to trip.label
        label.text = city.label
        self.city.text = city.locationName
    }
    
    func roundCorners() {
        self.layer.cornerRadius = 5.0
    }
}

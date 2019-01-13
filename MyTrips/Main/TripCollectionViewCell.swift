import UIKit

class TripCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var city: UILabel!
    
    override func awakeFromNib() {
        dropShadow()
        self.roundCorners(radius: 5.0)
        //bottomView.layer.cornerRadius = 5.0
    }
    
    func setLabels(city: PrimaryLocation){
        label.text = city.label
        self.city.text = city.locationName
    }
}

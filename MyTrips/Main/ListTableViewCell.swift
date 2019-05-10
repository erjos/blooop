import UIKit

//May want to reuse this class as an alternative view option for the main table -> see implementation on the older version of the app and deleted tripViewController
class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
        thumbnail.layer.borderWidth = 0.0
        //dateLabel.text = ""
        //activityLabel.text = ""
        locationLabel.text = ""
    }
    
    func setThumbnailImage(image: UIImage){
        imageContainer.isHidden = false
        thumbnail.image = image
        thumbnail.contentMode = .scaleToFill
        thumbnail.layer.borderWidth = 0.0
    }
    
    func handleFailedImage(){
        imageContainer.isHidden = false
        thumbnail.image = #imageLiteral(resourceName: "picture_thumbnail")
        thumbnail.contentMode = .scaleAspectFit
        thumbnail.layer.borderColor = UIColor.gray.cgColor
        thumbnail.layer.borderWidth = 2.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class TableCollectionView: UICollectionView {
    //allows us to quickly set/store and lookup the location of a collection view inside the table view
    var rowLocation: IndexPath?
}

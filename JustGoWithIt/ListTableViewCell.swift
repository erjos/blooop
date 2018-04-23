import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func handlePictureError(error: PhotoError){
        switch error {
        case .FailedMetaData :
            //inform user of failure - try again
            print("no meta data retrieved")
        case .FailedPhoto :
            //inform user of failure - try again
            print("no photo retrieved")
        case .NilPhoto:
            //inform user no picture exists
            print("photo came back as nil")
        case .NoPhotosInList:
            print("no photos in the list")
        }
    }
    
    func configureLastCell(){
        //TODO: decide how we want this to change for this cell
        activityIndicator.isHidden = true
        cellImage.isHidden = false
        cellLabel.text = "+ Add Place"
    }
    
    func setCellImage(placeID: String){
        activityIndicator.isHidden = false
        cellImage.isHidden = true
        GooglePhotoManager.getPhoto(placeID: placeID, success: { (image, string) in
            //success
            self.cellImage.image = image
            self.cellImage.contentMode = .scaleAspectFit
            self.activityIndicator.isHidden = true
            self.cellImage.isHidden = false
        }) { (error) in
            self.handlePictureError(error: error)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

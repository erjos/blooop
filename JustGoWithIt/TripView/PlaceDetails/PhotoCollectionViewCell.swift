import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageContainer: UIView!
    
    var imageLoaded = false
    
//    func setFirstImage(placeID: String){
//        activityIndicator.isHidden = false
//        imageView.isHidden = true
//        GooglePhotoManager.getPhoto(placeID: placeID, success: { (image, string) in
//            //success
//            self.imageView.image = image
//            self.imageView.contentMode = .scaleAspectFill //.scaleAspectFit
//            self.activityIndicator.isHidden = true
//            self.imageView.isHidden = false
//        }) { (error) in
//            self.handlePictureError(error: error)
//        }
//    }
    
    //should probably be called after a new cell is dequed from the list?
    func resetCell(){
        self.imageView.image = nil
        self.activityIndicator.isHidden = false
        self.imageView.isHidden = true
        self.imageLoaded = false
    }
    
    func setImage(image: UIImage){
        self.imageView.image = image
        self.imageView.contentMode = .scaleAspectFill //.scaleAspectFit
        self.activityIndicator.isHidden = true
        self.imageView.isHidden = false
        self.imageLoaded = true
    }
    
    //Receives the error and the view responds accordingly - message from the controller
    private func handlePictureError(error: PhotoError){
        switch error {
        case .FailedMetaData :
            //inform user of failure - try again
            print("no meta data retrieved")
        case .FailedPhoto :
            //inform user of failure - try again
            print("no photo retrieved")
        case .NilPhoto:
            //inform user picture failed - set state
            print("photo came back as nil")
        case .NoPhotosInList:
            //inform user no pictures exist - set state
            print("no photos in the list")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
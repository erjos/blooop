import Foundation
import GooglePlaces

enum PhotoStatus {
    case FailedMetaData
    case FailedPhoto
    case Success
}

class GoogleManager {
    
    static func getPhoto(placeID: String, success: @escaping (_ image: UIImage, _ attributedText: NSAttributedString)-> Void, failure: @escaping (_ status: PhotoStatus)->Void){
        loadFirstPhotoForPlace(placeID: placeID, success: { (image, string) in
            success(image, string)
        }) { status in
            failure(status)
        }
    }
    
    static func loadFirstPhotoForPlace(placeID: String, success: @escaping (_ image: UIImage, _ attributedText: NSAttributedString)-> Void, failure: @escaping (_ status: PhotoStatus)->Void){
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                failure(.FailedMetaData)
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto, success: { (image, string) in
                        success(image, string)
                    }, failure: { (status) in
                        failure(status)
                    })
                    
                }
            }
        }
    }
    
    static func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, success: @escaping (_ image: UIImage, _ attributedText: NSAttributedString)-> Void, failure: @escaping (_ status: PhotoStatus)->Void){
        
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                failure(.FailedPhoto)
                print("Error: \(error.localizedDescription)")
            } else {
                success(photo!, photoMetadata.attributions!)
            }
        })
    }
}

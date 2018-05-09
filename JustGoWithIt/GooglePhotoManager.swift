import Foundation
import GooglePlaces

enum PhotoError {
    case FailedMetaData
    case FailedPhoto
    case NilPhoto
    case NoPhotosInList
}

class GooglePhotoManager{
    
    func thing(){
    }
    
    //Gets a single photo and returns either photo or error enum
    static func getFirstPhoto(placeID: String, success: @escaping (_ image: UIImage, _ attributedText: NSAttributedString?)-> Void, failure: @escaping (_ status: PhotoError)->Void){
        loadFirstPhotoForPlace(placeID: placeID, success: { (image, string) in
            success(image, string)
        }) { status in
            failure(status)
        }
    }
    
    //Will return the metaData list of photos available for a place
    static func loadMetaDataList(placeID: String, success: @escaping (_ metaDataList: [GMSPlacePhotoMetadata])->Void, failure: @escaping (_ status: PhotoError)->Void){
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                failure(.FailedMetaData)
                print("Error: \(error.localizedDescription)")
            } else {
                guard let list = photos?.results else {
                    failure(.NoPhotosInList)
                    return
                }
                success(list)
            }
        }
    }
    
    private static func loadFirstPhotoForPlace(placeID: String, success: @escaping (_ image: UIImage, _ attributedText: NSAttributedString?)-> Void, failure: @escaping (_ status: PhotoError)->Void){
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                failure(.FailedMetaData)
                print("Error: \(error.localizedDescription)")
            } else {
                //nothing in the list skips this and doesn't return an error
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto, success: { (image, string) in
                        success(image, string)
                    }, failure: { (status) in
                        failure(status)
                    })
                } else {
                    failure(.NoPhotosInList)
                }
            }
        }
    }
    
    static func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, success: @escaping (_ image: UIImage, _ attributedText: NSAttributedString?)-> Void, failure: @escaping (_ status: PhotoError)->Void){
        
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                failure(.FailedPhoto)
                print("Error: \(error.localizedDescription)")
            } else {
                guard let picture = photo else {
                    failure(.NilPhoto)
                    return
                }
                success(picture, photoMetadata.attributions)
            }
        })
    }
}

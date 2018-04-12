import Foundation
import GooglePlaces

class GoogleManager {
    
    static func getPhoto(placeID: String)->(UIImage?, NSAttributedString?){
        var image: UIImage?
        var attributedText: NSAttributedString?
        
        let result = loadFirstPhotoForPlace(placeID: placeID)
        
        image = result.image
        attributedText = result.text
        
        return (image, attributedText)
    }
    
    static func loadFirstPhotoForPlace(placeID: String) -> (image: UIImage?, text: NSAttributedString?) {
        var image: UIImage?
        var attributedText: NSAttributedString?
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    let result = self.loadImageForMetadata(photoMetadata: firstPhoto)
                    image = result.image
                    attributedText = result.text
                }
            }
        }
        
        return (image, attributedText)
    }
    
    static func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) -> (image: UIImage?, text: NSAttributedString?){
        var image: UIImage?
        var attributedText: NSAttributedString?
        
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                //return(photo, photoMetadata.attributions)
                image = photo;
                attributedText = photoMetadata.attributions;
            }
        })
        return (image, attributedText)
    }
}

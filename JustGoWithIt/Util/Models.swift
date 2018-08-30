import Foundation
import GooglePlaces

import Realm
import RealmSwift

//PrimaryLocations are typically encouraged to be Cities, but allow for flexibility in this
class PrimaryLocation: Object {
    
    let subLocations = List<SubLocation>()
    @objc dynamic var placeID: String = ""
    @objc dynamic var locationName: String = ""
    @objc dynamic var locationId: String = ""
    
    //** User label - could be optional
    @objc dynamic var label: String = ""
    @objc dynamic var date: Date?
    
    override static func primaryKey() -> String {
        return "locationId"
    }
    
    private func generateLocationId()->String{
        let number = Int(arc4random_uniform(1000000))
        let id = locationName + number.description
        return id
    }
    
    //used when generating sample data for the app
    func setCity(name: String, placeID: String){
        self.placeID = placeID
        self.locationName = name
        locationId = generateLocationId()
    }
    
    func setCity(place: GMSPlace){
        placeID = place.placeID
        locationName = place.name
        locationId = generateLocationId()
    }
    
    func getSubLocation(from indexPath: IndexPath)-> SubLocation{
        return subLocations[indexPath.row]
    }
    
    func getSubLocationPlaceID(from indexPath: IndexPath) -> String{
        return subLocations[indexPath.row].placeID
    }
    
    func fetchGmsPlacesForCity(complete: @escaping(Bool)->Void){
        var fetchedPlaces = [String]()
        self.fetchGMSPlace { isSuccess in
            if(self.subLocations.count > 0){
                for location in self.subLocations{
                    location.fetchGMSPlace(success: { (id, isSuccess) in
                        fetchedPlaces.append(id)
                        if(fetchedPlaces.count == self.subLocations.count){
                            complete(true)
                        }
                    })
                }
            } else {
                complete(true)
            }
        }
    }
    
    func fetchGMSPlace(success: @escaping(Bool)->Void){
        GMSPlacesClient.shared().lookUpPlaceID(self.placeID) { (place, error) in
            guard let gms = place else {
                return success(false)
            }
            GoogleResourceManager.sharedInstance.addGmsPlace(place: gms)
            success(true)
        }
    }
}

//Sublocations can be any place that you want stored under your primary location
class SubLocation: Object {
    @objc dynamic var label: String?
    @objc dynamic var date: Date?
    @objc dynamic var placeID: String = ""
    
    func fetchGMSPlace(success: @escaping(_ id: String, _ success: Bool)->Void){
        GMSPlacesClient.shared().lookUpPlaceID(self.placeID) { (place, error) in
            guard let gms = place else {
                return success(self.placeID, false)
            }
            GoogleResourceManager.sharedInstance.addGmsPlace(place: gms)
            success(self.placeID, true)
        }
    }
}



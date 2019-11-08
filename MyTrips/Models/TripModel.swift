import Foundation
import GooglePlaces
import Realm
import RealmSwift

//Do we want to keep existing realms

//***IMPORTANT***
//Document schema versions to keep track of migrations
class PrimaryLocation: Object {
    let subLocations = List<SubLocation>()
    //** GooglePlace Unique ID
    @objc dynamic var placeID: String = ""
    //** City Name
    @objc dynamic var locationName: String = ""
    //** Trip Unique Identifier
    //ACCOUNT FOR THIS CHANGE IN THE MIGRATION
    @objc dynamic var tripUUID: String = ""
    
    //** User label - could be optional
    @objc dynamic var label: String = ""
    @objc dynamic var date: Date?
    
    override static func primaryKey() -> String {
        return "tripUUID"
    }
    
    
    //** Generates ID when user is not logged in
    func setTripUUID() {
        self.tripUUID = UUID().uuidString
    }
    
    //** Helper method to generate mock data
    func setCity(name: String, placeID: String) {
        self.placeID = placeID
        self.locationName = name
    }
    
    //** Adds sublocation to a trip
    func addSublocation(_ subLocation: SubLocation) {
        self.subLocations.append(subLocation)
    }
    
    //** Sets the primary location of the trip before saving it
    func setPrimaryLocation(place: GMSPlace) {
        placeID = place.placeID ?? "No ID found"
        locationName = place.name ?? "No name found"
    }
    
    func getSubLocation(from indexPath: IndexPath)-> SubLocation {
        return subLocations[indexPath.row]
    }
    
    func getSubLocationPlaceID(from indexPath: IndexPath) -> String {
        return subLocations[indexPath.row].placeID
    }
    
    //this is confusing and I need to reevaluate how I make this work
    //TODO: move this method to delegate/protocol
    func fetchGmsPlacesForCity(complete: @escaping(Bool)->Void) {
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
    
    func fetchGMSPlace(success: @escaping(Bool)->Void) {
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
    @objc dynamic var notes: String = ""
    
    func fetchGMSPlace(success: @escaping(_ id: String, _ success: Bool)->Void) {
        GMSPlacesClient.shared().lookUpPlaceID(self.placeID) { (place, error) in
            guard let gms = place else {
                return success(self.placeID, false)
            }
            GoogleResourceManager.sharedInstance.addGmsPlace(place: gms)
            success(self.placeID, true)
        }
    }
}

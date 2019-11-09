import Foundation
import GooglePlaces
import Realm
import RealmSwift

//***IMPORTANT***
//Document schema versions to keep track of migrations
class PrimaryLocation: Object {
    let subLocations = List<SubLocation>()
    //** GooglePlace Unique ID
    @objc dynamic var placeID: String = ""
    //** City Name
    @objc dynamic var locationName: String = ""
    
    //ACCOUNT FOR THESE CHANGE IN THE MIGRATION
    //** Trip Unique Identifier
    @objc dynamic var tripUUID: String = ""
    //** Trip Owner uuid
    @objc dynamic var owner: String = ""
    
    //** User label - could be optional
    @objc dynamic var label: String = ""
    
    //At no point right now are we setting a date on a primary location
    @objc dynamic var date: Date?
    
    //** returns the tripUUID as the primaryKey for realm to reference
    override static func primaryKey() -> String {
        return "tripUUID"
    }
    
    //** Helper function to setup PrimaryLocation from firebase doc reference
    func setPrimaryLocation(_ data: [String: Any], _ uuid: String) {
        self.placeID = data["placeId"] as? String ?? ""
        self.locationName = data["locationName"] as? String ?? ""
        self.owner = data["owner"] as? String ?? ""
        self.label = data["label"] as? String ?? ""
        
        self.tripUUID = uuid
        //create property for "owner"
        
        let subLocationList = data["subLocations"] as? [[String : Any]] ?? [[String:Any]]()
        
        for subData in subLocationList {
            let sub = SubLocation()
            sub.setSublocation(data: subData)
            subLocations.append(sub)
        }
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
    
    //** Helper function to setup SubLocation from firebase doc reference
    func setSublocation(data: [String : Any]) {
        self.label = data["label"] as? String
        self.date = data["date"] as? Date
        self.placeID = data["placeId"] as? String ?? ""
        self.notes = data["notes"] as? String ?? ""
    }
}

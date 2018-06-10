import Foundation
import GooglePlaces
import SwiftyJSON
import Realm
import RealmSwift

class Trip: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var startDate: Date?
    @objc dynamic var endDate: Date?
    let cities = List<City>()
    
    override static func primaryKey() -> String {
        return "name"
    }
    
    func getSubLocationPlaceID(from indexPath: IndexPath) -> String{
        return cities[indexPath.section].locations[indexPath.row].placeID
    }
    
    func getSubLocation(from indexPath: IndexPath)-> Location{
        return cities[indexPath.section].locations[indexPath.row]
    }
    
    //TODO: Improve this if possible...
    func fetchGMSPlacesForTrip(complete: @escaping(Bool)->Void){
        //probably don't need the IDs - but might be useful for identifying successes and failures?
        //could just use a simple counter
        var fetchedPlaces = [String]()
        
        //TODO: make this a fetch method for places on a single city - eliminate this nested for loop
        for city in cities {
            city.fetchGMSPlace(success: { isSuccess in
                if(city.locations.count > 0){
                    for location in city.locations{
                        location.fetchGMSPlace(success: { (id, isSuccess) in
                            fetchedPlaces.append(id)
                            if(fetchedPlaces.count == city.locations.count){
                                complete(true)
                            }
                        })
                    }
                } else {
                    //doesn't account for if there are multiple cities
                    complete(true)
                }
            })
        }
    }
}

class City: Object {
    let locations = List<Location>()
    @objc dynamic var date: Date?
    @objc dynamic var placeID: String = ""
    
    override static func ignoredProperties() -> [String] {
        return ["googlePlace"]
    }
    
    //TODO: implement solution to fetch fresh resources when loading a trip from the main view controller
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

class Location: Object {
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

extension Date {
    var day: Int { return Calendar.current.component(.day, from:self) }
    var month: Int { return Calendar.current.component(.month, from:self) }
    var year: Int { return Calendar.current.component(.year, from:self) }
    
    func formatDateAsString() -> String {
        let dateFormater = DateFormatter()
        if (self.month < 10) {
            dateFormater.dateFormat = "M/dd/yy"
        } else {
            dateFormater.dateFormat = "MM/dd/yy"
        }
        return dateFormater.string(from: self)
    }
}



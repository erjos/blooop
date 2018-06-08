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
        return cities[indexPath.section].locations[indexPath.row].placeID ?? ""
    }
    
    func getSubLocation(from indexPath: IndexPath)-> Location{
        return cities[indexPath.section].locations[indexPath.row]
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
    func fetchGMSPlace(){
        GMSPlacesClient.shared().lookUpPlaceID(self.placeID) { (place, error) in
            
        }
    }
}

class Location: Object {
    @objc dynamic var label: String?
    @objc dynamic var date: Date?
    @objc dynamic var placeID: String = ""
    
    func fetchGMSPlace(){
        GMSPlacesClient.shared().lookUpPlaceID(self.placeID) { (place, error) in
            
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



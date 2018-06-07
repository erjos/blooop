import Foundation
import GooglePlaces
import SwiftyJSON
import Realm
import RealmSwift

class Trip: Object {
    var name: String?
    var startDate: Date?
    var endDate: Date?
    var cities = [City]()
    
    //Returns the place ID of a location in a city, given a corresponding index path
    //city index corresponds to secion ; location index corresponds to row
    func getPhotoMetaData(from indexPath: IndexPath, collectionRow: Int) -> GMSPlacePhotoMetadata? {
        return cities[indexPath.section].locations[indexPath.row].photoMetaDataList?[collectionRow]
    }
    func setPhotoMetaData(_ indexPath: IndexPath, _ list: [GMSPlacePhotoMetadata]) {
        cities[indexPath.section].locations[indexPath.row].photoMetaDataList = list
    }
    
    func getSubLocationGMSPlace(from indexPath: IndexPath) -> GMSPlace{
        return cities[indexPath.section].locations[indexPath.row].googlePlace
    }
    
    func getSubLocation(from indexPath: IndexPath)-> Location{
        return cities[indexPath.section].locations[indexPath.row]
    }
}

class City: Object {
    var googlePlace = GMSPlace.init()
    var locations = [Location]()
    var date: Date?
}

class Location: Object {
    var googlePlace = GMSPlace.init()
    var label: String?
    var date: Date?
    var photoMetaDataList: [GMSPlacePhotoMetadata]?
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

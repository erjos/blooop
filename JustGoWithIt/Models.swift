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
    
    //Returns the place ID of a location in a city, given a corresponding index path
    //city index corresponds to secion ; location index corresponds to row
    func getPhotoMetaData(from indexPath: IndexPath, collectionRow: Int) -> GMSPlacePhotoMetadata? {
        return cities[indexPath.section].locations[indexPath.row].photoMetaDataList?[collectionRow]
    }
    
    func getPhotoMetaDataList(from indexPath: IndexPath) -> [GMSPlacePhotoMetadata]?{
        return cities[indexPath.section].locations[indexPath.row].photoMetaDataList
    }
    
    func setPhotoMetaData(_ indexPath: IndexPath, _ list: [GMSPlacePhotoMetadata]) {
        cities[indexPath.section].locations[indexPath.row].photoMetaDataList = list
    }
    
    func getSubLocationPlaceID(from indexPath: IndexPath) -> String{
        return cities[indexPath.section].locations[indexPath.row].placeID ?? ""
    }
    
//    func getSubLocationGMSPlace(from indexPath: IndexPath) -> GMSPlace?{
//        return cities[indexPath.section].locations[indexPath.row].googlePlace
//    }
    
    func getSubLocation(from indexPath: IndexPath)-> Location{
        return cities[indexPath.section].locations[indexPath.row]
    }
}

class City: Object {
    let locations = List<Location>()
    @objc dynamic var date: Date?
    @objc dynamic var placeID: String = ""
    
    //@objc dynamic var googlePlace: GMSPlace?
    
    override static func ignoredProperties() -> [String] {
        return ["googlePlace"]
    }
    
    func fetchGMSPlace(){
        GMSPlacesClient.shared().lookUpPlaceID(self.placeID) { (place, error) in
            // do something with that callback baby
        }
    }
}

class Location: Object {
    @objc dynamic var label: String?
    @objc dynamic var date: Date?
    @objc dynamic var placeID: String = ""
    
    //TODO: create a way to fetch the metadata
    var photoMetaDataList: [GMSPlacePhotoMetadata]?
    
    func fetchGMSPlace(){
        GMSPlacesClient.shared().lookUpPlaceID(self.placeID) { (place, error) in
            // do something with that callback baby
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

class GoogleResourceManager {
    //** This class should be created and destroyed for every trip that is opened **//
    //TODO: write a function that disposes of this data
    
    private var gmsPlaces = [GMSPlace]()
    private var photoMetaData = [(String, [GMSPlacePhotoMetadata])]()
    
    static let sharedInstance = GoogleResourceManager()
    
    private init() {}
    
    func addGmsPlace(place: GMSPlace){
        self.gmsPlaces.append(place)
    }
    
    func getPlaceForId(ID: String)->GMSPlace?{
        let list = self.gmsPlaces.filter { (place) -> Bool in
            return place.placeID == ID
        }
        return list.first
    }
    
    func addPhotoMetaData(metaData: (String, [GMSPlacePhotoMetadata])) {
        //** This list will correspond only to the order of the table cells when the view is initialize **//
        let isDuplicate = photoMetaData.contains { (id, metaDataList) -> Bool in
            return id == metaData.0
        }
        if(!isDuplicate){
            self.photoMetaData.append(metaData)
        }
    }
    
    func getMetaDataListFor(placeId: String) -> [GMSPlacePhotoMetadata]?{
        let result = photoMetaData.filter { (id, metaDataList) -> Bool in
            return id == placeId
        }
        return result.first?.1
    }
}

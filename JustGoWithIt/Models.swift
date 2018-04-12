import Foundation
import GooglePlaces

class Trip {
    var name: String?
    var startDate: Date?
    var endDate: Date?
    var cities = [City]()
}

class City {
    var googlePlace: GMSPlace
    var locations = [Location]()
    
    init(place: GMSPlace){
        self.googlePlace = place
    }
}

class Location {
    var googlePlace: GMSPlace
    var label: String?
    var date: Date?
    
    init(place: GMSPlace){
        self.googlePlace = place
    }
}

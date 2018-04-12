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

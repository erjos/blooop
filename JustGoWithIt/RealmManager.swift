import Foundation
import RealmSwift

class RealmManager {
    
    //TODO: create ENUM and return an error to be handled by the UI
    
    static func fetchData() -> Results<Trip>? {
        var results: Results<Trip>?
        do {
            let realm = try Realm()
            results = realm.objects(Trip.self)
            return results
        } catch let error as NSError {
            //handle error
            print(error)
        }
        return results
    }
    
    static func saveSublocationDate(trip: Trip, cityIndex: Int, date: Date){
        do {
            let realm = try Realm()
            try realm.write {
                trip.cities[cityIndex].locations.last?.date = date
                print("Added sublocation date")
            }
        } catch let error as NSError {
            //handle error
            print(error)
        }
    }
    
    static func saveSublocationName(trip: Trip, cityIndex: Int, label: String?){
        do {
            let realm = try Realm()
            try realm.write {
                trip.cities[cityIndex].locations.last?.label = label
                print("Added sublocation label")
            }
        } catch let error as NSError {
            //handle error
            print(error)
        }
    }
    
    static func addSublocationsToTrip(trip: Trip, cityIndex: Int, location: Location){
        do {
            let realm = try Realm()
            try realm.write {
                trip.cities[cityIndex].locations.append(location)
                print("Added new sublocation")
            }
        } catch let error as NSError {
            //handle error
            print(error)
        }
    }
    
    static func storeData(object: Trip) {
        //var realm: Realm
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object, update: true) //realm.add(object)
                print("Added new object")
            }
        } catch let error as NSError {
            //handle error
            print(error)
        }
    }
    
    static func deleteData(object: Object) {
        do {
            let realm = try Realm()
            try realm.write {
                 realm.delete(object)
                print("Deleted object")
            }
        } catch let error as NSError {
            //handle error
            print(error)
        }
    }
}

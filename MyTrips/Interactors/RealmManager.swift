import Foundation
import RealmSwift

class RealmManager {
    
    static func deleteSubLocation(city: PrimaryLocation, indexPath: IndexPath) {
        do {
            let realm = try Realm()
            try realm.write {
                city.subLocations.remove(at: indexPath.row)
            }
        } catch let error as NSError {
            //handle error
            print(error)
        }
    }
    
    static func deletePrimaryLocation(trip: PrimaryLocation) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(trip)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    static func fetchData() -> Results<PrimaryLocation>? {
        var results: Results<PrimaryLocation>?
        do {
            let realm = try Realm()
            results = realm.objects(PrimaryLocation.self)
            return results
        } catch let error as NSError {
            //handle error
            print(error)
        }
        return results
    }
    
    static func saveNotes(place: SubLocation, notes: String) {
        do {
            let realm = try Realm()
            try realm.write {
                place.notes = notes
            }
        } catch let error as NSError {
            //handle error
            print(error)
        }
    }
    
    //I dont think this will work correctly
    static func saveSublocationDate(place: SubLocation, date: Date) {
        do {
            let realm = try Realm()
            try realm.write {
                place.date = date
                print("Added sublocation date")
            }
        } catch let error as NSError {
            //handle error
            print(error)
        }
    }
    
    static func saveSublocationName(city: PrimaryLocation, label: String?){
        do {
            let realm = try Realm()
            try realm.write {
                city.subLocations.last?.label = label
                print("Added sublocation label")
            }
        } catch let error as NSError {
            //handle error
            print(error)
        }
    }
    
    //todo: rename city to trip I think :/
    //append the new subLocation to the sublocations property then update the object in storage
//    static func addSublocationsToCity(city: PrimaryLocation, location: SubLocation){
//        do {
//            let realm = try Realm()
//            try realm.write {
//                city.subLocations.append(location)
//                print("Added new sublocation")
//            }
//        } catch let error as NSError {
//            //handle error
//            print(error)
//        }
//    }
    
//    static func storeData(object: PrimaryLocation) {
//        do {
//            let realm = try Realm()
//            try realm.write {
//                realm.add(object, update: true)
//                print("Added new object")
//            }
//        } catch let error as NSError {
//            //handle error
//            print(error)
//        }
//    }
    
//    static func deleteData(object: Object) {
//        do {
//            let realm = try Realm()
//            try realm.write {
//                 realm.delete(object)
//                print("Deleted object")
//            }
//        } catch let error as NSError {
//            //handle error
//            print(error)
//        }
//    }
}

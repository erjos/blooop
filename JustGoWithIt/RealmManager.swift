import Foundation
import RealmSwift

class RealmManager {
    
    //TODO: create ENUM and return an error to be handled by the UI
    
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
    
    static func saveSublocationDate(city: PrimaryLocation, date: Date){
        do {
            let realm = try Realm()
            try realm.write {
                city.subLocations.last?.date = date
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
    
    static func addSublocationsToCity(city: PrimaryLocation, location: SubLocation){
        do {
            let realm = try Realm()
            try realm.write {
                city.subLocations.append(location)
                print("Added new sublocation")
            }
        } catch let error as NSError {
            //handle error
            print(error)
        }
    }
    
    static func storeData(object: PrimaryLocation) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object, update: true)
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

import Foundation
import RealmSwift

class RealmManager {
    
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
    
    //TODO: create ENUM and return an error to be handled by the UI
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

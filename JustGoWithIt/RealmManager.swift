import Foundation
import RealmSwift

class RealmManager {
    
    static func fetchData(realm: Realm) -> Results<Object> {
        let results: Results<Object> = realm.objects(Object.self)
        return results
    }
    
    static func storeData(object: Object) {
        //var realm: Realm
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

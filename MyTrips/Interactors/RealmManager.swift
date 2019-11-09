import Foundation
import RealmSwift

class RealmManager {
    
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
}

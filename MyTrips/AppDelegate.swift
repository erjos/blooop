import UIKit
import GooglePlaces
import GoogleMaps
import RealmSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var lastTrip: PrimaryLocation?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSPlacesClient.provideAPIKey(Keys.gmsPlacesKey)
        GMSServices.provideAPIKey(Keys.gmsServicesKey)
        
        //configure Firebase
        FirebaseApp.configure()
        
        //TODO: lets wipe the old realm and start from scratch for this version - need to make sure to get rid of this for future migrations
        //UPDATE THIS AND TEST REALM UPDATES
        let config = Realm.Configuration.init(schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
        
        Realm.Configuration.defaultConfiguration = config
        
        guard let tripID = UserDefaults.standard.string(forKey: "lastTrip") else {
            return true
        }
        
        //pull from realm
        let trips = RealmManager.fetchData()
        self.lastTrip = trips?.first(where: { tripID == $0.tripUUID })
        
        //UINavigationBar.styleTitle(with: UIColor.white)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

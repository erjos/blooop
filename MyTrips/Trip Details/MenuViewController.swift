import UIKit
import GooglePlaces

class MenuViewController: UIViewController {

    @IBAction func deleteTrip(_ sender: Any) {
        if let presentingVC = presentingViewController as? UINavigationController {
            if let vc = presentingVC.viewControllers.first as? TripViewController {
                let alert = UIAlertController(title: "Delete Trip", message: "Are you sure you want to delete this trip? All associated data will be erased.", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "Delete", style: .default, handler: { deleteAction in
                    RealmManager.deleteData(object: vc.city)
                    if let navVC = vc.presentingViewController as? UINavigationController {
                        if let mainVC = navVC.viewControllers.first as? MyTripsViewController {
                            vc.dismiss(animated: true, completion: mainVC.collection.reloadData)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.dismiss(animated: true) {
                    vc.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func about(_ sender: Any) {
        if let navVC = presentingViewController as? UINavigationController {
            if let tripVC = navVC.viewControllers[0] as? TripViewController {
                self.dismiss(animated: true) {
                    tripVC.performSegue(withIdentifier: "showAbout", sender: self)
                }
            }
        }
    }
    
    @IBAction func edit(_ sender: Any) {
        if let presentingVC = presentingViewController as? UINavigationController {
            if let vc = presentingVC.viewControllers.first as? TripViewController {
                vc.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "done_white"), style: .plain, target: self, action: #selector(vc.rightBarAction(_:)))
            }
            presentingVC.setEditing(true, animated: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewMap(_ sender: Any) {
        if let navVC = presentingViewController as? UINavigationController {
            if let tripVC = navVC.viewControllers[0] as? TripViewController {
                self.dismiss(animated: true) {
                    tripVC.performSegue(withIdentifier: "presentMap", sender: self)
                }
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
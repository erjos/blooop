import UIKit
import GooglePlaces

class MenuViewController: UIViewController {

    @IBAction func edit(_ sender: Any) {
        if let presentingVC = presentingViewController as? UINavigationController {
            if let vc = presentingVC.viewControllers.first as? TripViewController {
                vc.rightBarItem.title = "Done"
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

extension MenuViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //Do work with place object
        print(place.name)
        print(place.formattedAddress)
        print(place.attributions)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        //Handle error
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

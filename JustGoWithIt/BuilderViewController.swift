import UIKit
import GooglePlaces

class BuilderViewController: UIViewController {
    //One idea would be to show and hide the fields as needed to reduce the noise on the page and only allow users to enter information in a predetermined order
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    var trip = Trip()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide date and name views at start
        nameView.isHidden = true
        dateView.isHidden = true
        
        //set field delegates
        locationField.delegate = self
        setupNameField()
    }
    
    private func setupNameField(){
        nameField.keyboardType = .alphabet
        nameField.inputAccessoryView = setupPickerToolbar()
        nameField.delegate = self
    }
    
    private func setupPickerToolbar()-> UIToolbar{
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(self.selectCancel))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(self.selectDone))
        toolBar.setItems([cancel,spaceButton,done], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    @objc private func selectDone(){}
    @objc private func selectCancel(){}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BuilderViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(locationField.isFirstResponder){
            //launch google place picker
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
        }
    }
}

extension BuilderViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //create city
        let city = City.init(place: place)
        
        //add to city list on trip object
        //TODO: add this method to the trip class and ensure no duplicates
        trip.cities.append(city)
        
        //set the text field for location
        locationField.text = place.name
        
        //show the next field
        nameView.isHidden = false
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

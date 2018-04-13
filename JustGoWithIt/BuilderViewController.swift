import UIKit
import GooglePlaces

class BuilderViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var locationDivider: UIView!
    @IBOutlet weak var nameDivider: UIView!
    
    let datePicker = UIDatePicker()
    var trip = Trip()
    var isSubLocation = false //flag used to identify if builder is used for Location or Place (Locations contain places)
    var cityIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Trip"
        
        //hide views on load
        nameView.isHidden = true
        dateView.isHidden = true
        locationDivider.isHidden = true
        nameDivider.isHidden = true
        
        //TODO: add a dismiss icon to the navbar when sent from the tripVC
        //configure for place
        if(isSubLocation){
            
            //setup dismiss button
            let button = UIButton()
            button.setImage(#imageLiteral(resourceName: "closer"), for: .normal)
            button.addTarget(self, action: #selector(dismissIt), for: .touchUpInside)
            let barItem = UIBarButtonItem(customView: button)
            //set constraints on barItem
            let width = barItem.customView?.widthAnchor.constraint(equalToConstant: 30)
            width?.isActive = true
            let height = barItem.customView?.heightAnchor.constraint(equalToConstant: 35)
            height?.isActive = true
            button.tintColor = UIColor.darkGray
            //set button on navigationItem
            self.navigationItem.leftBarButtonItem = barItem
            
            locationLabel.text = "Choose a location"
            locationField.placeholder = "Search places"
            
            nameLabel.text = "What will you be doing?"
            nameField.placeholder = "Add activity label"
            
            dateLabel.text = "When is it?"
            dateField.placeholder = "Choose a Date"
        }
        
        //set field delegates
        locationField.delegate = self
        setupNameField()
        setupDatePicker(dateField, datePicker, nil)
    }
    
    @objc private func dismissIt(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupNameField(){
        nameField.keyboardType = .alphabet
        nameField.inputAccessoryView = setupPickerToolbar()
        nameField.delegate = self
    }
    
    private func setupDatePicker(_ field: UITextField, _ datePicker: UIDatePicker, _ yearsToMax: Int?){
        datePicker.datePickerMode = .date
        //check if there's a max date
        if let max = yearsToMax {
            var dateComponents = DateComponents()
            dateComponents.year = max
            let endDate = Calendar.current.date(byAdding: dateComponents, to: Date())
            datePicker.maximumDate = endDate
        }
        datePicker.minimumDate = Date()
        field.delegate = self
        field.inputView = datePicker
        field.inputAccessoryView = setupPickerToolbar()
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
    
    @objc private func selectDone(){
        if(nameField.isFirstResponder){
            if(!isSubLocation){
                trip.name = nameField.text
            } else {
                //should be the last element of the collection because we always append from this screen
                //could I write a test to ensure that this sets the correct name?
                trip.cities[cityIndex].locations.last?.label = nameField.text
            }
            
            nameField.resignFirstResponder()
            nameDivider.isHidden = false
            dateView.isHidden = false
        }
        
        if(dateField.isFirstResponder){
            if(!isSubLocation){
                //we will only set dates on cities and locations - lets calculate trip date dynamically based on how the user sets up their events
                trip.cities.last?.date = datePicker.date
            } else {
                trip.cities[cityIndex].locations.last?.date = datePicker.date
            }
            
            dateField.text = datePicker.date.formatDateAsString()
            dateField.resignFirstResponder()
            performSegue(withIdentifier: "builderToTrip", sender: self)
        }
    }
    
    @objc private func selectCancel(){
        nameField.resignFirstResponder()
        dateField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tripVC = segue.destination as? TripViewController
        tripVC?.trip = self.trip
    }
}

extension BuilderViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(locationField.isFirstResponder){
            //launch google place picker
            let autocompleteController = GMSAutocompleteViewController()
            if(isSubLocation){
                autocompleteController.autocompleteBoundsMode = .restrict
                autocompleteController.autocompleteBounds = LocationManager.getLocationBounds(trip.cities[cityIndex].googlePlace.coordinate)
            }
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
        }
    }
}

extension BuilderViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if(!isSubLocation){
            //create city
            let city = City.init(place: place)
            //TODO: account for if the user selects a city multiple times from this page - it should clean the list or immediately allow them to enter multiple cities...
            //add to city list on trip object
            //TODO: add this method to the trip class and ensure no duplicates
            trip.cities.append(city)
        } else {
            let location = Location(place: place)
            //append the new location to the end of the list at the appropriate index
            trip.cities[cityIndex].locations.append(location)
        }
        //set the text field for location
        locationField.text = place.name
        //show the next field
        locationDivider.isHidden = false
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

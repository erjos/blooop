import UIKit
import GooglePlaces

class BuilderViewController: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var locationDivider: UIView!
    @IBOutlet weak var nameDivider: UIView!
    
    var trip = Trip()
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide views on load
        nameView.isHidden = true
        dateView.isHidden = true
        locationDivider.isHidden = true
        nameDivider.isHidden = true
        
        //set field delegates
        locationField.delegate = self
        setupNameField()
        setupDatePicker(dateField, datePicker, nil)
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
            trip.name = nameField.text
            nameField.resignFirstResponder()
            nameDivider.isHidden = false
            dateView.isHidden = false
        }
        if(dateField.isFirstResponder){
            trip.startDate = datePicker.date
            dateField.text = datePicker.date.formatDateAsString()
            dateField.resignFirstResponder()
        }
    }
    
    @objc private func selectCancel(){
        nameField.resignFirstResponder()
        dateField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//TODO: move to another file
extension Date {
    var day: Int { return Calendar.current.component(.day, from:self) }
    var month: Int { return Calendar.current.component(.month, from:self) }
    var year: Int { return Calendar.current.component(.year, from:self) }
    
    func formatDateAsString() -> String {
        let dateFormater = DateFormatter()
        if (self.month < 10) {
            dateFormater.dateFormat = "M/dd/yy"
        } else {
            dateFormater.dateFormat = "MM/dd/yy"
        }
        return dateFormater.string(from: self)
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

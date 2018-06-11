import UIKit
import GooglePlaces
import GoogleMaps

class BuilderViewController: UIViewController {
    
    @IBOutlet weak var mapView: UIView!
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
    
    @IBAction func dismiss(_ sender: Any) {
        //Identify which view controller presented the builder
        if let mainVC = self.presentingViewController as? MyTripsViewController {
            self.dismiss(animated: true, completion: nil)
        }
        
        //this isn't working - maybe it's the navigation controller?
        if let tripVC = self.presentingViewController as? UINavigationController {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func saveNewTrip(){
        RealmManager.storeData(object: self.trip)
        if let navVC = self.presentingViewController as? UINavigationController {
            if let mainVC = navVC.viewControllers[0] as? MyTripsViewController {
                dismiss(animated: true, completion: {
                    mainVC.collection.reloadData()
                    mainVC.performSegue(withIdentifier: "toMain", sender: self.trip)
                })
            }
            if let tripVC = navVC.viewControllers[0] as? TripViewController {
                self.dismiss(animated: true, completion: tripVC.tableView.reloadData)
            }
        }
    }
    
    let datePicker = UIDatePicker()
    var trip = Trip()
    var isSubLocation = false //flag used to identify if builder is used for Location or Place (Locations contain places)
    var cityIndex = 0
    var coordinateBounds: GMSCoordinateBounds?
    var map: GMSMapView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Trip"
        
        //hide views on load
        nameView.isHidden = true
        dateView.isHidden = true
        locationDivider.isHidden = true
        nameDivider.isHidden = true
        //configure for place
        if(isSubLocation){

//            let button = UIButton()
//            button.setImage(#imageLiteral(resourceName: "close"), for: .normal)
//            button.addTarget(self, action: #selector(dismissIt), for: .touchUpInside)
//            let barItem = UIBarButtonItem(customView: button)
//            //set constraints on barItem
//            let width = barItem.customView?.widthAnchor.constraint(equalToConstant: 30)
//            width?.isActive = true
//            let height = barItem.customView?.heightAnchor.constraint(equalToConstant: 35)
//            height?.isActive = true
//            button.tintColor = UIColor.darkGray
//            //set button on navigationItem
//            self.navigationItem.leftBarButtonItem = barItem
            
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
        mapView.isHidden = true
        
        //handle map view
        if(isSubLocation){
            mapView.isHidden = false
            let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: trip.cities[cityIndex].placeID)
            let target = gms?.coordinate
            var camera = GMSCameraPosition.camera(withTarget: target!, zoom: 6)
            
            map = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
            map?.delegate = self
            //TODO: lets update these bounds when the map changes position
            coordinateBounds = LocationManager.getLocationBoundsFromMap(map: map!)
            //need to add it as a subview?
            self.mapView.addSubview(map!)
        }
    }
    
//    @objc private func dismissIt(){
//        self.dismiss(animated: true, completion: nil)
//    }
    
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
                trip.name = nameField.text ?? ""
            } else {
                //TODO: handle if nameField is left blank
                RealmManager.saveSublocationName(trip: trip, cityIndex: cityIndex, label: nameField.text)
            }
            
            nameField.resignFirstResponder()
            nameDivider.isHidden = false
            dateView.isHidden = false
        }
        
        if(dateField.isFirstResponder){
            if(!isSubLocation){
                //Does not need to be done in write block because it is not a Realm "managed object" at this point. The first time it becomes a realm managed object is when the segue is triggered from the builder to the trip viewer
                trip.cities.last?.date = datePicker.date
            } else {
                RealmManager.saveSublocationDate(trip: trip, cityIndex: cityIndex, date: datePicker.date)
            }
            
            dateField.text = datePicker.date.formatDateAsString()
            dateField.resignFirstResponder()
            
            saveNewTrip()
        }
    }
    
    @objc private func selectCancel(){
        nameField.resignFirstResponder()
        dateField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tripVC = segue.destination as? TripViewController
        tripVC?.trip = self.trip
        
        //store trip data
        RealmManager.storeData(object: self.trip)
    }
}

extension BuilderViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(locationField.isFirstResponder){
            //launch google place picker
            let autocompleteController = GMSAutocompleteViewController()
            if(isSubLocation){
                autocompleteController.autocompleteBoundsMode = .restrict
                autocompleteController.autocompleteBounds = self.coordinateBounds//LocationManager.getLocationBounds(trip.cities[cityIndex].googlePlace.coordinate)
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
            let city = City()
            city.placeID = place.placeID
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            //TODO: account for if the user selects a city multiple times from this page - it should clean the list or immediately allow them to enter multiple cities...
            //TODO: add this method to the trip class and ensure no duplicates
            trip.cities.append(city)
        } else {
            let location = Location()
            location.placeID = place.placeID
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            //append the new location to the end of the list at the appropriate index
            RealmManager.addSublocationsToTrip(trip: trip, cityIndex: cityIndex, location: location)
            //trip.cities[cityIndex].locations.append(location)
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

extension BuilderViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        //need to utilize shared map instance
        self.coordinateBounds = LocationManager.getLocationBoundsFromMap(map: map!)
    }
}

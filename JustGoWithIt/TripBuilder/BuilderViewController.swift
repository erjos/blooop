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
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var locationDivider: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchText: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nameViewHeight: NSLayoutConstraint! //120
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint! //100
    
    @IBOutlet weak var mapLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapLabel: UILabel!
    
    @IBAction func saveTrip(_ sender: Any) {
        saveNewTrip()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        //Identify which view controller presented the builder
        if let _ = self.presentingViewController as? MyTripsViewController {
            self.dismiss(animated: true, completion: nil)
        }
        
        if let _ = self.presentingViewController as? UINavigationController {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func tapSearch(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        if(isSubLocation){
            autocompleteController.autocompleteBoundsMode = .restrict
            autocompleteController.autocompleteBounds = self.coordinateBounds
        }
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func saveNewTrip(){
        RealmManager.storeData(object: self.city)
        if let navVC = self.presentingViewController as? UINavigationController {
            if let mainVC = navVC.viewControllers[0] as? MyTripsViewController {
                dismiss(animated: true, completion: {
                    mainVC.collection.reloadData()
                    mainVC.performSegue(withIdentifier: "toMain", sender: self.city)
                })
            }
            if let tripVC = navVC.viewControllers[0] as? TripViewController {
                self.dismiss(animated: true, completion: tripVC.tableView.reloadData)
            }
        }
    }
    
    let datePicker = UIDatePicker()
    
    var city = PrimaryLocation()
    
    //** Flag used to identify if builder is used for Location or Place (Locations contain places)
    var isSubLocation = false
    var coordinateBounds: GMSCoordinateBounds?
    var map: GMSMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Trip"
        
        doneButton.layer.cornerRadius = 5.0
        doneButton.isHidden = true
        
        //setup drop shadows
        searchView.dropShadow()
        nameField.dropShadow()
        dateField.dropShadow()
        mapView.dropShadow()
        doneButton.dropShadow()
        
        //hide views on load
        nameView.isHidden = true
        dateView.isHidden = true
        nameViewHeight.constant = 0
        dateViewHeight.constant = 0
        mapLabelConstraint.constant = 10
        
        //Add padding to the name and date fields
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15 , height: nameField.frame.height))
        nameField.leftViewMode = .always
        nameField.leftView = paddingView
        
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 15 , height: dateField.frame.height))
        dateField.leftViewMode = .always
        dateField.leftView = paddingView2

        //configure for place
        if(isSubLocation){
            mapView.layer.borderColor = UIColor.gray.cgColor
            mapView.layer.borderWidth = 2.0
            locationLabel.text = "Choose a location"
            searchText.text = "Search places"
        }
        
        //set field delegates
        setupNameField()
        setupDatePicker(dateField, datePicker, nil)
        mapView.isHidden = true
        mapLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isSubLocation){
            mapView.isHidden = false
            mapLabel.isHidden = false
            let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: city.placeID)
            let target = gms?.coordinate
            var camera = GMSCameraPosition.camera(withTarget: target!, zoom: 10)
            
            map = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
            map?.delegate = self
            coordinateBounds = LocationManager.getLocationBoundsFromMap(map: map!)
            //need to add it as a subview?
            self.mapView.addSubview(map!)
        }
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
                city.label = nameField.text ?? ""
            } else {
                //TODO: handle if nameField is left blank - remove cityIndex (no longer needed)
                RealmManager.saveSublocationName(city: city, label: nameField.text)
            }
            nameField.resignFirstResponder()
        }
        
        if(dateField.isFirstResponder){
            if(!isSubLocation){
                //NOTE: Does not need to be done in write block because it is NOT a Realm "managed object" at this point. It becomes a managed object is when the segue RealmManager.storeData method is called
                city.date = datePicker.date
            } else {
                RealmManager.saveSublocationDate(city: city, date: datePicker.date)
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
        tripVC?.city = self.city
        RealmManager.storeData(object: self.city)
    }
}

extension BuilderViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        locationView.bottomScrollShadow()
        if(scrollView.contentOffset.y <= 10){
            locationView.layer.shadowOpacity = 0.0
        }
    }
}

extension BuilderViewController: UITextFieldDelegate {
}

extension BuilderViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if(!isSubLocation){
            //set city data using place data
            city.setCity(place: place)
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            
            //TODO: test what happens when a user selects a city multiple times from the builder - does it change or update the model correctly?
        } else {
            let location = SubLocation()
            location.placeID = place.placeID
            GoogleResourceManager.sharedInstance.addGmsPlace(place: place)
            //append the new location to the end of the list at the appropriate index
            RealmManager.addSublocationsToCity(city: city, location: location)
            //trip.cities[cityIndex].locations.append(location)
        }
        //set the text field for location
        searchText.text = place.name
        searchText.textColor = UIColor.black
        
        
        //show the other fields
        locationDivider.isHidden = false
        nameView.isHidden = false
        dateView.isHidden = false
        doneButton.isHidden = false
        
        dismiss(animated: true, completion: nil)
        UIView.animate(withDuration: 1.0 , animations: {
            //
            self.nameViewHeight.constant = 120
            self.dateViewHeight.constant = 100
            self.mapLabelConstraint.constant = 60
        }) { (complete) in
            //
        }
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
        self.coordinateBounds = LocationManager.getLocationBoundsFromMap(map: map!)
    }
}

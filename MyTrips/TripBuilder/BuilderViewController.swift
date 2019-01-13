import UIKit
import GooglePlaces
import GoogleMaps

class BuilderViewController: UIViewController {
    
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var labelField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var locationDivider: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchText: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nameViewHeight: NSLayoutConstraint! //120
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint! //100
    @IBOutlet weak var mapLabel: UILabel!
    
    let datePicker = UIDatePicker()
    var city = PrimaryLocation()
    //TODO: consider changing this to an ENUM represent explicit state of this page
    var isSubLocation = false
    var coordinateBounds: GMSCoordinateBounds?
    var map: GMSMapView?
    
    @IBAction func saveTrip(_ sender: Any) {
        //calling select done here will ensure that any active fields will be saved first
        self.selectDone()
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
    
    @IBAction func toggleSwitch(_ sender: Any) {
        let toggle = sender as! UISwitch
        let state = toggle.isOn
        if(state){
            map?.createMapMarkers(for: city, map: map)
        } else {
            map?.clear()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Trip"
        
        doneButton.layer.cornerRadius = 5.0
        doneButton.isHidden = true
        
        //setup drop shadows
        searchView.dropShadow()
        labelField.dropShadow()
        dateField.dropShadow()
        mapView.dropShadow()
        doneButton.dropShadow()
        
        //hide views on load
        nameView.isHidden = true
        dateView.isHidden = true
        nameViewHeight.constant = 0
        dateViewHeight.constant = 0
        //TODO: maybe collapse height of done button?
        
        //Add padding to the name and date fields
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15 , height: labelField.frame.height))
        labelField.leftViewMode = .always
        labelField.leftView = paddingView
        
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
        
        mapContainer.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isSubLocation){
            setupMapView()
        }
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
    
    private func setupMapView(){
        mapContainer.isHidden = false
        let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: city.placeID)
        let target = gms?.coordinate
        var camera = GMSCameraPosition.camera(withTarget: target!, zoom: 10)
        map = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
        map?.delegate = self
        coordinateBounds = LocationManager.getLocationBoundsFromMap(map: map!)
        self.mapView.addSubview(map!)
        map?.createMapMarkers(for: self.city, map: map)
    }
    
    private func setupNameField(){
        labelField.keyboardType = .alphabet
        labelField.inputAccessoryView = setupPickerToolbar()
        labelField.delegate = self
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
        if(labelField.isFirstResponder){
            if(!isSubLocation){
                city.label = labelField.text ?? ""
            } else {
                //TODO: handle if nameField is left blank - remove cityIndex (no longer needed)
                RealmManager.saveSublocationName(city: city, label: labelField.text)
            }
            labelField.resignFirstResponder()
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
        labelField.resignFirstResponder()
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
            //TODO: set height of done button back to normal, if it is collapsed
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
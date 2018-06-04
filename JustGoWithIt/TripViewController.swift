import UIKit
import GooglePlaces

class TripViewController: UIViewController {

    var collapsedSectionHeaders = [Int]()
    //Trip must be initialized to access this page
    var trip: Trip!

    @IBAction func addPlaceAction(_ sender: Any) {
        performSegue(withIdentifier: "tripToBuilder", sender: self)
    }
    
    @IBOutlet weak var addPlaceButton: UIButton!
    //@IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    //TODO: if the user leaves the main page while still editing, we should turn off edit mode // what would th asd
    @IBAction func rightBarAction(_ sender: Any) {
        if(isEditing){
            setEditing(false, animated: true)
            rightBarItem.title = "•••"
        }else {
            performSegue(withIdentifier: "presentMenu", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "listCell")
        self.title = trip?.name!
        addPlaceButton.layer.cornerRadius = 20.0
        //tripDate.text = trip?.startDate?.formatDateAsString()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "tripToBuilder"){
            let navigation = segue.destination as? UINavigationController
            guard let builder = navigation?.viewControllers[0] as? BuilderViewController else {
                print("Failed to cast view controller")
                return
            }
//            let indexPath = sender as! IndexPath
            //pass necessary objects off to the builder
            builder.isSubLocation = true
            
            //TODO: create a more flexible builder to allow users to add to multiple cities (either by changing the location
            // on the builder or by assuming it based on where they are on the screen (might even be able to add new cities this way)
            builder.cityIndex = 0 //This will always set the city to be the first on the trip !!! won't work for multi city
            builder.trip = self.trip
        }
        if(segue.identifier == "presentPlace"){
            let destination = segue.destination as! PlaceModalViewController
            //TODO: might be easier to just make the sender the place we are sending...
            let indexPath = sender as! IndexPath
            destination.place = trip.getSubLocation(from: indexPath)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
}

extension TripViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //Sub location selected by user (contained by main city) - new cities are added via the menu
        //let selectedLocation = place
        
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

extension TripViewController: ListHeaderDelegate{
    func shouldExpandOrCollapse(section: Int) {
        let isExpanded = collapsedSectionHeaders.contains(section)
        if(isExpanded){
            //Collapse the cell
            collapsedSectionHeaders = collapsedSectionHeaders.filter({ expanded -> Bool in
                //will remove the expanded section from the list
                return expanded != section
            })
            tableView(self.tableView, numberOfRowsInSection: section)
        } else {
            //expand the section
            collapsedSectionHeaders.append(section)
            tableView(self.tableView, numberOfRowsInSection: section)
        }
        let set = IndexSet.init(integer: section)
        tableView.reloadSections(set, with: UITableViewRowAnimation.automatic)
    }
}

extension TripViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //TODO: this is the callback after delete is pressed, use this to remove the cells from the table
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeCount = trip.cities[indexPath.section].locations.count
        performSegue(withIdentifier: "presentPlace", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let isCollapsed = collapsedSectionHeaders.contains(section)
        let header = Bundle.main.loadNibNamed("ListHeader", owner: self, options: nil)?.first as! ListHeader
        if(!isCollapsed){
            //style collapsed headers
            //header.setDropShadow()
        }
        header.arrow.image = isCollapsed ? header.imageRotatedByDegrees(oldImage: header.arrow.image!, deg: -90.0) : header.arrow.image
        header.delegate = self
        header.section = section
        let city = trip.cities[section]
        
        GooglePhotoManager.getFirstPhoto(placeID: city.googlePlace.placeID, success: { image, attributes in
            //success
            header.headerImage.image = image
        }) { (error) in
            //error
        }
        //set city name on label
        header.mainLabel.text = city.googlePlace.name
        //set date on label
        header.dateLabel.text = city.date?.formatDateAsString()
        
//        let sectionCount = trip.cities.count
//        if(section == sectionCount){
//            //configure for last section
//            header.dateLabel.isHidden = true
//            //header.button.isHidden = true
//            header.arrow.image = #imageLiteral(resourceName: "Add")
//            header.arrow.contentMode = .scaleAspectFit
//            header.mainLabel.text = "New Location"
//        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 180.0
    }
    
    //might still want to use this at somepoint to improve performance
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        //use this function to load the photos within the cells before they come onto the screen.
    //        let f = indexPath.row
    //        print(f)
    //    }
}

extension TripViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let cityCount = trip?.cities.count else{
            return 0
        }
        return cityCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListTableViewCell
        
        //let placeCount = trip.cities[indexPath.section].locations.count // we may not need this anymore cause the table cell should match the count :)
        
        let gmsPlace = trip.getSubLocationGMSPlace(from: indexPath)
        //for each place in the list - fetch the photo meta data and store on the model
        GooglePhotoManager.loadMetaDataList(placeID: gmsPlace.placeID, success: { list in
            //successfully get meta data list
            self.trip.setPhotoMetaData(indexPath, list)
            //cell.collectionView.reloadData()
        }) { error in
            //failed to get metaDatalist
        }
        
        GooglePhotoManager.getFirstPhoto(placeID: gmsPlace.placeID, success: { (image, attr) in
            cell.setThumbnailImage(image: image)
        }) { error in
            cell.handleFailedImage()
        }
        
        //cell.setupCollectionView(viewController: self, forIndexPath: indexPath)
        
        cell.activityLabel.text = trip.getSubLocation(from: indexPath).label
        cell.dateLabel.text = trip.getSubLocation(from: indexPath).date?.formatDateAsString()
        cell.locationLabel.text = gmsPlace.name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let shouldCollapse = self.collapsedSectionHeaders.contains(section)
        //TODO: make it easier to retrieve this (push to model)
        let sectionCount = trip.cities.count
        
        //This should only happen if it is the last section in the table (used to add more sections)
        if(section >= sectionCount){
            return 0
        }
        
        let placeCount = trip.cities[section].locations.count
        
        if (shouldCollapse){
            return 0
        } else {
            return placeCount //+ 1
        }
    }
}

//extension TripViewController : UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize.init(width: 200, height: 115)
//    }
//}
//
//extension TripViewController : UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let collection = collectionView as! TableCollectionView
//        let rowLocation = collection.rowLocation
//        let photoCell = cell as! PhotoCollectionViewCell
//        guard !photoCell.imageLoaded else {
//            return
//        }
//        guard let metaData = trip.getPhotoMetaData(from: rowLocation!, collectionRow: indexPath.row) else {
//            return
//        }
//        //should this be called by a method on the cell like "setFirstImage" ?
//        GooglePhotoManager.loadImageForMetadata(photoMetadata: metaData, success: { (image, attributes) in
//            photoCell.setImage(image: image)
//        }) { photoError in
//            //error
//        }
//    }
//}
//
//extension TripViewController : UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let collection = collectionView as! TableCollectionView
//        guard let indexPath = collection.rowLocation else {
//            return 1
//        }
//        guard let photoList = trip.getSubLocation(from: indexPath).photoMetaDataList else {
//            return 1
//        }
//        return photoList.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
//        cell.resetCell()
//        return cell
//    }
//}


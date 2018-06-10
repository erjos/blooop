import UIKit
import GooglePlaces
import MaterialComponents.MaterialButtons

class TripViewController: UIViewController {

    var collapsedSectionHeaders = [Int]()
    var trip: Trip!
    var lastContentOffset: CGFloat = 0
    
    @IBAction func addPlace(_ sender: Any) {
        performSegue(withIdentifier: "tripToBuilder", sender: self)
    }
    @IBOutlet weak var floatingButton: MDCFloatingButton!
    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func rightBarAction(_ sender: Any) {
        if(isEditing){
            setEditing(false, animated: true)
            rightBarItem.title = "•••"
        }else {
            performSegue(withIdentifier: "presentMenu", sender: self)
        }
    }
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showHideButtonAnimate(shouldShow: Bool){
        let bottomViewValue: CGFloat = shouldShow ? 0.0 : 60.0
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            //TODO: update this with the correct constraints to animate the button
            //self.bottomViewToBottom.constant = bottomViewValue
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "listCell")
        self.title = trip?.name
        //tripDate.text = trip?.startDate?.formatDateAsString()
        
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        floatingButton.setImage(plusImage, for: .normal)
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
            builder.isSubLocation = true
            builder.cityIndex = 0 // NOTE: This will always set the city to be the first on the trip !!! won't work for multi city
            builder.trip = self.trip
        }
        if(segue.identifier == "presentPlace"){
            let destination = segue.destination as! PlaceModalViewController
            let indexPath = sender as! IndexPath
            destination.place = trip.getSubLocation(from: indexPath)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
}

//TODO: not sure if we need this here right now
extension TripViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //Sub location selected by user (contained by main city) - new cities are added via the menu
        //let selectedLocation = place
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        //TODO: Handle error
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

extension TripViewController: UITableViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //TODO: refine this method to correctly determine when to show and hide the button
        if (self.lastContentOffset < scrollView.contentOffset.y) {
            // moved to top
            
            //self.showHideButtonAnimate(shouldShow: true)
        } else if (self.lastContentOffset > scrollView.contentOffset.y) {
            // moved to bottom
            
            //self.showHideButtonAnimate(shouldShow: false)
        } else {
            // didn't move
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
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
        let header = Bundle.main.loadNibNamed("ListHeader", owner: self, options: nil)?.first as! ListHeader
        //TODO: uncomment this code when enabling collapsable table view sections
//        let isCollapsed = collapsedSectionHeaders.contains(section)
//        if(!isCollapsed){
//            //style collapsed headers
//        }
//        header.arrow.image = isCollapsed ? header.imageRotatedByDegrees(oldImage: header.arrow.image!, deg: -90.0) : header.arrow.image
//        header.delegate = self
        header.section = section
        let city = trip.cities[section]
        GooglePhotoManager.getFirstPhoto(placeID: city.placeID, success: { image, attributes in
            //SUCCESS
            header.headerImage.image = image
        }) { (error) in
            //ERROR
        }
        let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: city.placeID)
        header.mainLabel.text = gms?.name
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
        return 255.0
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
        let placeID = trip.getSubLocationPlaceID(from: indexPath)
        
        GooglePhotoManager.loadMetaDataList(placeID: placeID, success: { list in
            GoogleResourceManager.sharedInstance.addPhotoMetaData(metaData: (placeID, list))
        }) { error in
            //TODO: ERROR
        }
        
        GooglePhotoManager.getFirstPhoto(placeID: placeID, success: { (image, attr) in
            cell.setThumbnailImage(image: image)
        }) { error in
            cell.handleFailedImage()
        }
        
        cell.activityLabel.text = trip.getSubLocation(from: indexPath).label
        cell.dateLabel.text = trip.getSubLocation(from: indexPath).date?.formatDateAsString()
        let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: placeID)
        cell.locationLabel.text = gms?.name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let shouldCollapse = self.collapsedSectionHeaders.contains(section)
        let sectionCount = trip.cities.count
        
        //This should only happen if it is the last section in the table (used to add more sections)
        if(section >= sectionCount){
            return 0
        }
        
        let placeCount = trip.cities[section].locations.count
        if (shouldCollapse){
            return 0
        } else {
            return placeCount
        }
    }
}
//TODO: save this for later - do not need expandable table view sections for the MVP
//extension TripViewController: ListHeaderDelegate{
//    func shouldExpandOrCollapse(section: Int) {
//        let isExpanded = collapsedSectionHeaders.contains(section)
//        if(isExpanded){
//            //Collapse the cell
//            collapsedSectionHeaders = collapsedSectionHeaders.filter({ expanded -> Bool in
//                //will remove the expanded section from the list
//                return expanded != section
//            })
//            tableView(self.tableView, numberOfRowsInSection: section)
//        } else {
//            //expand the section
//            collapsedSectionHeaders.append(section)
//            tableView(self.tableView, numberOfRowsInSection: section)
//        }
//        let set = IndexSet.init(integer: section)
//        tableView.reloadSections(set, with: UITableViewRowAnimation.automatic)
//    }
//}

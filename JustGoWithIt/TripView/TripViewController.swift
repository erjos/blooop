import UIKit
import GooglePlaces
import MaterialComponents.MaterialButtons

class TripViewController: UIViewController {

    var collapsedSectionHeaders = [Int]()
    var city: PrimaryLocation!
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
        //TODO: might make this label optional - if so the title of this page should be consistent
        self.title = city?.label
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        floatingButton.setImage(plusImage, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "tripToBuilder"){
            guard let builder = segue.destination as? BuilderViewController else {
                print("Failed to cast view controller")
                return
            }
            builder.isSubLocation = true
            builder.city = self.city
        }
        if(segue.identifier == "presentPlace"){
            let destination = segue.destination as! PlaceModalViewController
            let indexPath = sender as! IndexPath
            destination.place = city.getSubLocation(from: indexPath)
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
        //TODO: maybe remove not sure why we need this
        let placeCount = city.subLocations.count
        performSegue(withIdentifier: "presentPlace", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("ListHeader", owner: self, options: nil)?.first as! ListHeader
        header.section = section
        GooglePhotoManager.getFirstPhoto(placeID: city.placeID, success: { image, attributes in
            //SUCCESS
            header.headerImage.image = image
        }) { (error) in
            //ERROR
        }
        let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: city.placeID)
        header.mainLabel.text = gms?.name
        header.dateLabel.text = city.date?.formatDateAsString()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 255.0
    }
}

extension TripViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! ListTableViewCell
        let placeID = city.getSubLocationPlaceID(from: indexPath)
        
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
        
        cell.activityLabel.text = city.getSubLocation(from: indexPath).label ?? "Add label"
        cell.dateLabel.text = (city.getSubLocation(from: indexPath).date == nil) ? "Add date" : city.getSubLocation(from: indexPath).date?.formatDateAsString()
        let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: placeID)
        cell.locationLabel.text = gms?.name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let placeCount = city.subLocations.count
        return placeCount
    }
}

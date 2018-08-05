import UIKit
import GooglePlaces
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialAppBar
import MaterialComponents.MaterialFlexibleHeader

class TripViewController: UIViewController {

    var collapsedSectionHeaders = [Int]()
    var city: PrimaryLocation!
    var lastContentOffset: CGFloat = 0
    let headerbackground = UIColor.init(red: 86/255, green: 148/255, blue: 217/255, alpha: 1.0)
    
    
    @IBOutlet weak var emptyTableState: UIView!
    @IBAction func addPlace(_ sender: Any) {
        performSegue(withIdentifier: "tripToBuilder", sender: self)
    }
    @IBOutlet weak var floatingButton: MDCFloatingButton!
    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func rightBarAction(_ sender: Any) {
        if(isEditing){
            setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "menu_white"), style: .plain, target: self, action: #selector(rightBarAction(_:)))
        }else {
            performSegue(withIdentifier: "presentMenu", sender: self)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        //colors go top to bottom
        gradientLayer.colors = [headerbackground.cgColor, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //APP BAr
    let appBar = MDCAppBar()
    let headerView = TripHeaderView()
    
    func configureAppBar(){
        //configure app bar
        self.addChildViewController(appBar.headerViewController)
        appBar.navigationBar.backgroundColor = .clear
        appBar.navigationBar.title = nil
        appBar.headerViewController.layoutDelegate = self
        
        //Get the Photo
        GooglePhotoManager.getFirstPhoto(placeID: city.placeID, success: { image, attributes in
            //SUCCESS
            let imageView = UIImageView.init(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            self.headerView.imageView = imageView
            
            let headerbackground = UIColor.init(red: 86/255, green: 148/255, blue: 217/255, alpha: 1.0)
            
            
            imageView.createGradientLayer(colors: [headerbackground.cgColor, headerbackground.cgColor, headerbackground.withAlphaComponent(0.60).cgColor, headerbackground.withAlphaComponent(0.30).cgColor, headerbackground.withAlphaComponent(0.20).cgColor, headerbackground.withAlphaComponent(0.10).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor])
            self.headerView.addSubview(imageView)
            self.headerView.bringSubview(toFront: self.headerView.titleLabel)
        }) { (error) in
            //ERROR
        }
        
        let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: city.placeID)
        headerView.titleLabel.text = gms?.name
        
        // 3
        let header = appBar.headerViewController.headerView
        header.backgroundColor = .clear
        header.maximumHeight = TripHeaderView.Constants.maxHeight
        header.minimumHeight = TripHeaderView.Constants.minHeight
        // 4
        headerView.frame = header.bounds
        header.insertSubview(headerView, at: 0)
        // 5
        header.trackingScrollView = tableView
        
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(image: #imageLiteral(resourceName: "menu_white"), style: .plain, target: self, action: #selector(rightBarAction(_:))), animated: false)
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_white"), style: .plain, target: self, action: #selector(backAction(_:))), animated: false)
        
        // 6
        appBar.addSubviewsToParent()
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
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        configureAppBar()
        
        tableView.register(UINib.init(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "listCell")
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        floatingButton.setImage(plusImage, for: .normal)
        createGradientLayer()
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
            // this is necessary to make sure the view Controller underneath doesn't get cleaned up
            destination.modalPresentationStyle = .overCurrentContext
        }
        if(segue.identifier == "presentMap"){
            let destination = segue.destination as! MapViewController
            destination.city = self.city
            destination.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
}

extension TripViewController: MDCFlexibleHeaderViewLayoutDelegate {
    
    public func flexibleHeaderViewController(_ flexibleHeaderViewController: MDCFlexibleHeaderViewController,
                                             flexibleHeaderViewFrameDidChange flexibleHeaderView: MDCFlexibleHeaderView) {
        headerView.update(withScrollPhasePercentage: flexibleHeaderView.scrollPhasePercentage)
    }
}

extension TripViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let headerView = appBar.headerViewController.headerView
        
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollDidScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let headerView = appBar.headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollDidEndDecelerating()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let headerView = appBar.headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let headerView = appBar.headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollWillEndDragging(withVelocity: velocity,
                                                     targetContentOffset: targetContentOffset)
        }
    }
    
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        //TODO: refine this method to correctly determine when to show and hide the button
    //        if (self.lastContentOffset < scrollView.contentOffset.y) {
    //            // moved to top
    //
    //            //self.showHideButtonAnimate(shouldShow: true)
    //        } else if (self.lastContentOffset > scrollView.contentOffset.y) {
    //            // moved to bottom
    //
    //            //self.showHideButtonAnimate(shouldShow: false)
    //        } else {
    //            // didn't move
    //        }
    //    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
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
        let isTableEmpty = (placeCount == 0)
        self.emptyTableState.isHidden = !isTableEmpty
        return placeCount
    }
}

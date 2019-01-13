import UIKit
import RealmSwift

class MyTripsViewController: UIViewController {

    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var emptyCollectionState: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collection: UICollectionView!
    //@IBOutlet weak var floatingButton: MDCFloatingButton!
    
    @IBAction func pressFloatingAdd(_ sender: Any) {
        performSegue(withIdentifier: "toBuilder", sender: self)
    }
    
    var gradientLayer: CAGradientLayer!
    var cities : Results<PrimaryLocation>?
    var collectionCount: Int = 0
    let userDefaults = UserDefaults.standard
    
    var collectionImages = [UIImage]()
    
    let headerbackground = UIColor.init(red: 86/255, green: 148/255, blue: 217/255, alpha: 1.0)
    
    //APP BAr
    //let appBar = MDCAppBar()
    let headerView = HomeHeaderView()
    
    //we want to generate trips and add them to Realm only on the first launch. - will have to use the User defaults storage probably.
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        //colors go top to bottom
        gradientLayer.colors = [headerbackground.cgColor, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
//    func configureAppBar(){
//        //configure app bar
//        self.addChildViewController(appBar.headerViewController)
//        appBar.navigationBar.backgroundColor = .clear
//        appBar.navigationBar.title = nil
//        appBar.headerViewController.layoutDelegate = self
//        // 3
//        let header = appBar.headerViewController.headerView
//        header.backgroundColor = .clear
//        header.maximumHeight = HomeHeaderView.Constants.maxHeight
//        header.minimumHeight = HomeHeaderView.Constants.minHeight
//        // 4
//        headerView.frame = header.bounds
//        header.insertSubview(headerView, at: 0)
//        // 5
//        header.trackingScrollView = collection
////        //may need to setup and item on storyboard as well to wire up actions with the following button
////        self.navigationItem.setRightBarButton(UIBarButtonItem.init(image: #imageLiteral(resourceName: "menu_white"), style: .plain, target: self, action: nil), animated: false)
//        // 6
//        appBar.addSubviewsToParent()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        //TODO: improve this function to handle a blend on its own
        headerView.gradientView.createGradientLayer(colors: [headerbackground.cgColor, headerbackground.cgColor, headerbackground.withAlphaComponent(0.60).cgColor, headerbackground.withAlphaComponent(0.30).cgColor, headerbackground.withAlphaComponent(0.20).cgColor, headerbackground.withAlphaComponent(0.10).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleFirstLaunch()
        self.navigationController?.navigationBar.isHidden = true

        //configureAppBar()
        
        emptyStateLabel.shadowColor = UIColor.white
        emptyStateLabel.shadowOffset = CGSize.init(width: 1, height: 1)
        
        self.activityIndicator.isHidden = true
        self.emptyCollectionState.isHidden = true
        self.cities = RealmManager.fetchData()
        generateCollectionImages()
        
        collection.backgroundColor = UIColor.clear

        collection.register(UINib.init(nibName: "TripCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Card")
        
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        //floatingButton.setImage(plusImage, for: .normal)
        
        createGradientLayer() //or set Backgound to headerbackground
        
    }
    
    func handleFirstLaunch(){
        let didCompleteFirstLaunch = userDefaults.bool(forKey: "firstLaunch")
        guard !didCompleteFirstLaunch else {
            return
        }
        // generate sample data
        let sampleTrips = Mock.generateSampleData()
        
        //store sample data in realm
        for trip in sampleTrips {
            RealmManager.storeData(object: trip)
        }
        
        // set finishedFirstLaunch flag to true
        userDefaults.set(true, forKey: "firstLaunch")
    }
    
    func createCity(name: String, id: String)->PrimaryLocation{
        let city = PrimaryLocation()
    
        return city
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMain"){
            guard let navigationController = segue.destination as? UINavigationController else {
                print("Failed to cast")
                return
            }
            guard let tripVC = navigationController.viewControllers[0] as? TripViewController else {
                print("Wrong view controller")
                return
            }
            if let indexPath = sender as? IndexPath {
                let city = cities?[indexPath.row]
                tripVC.city = city
            }
            if let city = sender as? PrimaryLocation {
                tripVC.city = city
            }
        }
    }
    
    func generateCollectionImages(){
        guard let cityList = cities else {return}
        for city in cityList {
            guard let cityIndex = cityList.index(of: city) else {return}
            let photoIndex = ( cityIndex + 1) % 5
            switch (photoIndex) {
            case 0 :
                self.collectionImages.append(#imageLiteral(resourceName: "city"))
            case 1 :
                self.collectionImages.append(#imageLiteral(resourceName: "city_2"))
            case 2 :
                self.collectionImages.append(#imageLiteral(resourceName: "city_3"))
            case 3 :
                self.collectionImages.append(#imageLiteral(resourceName: "city_4"))
            case 4 :
                self.collectionImages.append(#imageLiteral(resourceName: "city_5"))
            default:
                self.collectionImages.append(#imageLiteral(resourceName: "city"))
            }
        }
    }
}

//extension MyTripsViewController: MDCFlexibleHeaderViewLayoutDelegate {
//
//    public func flexibleHeaderViewController(_ flexibleHeaderViewController: MDCFlexibleHeaderViewController,
//                                             flexibleHeaderViewFrameDidChange flexibleHeaderView: MDCFlexibleHeaderView) {
//        headerView.update(withScrollPhasePercentage: flexibleHeaderView.scrollPhasePercentage)
//    }
//}

extension MyTripsViewController: UIScrollViewDelegate {
//     func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        let headerView = appBar.headerViewController.headerView
//
//        if scrollView == headerView.trackingScrollView {
//            headerView.trackingScrollDidScroll()
//        }
//    }
//
//     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let headerView = appBar.headerViewController.headerView
//        if scrollView == headerView.trackingScrollView {
//            headerView.trackingScrollDidEndDecelerating()
//        }
//    }
//
//     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        let headerView = appBar.headerViewController.headerView
//        if scrollView == headerView.trackingScrollView {
//            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
//        }
//    }
//
//     func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
//                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let headerView = appBar.headerViewController.headerView
//        if scrollView == headerView.trackingScrollView {
//            headerView.trackingScrollWillEndDragging(withVelocity: velocity,
//                                                     targetContentOffset: targetContentOffset)
//        }
//    }
}

extension MyTripsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //fetch necessary data for the page
        let trip = cities?[indexPath.row]
        self.activityIndicator.isHidden = false
        self.view.isUserInteractionEnabled = false
        trip?.fetchGmsPlacesForCity(complete: { (isComplete) in
            self.activityIndicator.isHidden = true
            self.view.isUserInteractionEnabled = true
            self.performSegue(withIdentifier: "toMain", sender: indexPath)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let theCell = cell as! TripCollectionViewCell
        DispatchQueue.global().async {
            let image = self.collectionImages[indexPath.row]
            DispatchQueue.main.async {
                theCell.image.image = image
            }
        }
    }
}

extension MyTripsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 25, 0, 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = self.view.window?.frame.width
        //this number is 70 to give additional room inside the collection - constraints add to 60 outside the collection
        let cellWidth = deviceWidth! - 70
        let size = CGSize.init(width: cellWidth, height: 155)
        return size
    }
}

extension MyTripsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let cityCount = cities?.count else {
                //TODO: swap this out with an error state rather than an empty state
            self.emptyCollectionState.isHidden = false
            return 0
        }
        guard (cityCount != 0) else {
            self.emptyCollectionState.isHidden = false
            return 0
        }
        emptyCollectionState.isHidden = true
        return cityCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card",
                                                      for: indexPath) as! TripCollectionViewCell
        if(collectionView == collection){
            guard let city = cities?[indexPath.row] else {
                print("Failed to get city")
                return cell
            }
            cell.setLabels(city: city)
//            cell.layer.shouldRasterize = true
//            cell.layer.rasterizationScale = UIScreen.main.scale
        }
        return cell
    }
}



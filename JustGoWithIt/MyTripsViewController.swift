import UIKit
import RealmSwift
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialAppBar
import MaterialComponents.MaterialFlexibleHeader

class MyTripsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var emptyCollectionState: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var suggestionCollection: UICollectionView!
    @IBOutlet weak var floatingButton: MDCFloatingButton!
    
    @IBAction func pressFloatingAdd(_ sender: Any) {
        performSegue(withIdentifier: "toBuilder", sender: self)
    }
    
    var gradientLayer: CAGradientLayer!
    var cities: Results<PrimaryLocation>?
    var collectionCount: Int = 0
    
    let headerbackground = UIColor.init(red: 86/255, green: 148/255, blue: 217/255, alpha: 1.0)
    
    //APP BAr
    let appBar = MDCAppBar()
    let heroHeaderView = HomeHeaderView()
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        //colors go top to bottom
        gradientLayer.colors = [headerbackground.cgColor, UIColor.white.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func configureAppBar(){
        //heroHeaderView.loadUpView()
        //configure app bar
        self.addChildViewController(appBar.headerViewController)
        appBar.navigationBar.backgroundColor = .clear
        appBar.navigationBar.title = nil
        appBar.headerViewController.layoutDelegate = self
        // 3
        let headerView = appBar.headerViewController.headerView
        headerView.backgroundColor = .clear
        headerView.maximumHeight = HomeHeaderView.Constants.maxHeight
        headerView.minimumHeight = HomeHeaderView.Constants.minHeight
        // 4
        heroHeaderView.frame = headerView.bounds
        headerView.insertSubview(heroHeaderView, at: 0)
        // 5
        headerView.trackingScrollView = scrollView
        //can add programmatically - justn need better color - can show/hide in delegate methods??
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(image: #imageLiteral(resourceName: "menu_white"), style: .plain, target: self, action: nil), animated: false)
        // 6
        appBar.addSubviewsToParent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //TODO: improve this function to handle a blend on its own
        heroHeaderView.gradientView.createGradientLayer(colors: [headerbackground.cgColor, headerbackground.cgColor, headerbackground.withAlphaComponent(0.60).cgColor, headerbackground.withAlphaComponent(0.30).cgColor, headerbackground.withAlphaComponent(0.20).cgColor, headerbackground.withAlphaComponent(0.10).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor, headerbackground.withAlphaComponent(0.0).cgColor])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        scrollView.delegate = self
        configureAppBar()
        
        emptyStateLabel.shadowColor = UIColor.white
        emptyStateLabel.shadowOffset = CGSize.init(width: 1, height: 1)
        
        self.activityIndicator.isHidden = true
        self.emptyCollectionState.isHidden = true
        self.cities = RealmManager.fetchData()
        collection.backgroundColor = UIColor.clear
        suggestionCollection.backgroundColor = UIColor.clear

        collection.register(UINib.init(nibName: "TripCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Card")
        suggestionCollection.register(UINib.init(nibName: "TripCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Card")
        
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        floatingButton.setImage(plusImage, for: .normal)
        
        //TODO: this applies to the entire view on the screen - if you want to get more specific with subviews we can do that
        createGradientLayer() //or set Backgound to headerbackground
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
    
    func setCollectionPageCount(items: Int){
        var pageCount = items / 3
        let remainder = items % 3
        if (remainder > 0){
            pageCount += 1
        }
        pageControl.numberOfPages = pageCount
    }
    
    func getCollectionCellImage(indexPath: IndexPath)->UIImage{
        let photoIndex = (indexPath.row + 1) % 5
        switch (photoIndex) {
        case 0 :
            return #imageLiteral(resourceName: "city")
        case 1 :
            return #imageLiteral(resourceName: "city_2")
        case 2 :
            return #imageLiteral(resourceName: "city_3")
        case 3 :
            return #imageLiteral(resourceName: "city_4")
        case 4 :
            return #imageLiteral(resourceName: "city_5")
        default:
            return #imageLiteral(resourceName: "city")
        }
    }
}

extension MyTripsViewController: MDCFlexibleHeaderViewLayoutDelegate {
    
    public func flexibleHeaderViewController(_ flexibleHeaderViewController: MDCFlexibleHeaderViewController,
                                             flexibleHeaderViewFrameDidChange flexibleHeaderView: MDCFlexibleHeaderView) {
        heroHeaderView.update(withScrollPhasePercentage: flexibleHeaderView.scrollPhasePercentage)
        let imageAlpha = min(flexibleHeaderView.scrollPhasePercentage.scaled(from: 0...0.8, to: 0...1), 1.0)
//        let alpha = 1 - imageAlpha
//        //TODO: there has to be abetter way to do this than to redraw the image every time we want to change the alpha
//        let image = #imageLiteral(resourceName: "menu_white").alpha(alpha)
//        self.navigationItem.rightBarButtonItem?.image = image
    }
}

extension MyTripsViewController: UIScrollViewDelegate {
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
        
        if(scrollView == collection){
            let pageNumber = round(self.collection.contentOffset.x/self.collection.frame.size.width)
            self.pageControl.currentPage = Int(pageNumber)
            guard self.pageControl.currentPage < (self.cities?.count)! else {return}
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
}

extension MyTripsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //fetch necessary data for the page
        let trip = cities?[indexPath.row]
        self.activityIndicator.isHidden = false
        self.contentView.isUserInteractionEnabled = false
        trip?.fetchGmsPlacesForCity(complete: { (isComplete) in
            self.activityIndicator.isHidden = true
            self.contentView.isUserInteractionEnabled = true
            self.performSegue(withIdentifier: "toMain", sender: indexPath)
        })
    }
}

extension MyTripsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(collectionView == collection){
            return 50.0
        } else {
            return 10.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 25, 0, 25)
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let pageNumber = round(self.collection.contentOffset.x/self.collection.frame.size.width)
//        self.pageControl.currentPage = Int(pageNumber)
//        guard self.pageControl.currentPage < (self.cities?.count)! else {return}
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == collection){
            let deviceWidth = self.view.window?.frame.width
            //this number is 70 to give additional room inside the collection - constraints add to 60 outside the collection
            let cellWidth = deviceWidth! - 70
            let size = CGSize.init(width: cellWidth, height: 155)
            return size
        } else {
          let size = CGSize.init(width: 150, height: 175)
            return size
        }
    }
}

extension MyTripsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == collection){
            guard let cityCount = cities?.count else {
                self.pageControl.isHidden = true
                //TODO: swap this out with an error state rather than an empty state
                self.emptyCollectionState.isHidden = false
                return 0
            }
            setCollectionPageCount(items: cityCount)
            guard (cityCount != 0) else {
                self.emptyCollectionState.isHidden = false
                return 0
            }
            return cityCount
        } else {
            return 5
        }
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
            cell.image.image = getCollectionCellImage(indexPath: indexPath)
        }
        return cell
    }
}

extension UIImage {
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UIView {
    func roundCorners() {
        self.layer.cornerRadius = 5.0
    }
    
    func createGradientLayer(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        
        if let current = self.layer.sublayers?[0] {
            self.layer.replaceSublayer(current, with: gradientLayer)
        } else {
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
}

extension UINavigationBar {
    static func styleTitle(with color: UIColor) {
        let titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 22)!,
            NSAttributedStringKey.foregroundColor: color
        ]
        UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
    }
}

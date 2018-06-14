import UIKit
import RealmSwift
import MaterialComponents.MaterialButtons

class MyTripsViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var suggestionCollection: UICollectionView!
    @IBOutlet weak var floatingButton: MDCFloatingButton!
    
    //var lastContentOffset: CGFloat = 0
    
    @IBAction func pressFloatingAdd(_ sender: Any) {
        performSegue(withIdentifier: "toBuilder", sender: self)
    }
    
    var gradientLayer: CAGradientLayer!
    
    var trips: Results<Trip>?
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.lightGray.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trips = RealmManager.fetchData()
        collection.backgroundColor = UIColor.clear
        suggestionCollection.backgroundColor = UIColor.clear

        collection.register(UINib.init(nibName: "TripCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Card")
        suggestionCollection.register(UINib.init(nibName: "TripCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Card")
        
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        //floatingButton.setBackgroundImage(plusImage, for: .normal)
        floatingButton.setImage(plusImage, for: .normal)
        //floatingButton.imageView?.tintColor = UIColor.black
        createGradientLayer()
        setCollectionPageCount()
    }
    
    func setCollectionPageCount(){
        var pageCount = (trips?.count)! / 3
        let remainder = (trips?.count)! % 3
        if (remainder > 0){
            pageCount += 1
        }
        pageControl.numberOfPages = pageCount
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                let trip = trips?[indexPath.row]
                tripVC.trip = trip
            }
            
            if let trip = sender as? Trip {
                tripVC.trip = trip
            }
        }
    }
}

extension MyTripsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //fetch necessary data for the page
        let trip = trips?[indexPath.row]
        trip?.fetchGMSPlacesForTrip(complete: { (isComplete) in
            self.performSegue(withIdentifier: "toMain", sender: indexPath)
        })
    }
}

extension MyTripsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 5, 0, 5)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(self.collection.contentOffset.x/self.collection.frame.size.width)
        self.pageControl.currentPage = Int(pageNumber)
        guard self.pageControl.currentPage < (self.trips?.count)! else {return}
    }
    
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
            //TODO: don't force unwrap this
            setCollectionPageCount()
            return (trips?.count)!
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card",
                                                      for: indexPath) as! TripCollectionViewCell
        if(collectionView == collection){
            let trip = trips?[indexPath.row]
            cell.setLabel(name: (trip?.name)!)
        }
        return cell
    }
}

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
    
    @IBAction func pressFloatingAdd(_ sender: Any) {
        performSegue(withIdentifier: "toBuilder", sender: self)
    }
    
    var gradientLayer: CAGradientLayer!
    var cities: Results<PrimaryLocation>?
    var collectionCount: Int = 0
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.lightGray.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cities = RealmManager.fetchData()
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
                let city = cities?[indexPath.row]
                tripVC.city = city
            }
            
            if let city = sender as? PrimaryLocation {
                tripVC.city = city
            }
        }
    }
    
    func setCollectionPageCount(){
        var pageCount = (cities?.count)! / 3
        let remainder = (cities?.count)! % 3
        if (remainder > 0){
            pageCount += 1
        }
        pageControl.numberOfPages = pageCount
    }
    
    //doesn't really work because the collection is lazy loading
    func getCollectionCellImage(index: Int)->UIImage{
        switch (index) {
        case 0 :
            return #imageLiteral(resourceName: "city")
        case 1 :
            return #imageLiteral(resourceName: "city_2")
        case 2 :
            return #imageLiteral(resourceName: "city_3")
        case 3 :
            return #imageLiteral(resourceName: "city_4")
        default:
            return #imageLiteral(resourceName: "city")
        }
    }
}

extension MyTripsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //fetch necessary data for the page
        let trip = cities?[indexPath.row]
        trip?.fetchGmsPlacesForCity(complete: { (isComplete) in
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(self.collection.contentOffset.x/self.collection.frame.size.width)
        self.pageControl.currentPage = Int(pageNumber)
        guard self.pageControl.currentPage < (self.cities?.count)! else {return}
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
            return (cities?.count)!
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
            
            //need a way to tie the collection count to the row so that if you swipe back and forth this stays in sync
            //set the collection count for every 4th (1,2,3,4 repeating)
            let photoIndex = (indexPath.row + 1) % 4
            cell.image.image = getCollectionCellImage(index: photoIndex)
        }
        return cell
    }
}

import UIKit
import RealmSwift
import MaterialComponents.MaterialButtons

class MyTripsViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var suggestionCollection: UICollectionView!
    @IBOutlet weak var floatingButton: MDCFloatingButton!
    
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
        collection.backgroundColor = UIColor.clear

        collection.register(UINib.init(nibName: "TripCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Card")
        suggestionCollection.register(UINib.init(nibName: "TripCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Card")
        
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        //floatingButton.setBackgroundImage(plusImage, for: .normal)
        floatingButton.setImage(plusImage, for: .normal)
        //floatingButton.imageView?.tintColor = UIColor.black
        createGradientLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //TODO: This is not gonna work for all devices - needs more specific logic
//        let deviceHeight = self.view.window?.frame.height
//        let collectionViewHeight = deviceHeight! - 176
//        collectionHeight.constant = collectionViewHeight
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = self.view.window?.frame.width
        let cellWidth = deviceWidth! - 60
        
        let size = CGSize.init(width: cellWidth, height: 155)
        return size
    }
}

extension MyTripsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == collection){
            //TODO: don't force unwrap this
            self.trips = RealmManager.fetchData()
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

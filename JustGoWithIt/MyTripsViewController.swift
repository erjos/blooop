import UIKit
import RealmSwift
import MaterialComponents.MaterialButtons

class MyTripsViewController: UIViewController {

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var floatingButton: MDCFloatingButton!
    
    @IBAction func pressFloatingAdd(_ sender: Any) {
        performSegue(withIdentifier: "toBuilder", sender: self)
    }
    
    var trips: Results<Trip>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.register(UINib.init(nibName: "TripCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Card")
        
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        //floatingButton.setBackgroundImage(plusImage, for: .normal)
        floatingButton.setImage(plusImage, for: .normal)
        //floatingButton.imageView?.tintColor = UIColor.black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMain"){
            let tripVC = segue.destination as! TripViewController
            let indexPath = sender as! IndexPath
            let trip = trips?[indexPath.row]
            tripVC.trip = trip
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        let size = CGSize.init(width: 125, height: 135)
        return size
    }
}

extension MyTripsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //TODO: don't force unwrap this
        self.trips = RealmManager.fetchData()
        return (trips?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card",
                                                      for: indexPath) as! TripCollectionViewCell
        return cell
    }
}

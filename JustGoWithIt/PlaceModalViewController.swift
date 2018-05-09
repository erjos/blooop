import UIKit

class PlaceModalViewController: UIViewController {

    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var openStatus: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

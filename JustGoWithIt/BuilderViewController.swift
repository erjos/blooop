import UIKit

class BuilderViewController: UIViewController {
    //One idea would be to show and hide the fields as needed to reduce the noise on the page and only allow users to enter information in a predetermined order
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide date and name views at start
        nameView.isHidden = true
        dateView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

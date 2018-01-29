import UIKit

class MenuViewController: UIViewController {

    @IBAction func edit(_ sender: Any) {
        if let presentingVC = presentingViewController as? UINavigationController {
            if let vc = presentingVC.viewControllers.first as? ViewController {
                vc.rightBarItem.title = "Done"
            }
            presentingVC.setEditing(true, animated: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
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

import UIKit

class ListHeader: UITableViewHeaderFooterView {
    
    weak var delegate: ListHeaderDelegate?
    var section: Int?
    @IBOutlet weak var bubble: UIView!
    @IBOutlet weak var button: UIButton!
    @IBAction func expandOrCollapse(_ sender: Any) {
        //TODO: switch button label on expand and collapse
        delegate?.shouldExpandOrCollapse(section: self.section!)
    }
}

protocol ListHeaderDelegate: class {
    func shouldExpandOrCollapse(section: Int)
}

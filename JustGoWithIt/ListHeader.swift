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
    
    func setDropShadow(){
        let shadowPath = UIBezierPath(rect: self.bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1.5
        layer.shadowPath = shadowPath.cgPath
    }
}

protocol ListHeaderDelegate: class {
    func shouldExpandOrCollapse(section: Int)
}

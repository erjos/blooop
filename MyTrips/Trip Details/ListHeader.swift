import UIKit

class ListHeader: UITableViewHeaderFooterView {
   
    @IBOutlet weak var titleView: UIView!
    weak var delegate: ListHeaderDelegate?
    var section: Int?
    @IBOutlet weak var bubble: UIView!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var headerImage: UIImageView!
    @objc func expandCollapse(){
        delegate?.shouldExpandOrCollapse(section: self.section!)
    }
    
    func addDateShadow(){
        let shadowPath = UIBezierPath(rect: dateLabel.bounds)
        dateLabel.layer.masksToBounds = false
        dateLabel.layer.shadowColor = UIColor.black.cgColor
        dateLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        dateLabel.layer.shadowOpacity = 0.5
        dateLabel.layer.shadowRadius = 1.5
        dateLabel.layer.shadowPath = shadowPath.cgPath
    }
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.expandCollapse))
        self.addGestureRecognizer(tapGesture)
        self.arrow.isHidden = true
    }
    
    func setGradient(){
        let gradient = CAGradientLayer()
        gradient.frame = titleView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.9).cgColor, UIColor.white.cgColor]
        titleView.layer.mask = gradient
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

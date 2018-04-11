import UIKit

class ListHeader: UITableViewHeaderFooterView {
   
    weak var delegate: ListHeaderDelegate?
    var section: Int?
    @IBOutlet weak var bubble: UIView!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var mainLabel: UILabel!
    @objc func expandCollapse(){
        delegate?.shouldExpandOrCollapse(section: self.section!)
    }
    
//    @IBAction func pressAddLocation(_ sender: Any) {
//        //Action when a user presses the "add" button
//        delegate?.didSelectAdd()
//    }
    
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
        //addDateShadow()
        self.addGestureRecognizer(tapGesture)
    }
    
    //maybe add to extension of UI image
    func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
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
    func didSelectAdd()
}

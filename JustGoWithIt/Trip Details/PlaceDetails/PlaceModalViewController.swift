import UIKit
import GooglePlaces
import AMPopTip

class PlaceModalViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var notesIcon: UIButton!
    @IBOutlet weak var placeIcon: UIButton!
    @IBOutlet weak var phone: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    var place : SubLocation!
    var photoCount = 0
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollection.delegate = self
        photoCollection.dataSource = self
        photoCollection.register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        setLabels()
        phone.roundCorners(radius: 22.0)
        placeIcon.roundCorners(radius: 22.0)
        notesIcon.roundCorners(radius: 22.0)
        contentView.dropShadow()
        
//        let poptip = PopTip()
//        poptip.shouldDismissOnTap = true
//        let rect = phone.frame
//        let new = rect.insetBy(dx: 1.0, dy: 0.0)
//        poptip.show(text: "314-852-5644", direction: .down, maxWidth: 100, in: contentView, from: phone.frame)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let poptip = PopTip()
        poptip.shouldDismissOnTap = true
        let rect = phone.frame
        let new = rect.insetBy(dx: 1.0, dy: 0.0)
        poptip.show(text: "314-852-5644", direction: .down, maxWidth: 100, in: contentView, from: phone.frame)
    }
    
    func setLabels(){
        let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: place.placeID)
        
        //TODO: initiate either a tooltip to display this info or just direct them to a map or press to call function
        //phoneNumber.text = gms?.phoneNumber
        //address.text = gms?.formattedAddress
        //openStatus.text = (gms?.openNowStatus == GMSPlacesOpenNowStatus.yes) ? "Open" : "Closed"
        locationLabel.text = gms?.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PlaceModalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let photos = GoogleResourceManager.sharedInstance.getMetaDataListFor(placeId: place.placeID)?.count else {
            return 0
        }
        self.photoCount = photos
        self.pageControl.numberOfPages = photoCount
        return photoCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        //do we need to reset cell?
        return cell
    }
}

extension PlaceModalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 25, 0, 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = self.view.window?.frame.width
        //this number is 70 to give additional room inside the collection - constraints add to 60 outside the collection
        let cellWidth = deviceWidth! - 70
        let size = CGSize.init(width: cellWidth, height: 155)
        return size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(self.photoCollection.contentOffset.x/self.photoCollection.frame.size.width)
        
        self.pageControl.currentPage = Int(pageNumber)
        guard self.pageControl.currentPage < self.photoCount else {return}
    }
}

extension PlaceModalViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoCell = cell as! PhotoCollectionViewCell
        guard !photoCell.imageLoaded else {
            return
        }
        
        guard let metaDataList = GoogleResourceManager.sharedInstance.getMetaDataListFor(placeId: place.placeID) else {
            return
        }
        
        let metaData = metaDataList[indexPath.row]
        
        //should this be called by a method on the cell like "setFirstImage" ?
        GooglePhotoManager.loadImageForMetadata(photoMetadata: metaData, success: { (image, attributes) in
            photoCell.setImage(image: image)
        }) { photoError in
            //error
        }
    }
}


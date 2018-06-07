import UIKit
import GooglePlaces

class PlaceModalViewController: UIViewController {

    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var openStatus: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    var place : Location!
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollection.delegate = self
        photoCollection.dataSource = self
        photoCollection.register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        setLabels()
    }
    
    func setLabels(){
        phoneNumber.text = place.googlePlace?.phoneNumber
        address.text = place.googlePlace?.formattedAddress
        openStatus.text = (place.googlePlace?.openNowStatus == GMSPlacesOpenNowStatus.yes) ? "Open" : "Closed"
        placeLabel.text = place.label
        locationLabel.text = place.googlePlace?.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PlaceModalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photoCount = place.photoMetaDataList?.count else {
            return 1
        }
        return photoCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        //do we need to reset cell?
        return cell
    }
}

extension PlaceModalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 200, height: 115)
    }
}

extension PlaceModalViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoCell = cell as! PhotoCollectionViewCell
        guard !photoCell.imageLoaded else {
            return
        }
        guard let metaData = place.photoMetaDataList?[indexPath.row] else {
            return
        }
        //should this be called by a method on the cell like "setFirstImage" ?
        GooglePhotoManager.loadImageForMetadata(photoMetadata: metaData, success: { (image, attributes) in
            photoCell.setImage(image: image)
        }) { photoError in
            //error
        }
    }
}


//
//  PlaceDetailsViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 4/30/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//
import UIKit
import GooglePlaces

class PlaceDetailsViewController: UIViewController {
    
    var place: SubLocation!
    var photoCount = 0
    weak var delegate: PlaceDetailsDelegate?
    lazy var gmsPlace = GoogleResourceManager.sharedInstance.getPlaceForId(ID: place.placeID)

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    @IBAction func didPressClose(_ sender: Any) {
        delegate?.shouldClose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create outlet for the collectionView and page control
        photoCollection.register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //TODO: we have some inconsistencies with how we label things right now - between the place label and the gms name (right now they're the same but wont always be)
        placeLabel.text = place?.label
        self.photoCollection.reloadData()
    }

}

protocol PlaceDetailsDelegate: class {
    func shouldClose()
}

extension PlaceDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = GoogleResourceManager.sharedInstance.getMetaDataListFor(placeId: place.placeID)?.count else {
            return 0
        }
        self.photoCount = photos
        self.pageControl.numberOfPages = photoCount
        if(photoCount == 0) {
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

extension PlaceDetailsViewController: UICollectionViewDelegateFlowLayout {
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

extension PlaceDetailsViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoCell = cell as! PhotoCollectionViewCell
        guard !photoCell.imageLoaded else {
            return
        }
        
        guard let metaDataList = GoogleResourceManager.sharedInstance.getMetaDataListFor(placeId: place.placeID) else {
            //this actually indicates an error
            photoCell.setImage(image: #imageLiteral(resourceName: "picture_thumbnail"))
            return
        }
        
        guard metaDataList.count > 0 else {
            //this is setting the thumbnail
            photoCell.setImage(image: #imageLiteral(resourceName: "picture_thumbnail"), mode: UIViewContentMode.scaleAspectFit)
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

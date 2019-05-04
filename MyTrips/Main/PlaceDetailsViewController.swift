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

    @IBOutlet weak var moreInfoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var moreInfoView: UIView!
    
    @IBAction func didPressClose(_ sender: Any) {
        delegate?.shouldCloseDetails()
    }
    
    @IBAction func tapNotes(_ sender: Any) {
        //TODO: maybe create and enum to represent notes state
        guard self.textViewHeightConstraint.constant != 80 else {
            return
        }
        toggleNotes()
    }
    
    @IBAction func clickNotesButton(_ sender: Any) {
        toggleNotes()
    }
    
    @IBAction func clickMoreInfo(_ sender: Any) {
        self.moreInfoView.isHidden = !self.moreInfoView.isHidden
        UIView.animate(withDuration: 0.2) {
            self.moreInfoHeightConstraint.constant = self.moreInfoHeightConstraint.constant == 50 ? 0 : 50
            self.view.layoutIfNeeded()
        }
    }
    
    //TODO: probably should provide explicit open close instructions here so that we can use it to return vc to initial state when we close out
    func toggleNotes() {
        UIView.animate(withDuration: 0.2) {
            self.textViewHeightConstraint.constant = self.textViewHeightConstraint.constant == 80 ? 30 : 80
            self.view.layoutIfNeeded()
        }
        self.notesTextView.isEditable = !self.notesTextView.isEditable
        self.notesTextView.isScrollEnabled = !self.notesTextView.isScrollEnabled
        if (self.notesTextView.isEditable) {
            notesTextView.becomeFirstResponder()
            
        }
        
        //When open delete placeholder text and scroll to bottom - when closed, if empty, replace placeholder text
        //Need to adjust frame of screen so notes are visible when keyboard is open
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create outlet for the collectionView and page control
        photoCollection.register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.parent?.view.frame.origin.y == 0 {
                self.parent?.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.parent?.view.frame.origin.y != 0 {
            self.parent?.view.frame.origin.y = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //TODO: we have some inconsistencies with how we label things right now - between the place label and the gms name (right now they're the same but wont always be)
        placeLabel.text = place?.label
        self.photoCollection.reloadData()
        
        //hide more info view
        self.moreInfoView.isHidden = true
        self.moreInfoHeightConstraint.constant = 0
    }

}

protocol PlaceDetailsDelegate: class {
    func shouldCloseDetails()
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

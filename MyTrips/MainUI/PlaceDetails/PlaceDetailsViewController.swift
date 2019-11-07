//
//  PlaceDetailsViewController.swift
//  MyTrips
//
//  Created by Ethan Joseph on 4/30/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//
import UIKit
import GooglePlaces

//TODO:
//> allow users to add a custom label besides the place location name?

//> we have some inconsistencies with how we label things right now - between the place label and the gms name (right now they're the same but wont always be)

//> add category capabilities

class PlaceDetailsViewController: UIViewController {
    var place: SubLocation!
    var photoCount = 0
    weak var delegate: PlaceDetailsDelegate?
    lazy var gmsPlace = GoogleResourceManager.sharedInstance.getPlaceForId(ID: place.placeID)
    
    let NOTES_PLACEHOLDER = "Notes..."
    
    let datePicker = UIDatePicker()
    var collapsedNotesHeight: CGFloat = 30

    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var moreInfoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    
    @IBAction func didPressClose(_ sender: Any) {
        delegate?.shouldCloseDetails()
    }
    
    @IBAction func tapNotes(_ sender: Any) {
        guard !self.notesTextView.isEditable else {
            return
        }
        toggleNotes()
    }
    
    @IBAction func clickNotesButton(_ sender: Any) {
        //notesTextView.resignFirstResponder()
        toggleNotes()
    }
    
    @IBAction func clickMoreInfo(_ sender: Any) {
        self.moreInfoView.isHidden = !self.moreInfoView.isHidden
        UIView.animate(withDuration: 0.2) {
            //TODO: get rid of this hard coded constraint - set a variable on the view controller in view did load to pull the values from the storyboard
            self.moreInfoHeightConstraint.constant = self.moreInfoHeightConstraint.constant == 60 ? 0 : 60
            self.view.layoutIfNeeded()
        }
    }
    
    func getCollectionHeight() -> CGFloat {
        return self.view.frame.height - 120
    }
    
    @IBAction func clickDate(_ sender: Any) {
        self.dateField.becomeFirstResponder()
    }
    
    @IBAction func tapPhoneView(_ sender: Any) {
        guard let phone = gmsPlace?.phoneNumber else {
            return
        }
        guard let url = URL(string: phone) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func tapWebsiteView(_ sender: Any) {
        guard let url = gmsPlace?.website else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc func notesDoneAction() {
        toggleNotes()
    }
    
    @objc func dateDoneAction() {
        dateField.resignFirstResponder()
    }
    
    //might be easier to read if we pass in an enum
    func toggleNotes() {
        if (notesTextView.isFirstResponder) {
            notesTextView.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.2) {
            if(self.collapsedNotesHeight < 80) {
                self.textViewHeightConstraint.constant = self.textViewHeightConstraint.constant == 80 ? self.collapsedNotesHeight : 80
                self.view.layoutIfNeeded()
            }
        }
        self.notesTextView.isEditable = !self.notesTextView.isEditable
        if (self.notesTextView.isEditable) {
            notesTextView.becomeFirstResponder()
        }
        
        if(notesTextView.text == NOTES_PLACEHOLDER) {
            notesTextView.text = ""
        } else if (notesTextView.text == "") {
            notesTextView.text = NOTES_PLACEHOLDER
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollection.register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        //setup place label
        placeLabel.text = place?.label
        self.photoCollection.reloadData()
        
        //setup date
        if(place.date == nil) {
            self.dateField.isHidden = true
        } else {
            dateField.text = place.date?.formatDateAsString()
            datePicker.date = place.date ?? Date()
        }
        datePicker.datePickerMode = .date
        dateField.inputView = datePicker
        dateField.inputAccessoryView = createInputToolbar(doneSelector: #selector(dateDoneAction), cancelButton: false, cancelSelector: nil)
        
        //setup more-info
        self.moreInfoView.isHidden = true
        self.moreInfoHeightConstraint.constant = 0
        
        if let phone = gmsPlace?.phoneNumber {
            self.phoneNumber.text = phone
        }
        
        if let website = gmsPlace?.website?.description {
            self.website.text = website
        }
        
        //setup notes
        notesTextView.inputAccessoryView = createInputToolbar(doneSelector: #selector(self.notesDoneAction), cancelButton: false, cancelSelector: nil)
        if(!self.place.notes.isEmpty) {
            self.notesTextView.text = place.notes
        }
        
        //setup keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        //TODO: wish I had some comments explaining why these are here - idk if they do anything - experiment removing them
        textViewHeightConstraint.constant = notesTextView.getHeightToFit()
        self.collapsedNotesHeight = notesTextView.getHeightToFit()
        
        //set the collection height
        self.collectionHeightConstraint.constant = self.getCollectionHeight()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.parent?.view.frame.origin.y == 0 {
                self.parent?.view.frame.origin.y -= (keyboardSize.height - 50)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.parent?.view.frame.origin.y != 0 {
            self.parent?.view.frame.origin.y = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.photoCollection.reloadData()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { _ in
            self.collectionHeightConstraint.constant = self.getCollectionHeight()
            self.photoCollection.reloadItems(at: self.photoCollection.indexPathsForVisibleItems)
            self.photoCollection.scrollToItem(at: self.photoCollection.indexPathsForVisibleItems[0], at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
        }
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
        return 0.0//50.0
    }
    
    //This just needs to the padding of the cell in the view divided by two - might not need it for the
    //full width
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        let screenWidth = self.contentView.frame.width
//        let padding = screenWidth * 0.2
//        let cellWidth = screenWidth - padding
//
//        let extraSpace =
        
         return UIEdgeInsetsMake(0, 0, 0, 0)//UIEdgeInsetsMake(0, 25, 0, 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = self.contentView.frame.width
        //this number is 70 to give additional room inside the collection - constraints add to 60 outside the collection 25+25+10+10
        //must be related to the size of the content when we initialize it from the storyboard?
        //let padding = screenWidth * 0.2
        
        //let cellWidth = screenWidth - padding
        
        //.54 ratio used to calculate height of the cell - do we need to use this ratio?
        let size = CGSize.init(width: screenWidth, height: getCollectionHeight())//(screenWidth * 0.54))
        return size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(self.photoCollection.contentOffset.x/self.photoCollection.frame.size.width)
        
        self.pageControl.currentPage = Int(pageNumber)
        guard self.pageControl.currentPage < self.photoCount else {return}
    }
}

extension PlaceDetailsViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }
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
            photoCell.setImage(image: #imageLiteral(resourceName: "picture_thumbnail"))
            return
        }
        let metaData = metaDataList[indexPath.row]
        
        //should this be called by a method on the cell like "setFirstImage" ?
        GooglePhotoManager.loadImageForMetadata(photoMetadata: metaData, success: { (image, attributes) in
            photoCell.setImage(image: image, mode: UIViewContentMode.scaleAspectFit)
        }) { photoError in
            //error
        }
    }
}

extension PlaceDetailsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        //save date to realm object
        RealmManager.saveSublocationDate(place: place, date: datePicker.date)
        textField.text = datePicker.date.formatDateAsString()
        textField.isHidden = false
    }
}

extension PlaceDetailsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        //update new notes collapsed height
        let height = self.notesTextView.getHeightToFit()
        self.collapsedNotesHeight = height
        
        if(notesTextView.text != NOTES_PLACEHOLDER) {
            //save to realm object
            RealmManager.saveNotes(place: place, notes: notesTextView.text)
        }
    }
}

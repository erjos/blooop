//
//  GoogleResourceManager.swift
//  JustGoWithIt
//
//  Created by Joseph, Ethan on 6/8/18.
//  Copyright © 2018 Joseph, Ethan. All rights reserved.
//

import Foundation
import GooglePlaces

class GoogleResourceManager {
    //** This class should be created and destroyed for every trip that is opened OR the data needs to be wiped **//
    //TODO: write a function that disposes of this data
    
    private var gmsPlaces = [GMSPlace]()
    private var photoMetaData = [(String, [GMSPlacePhotoMetadata])]()
    
    static let sharedInstance = GoogleResourceManager()
    
    private init() {}
    
    func addGmsPlace(place: GMSPlace){
        self.gmsPlaces.append(place)
    }
    
    func getPlaceForId(ID: String)->GMSPlace?{
        let list = self.gmsPlaces.filter { (place) -> Bool in
            return place.placeID == ID
        }
        return list.first
    }
    
    func addPhotoMetaData(metaData: (String, [GMSPlacePhotoMetadata])) {
        //** This list will correspond only to the order of the table cells when the view is initialize **//
        let isDuplicate = photoMetaData.contains { (id, metaDataList) -> Bool in
            return id == metaData.0
        }
        if(!isDuplicate){
            self.photoMetaData.append(metaData)
        }
    }
    
    func getMetaDataListFor(placeId: String) -> [GMSPlacePhotoMetadata]?{
        let result = photoMetaData.filter { (id, metaDataList) -> Bool in
            return id == placeId
        }
        return result.first?.1
    }
}

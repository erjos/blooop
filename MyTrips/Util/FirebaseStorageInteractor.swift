//
//  DatabaseInteractor.swift
//  MyTrips
//
//  Created by Ethan Joseph on 10/16/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseStorageInteractor: StorageProtocol {
    func updateTrip(trip: PrimaryLocation, user: User?) {
        
        guard let activeUser = user else {
            return
        }
        
        var subs = [[String : Any]]()
        let sublocations = trip.subLocations
        for sublocation in sublocations {
            
                let locationData = ["label" : sublocation.label as Any,
                                    "date" : sublocation.date as Any,
                                    "placeId" : sublocation.placeID,
                                    "notes" : sublocation.notes] as [String : Any]
                
                subs.append(locationData)
        }

        let docData : [String : Any] = ["owner" : activeUser.uid,
                                        "placeId" : trip.placeID,
                                        "label" : trip.label,
                                        "locationId" : trip.locationId,
                                        "subLocations" : subs]
        
        Firestore.firestore().collection("trips").addDocument(data: docData)
    }
}

protocol StorageProtocol {
    func updateTrip(trip: PrimaryLocation, user: User?)
}

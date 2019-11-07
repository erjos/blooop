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

class NetworkStorageClient: NetworkStorageProtocol {
    func updateTrip(_ trip: PrimaryLocation, _ userId: String) {
        
        var subs = [[String : Any]]()
        let sublocations = trip.subLocations
        for sublocation in sublocations {
            
                let locationData = ["label" : sublocation.label as Any,
                                    "date" : sublocation.date as Any,
                                    "placeId" : sublocation.placeID,
                                    "notes" : sublocation.notes] as [String : Any]
                
                subs.append(locationData)
        }

        let docData : [String : Any] = ["owner" : userId,
                                        "placeId" : trip.placeID,
                                        "label" : trip.label,
                                        "locationId" : trip.locationId,
                                        "subLocations" : subs]
        
        Firestore.firestore().collection("trips").addDocument(data: docData)
    }
}

protocol NetworkStorageProtocol {
    //updates single trip in storage
    func updateTrip(_ trip: PrimaryLocation, _ userId: String)
}

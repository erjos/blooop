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

//NOTES: If we handle the errors so that when network connection fails we store the trip locally, then the next time we have a successful connection and the user is logged in we should just be able to update the trip without issue

//Test these different cases of logging in and then trying to modify a trip when the network connection is lost
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
                                        "subLocations" : subs]
        //** get the existing document at this path
        let docRef = Firestore.firestore().collection("trips").document(trip.tripUUID)
        
        docRef.updateData(docData) { error in
            //** handle the error if the server fails to update the data
        }
    }
    
    func saveNewTrip(_ trip: PrimaryLocation, _ userId: String) {
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
                                            "subLocations" : subs]
            
        let docRef = Firestore.firestore().collection("trips").addDocument(data: docData) { error in
            //** handle error
        }
        
        //** set trip unique id with doc id generated by the server
        trip.tripUUID = docRef.documentID
    }
}

protocol NetworkStorageProtocol {
    //saves a new trip remotely when a user is logged in
    func saveNewTrip(_ trip: PrimaryLocation, _ userId: String)
    //updates existing trip remotely when a user is logged in
    func updateTrip(_ trip: PrimaryLocation, _ userId: String)
}

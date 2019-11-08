//
//  StorageInteractor.swift
//  MyTrips
//
//  Created by Ethan Joseph on 11/6/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//
import Foundation

class StorageInteractor: Storage {
    
    lazy var networkStorageClient: NetworkStorageProtocol = NetworkStorageClient()
    lazy var localStorageClient: LocalStorageProtocol = LocalStorageClient()
    
    func saveNewTrip(userId: String?, trip: PrimaryLocation) {
        //check for the user
        guard let uuid = userId else {
            //set trip id locally to save to realm
            trip.setTripUUID()
            self.localStorageClient.updateTrip(trip)
            return
        }
        
        self.networkStorageClient.saveNewTrip(trip, uuid)
    }
    
    func updateTrip(userId: String?, trip: PrimaryLocation) {
        guard let uuid = userId else {
            self.localStorageClient.updateTrip(trip)
            return
        }
        
        self.networkStorageClient.updateTrip(trip, uuid)
    }
}

protocol Storage {
    //saves new trip
    func saveNewTrip(userId: String?, trip: PrimaryLocation)
    //updates existing trip
    func updateTrip(userId: String?, trip:PrimaryLocation)
}

//delete the RealmManager class and test that local storage functionality is retained
//implement the function
//write tests for the new networking and storage components


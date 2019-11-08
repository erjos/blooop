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
    
    func saveTrip(userId: String?, trip: PrimaryLocation) {
        //check for the user
        guard let uuid = userId else {
            self.localStorageClient.updateTrip(trip)
            return
        }
        
        self.networkStorageClient.saveNewTrip(trip, uuid)//updateTrip(trip, uuid)
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
    func saveTrip(userId: String?, trip: PrimaryLocation)
    
    func updateTrip(userId: String?, trip:PrimaryLocation)
}

//delete the RealmManager class and test that local storage functionality is retained
//implement the function
//write tests for the new networking and storage components


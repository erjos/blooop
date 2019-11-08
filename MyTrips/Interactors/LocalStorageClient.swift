//
//  LocalStorageClient.swift
//  MyTrips
//
//  Created by Ethan Joseph on 11/7/19.
//  Copyright © 2019 Joseph, Ethan. All rights reserved.
//
import Foundation
import RealmSwift

//goal - get rid of the realm manager class and move everything into this class...

class LocalStorageClient: LocalStorageProtocol {
    //will add or update a trip in the realm
    func updateTrip(_ trip: PrimaryLocation) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(trip, update: .modified)
                print("Added new object")
            }
        } catch let error as NSError {
            //handle error
            print(error)
            
        }
    }
}

protocol LocalStorageProtocol {
    //will save new trip or update existing trip
    func updateTrip(_ trip: PrimaryLocation)
}

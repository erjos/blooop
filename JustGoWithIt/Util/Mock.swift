//
//  Mock.swift
//  MyTrips
//
//  Created by Ethan Joseph on 8/28/18.
//  Copyright © 2018 Joseph, Ethan. All rights reserved.
//

import Foundation

class Mock {
    
    private static func createSubLocations(placeIDs: [String])->[SubLocation]{
        var subLocations = [SubLocation]()
        for ids in placeIDs{
            let sublocation = SubLocation()
            sublocation.placeID = ids
            subLocations.append(sublocation)
        }
        return subLocations
    }
    
    static func generateSampleData() -> [PrimaryLocation] {
        let sanFran = PrimaryLocation()
        sanFran.setCity(name: "San Francisco", placeID: "ChIJIQBpAG2ahYAR_6128GcTUEo")
        
        let sanFranIDs = ["ChIJxdYX1GGOhYARiIigVMJ9TOY","ChIJaQ1QHj1-j4ARGwFcVV3HM9A","ChIJyzeuaJCAhYARCmK0UthwWrY", "ChIJ5abCmkWHhYARH3zgiLVc_Ew", "ChIJ00mFOjZ5hYARk-l1ppUV6pQ"]
        
        sanFran.subLocations.append(objectsIn: createSubLocations(placeIDs: sanFranIDs))
        
        let amsterdamIDs = ["ChIJk17zB7gJxkcR8E1SEpIcE_4", "ChIJufaJMsEJxkcRSiGAzmpg3Qc", "ChIJSRE-IcUJxkcRCltjPmVdmtQ", "ChIJX1rTlu8JxkcRGsV8-a4oKMI", "ChIJSxklPO0JxkcRCqxBkavK008"]
        
        let amsterdam = PrimaryLocation()
        amsterdam.setCity(name: "Amsterdam", placeID: "ChIJVXealLU_xkcRja_At0z9AGY")
        amsterdam.subLocations.append(objectsIn: createSubLocations(placeIDs: amsterdamIDs))
        
        let copenIDs = ["ChIJYRDKMj1TUkYR5AYW9s_cEN8", "ChIJ6Y6AJBhTUkYRLnz8lc7V9yc", "ChIJVe18nhxTUkYRGubgnsctYNA", "ChIJpTt3fhFTUkYR7OVzYgAGSfo", "ChIJ13K41xNTUkYR82m2zsHJoWc"]
        
        let copen = PrimaryLocation()
        copen.setCity(name: "Copenhagen", placeID: "ChIJIz2AXDxTUkYRuGeU5t1-3QQ")
        copen.subLocations.append(objectsIn: createSubLocations(placeIDs: copenIDs))
        
        let city4 = PrimaryLocation()
        city4.setCity(name: "Sydney", placeID: "ChIJP5iLHkCuEmsRwMwyFmh9AQU")
        
        let trips = [sanFran, amsterdam, copen, city4]
        return trips
    }
}

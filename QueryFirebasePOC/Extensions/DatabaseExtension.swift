//
//  DatabaseExtension.swift
//  QueryFirebasePOC
//
//  Created by Pritam Hinger on 17/10/20.
//  Copyright © 2020 Pritam Hinger. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension Database{
    func addPlace(place: Location, onCompletion: @escaping(Bool, Error?) -> Void){
        var locDict = [String: AnyObject]()
        locDict["name"] = place.name as AnyObject
        locDict["latitude"] = place.latitude as AnyObject
        locDict["longitude"] = place.longitude as AnyObject
        
        Database.database().reference().child("locations").childByAutoId().setValue(locDict) { (error, dbRef) in
            if let err = error{
                onCompletion(false, err)
                return
            }
            
            onCompletion(true, nil)
        }
    }
    
    func getAllPlaces(onCompletion: @escaping([String: AnyObject]?) -> Void){
        Database.database().reference().child("locations").observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String: AnyObject]{
                onCompletion(data)
                return
            }
            
            onCompletion(nil)
            return
        }
    }
}

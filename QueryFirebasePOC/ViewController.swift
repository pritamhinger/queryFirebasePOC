//
//  ViewController.swift
//  QueryFirebasePOC
//
//  Created by Pritam Hinger on 17/10/20.
//  Copyright © 2020 Pritam Hinger. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var locations = [Location]()
    var filtered = false
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationTableViewCell
        let location = locations[indexPath.row]
        cell.name.text = "Name : \(location.name)"
        cell.longitude.text = "Longitude: \(location.longitude)"
        cell.latitude.text = "Latitude: \(location.latitude)"
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 100
    }
    
    fileprivate func getLocationDataFromFirebaseResponse(_ data: [String : AnyObject]) {
        let decoder = JSONDecoder()
        for item in data {
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: item.value, options: .prettyPrinted)
                self.locations.append(try decoder.decode(Location.self, from: jsonData))
            }
            catch let err{
                print(err.localizedDescription)
            }
        }
    }
    
    fileprivate func loadAllLocations() {
        Database.database().getAllPlaces { (dataDict: [String: AnyObject]?) in
            if let data = dataDict{
                self.locations = [Location]()
                self.getLocationDataFromFirebaseResponse(data)
                
                if(self.locations.count > 0){
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAllLocations()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func filterLocations(_ sender: Any) {
        
        if !filtered{
            
            let fromLatitude = Double.random(in: -90 ..< 0)
            let fromLongitude = Double.random(in: -180 ..< 0)
            let toLatitude = Double.random(in: 0 ..< 90)
            let toLongitude = Double.random(in: 0 ..< 180)
            
            print("Latitude [from : \(fromLatitude) -- to : \(toLatitude)]")
            print("Longitude [from : \(fromLongitude) -- to : \(toLongitude)]")
            
            Database.database().reference().child("locations").queryOrdered(byChild: "longitude").queryStarting(atValue: fromLongitude).queryEnding(atValue: toLongitude).observeSingleEvent(of: .value) { (snapshot) in
                if let data = snapshot.value as? [String: AnyObject]{
                    self.locations = [Location]()
                    self.getLocationDataFromFirebaseResponse(data)
                    
                    if(self.locations.count > 0){
                        self.tableView.reloadData()
                    }
                }
            }
        }
        else{
            loadAllLocations()
        }
        
        filtered = !filtered
    }
    
    @IBAction func addLocationInFirebase(_ sender: Any) {
        //The numbers are in decimal degrees format and range from -90 to 90 for latitude and -180 to 180 for longitude.
        
        let latitude = Double.random(in: -90 ..< 90)
        let longitude = Double.random(in: -180 ..< 180)
        let location = Location(name: "Loc1", longitude: longitude, latitude: latitude)
        Database.database().addPlace(place: location) { (status, error) in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            
            if !status{
                print("API Call failed")
            }
            
            print("Location Saved")
        }
    }
    
}


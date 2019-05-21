//
//  MechanicTableViewController.swift
//  MyVPAIRFinal
//
//  Created by Swati Singh on 04/10/18.
//  Copyright © 2018 Swati Singh. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit


class MechanicTableViewController: UITableViewController , CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var mechanicLocation = CLLocationCoordinate2D()
    
    
    
    var mechanicRequests : [DataSnapshot] = []
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        // It is the same code that i used in customerVC inside of logout
        
        try? Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Database.database().reference().child("mechanicRequests").observe(.childAdded) { (snapshot) in
             if let  mechanicRequestDict =  snapshot.value as? [String :AnyObject] {
            if let mechanicLat = mechanicRequestDict["mechanicLat"] as? Double {
                 
            
                
            } else {
                
                self.mechanicRequests.append(snapshot)
                self.tableView.reloadData()
                
                }
            }
                
            
            
        }
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate{
            
            mechanicLocation = coord
            
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mechanicRequests.count
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mechanicRequestCell", for: indexPath)
        
        let snapshot = mechanicRequests[indexPath.row]
        if let  mechanicRequestDict =  snapshot.value as? [String :AnyObject] {
            if let email = mechanicRequestDict["email"] as? String {
                
                if let lat = mechanicRequestDict["lat"] as? Double {
                    if let lon = mechanicRequestDict["lon"] as? Double{
                        
                        let mechanicCLLocation = CLLocation(latitude: mechanicLocation.latitude, longitude: mechanicLocation.longitude)
                        let customerCLLocation = CLLocation(latitude: lat, longitude: lon)
                        // Now we'll find out the distance btw the mechanic and the customer using the following line, very simple
                        
                        let distance =  mechanicCLLocation.distance(from: customerCLLocation) / 1000
                        
                        // We have divided by 1000 in order to convert this in kilometers .
                        // We're gonna round off the distance for better representation
                        
                        let roundedDistance = round(distance * 100)/100
                        
                        
                        cell.textLabel?.text = " \(email) - \(roundedDistance) Km away!"
                        
                        
                    }
                    
                }
                
            }
        }
        
        
        return  cell
        
    }
    
    
    //Creating a new function that can go from the MechanicVC to the AcceptRequestVC
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let snapshot = mechanicRequests[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let acceptVC = segue.destination as? AcceptRequestViewController {
            
            if let snapshot = sender as? DataSnapshot {
                if let  mechanicRequestDict =  snapshot.value as? [String :AnyObject] {
                    if let email = mechanicRequestDict["email"] as? String {
                        
                        if let lat = mechanicRequestDict["lat"] as? Double {
                            if let lon = mechanicRequestDict["lon"] as? Double{
                                
                                acceptVC.requestEmail = email
                                
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                
                                acceptVC.requestLocation = location
                                acceptVC.mechanicLocation = mechanicLocation
                                
                            }
                        }
                    }
                }
        
            }
            
            
            
            
            
        }
    }
    
    
    
    
}

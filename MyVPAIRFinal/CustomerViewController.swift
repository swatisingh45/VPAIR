//
//  CustomerViewController.swift
//  MyVPAIRFinal
//
//  Created by Swati Singh on 04/10/18.
//  Copyright © 2018 Swati Singh. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class CustomerViewController: UIViewController,  CLLocationManagerDelegate{
    
    
    var userLocation = CLLocationCoordinate2D()
    var mechanicLocation = CLLocationCoordinate2D()
    
    
    var locationManager = CLLocationManager()
    // With this we would do some set up in viewDidLoad
    
    var mechanicHasBeenCalled = false
    var mechanicOntheWay = false
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        // for logging  out of the session of the user from the account
        
        try? Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    @IBOutlet var map: MKMapView!
    
    @IBOutlet var callamechanic: UIButton!
    
    @IBAction func callamechanicFunc(_ sender: Any) {
        // We have to create a dictionary in order to store the information we wanna extract and also see this dictionary
        // It says the cictionary can be of any type but the nameof it is String for example email,lat or lan .
        
        // We have to authenticate the email address
        //FIRAuth has been changed to AutH : NOTE
        
        if !mechanicOntheWay {
            
            if let email = Auth.auth().currentUser?.email {
                
                if mechanicHasBeenCalled {
                    // Flip these things
                    mechanicHasBeenCalled = false
                    callamechanic.setTitle("Request a mechanic", for: .normal)
                    Database.database().reference().child("mechanicRequests").queryOrdered(byChild: "email").queryEqual(toValue: email ).observe(.childAdded) { (snapshot) in
                        
                        snapshot.ref.removeValue()
                        Database.database().reference().child("mechanicRequests") .removeAllObservers()
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                } else {
                    
                    // IF mechanic has not been called
                    
                    let mechanicRequestDictionary : [String : Any]  = ["email": email,"phoneNumber" : Constants.mobileNumber, "lat" : userLocation.latitude, "lon" : userLocation.longitude]
                    Database.database().reference().child("mechanicRequests").childByAutoId().setValue(mechanicRequestDictionary)
                    mechanicHasBeenCalled = true
                    callamechanic.setTitle("Cancel the request", for: .normal)
                    
                    
                }
                
                
                
            }
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email {
            
            Database.database().reference().child("mechanicRequests").queryOrdered(byChild: "email").queryEqual(toValue: email ).observe(.childAdded) { (snapshot) in
                
                self.mechanicHasBeenCalled = true
                self.callamechanic.setTitle("Cancel the request", for: .normal)
                Database.database().reference().child("mechanicRequests") .removeAllObservers()
                
                if let  mechanicRequestDict =  snapshot.value as? [String :AnyObject] {
                    if let mechanicLat = mechanicRequestDict["mechanicLat"] as? Double {
                        if let mechanicLon = mechanicRequestDict["mechanicLon"] as? Double {
                            
                            self.mechanicLocation = CLLocationCoordinate2D(latitude: mechanicLat, longitude: mechanicLat)
                            self.mechanicOntheWay = true
                            self.displayMechanicAndCustomer()
                            
                            if let email = Auth.auth().currentUser?.email {
                                Database.database().reference().child("mechanicRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snapshot) in
                                    
                                    if let  mechanicRequestDict =  snapshot.value as? [String :AnyObject] {
                                        if let mechanicLat = mechanicRequestDict["mechanicLat"] as? Double {
                                            if let mechanicLon = mechanicRequestDict["mechanicLon"] as? Double {
                                                
                                                self.mechanicLocation = CLLocationCoordinate2D(latitude: mechanicLat, longitude: mechanicLat)
                                                self.mechanicOntheWay = true
                                                self.displayMechanicAndCustomer()
                                                
                                                
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                
                                
                            }
                        }
                    }
                    
                    
                }
                
            }
        }
    }
    
    
    
    // We want both the customer and the mechanic to be displayed on the map at the same time
    
    func displayMechanicAndCustomer() {
        
        let mechanicCLLocation = CLLocation(latitude: mechanicLocation.latitude, longitude: mechanicLocation.longitude)
        let customerCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude )
        let distance =  mechanicCLLocation.distance(from: customerCLLocation) / 1000
        let roundedDistance = round(distance * 100)/100
        
        callamechanic.setTitle("Your mechanic is \(roundedDistance) Km away !", for: .normal)
        map.removeAnnotations(map.annotations)
        
        let latDelta =  abs( mechanicLocation.latitude - userLocation.latitude)*2 + 0.005
        let lonDelta =  abs( mechanicLocation.longitude - userLocation.longitude)*2 + 0.005
        
        
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta ))
        
        map.setRegion(region, animated: true)
        
        let customerAnno = MKPointAnnotation()
        customerAnno.coordinate = userLocation
        customerAnno.title = "Your location"
        map.addAnnotation(customerAnno)
        
        
        
        let mechanicAnno = MKPointAnnotation()
        mechanicAnno.coordinate = mechanicLocation
        mechanicAnno.title = "Your Mechanic's location"
        map.addAnnotation(mechanicAnno)
        
        
    }
    

    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let  coord =   manager.location?.coordinate{
            
            let centre =   CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            userLocation = centre
            
            
            if mechanicHasBeenCalled {
                
                displayMechanicAndCustomer()
                
                
            }
                
            else {
                // LatDelta : 0.01 and LonDekta : 0.01
                
                
                let region = MKCoordinateRegion(center: centre, span:  MKCoordinateSpan(latitudeDelta:0.01, longitudeDelta: 0.01))
                map.setRegion(region, animated: true)
                map.removeAnnotations(map.annotations)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = centre
                annotation.title = "Your location"
                map.addAnnotation(annotation)
                
                
                
            }
            
        }
    }
    
    
    
    
}

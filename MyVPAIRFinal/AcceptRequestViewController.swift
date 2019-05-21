//
//  AcceptRequestViewController.swift
//  MyVPAIRFinal
//
//  Created by Swati Singh on 04/10/18.
//  Copyright © 2018 Swati Singh. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestViewController: UIViewController {
    // For request status :-
    var requestStatus = false
    
    @IBOutlet var map: MKMapView!
    
    //Request for user's location
    
    var requestLocation = CLLocationCoordinate2D()
    var mechanicLocation = CLLocationCoordinate2D()
    
    var requestEmail = ""
    
    @IBAction func acceptTapped(_ sender: Any) {
        // Now when we accept the request, there are two things that we wanna do .
        // 1. Update the ride request
        
        
        
        Database.database().reference().child("mechanicRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            
        snapshot.ref.updateChildValues(["mechanicLat": self.mechanicLocation.latitude, "mechanicLon" : self.mechanicLocation.longitude])
             Database.database().reference().child("mechanicRequests") .removeAllObservers()
            
        
        }
        //2 . We want to give directions
        
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude )
        // Make Geo-Coder
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placemark)
                    //Giving it a name
                    
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving ]
                    mapItem.openInMaps(launchOptions: options)
                    
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   // Set the map at correct place
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta:0.01, longitudeDelta:0.01))
    
        map.setRegion(region, animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
        
    }

 

}

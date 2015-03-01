//
//  ViewController.swift
//  His Map Favorites
//
//  Created by Luke Davitt on 2/27/15.
//  Copyright (c) 2015 Luke Davitt. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var manager:CLLocationManager!
    @IBOutlet weak var myMap: MKMapView!
    
    @IBAction func findMe(sender: AnyObject) {
        
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "back"{

            self.navigationController?.navigationBarHidden = false
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest

        if activePlace == -1{
            
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        }else{
            
            let lat = NSString(string: places[activePlace]["lat"]!).doubleValue
            let lng = NSString(string: places[activePlace]["lng"]!).doubleValue
            
            var latitude:CLLocationDegrees = lat
            var longitude:CLLocationDegrees = lng
            
            var latDelta:CLLocationDegrees = 0.01
            var lngDelta:CLLocationDegrees = 0.01
            
            var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lngDelta)
            
            var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longitude)
            
            var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            myMap.setRegion(region, animated: true)
            
            var annotation = MKPointAnnotation()
            
            annotation.coordinate = location
            annotation.title = places[activePlace]["name"]
            
            myMap.addAnnotation(annotation)
            
            var uilpgr = UILongPressGestureRecognizer(target:self, action: "action:")
            
            uilpgr.minimumPressDuration = 2.0
            
            myMap.addGestureRecognizer(uilpgr)
            
        }
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func action(gestureRecognizer:UIGestureRecognizer){
        
        
        println("here?")
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            var touchPoint = gestureRecognizer.locationInView(self.myMap)
            
            var newCoordinate = myMap.convertPoint(touchPoint, toCoordinateFromView: self.myMap)
            
           
            
            
            var loc = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(loc, completionHandler:{(placemarks, error) in
                
                if ((error) != nil)  { println("Error: \(error)") }
                else {
                    
                    let p = CLPlacemark(placemark: placemarks?[0] as CLPlacemark)
                    
                    var subThoroughfare:String
                    
                    if ((p.subThoroughfare) != nil) {
                        subThoroughfare = p.subThoroughfare
                    } else {
                        subThoroughfare = ""
                    }
                    
                    var thoroughfare:String
                    
                    if ((p.thoroughfare) != nil) {
                        
                        thoroughfare = p.thoroughfare
                    }else{
                        thoroughfare = ""
                    }
                    
                    var title = "\(subThoroughfare) \(thoroughfare)"
                    
                    if title == " " {
                        
                        var date = NSDate()
                        
                        title = "Added \(date)"
                        
                    }
                    
                    
                    var annotation = MKPointAnnotation()
                    
                    annotation.coordinate = newCoordinate
                    
                    annotation.title = "\(subThoroughfare) \(thoroughfare)"
                    
                    self.myMap.addAnnotation(annotation)
                    
                    places.append(["name":title,"lat":"\(newCoordinate.latitude)","lng":"\(newCoordinate.longitude)"])
                    
                }
                
                
            })
        }else{
            println("\(gestureRecognizer.state)")
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        
        var userLocation:CLLocation = locations[0] as CLLocation
        var latitude:CLLocationDegrees = userLocation.coordinate.latitude
        var longitude:CLLocationDegrees = userLocation.coordinate.longitude
        
        var latDelta:CLLocationDegrees = 0.01
        var lngDelta:CLLocationDegrees = 0.01
        
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lngDelta)
        
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longitude)
        
        var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        myMap.setRegion(region, animated: true)
        
        manager.stopUpdatingLocation()

        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler:{(placemarks, error) in
            
            if ((error) != nil)  { println("Error: \(error)") }
            else {
                
                let p = CLPlacemark(placemark: placemarks?[0] as CLPlacemark)
                
                var subThoroughfare:String
                
                if ((p.subThoroughfare) != nil) {
                    subThoroughfare = p.subThoroughfare
                } else {
                    subThoroughfare = ""
                }
                
                //self.address.text =  "\(subThoroughfare) \(p.thoroughfare) \n \(p.subLocality) \n \(p.subAdministrativeArea) \n \(p.postalCode) \(p.country)"
                
                
                
                
            }
            
            
        })
        
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error:NSError){
        println(error)
    }


}


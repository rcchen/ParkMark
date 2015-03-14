//
//  ParkViewController.swift
//  ParkMark
//
//  Created by Roger Chen on 3/13/15.
//  Copyright (c) 2015 Roger Chen. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class ParkViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!

    // MARK: - Variables
    
    var currentMarker: Marker?
    var lastLocation: CLLocation?
    var mapMarker: MapMarker?
    var routeOverlay: MKOverlay?
    
    // MARK: - Constants

    let CURRENT_STATUS_KEY = "ParkViewStatus"

    let defaults = NSUserDefaults.standardUserDefaults()
    let locationManager = CLLocationManager()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext

    // MARK: - Current statuses

    enum ParkViewStatus: Int {
        case Start = 1
        case Locate = 2
        case Finish = 3
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the location manager
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        // Set the action bar based on the current status
        setActionButtonStatus()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DirectionsSegue" || segue.identifier == "DirectDirectionsSegue" {
            let directionsController = segue.destinationViewController as DirectionsViewController
            directionsController.source = MKPlacemark(coordinate: mapMarker!.coordinate, addressDictionary: nil)
            directionsController.destination = MKPlacemark(coordinate: currentMarker!.coordinate, addressDictionary: nil)
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        // Check the text on the sender
        if let button = sender as? UIButton {
            if let label = button.titleLabel?.text {
                if label == "Find Car" || label == "Show Directions" {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - IBAction

    @IBAction func doneButton(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func respondToActionButton(sender: UIButton) {
        // Get the current status of the action button, and figure out what to do from there
        let status = defaults.integerForKey(CURRENT_STATUS_KEY)
        switch status {

        case ParkViewStatus.Start.rawValue:
            var marker = NSEntityDescription.insertNewObjectForEntityForName("Marker", inManagedObjectContext: managedObjectContext!) as Marker
            if let tempMarker = mapMarker {
                marker.latitude = tempMarker.coordinate.latitude
                marker.longitude = tempMarker.coordinate.longitude
            }
            currentMarker = marker
            defaults.setInteger(ParkViewStatus.Locate.rawValue, forKey: CURRENT_STATUS_KEY)

        case ParkViewStatus.Locate.rawValue:
            defaults.setInteger(ParkViewStatus.Finish.rawValue, forKey: CURRENT_STATUS_KEY)
        
        case ParkViewStatus.Finish.rawValue:
            defaults.setInteger(ParkViewStatus.Start.rawValue, forKey: CURRENT_STATUS_KEY)
            
        default: ()
        
        }
        setActionButtonStatus()
    }

    @IBAction func getCurrentLocation(sender: UIButton) {
        if (verifyLocationSettings() && lastLocation != nil) {
            let region = MKCoordinateRegionMakeWithDistance(lastLocation!.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
            if let marker = mapMarker {
                mapView.removeAnnotation(marker)
            }
            mapMarker = MapMarker(coordinate: lastLocation!.coordinate)
            mapView.addAnnotation(mapMarker)
        }
    }

    @IBAction func dragMap(sender: AnyObject) {
        println("draggginnn")
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        if let marker = mapMarker {
            mapView.removeAnnotation(marker)
        }
        mapMarker = MapMarker(coordinate: mapView.centerCoordinate)
        mapView.addAnnotation(mapMarker)
    }
    
    // MARK: - CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        lastLocation = newLocation
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Private methods

    private func roundLocateButton() {
        locateButton.layer.cornerRadius = 0.5 * locateButton.bounds.size.width
        locateButton.setImage(UIImage(named: "Locate"), forState: .Normal)
    }

    private func setActionButtonStatus() {
        var status = defaults.integerForKey(CURRENT_STATUS_KEY)
        if (status == 0) {
            defaults.setInteger(1, forKey: CURRENT_STATUS_KEY)
            status = 1
        }
        switch status {
            case ParkViewStatus.Start.rawValue:
                directionsButton.hidden = true
                actionButton.setTitle("Record Location", forState: UIControlState.Normal)
            case ParkViewStatus.Locate.rawValue:
                actionButton.setTitle("Find Car", forState: UIControlState.Normal)
            case ParkViewStatus.Finish.rawValue:
                directionsButton.hidden = false
                actionButton.setTitle("Finish", forState: UIControlState.Normal)
            default: ()
        }
    }

    private func verifyLocationSettings() -> Bool {
        switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                return true
            case .NotDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .Restricted, .Denied:
                let alertController = UIAlertController(
                    title: "Location Access Disabled",
                    message: "This app requires location services to be enabled. Please go to Settings and enable it now.",
                    preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let settingsAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                    if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                alertController.addAction(settingsAction)
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
        }
        return false
    }

    private func recordLocationData() {
        let marker = NSEntityDescription.insertNewObjectForEntityForName("Marker", inManagedObjectContext: self.managedObjectContext!) as Marker
        let coordinate = locationManager.location.coordinate
        marker.latitude = coordinate.latitude
        marker.longitude = coordinate.longitude
    }

}
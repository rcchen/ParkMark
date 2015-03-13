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

class ParkViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var actionButton: UIButton!

    // MARK: - Variables
    
    var currentAnnotation: MKAnnotation?

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

        if (verifyLocationSettings()) {
            let region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
        }
        
        // Set the action bar based on the current status
        setActionButtonStatus()
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        println(managedObjectContext)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    // MARK: - IBAction

    @IBAction func respondToActionButton(sender: UIButton) {
        if (verifyLocationSettings()) {
            
        } else {
            println("need to activate it")
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .Authorized {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        let region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 500, 500)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Private methods

    private func setActionButtonStatus() {
        var status = defaults.integerForKey(CURRENT_STATUS_KEY)
        if (status == 0) {
            defaults.setInteger(1, forKey: CURRENT_STATUS_KEY)
            status = 1
        }
        switch status {
            case ParkViewStatus.Start.rawValue:
                actionButton.setTitle("Record Location", forState: UIControlState.Normal)
            case ParkViewStatus.Locate.rawValue:
                actionButton.setTitle("Find Car", forState: UIControlState.Normal)
            case ParkViewStatus.Finish.rawValue:
                actionButton.setTitle("Finish", forState: UIControlState.Normal)
            default: ()
        }
    }

    private func verifyLocationSettings() -> Bool {
        switch CLLocationManager.authorizationStatus() {
            case .Authorized, .AuthorizedWhenInUse:
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
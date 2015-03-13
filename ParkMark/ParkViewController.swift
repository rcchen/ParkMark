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

    // MARK: - Variables
    
    var currentMarker: Marker?
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
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        // Set the action bar based on the current status
        setActionButtonStatus()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - IBAction

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
                if let current = currentMarker {
                    if let map = mapMarker {
                        let source = map.coordinate
                        let destination = current.coordinate
                        defaults.setInteger(ParkViewStatus.Finish.rawValue, forKey: CURRENT_STATUS_KEY)
                        let request = MKDirectionsRequest()
                        request.setSource(MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil)))
                        request.setDestination(MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil)))
                        let directions = MKDirections(request: request)
                        directions.calculateDirectionsWithCompletionHandler({(response: MKDirectionsResponse!, error: NSError!) in
                            if error != nil {
                                // Handle error here
                            } else {
                                for route in response.routes as [MKRoute] {
                                    self.routeOverlay = route.polyline
                                    self.mapView.addOverlay(self.routeOverlay, level: MKOverlayLevel.AboveRoads)
                                    for step in route.steps {
                                        println(step.instructions)
                                    }
                                }
                            }
                        })
                    }
                }
            case ParkViewStatus.Finish.rawValue:
                self.mapView.removeOverlay(self.routeOverlay)
                defaults.setInteger(ParkViewStatus.Start.rawValue, forKey: CURRENT_STATUS_KEY)
            default: ()
        }
        setActionButtonStatus()
    }

    @IBAction func getCurrentLocation(sender: UIButton) {
        if (verifyLocationSettings() && locationManager.location != nil) {
            let region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
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

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }
    
    // MARK: - CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            manager.startUpdatingLocation()
        }
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
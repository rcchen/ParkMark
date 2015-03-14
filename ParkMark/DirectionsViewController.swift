//
//  DirectionsViewController.swift
//  ParkMark
//
//  Created by Roger Chen on 3/13/15.
//  Copyright (c) 2015 Roger Chen. All rights reserved.
//

import MapKit
import UIKit

class DirectionsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Constants

    let locationManager = CLLocationManager()
    
    // MARK: - Variables

    var source: MKPlacemark!
    var destination: MKPlacemark!

    var steps = [MKRouteStep]()
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        self.mapView.showsUserLocation = true
        calculateRoute()
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 33/255.0, green: 150/255.0, blue: 243/255.0, alpha: 1.0)
        renderer.lineWidth = 7.0
        return renderer
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if (annotation .isMemberOfClass(MKUserLocation)) {
            return nil
        }
        
        let identifier = "Annotation"
        var annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier) as MKPinAnnotationView

        if (annotation.coordinate.latitude == source.coordinate.latitude &&
            annotation.coordinate.longitude == source.coordinate.longitude) {
            annotationView.pinColor = MKPinAnnotationColor.Red
        }

        if (annotation.coordinate.latitude == destination.coordinate.latitude &&
            annotation.coordinate.longitude == destination.coordinate.longitude) {
            annotationView.pinColor = MKPinAnnotationColor.Green
        }

        annotationView.animatesDrop = true
        return annotationView

    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.steps.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DirectionCell") as DirectionTableViewCell
        let step = self.steps[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row + 1). \(step.instructions)"
        return cell
    }

    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    // MARK: - Private functions

    private func calculateRoute() {
        
        // Set up the request for directions
        let request = MKDirectionsRequest()
        request.setSource(MKMapItem(placemark: source))
        request.setDestination(MKMapItem(placemark: destination))
        request.transportType = MKDirectionsTransportType.Walking
        
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler({(response: MKDirectionsResponse!, error: NSError!) in
            if error != nil {
                // Handle error here
            } else {
                for route in response.routes as [MKRoute] {
                    let insets = UIEdgeInsetsMake(60, 10, 20, 10)
                    self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: insets, animated: true)
                    for step in route.steps {
                        self.steps.append(step as MKRouteStep)
                    }
                    self.tableView.reloadData()

                    // Add annotated pins
                    self.mapView.addAnnotation(MapMarker(coordinate: self.source.coordinate))
                    self.mapView.addAnnotation(MapMarker(coordinate: self.destination.coordinate))
                }
            }
        })

    }

}

//
//  MapMarker.swift
//  ParkMark
//
//  Created by Roger Chen on 3/13/15.
//  Copyright (c) 2015 Roger Chen. All rights reserved.
//

import Foundation
import MapKit

class MapMarker: NSObject, MKAnnotation {
    var color: UIColor?
    var coordinate: CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D, color: UIColor? = UIColor.redColor()) {
        self.coordinate = coordinate
        self.color = color
    }
}
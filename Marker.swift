//
//  Marker.swift
//  ParkMark
//
//  Created by Roger Chen on 3/13/15.
//  Copyright (c) 2015 Roger Chen. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Marker: NSManagedObject, MKAnnotation {

    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var rating: NSNumber
    @NSManaged var notes: String
    @NSManaged var name: String
    @NSManaged var last_visited: NSDate

    

}

//
//  Destination.swift
//  HikeStride
//
//  Created by Janindu Dissanayake on 2024-06-07.
//

import Foundation
import CoreLocation

struct Destination: Identifiable {
    var id = UUID()
    var name: String
    var distance: String
    var location: String
    var coordinate: CLLocationCoordinate2D
}

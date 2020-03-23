//
//  Bins.swift
//  Bin Finder
//
//  Created by Antonio Baldi on 18/02/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import Foundation
import CoreLocation
public struct BinStruct {
    var type: String
    var latitude: CLLocationDegrees
    var longtitude: CLLocationDegrees
    var visible = true
}
public var bins = Array<BinStruct>()

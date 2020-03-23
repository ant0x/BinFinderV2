//
//  Bin.swift
//  Bin Finder
//
//  Created by Ciro Maione on 14/02/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import UIKit
import CoreLocation

class Bin: NSObject {

    let id: Int
    let latitude: Double
    let longitude: Double
    let waste: String
    
    init(id: Int, latitude: Double, longitude: Double, waste: String) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.waste = waste
    }
    
}

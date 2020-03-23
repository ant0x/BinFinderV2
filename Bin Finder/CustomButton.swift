//
//  CustomButton.swift
//  Bin Finder
//
//  Created by Antonio Baldi on 17/02/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

public class cButton: UIButton
{
    var annotation : MKAnnotation
    var coordinate: CLLocationCoordinate2D
    init(annotation:MKAnnotation,frame:CGRect) {
        self.coordinate = annotation.coordinate
        self.annotation = annotation
        super.init(frame: frame)

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


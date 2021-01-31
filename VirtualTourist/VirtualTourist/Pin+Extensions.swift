//
//  Pin+Extensions.swift
//  VirtualTourist
//
//  Created by Viktor Lund on 23.01.21.
//

import Foundation
import MapKit

extension Pin {
    
    
    
    func asCoordinate() -> CLLocationCoordinate2D {
        
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

import MapKit

class PinMapAnnotation: MKPointAnnotation {
    
    let pin: Pin
    
    init(pin: Pin) {
        self.pin = pin
        
        super.init()
        
        self.coordinate = pin.asCoordinate()
    }
}

// MARK - Gesture


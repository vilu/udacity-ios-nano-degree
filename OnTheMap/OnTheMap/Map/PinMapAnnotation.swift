import UIKit
import MapKit

class PinMapAnnotation: MKPointAnnotation {
    
    var mediaURL: String?
    
    init?(latitude: Double, longitude: Double, title: String, subtitle: String, mediaURL: String?) {
        guard latitude >= -90 && latitude <= 90 else {
            return nil
        }
        
        guard longitude >= -180 && longitude <= 180 else {
            return nil
        }
        
        
        super.init()
        
        self.coordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
        self.title = title
        self.subtitle = subtitle
        self.mediaURL = mediaURL
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, mediaURL: String?) {
        super.init()
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.mediaURL = mediaURL
    }
}

import UIKit
import MapKit

final class ConfirmLocationViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var confirmButton: UIButton!
    
    var location: String?
    var url: URL?
    var coordinate: CLLocationCoordinate2D?

    private var parseAPI: ParseAPIProtocol!
    
    override func viewDidLoad() {
        print("displayedAnnotations viewDidLoad")
        confirmButton.layer.cornerRadius = 5.0
        
        map.delegate = self
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        parseAPI = appDelegate.dependencies.parseAPI
        
        guard
            let location = location,
            let url = url,
            let coordinate = coordinate else {
            return
        }
        
        setLocation(location: location, url: url, coordinate: coordinate)
    }
    
    @IBAction func confirmButtonOnTouchUpInside(_ sender: UIButton) {
        
        let location = StudentLocation(
            id: <#T##String#>,
            uniqueKey: <#T##String?#>,
            firstName: <#T##String#>,
            lastName: <#T##String#>,
            mapString: <#T##String#>,
            mediaURL: <#T##String#>,
            latitude: <#T##Double#>,
            longitude: <#T##Double#>
        )
        
        parseAPI.postLocation(location: location) { result in
            
        }
        

    }
    
    private func setLocation(
        location: String,
        url: URL,
        coordinate: CLLocationCoordinate2D
    ) {
        let annotation = PinMapAnnotation(
            coordinate: coordinate,
            title: location,
            subtitle: url.absoluteString,
            mediaURL: url.absoluteString
        )
        map.addAnnotations([annotation])
    }
   
}

// MARK: - MKMapViewDelegate
extension ConfirmLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PinMapAnnotation else {
            return nil
        }
        
        let reuseId = Constants.Layout.Identifiers.pinReuseIdentifier
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        annotationView.canShowCallout = true
        annotationView.isSelected = true
        annotationView.annotation = annotation
        
        return annotationView
    }
    
}

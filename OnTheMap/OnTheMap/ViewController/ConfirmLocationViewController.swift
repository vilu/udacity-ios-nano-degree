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
        confirmButton.layer.cornerRadius = 5.0
        
        map.delegate = self
        
        guard
            let location = location,
            let url = url,
            let coordinate = coordinate else {
            return
        }
        
        setLocation(location: location, url: url, coordinate: coordinate)
    }
    
    @IBAction func confirmButtonOnTouchUpInside(_ sender: UIButton) {
        
        guard
            let uniqueKey = AppState.shared.accountKey,
            let firstName = AppState.shared.firstName,
            let lastName = AppState.shared.lastName,
            let location = location,
            let url = url,
            let coordinate = coordinate
        else {
            return
        }
        
        let studentInformation = CreateStudentInformation(
            uniqueKey: uniqueKey,
            firstName: firstName,
            lastName: lastName,
            mapString: location,
            mediaURL: url.absoluteString,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        AppDependencies.parseAPI.post(studentInformation: studentInformation) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.navigationController?.popToRootViewController(animated: true)
                case .failure(let error):
                    print("Failed to create location \(String(describing: error))")
                    let alert = UIAlertController.defaultAlert(
                        title: "Failed to create location",
                        message: "Please re-check the provided location and try again",
                        actionTitle: "OK")
                    self.present(alert, animated: true, completion: nil)
                }
            }
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
        map.selectAnnotation(annotation, animated: true)
    }
    
    @IBAction func cancelButtonOnTap(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
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

        annotationView.annotation = annotation
        annotationView.canShowCallout = true

        
        return annotationView
    }
    
}

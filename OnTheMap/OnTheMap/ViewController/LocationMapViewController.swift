import UIKit
import MapKit
import WebKit

final class LocationMapViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
        
    private var displayedAnnotations: [MKAnnotation]? {
        willSet {
            if let currentAnnotations = displayedAnnotations {
                map.removeAnnotations(currentAnnotations)
            }
        }
        didSet {
            if let newAnnotations = displayedAnnotations {
                map.addAnnotations(newAnnotations)
            }
        }
    }
    
    override func viewDidLoad() {
        map.delegate = self
        
        updateLocations()
    }
    
    @IBAction func logoutOnTap(_ sender: Any) {
        guard
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            let storyboard = storyboard
        else {
            return
        }
        
        AppDependencies.udacityAPI.signOut { _ in
            DispatchQueue.main.async {
                let vc = storyboard.instantiateViewController(identifier: Constants.Layout.Identifiers.signInViewController)
                
                sceneDelegate.window?.rootViewController = vc
            }
        }
    }
    
    @IBAction func refreshOnTap(_ sender: Any) {
        fetchLocations()
    }
    
    @IBAction func addLocationOnTap(_ sender: Any) {
        guard let storyboard = storyboard, let navigationController = navigationController else {
            return
        }
        
        let addLocationVC = storyboard.instantiateViewController(identifier: Constants.Layout.Identifiers.addLocationViewController)
        navigationController.pushViewController(addLocationVC,
                                                animated: true)
    }
    
    private func fetchLocations() {
        updateLocations()
    }
    
    private func updateLocations() {
        AppDependencies.parseAPI.fetchLocations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    self.displayedAnnotations = locations.map { location in
                        PinMapAnnotation(
                            latitude: location.latitude,
                            longitude: location.longitude,
                            title: "\(location.firstName) \(location.lastName)",
                            subtitle: location.mediaURL,
                            mediaURL: location.mediaURL
                        )
                    }.compactMap { $0 }
                    
                case .failure(let error):
                    print("Parse API Error: \(String(describing: error))")
                    let alert = UIAlertController.defaultAlert(
                        title: "Failed to retrieve student locations",
                        message: "Please retry in the upper right corner",
                        actionTitle: "OK")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}


// MARK: - MKMapViewDelegate
extension LocationMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PinMapAnnotation else {
            return nil
        }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.Layout.Identifiers.pinReuseIdentifier) ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.Layout.Identifiers.pinReuseIdentifier)
        
        annotationView.canShowCallout = true
        annotationView.annotation = annotation
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView
    }
    
    func mapView(_ _mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard
            let annotation = view.annotation as? PinMapAnnotation,
            let url = annotation.mediaURL
        else {
            return
        }
        
        attemptOpenWithAlertFallback(url: url)
    }
    
}

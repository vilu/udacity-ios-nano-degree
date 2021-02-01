import UIKit
import MapKit
import CoreData

final class TravelLocationsViewController: UIViewController {
    
    private let map = MKMapView()
    
    let mapRegionRepository: UserDefaultsMapRegionRepository
    let flickerApi: FlickerApi
    let persistentContainer: PersistentContainer
    
    init(
        mapRegionRepository: UserDefaultsMapRegionRepository,
        flickerApi: FlickerApi,
        persistentContainer: PersistentContainer
    ) {
        self.mapRegionRepository = mapRegionRepository
        self.flickerApi = flickerApi
        self.persistentContainer = persistentContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(map)
        
        map.delegate = self
        
        mapRegionRepository.get { result in
            switch result {
            case .success(let existingMapRegion):
                if let existingMapRegion = existingMapRegion {
                    self.map.setRegion(MKCoordinateRegion(
                        center: CLLocationCoordinate2DMake(existingMapRegion.center.latitude, existingMapRegion.center.longitude),
                        span: MKCoordinateSpan(
                            latitudeDelta: existingMapRegion.span.latitudeDelta,
                            longitudeDelta: existingMapRegion.span.longitudeDelta
                        )
                    ), animated: true)
                }
                
            case .failure(let error):
                Log.info("Failed to fetch previous map region configuration: \(error)")
            }
        }
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            let pins = try persistentContainer.viewContext.fetch(fetchRequest)
            for pin in pins {
                map.addAnnotation(PinMapAnnotation(pin: pin))
            }
        } catch {
            Log.info("Failed to fetch pins from core data: \(error)")
        }
        
        map.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])

        map.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longTapped)))
    }
    
    @objc
    private func longTapped(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {
            return
        }

        let coordinate = map.convert(sender.location(in: map), toCoordinateFrom: map)
        
        Log.info("Created pin with \(coordinate)")
        
        let pin = Pin(context: persistentContainer.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        
        let annotation = PinMapAnnotation(pin: pin)

        map.addAnnotation(annotation)
        
        persistentContainer.saveContext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setToolbarHidden(true, animated: false)
    }
}

// MARK: - MKMapViewDelegate

extension TravelLocationsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapRegionRepository.save(mapRegion: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? PinMapAnnotation else {
            return nil
        }
        
        let reuseId = Constants.Layout.Identifiers.pinReuseIdentifier
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? PinAnnotationView ?? PinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        annotationView.onTapCallback = { pin in
            guard let navigationController = self.navigationController else {
                return
            }
            
            let photoAlbumViewController = PhotoAlbumViewController(
                pin: pin,
                persistentContainer: self.persistentContainer,
                flickerApi: self.flickerApi
            )
            
            navigationController.pushViewController(photoAlbumViewController, animated: true)
        }
        
        annotationView.annotation = annotation
        
        return annotationView
    }
}


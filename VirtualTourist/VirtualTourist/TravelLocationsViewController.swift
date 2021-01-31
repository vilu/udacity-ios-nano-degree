import UIKit
import MapKit

final class TravelLocationsViewController: UIViewController {
    
    private let map = MKMapView()
    
    let mapRegionRepository: MapRegionRepositoryProtocol
    let pinRepository: PinRepositoryProtocol
    let flickerApi: FlickerApi
    let persistentContainer: PersistentContainer
    
    init(
        mapRegionRepository: MapRegionRepositoryProtocol,
        pinRepository: PinRepositoryProtocol,
        flickerApi: FlickerApi,
        persistentContainer: PersistentContainer
    ) {
        self.mapRegionRepository = mapRegionRepository
        self.pinRepository = pinRepository
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
                    map.setRegion(MKCoordinateRegion(
                        center: CLLocationCoordinate2DMake(existingMapRegion.center.latitude, existingMapRegion.center.longitude),
                        span: MKCoordinateSpan(
                            latitudeDelta: existingMapRegion.span.latitudeDelta,
                            longitudeDelta: existingMapRegion.span.longitudeDelta
                        )
                    ), animated: true)
                }
                
                
                
            case .failure(let error):
                // TODO handle error
                Log.info("## error: \(error)")
            }
        }
        
        pinRepository.get { result in
            switch result {
            case .success(let pins):
                for pin in pins {
                    map.addAnnotation(PinMapAnnotation(pin: pin))
                }
            case .failure(let error):
                // TODO handle error
                Log.info("## error: \(error)")
            }
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
        
        Log.info("Create pin with \(coordinate)")
        
        let pin = Pin(context: persistentContainer.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        
        let annotation = PinMapAnnotation(pin: pin)

        map.addAnnotation(annotation)
        
        persistentContainer.saveContext()
        
        Log.info("Was long tapped at \(sender.location(in: map))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: true)
//    }
    
    
}

// MARK: - MKMapViewDelegate

extension TravelLocationsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        mapRegionRepository.save(mapRegion: mapView.region) { result in
            Log.info("save result: \(String(describing: result))")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? PinMapAnnotation else {
            return nil
        }
        
        let reuseId = Constants.Layout.Identifiers.pinReuseIdentifier
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? PinAnnotationView ?? PinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        annotationView.onTapCallback = { pin in
            guard let navigationController = self.navigationController else { return }
            
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

final class PinAnnotationView: MKPinAnnotationView {
    
    var onTapCallback: ((Pin) -> Void)?
    
    init(
        annotation: PinMapAnnotation,
        reuseIdentifier: String
    ) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func onTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            guard
                let onTapCallback = onTapCallback,
                let annotation = annotation as? PinMapAnnotation else {
                return
            }
            onTapCallback(annotation.pin)
        }
    }
    
    
}

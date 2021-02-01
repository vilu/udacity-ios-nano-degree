import UIKit
import MapKit
import Network

final class PhotoAlbumViewController: UIViewController {
    
    private var stackView: UIStackView!
    private var album: UICollectionView!
    private var setPhotosFromFlickerToolbarButton: UIBarButtonItem!
    private var noImagesFoundView: UIView!
    private let flickerApi: FlickerApi
    private let persistentContainer: PersistentContainer
    private let pin: Pin
    private let downloader = AsyncDownloader()
    
    private var photos: [Photo] = []
    
    init(
        pin: Pin,
        persistentContainer: PersistentContainer,
        flickerApi: FlickerApi
    ) {
        self.pin = pin
        self.persistentContainer = persistentContainer
        self.flickerApi = flickerApi
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setPhotosFromFlickerToolbarButton = UIBarButtonItem(title: "New album", style: .plain, target: self, action: #selector(didTapNewAlbumButton))
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            setPhotosFromFlickerToolbarButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        ]
        
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let map = MKMapView()
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let center = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        map.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
        map.addAnnotation(PinMapAnnotation(pin: pin))
        map.delegate = self
        
        album = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width), collectionViewLayout: layout())
        album.delegate = self
        album.dataSource = self
        album.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseId)
        album.backgroundColor = .white
        
        if let pinPhotos = pin.relationship?.allObjects.compactMap({ $0 as? Photo}), !pinPhotos.isEmpty {
            photos = pinPhotos.sorted()
            album.reloadData()
        } else {
            setPhotosFromFlickr()
        }
        
        view.addSubview(stackView)
        
        noImagesFoundView = UIView()
        noImagesFoundView.backgroundColor = .white
        noImagesFoundView.isHidden = true
        let noImagesFoundLabel = UILabel()
        noImagesFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        noImagesFoundLabel.text = "No images found"
        noImagesFoundView.addSubview(noImagesFoundLabel)
        view.addSubview(noImagesFoundView)
        
        
        stackView.addArrangedSubview(map)
        stackView.addArrangedSubview(album)
        stackView.addArrangedSubview(noImagesFoundView)
        
        NSLayoutConstraint.activate([
            map.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.33),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            noImagesFoundLabel.centerXAnchor.constraint(equalTo: noImagesFoundView.centerXAnchor),
            noImagesFoundLabel.centerYAnchor.constraint(equalTo: noImagesFoundView.centerYAnchor)
        ])
    }
    
    @objc private func didTapNewAlbumButton(_ sender: UIBarButtonItem) {
        setPhotosFromFlickr()
    }
    
    private func setPhotosFromFlickr() {
        setPhotosFromFlickerToolbarButton.isEnabled = false
        flickerApi.getPhotos(latitude: pin.latitude, longitude: pin.longitude) { result in
            switch result {
            case .success(let flickrPhotos):
                DispatchQueue.main.async {
                    self.noImagesFoundView.isHidden = !flickrPhotos.isEmpty
                    self.album.isHidden = flickrPhotos.isEmpty
                    self.setPhotosFromFlickerToolbarButton.isEnabled = true
                    if let oldPhotos = self.pin.relationship {
                        self.pin.removeFromRelationship(oldPhotos)
                    }
                    self.photos = flickrPhotos.map { flickrPhoto in
                        let photo = Photo(context: self.persistentContainer.viewContext)
                        photo.name = flickrPhoto.title
                        photo.url = flickrPhoto.url_q
                        photo.data = nil
                        self.pin.addToRelationship(photo)
                        return photo
                    }.sorted()
                    
                    self.persistentContainer.saveContext()
                    
                    self.album.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.setPhotosFromFlickerToolbarButton.isEnabled = true
                    Log.info("Failed to fetch photos \(error)")
                }
                
            }
            
        }
    }
    
    private func layout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3333333333333),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.3333333333333))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.setToolbarHidden(false, animated: false)
    }
}

final class Cell: UICollectionViewCell {
    static let colors = [UIColor.red,UIColor.green,UIColor.blue]
    static let reuseId = "cell-reuse-id"
    
    var downloader: AsyncDownloader!
    
    private let imageView: UIImageView = {
        let imgView = UIImageView()
        
        imgView.contentMode = .scaleAspectFill

        imgView.layer.borderWidth = 2
        imgView.layer.borderColor = UIColor.white.cgColor
        
        return imgView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let actInd = UIActivityIndicatorView()
        actInd.startAnimating()
        return actInd
    }()
    
    var photo: Photo? {
        willSet {
            if let photo = newValue {
                if let data = photo.data {
                    imageView.image = UIImage(data: data)
                    imageView.isHidden = false
                    activityIndicator.isHidden = true
                } else if let urlStr = photo.url, let url = URL(string: urlStr) {
                    downloader.download(url: url) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let data):
                                self.imageView.image = UIImage(data: data)
                                self.imageView.isHidden = false
                                self.activityIndicator.isHidden = true
                            case .failure(let error):
                                Log.info("Image download failed with: \(error)")
                            }
                        }
                    }
                } else {
                    Log.info("Unexpected photo value: \(String(describing: newValue))")
                }
            } else {
                imageView.isHidden = true
                activityIndicator.isHidden = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.isHidden = true
        activityIndicator.isHidden = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseId, for: indexPath) as! Cell
        cell.downloader = downloader
        
        let photo = photos[indexPath.row]
        cell.photo = photo
        
        return cell
    }
}

// MARK: - MKMapViewDelegate

extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ view: UICollectionView, didSelectItemAt: IndexPath) {
        let selectedPhoto = photos.remove(at: didSelectItemAt.row)
        
        
        pin.removeFromRelationship(selectedPhoto)
        
        self.persistentContainer.saveContext()
        
        self.album.reloadData()
    }
}

// MARK: - MKMapViewDelegate

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? PinMapAnnotation else {
            return nil
        }
        
        let reuseId = Constants.Layout.Identifiers.pinReuseIdentifier
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? PinAnnotationView ?? PinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        annotationView.annotation = annotation
        
        return annotationView
    }
}




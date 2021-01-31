import MapKit

enum MapRegionRepositoryError: Error {
    case generalError
}


protocol MapRegionRepositoryProtocol {
    
    func save(mapRegion: MKCoordinateRegion, completion: ((Result<Void, MapRegionRepositoryError>) -> Void))
    
    func get(completion: ((Result<MKCoordinateRegion?, MapRegionRepositoryError>) -> Void))
    
}

final class UserDefaultsRegionRepository: MapRegionRepositoryProtocol {
    
    private static let userDefaultsKey = "user-map-region"
    
    private let encoder: PropertyListEncoder = PropertyListEncoder()
    private let decoder: PropertyListDecoder = PropertyListDecoder()
    
    private struct MapRegion: Codable, CustomStringConvertible {
        var latitude: Double
        var latitudeDelta: Double
        var longitude: Double
        var longitudeDelta: Double
        
        init(from region: MKCoordinateRegion) {
            self.latitude = region.center.latitude
            self.latitudeDelta = region.span.latitudeDelta
            self.longitude = region.center.longitude
            self.longitudeDelta = region.span.longitudeDelta
        }
        
        var description: String {
            return """
                MapRegion(
                    latitude: \(latitude),
                    latitudeDelta: \(latitudeDelta),
                    longitude: \(longitude),
                    longitudeDelta: \(longitudeDelta)
                )
                """
        }
        
        func asMKCoordinateRegion() -> MKCoordinateRegion {
            MKCoordinateRegion(
                center: CLLocationCoordinate2DMake(self.latitude, self.longitude),
                span: MKCoordinateSpan(
                    latitudeDelta: self.latitudeDelta,
                    longitudeDelta: self.longitudeDelta
                )
            )
        }
    }
    
    func save(mapRegion: MKCoordinateRegion, completion: ((Result<Void, MapRegionRepositoryError>) -> Void)) {
        do {
            let data = try encoder.encode(MapRegion(from: mapRegion))
            UserDefaults.standard.set(data, forKey: UserDefaultsRegionRepository.userDefaultsKey)
            Log.info("Saved region \(String(describing: MapRegion(from: mapRegion)))")
        } catch {
            Log.info("Could not persist map region: \(error)")
            completion(.failure(.generalError))
        }
    }
    
    func get(completion: ((Result<MKCoordinateRegion?, MapRegionRepositoryError>) -> Void)) {
        if
            let data = UserDefaults.standard.data(forKey: UserDefaultsRegionRepository.userDefaultsKey),
            let region = try? decoder.decode(MapRegion.self, from: data) {
            Log.info("Fetched region \(String(describing: region))")
            return completion(.success(region.asMKCoordinateRegion()))
        }
        Log.info("Failed to fetch")
        return completion(.success(nil))
    }
}

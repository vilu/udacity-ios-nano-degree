import MapKit

enum MapRegionRepositoryError: Error {
    case generalError
}

final class UserDefaultsMapRegionRepository {
    
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
    
    func save(mapRegion: MKCoordinateRegion) {
        DispatchQueue.global().async {
            do {
                let data = try self.encoder.encode(MapRegion(from: mapRegion))
                UserDefaults.standard.set(data, forKey: UserDefaultsMapRegionRepository.userDefaultsKey)
                Log.info("Persisted map region")
            } catch {
                Log.info("Failed to persist map region: \(error)")
            }
        }
    }
    
    func get(completion: @escaping ((Result<MKCoordinateRegion?, MapRegionRepositoryError>) -> Void)) {
        DispatchQueue.global().async {
            if
                let data = UserDefaults.standard.data(forKey: UserDefaultsMapRegionRepository.userDefaultsKey),
                let region = try? self.decoder.decode(MapRegion.self, from: data) {
                Log.info("Fetched map region \(String(describing: region))")
                return completion(.success(region.asMKCoordinateRegion()))
            }
            Log.info("Failed to fetch map region")
            return completion(.success(nil))
        }
    }
}

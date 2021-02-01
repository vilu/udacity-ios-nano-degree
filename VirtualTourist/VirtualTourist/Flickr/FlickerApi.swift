import Network
import Foundation

enum FlickrApiError: Error {
    case defaultError
}

final class FlickerApi {
    
    private static let flickrApiKey = "833f590f632db4f964c517d4395cf00b"
    
    private let jsonDecoder = JSONDecoder()
    
    struct PhotoResponse: Codable {
        
        struct Photos: Codable {
            struct Photo: Codable {
                var id: String
                var title: String
                var url_q: String
                var height_q: Int
                var width_q: Int
            }
            var photo: [Photo]
        }
        
        var photos: Photos
        
    }
    
    func getPhotos(latitude: Double, longitude: Double, complete: @escaping (Result<[PhotoResponse.Photos.Photo], FlickrApiError>) -> Void) {
        guard let url = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FlickerApi.flickrApiKey)&lat=\(latitude)&lon=\(longitude)&extras=url_sq,url_t,url_s,url_q,url_m,url_n,url_z,url_c,url_l,url_o&format=json&nojsoncallback=1&per_page=20") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard error == nil else {
                Log.info("""
                        Flickr search call failed
                        error: \(String(describing: error?.localizedDescription))
                    """)
                return complete(.failure(.defaultError))
            }
            
            guard
                let httpResponse = (response as? HTTPURLResponse),
                httpResponse.statusCode == 200
            else {
                Log.info("""
                    Unexpected Flickr search response
                    response: \(String(describing: response))
                """)
                
                return complete(.failure(.defaultError))
            }
            
            let photoResponse = data.flatMap { try? self.jsonDecoder.decode(PhotoResponse.self, from: $0) }
            
            guard
                let payload = photoResponse
            else {
                Log.info("""
                    Invalid Flickr search response data
                    response: \(data.flatMap { String(data: $0, encoding: .utf8) } ?? "<MISSING PAYLOAD>" )
                """)
                
                return complete(.failure(.defaultError))
            }
            
            complete(.success(payload.photos.photo))
        })
        task.resume()
    }
}

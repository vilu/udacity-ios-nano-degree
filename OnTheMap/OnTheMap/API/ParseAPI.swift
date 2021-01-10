import Foundation

enum ParseAPIError: Error {
    case generalError
}

protocol ParseAPIProtocol {
    func fetchLocations(callback: @escaping (Result<[StudentInformation], ParseAPIError>) -> Void)
    
    func post(studentInformation: CreateStudentInformation, callback: @escaping (Result<StudentInformation, ParseAPIError>) -> Void)
}

final class ParseAPI: ParseAPIProtocol {
    private let jsonHttpClient: HttpClientProtocol = JsonHttpClient()
    
    private let apiBasePath: String = "https://onthemap-api.udacity.com/v1"
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            let iso8601DateFormatter = ISO8601DateFormatter()
            iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return iso8601DateFormatter.date(from: dateStr)!
        }
        return decoder
    }()
    
    func fetchLocations(callback: @escaping (Result<[StudentInformation], ParseAPIError>) -> Void) {
        guard let url = URL(string: "\(apiBasePath)/StudentLocation?limit=100&order=-updatedAt") else {
            callback(Result.failure(.generalError))
            return
        }
        
        jsonHttpClient.get(url: url, headers: []) { (result: Result<LocationResponse?, HTTPError<ParseAPIErrorResponse>>) in
            switch result {
            case .success(let response):
                guard let response = response else {
                    callback(.failure(.generalError))
                    return
                }
                
                let locations = response.results.map { location in
                    StudentInformation(
                        id: location.objectId,
                        uniqueKey: location.uniqueKey,
                        firstName: location.firstName,
                        lastName: location.lastName,
                        mapString: location.mapString,
                        mediaURL: location.mediaURL,
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                }
                callback(.success(locations))
            case .failure:
                callback(.failure(.generalError))
            }
        }
    }
    
    func post(studentInformation: CreateStudentInformation, callback: @escaping (Result<StudentInformation, ParseAPIError>) -> Void) {
        guard let url = URL(string: "\(apiBasePath)/StudentLocation") else {
            callback(Result.failure(.generalError))
            return
        }
        
        let request = CreateLocationRequest(
            firstName: studentInformation.firstName,
            lastName: studentInformation.lastName,
            latitude: studentInformation.latitude,
            longitude: studentInformation.longitude,
            mapString: studentInformation.mapString,
            mediaURL: studentInformation.mediaURL,
            uniqueKey: studentInformation.uniqueKey)
        
        jsonHttpClient.post(url: url, body: request, headers: []) { (result: Result<CreateLocationResponse?, HTTPError<ParseAPIErrorResponse>>) in
            switch result {
            case .success(let response):
                guard let response = response else {
                    callback(.failure(.generalError))
                    return
                }
                
                callback(
                    .success(
                        StudentInformation(
                            id: response.objectId,
                            uniqueKey: studentInformation.uniqueKey,
                            firstName: studentInformation.firstName,
                            lastName: studentInformation.lastName,
                            mapString: studentInformation.mapString,
                            mediaURL: studentInformation.mediaURL,
                            latitude: studentInformation.latitude,
                            longitude: studentInformation.longitude
                        )
                    )
                )
            case .failure:
                callback(.failure(.generalError))
            }
        }
    }
}

// MARK: - DTOs
extension ParseAPI {
    struct ParseAPIErrorResponse: Codable, Error {
        var status: Int?
        var error: String?
    }
    
    struct LocationResponse: Codable {
        struct Location: Codable {
            var createdAt: Date
            var firstName: String
            var lastName: String
            var latitude: Double
            var longitude: Double
            var mapString: String
            var mediaURL: String
            var objectId: String
            var uniqueKey: String
            var updatedAt: Date
        }
        
        var results: [Location]
    }
    
    struct CreateLocationRequest: Codable {
        var firstName: String
        var lastName: String
        var latitude: Double
        var longitude: Double
        var mapString: String
        var mediaURL: String
        var uniqueKey: String
    }
    
    struct CreateLocationResponse: Codable {
        var objectId: String
        var createdAt: Date
    }
}

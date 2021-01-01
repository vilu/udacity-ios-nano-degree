import Foundation

// MARK: TODO Organize domain classes correctly

class AppState {
    var session: Session?
}

class AppDependencies {
    var udacityAPI: UdacityAPIProtocol
    var parseAPI: ParseAPIProtocol
    
    init(
        udacityAPI: UdacityAPIProtocol,
        parseAPI: ParseAPIProtocol
    ) {
        self.udacityAPI = udacityAPI
        self.parseAPI = parseAPI
    }
}

struct Session {
    var id: String
    var expiration: Date
}

struct StudentInformation {
    
}

struct StudentLocation {
    var id: String
    var uniqueKey: String?
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
}

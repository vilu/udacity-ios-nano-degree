import Foundation

class AppState {
    static var shared: AppState = AppState()
    
    var session: Session?
    var accountKey: String?
    var user: User?
    var studentInformations: [StudentInformation] = []
}

struct AppDependencies {
    static let udacityAPI: UdacityAPIProtocol = UdacityAPI()
    static let parseAPI: ParseAPIProtocol = ParseAPI()
}

struct Session {
    var id: String
    var expiration: Date
}

struct User {
    var firstName: String
    var lastName: String
}

struct StudentInformation {
    var id: String
    var uniqueKey: String?
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
}

struct CreateStudentInformation {
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
}

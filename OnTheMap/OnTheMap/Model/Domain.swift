import Foundation

class AppState {
    static var shared: AppState = AppState(firstName: "Ignatius", lastName: "J. Reilly")
    
    var session: Session?
    var accountKey: String?
    var firstName: String?
    var lastName: String?
    var studentInformations: [StudentInformation]?
    
    init(firstName: String, lastName:String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}

struct AppDependencies {
    static let udacityAPI: UdacityAPIProtocol = UdacityAPI()
    static let parseAPI: ParseAPIProtocol = ParseAPI()
}

struct Session {
    var id: String
    var expiration: Date
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

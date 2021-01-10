import Foundation

enum UdacityAPIError: Error {
    case generalError
    case authenticationError
}

protocol UdacityAPIProtocol {
    func signIn(email: String, password:String, callback: @escaping (Result<(session: Session, accountKey: String), UdacityAPIError>) -> Void)
    
    func signOut(callback: @escaping (Result<Void, UdacityAPIError>) -> Void)
}

final class UdacityAPI: UdacityAPIProtocol {
    private let jsonHttpClient: HttpClientProtocol = JsonHttpClient(preProcessData: { data in
        let range = 5..<data.count
        return data.subdata(in: range)
    })
    
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
    
    func signIn(email: String, password: String, callback: @escaping (Result<(session: Session, accountKey: String), UdacityAPIError>) -> Void) {
        guard let url = URL(string: "\(apiBasePath)/session") else {
            callback(Result.failure(.generalError))
            return
        }
        
        let payload = SignInRequest(
            username: email,
            password: password
        )
        
        jsonHttpClient.post(url: url, body: payload, headers: []) { (result: Result<SignInResponse?, HTTPError<UdacityAPIErrorResponse>>) in
            switch result {
            case .success(let response):
                guard let response = response else {
                    callback(.failure(.generalError))
                    return
                }
                callback(
                    .success(
                        (
                            accountKey: response.account.key,
                            session: Session(
                                id: response.session.id,
                                expiration: response.session.expiration
                            )
                        )
                    )
                )
            case .failure(let error):
                switch error {
                case .serverError(403, _):
                    callback(.failure(.authenticationError))
                default:
                    callback(.failure(.generalError))
                }
            }
        }
    }
    
    func signOut(callback: @escaping (Result<Void, UdacityAPIError>) -> Void) {
        guard let url = URL(string: "\(apiBasePath)/session") else {
            callback(Result.failure(.generalError))
            return
        }
        
        guard let xsrfToken = (HTTPCookieStorage.shared.cookies ?? []).first(where: { $0.name == "XSRF-TOKEN" }) else {
            callback(.success(()))
            return
        }
        
        let xsrfCookie = (key: xsrfToken.name, value: xsrfToken.value)
        
        jsonHttpClient.delete(url: url, body: nil as JsonHttpClient.Nothing?, headers: [xsrfCookie]) { (result: Result<JsonHttpClient.Nothing?, HTTPError<UdacityAPIErrorResponse>>) in
            switch result {
            case .success:
                callback(
                    .success(())
                )
            case .failure(let error):
                switch error {
                case .serverError(403, _):
                    callback(.failure(.authenticationError))
                default:
                    callback(.failure(.generalError))
                }
            }
        }
    }
}

// MARK: - DTOs
extension UdacityAPI {
    struct UdacityAPIErrorResponse: Codable, Error {
        var status: Int?
        var error: String?
    }
    
    struct SignInRequest: Codable {
        struct SignInRequestBody: Codable {
            var username: String
            var password: String
        }
        
        var udacity: SignInRequestBody
        init(username: String, password: String) {
            self.udacity = SignInRequestBody(username: username, password: password)
        }
    }
    
    struct SignInResponse: Codable {
        struct Account: Codable {
            var registered: Bool
            var key: String
        }
        
        struct Session: Codable {
            var id: String
            var expiration: Date
        }
        var account: Account
        var session: Session
    }
}

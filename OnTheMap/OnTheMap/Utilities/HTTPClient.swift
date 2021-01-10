import Foundation

enum HTTPError<ServerError: Decodable>:Error {
    case generalError
    case serverError(statusCode: Int, error: ServerError?)
}

protocol HttpClientProtocol {
    func get<Response: Decodable, ServerError: Decodable>(url: URL, headers: [(key: String, value: String)], callback: @escaping (Result<Response?, HTTPError<ServerError>>) -> Void)
    
    func post<Request: Encodable,  Response: Decodable, ServerError: Decodable>(url: URL, body: Request?, headers: [(key: String, value: String)], callback: @escaping (Result<Response?, HTTPError<ServerError>>) -> Void)
    
    func delete<Request: Encodable,  Response: Decodable, ServerError: Decodable>(url: URL, body: Request?, headers: [(key: String, value: String)], callback: @escaping (Result<Response?, HTTPError<ServerError>>) -> Void)
}

final class JsonHttpClient:HttpClientProtocol {
    
    struct Nothing: Codable {}
    
    private let preProcessData: ((Data) -> Data)?
    
    init(preProcessData: ((Data) -> Data)? = nil) {
        self.preProcessData = preProcessData
    }
    
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
    
    private func baseRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func send<Request: Encodable,  Response: Decodable, ServerError: Decodable>(
        url: URL,
        method: String,
        body: Request?,
        headers: [(key: String, value: String)],
        callback: @escaping (Result<Response?, HTTPError<ServerError>>) -> Void
    ) {
        do {
            var request = baseRequest(url: url, method: method)
            
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
            
            let jsonPayload = try body.map { try JSONEncoder().encode($0) }
            request.httpBody = jsonPayload
            let session = URLSession.shared
            session.dataTask(with: request) { data, response, error in
                do {
                    let response = response as! HTTPURLResponse

                    let responseData: Data?
                    if let preProcessData = self.preProcessData, let data = data {
                        responseData = preProcessData(data)
                    } else {
                        responseData = data
                    }
                    
                    // Handle successful response
                    if (200...399).contains(response.statusCode) {
                        let response = try responseData.flatMap { d in
                            return try self.jsonDecoder.decode(Response.self, from: d)
                        }
                        
                        callback(.success(response))
                    } else {
                        // Handle error response
                        let error = responseData.flatMap { d in
                            return try? JSONDecoder().decode(ServerError.self, from: d)
                        }
                        callback(
                            .failure(
                                .serverError(statusCode: response.statusCode, error: error)
                            )
                        )
                    }
                } catch {
                    print("Http response processing error: \(String(describing: error))")
                    callback(.failure(.generalError))
                }
            }.resume()
        } catch {
            print("Http request creation error: \(String(describing: error))")
            callback(.failure(.generalError))
        }
    }
    
    func get<Response: Decodable, ServerError: Decodable>(
        url: URL,
        headers: [(key: String, value: String)] = [],
        callback: @escaping (Result<Response?, HTTPError<ServerError>>) -> Void) {
        send(
            url: url,
            method: "GET",
            body: nil as Nothing?,
            headers: headers,
            callback: callback
        )
    }
    
    func post<Request: Encodable, Response: Decodable, ServerError: Decodable>(
        url: URL,
        body: Request?,
        headers: [(key: String, value: String)],
        callback: @escaping (Result<Response?, HTTPError<ServerError>>) -> Void)  {
        send(url: url, method: "POST", body: body, headers: headers, callback: callback)
    }
    
    func delete<Request: Encodable, Response: Decodable, ServerError: Decodable>(
        url: URL,
        body: Request?,
        headers: [(key: String, value: String)],
        callback: @escaping (Result<Response?, HTTPError<ServerError>>) -> Void)  {
        send(url: url, method: "DELETE", body: body, headers: headers, callback: callback)
    }
}

import Foundation
import Network

enum AsyncDownloaderError: Error {
    case defaultError
}

final class AsyncDownloader {
    func download(url: URL, completion: @escaping (Result<Data, AsyncDownloaderError>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url) else {
                return completion(.failure(.defaultError))
            }
            
            return completion(.success(data))
        }
    }
}

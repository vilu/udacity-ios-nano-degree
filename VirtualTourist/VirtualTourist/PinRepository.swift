import CoreData

enum PinRepositoryError: Error {
    case generalError
}

protocol PinRepositoryProtocol {
    
    func get(complete: (Result<[Pin], PinRepositoryError>) -> Void)
    
}

final class PinRepository: PinRepositoryProtocol {
    
    private let persistentContainer: PersistentContainer
    
    init(persistentContainer: PersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    
    func get(complete: (Result<[Pin], PinRepositoryError>) -> Void) {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            // TODO should I specify the thread here?
            let pins = try persistentContainer.viewContext.fetch(fetchRequest)
            complete(.success(pins))
        } catch {
            assertionFailure("Oops \(error)")
            complete(.failure(.generalError))
        }
    }
    
}

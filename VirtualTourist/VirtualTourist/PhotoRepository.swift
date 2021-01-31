import CoreData


protocol PhotoRepositoryProtocol {
    
    func new(pin: Pin, imageURL: String) -> Photo
    
    func get() -> [Photo]
    
    func save()
    
}

final class PhotoRepository: PhotoRepositoryProtocol {
    
    private let persistentContainer: PersistentContainer
    
    init(persistentContainer: PersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func new(pin: Pin, imageURL: String) -> Photo {
        let photo = Photo(context: persistentContainer.viewContext)
        photo.relationship = pin
        photo.url = imageURL
        return photo
    }
    
    
    func get() -> [Photo] {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        do {
            // TODO should I specify the thread here?
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            assertionFailure("Oops \(error)")
        }
        return []
    }
    
    func save() {
        persistentContainer.saveContext()
    }
    
}

import Foundation

extension Photo: Comparable {
    public static func < (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.name ?? "" < rhs.name ?? ""
    }
    
    
}

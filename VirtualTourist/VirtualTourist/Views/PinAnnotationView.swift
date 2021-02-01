import Foundation
import MapKit

final class PinAnnotationView: MKPinAnnotationView {
    
    var onTapCallback: ((Pin) -> Void)?
    
    init(
        annotation: PinMapAnnotation,
        reuseIdentifier: String
    ) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func onTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            guard
                let onTapCallback = onTapCallback,
                let annotation = annotation as? PinMapAnnotation else {
                return
            }
            onTapCallback(annotation.pin)
        }
    }
}

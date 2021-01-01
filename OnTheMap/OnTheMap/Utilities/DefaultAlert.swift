import UIKit

extension UIAlertController {
    
    static func defaultAlert(
        title: String,
        message: String,
        actionTitle: String = "OK",
        action: ((UIAlertAction) -> Void)? = nil
    ) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(
                title: actionTitle,
                style: .default,
                handler: { alertAction in
                    action?(alertAction)
                    alertController.dismiss(animated: true, completion: nil)
                }
            )
        )
        
        return alertController
    }
}

import UIKit

extension UIViewController {
    func attemptOpenWithAlertFallback(url urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            let alert = UIAlertController.defaultAlert(
                title: "Could not open link",
                message: "Invalid URL",
                actionTitle: "Dismiss")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        UIApplication.shared.open(url)
    }
}

import UIKit
import CoreLocation

final class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var stackViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    private let geocoder: CLGeocoder = CLGeocoder()
    
    override func viewDidLoad() {
        findLocationButton.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func findLocationButtonOnTouchUpInside(_ sender: UIButton) {
        guard
            let location = locationTextField.text,
            let link = linkTextField.text,
            !location.isEmpty,
            !link.isEmpty
        else {
            return
        }
        
        activityIndicator.startAnimating()
        
        
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                print("Failed to geocode location \(location) with error: \(String(describing: error))")
                let alert = UIAlertController.defaultAlert(
                    title: "Failed to geocode location",
                    message: "Please re-check the provided location and try again",
                    actionTitle: "OK")
                return self.present(alert, animated: true, completion: nil)
            }
            
            guard
                let placemarks = placemarks,
                placemarks.count > 0
            else {
                print("Failed to find coordinates for location \(location)")
                let alert = UIAlertController.defaultAlert(
                    title: "Could not find coordinates for location",
                    message: "Please re-check the provided location and try again",
                    actionTitle: "OK")
                return self.present(alert, animated: true, completion: nil)
            }
            
            let placemark = placemarks[0]
            
            guard let coordinate = placemark.location?.coordinate else {
                return
            }
            
            guard let confirmLocationViewController = self.storyboard?.instantiateViewController(identifier: Constants.Layout.Identifiers.confirmLocationViewController) as? ConfirmLocationViewController else {
                return
            }
            
            guard
                let url = URL(string: link),
                UIApplication.shared.canOpenURL(url) else {
                let alert = UIAlertController.defaultAlert(
                    title: "Invalid URL provided",
                    message: "Please retry with a valid URL",
                    actionTitle: "Dismiss")
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            confirmLocationViewController.location = location
            confirmLocationViewController.url = url
            confirmLocationViewController.coordinate = coordinate
            
            guard let navigationController = self.navigationController else {
                return
            }
            
            navigationController.pushViewController(confirmLocationViewController, animated: true)
        }
    }
    
    @IBAction func cancelButtonOnTap(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification:Notification) {
        guard locationTextField.isFirstResponder || linkTextField.isFirstResponder else {
            return
        }
        stackViewBottomConstraint.constant = getKeyboardHeight(notification)
        NSLayoutConstraint.activate([stackViewBottomConstraint])
        NSLayoutConstraint.deactivate([stackViewCenterYConstraint])
    }
    
    @objc private func keyboardWillHide(_ notification:Notification) {
        NSLayoutConstraint.deactivate([stackViewBottomConstraint])
        NSLayoutConstraint.activate([stackViewCenterYConstraint])
    }
    
    private func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}

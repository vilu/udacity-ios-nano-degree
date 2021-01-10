import UIKit

final class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        logInButton.layer.cornerRadius = Constants.Layout.buttonCornerRadius
    }

    @IBAction func logInButtonOnTouchUpInside(_ sender: UIButton) {
        
        guard let email = emailTextField.text else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        AppDependencies.udacityAPI.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("Udacity API Error: \(String(describing: error))")
                    let alert: UIAlertController?
                    switch error {
                    case .authenticationError:
                        alert = UIAlertController.defaultAlert(
                            title: "Sign in failed",
                            message: "Authentication fail, please review your credentials",
                            actionTitle: "OK")
                    case .generalError:
                        alert = UIAlertController.defaultAlert(
                            title: "Sign in failed",
                            message: "Something wen't wrong, please try again",
                            actionTitle: "OK")
                    }
                    alert.map { self.present($0, animated: true, completion: nil) } 
                case .success((let session, let accountKey)):
                    AppState.shared.session = session
                    AppState.shared.accountKey = accountKey
                    
                    self.performSegue(withIdentifier: "tabBarSegue", sender: self)
                }
            }
        }
    }
    
    @IBAction func signUpButtonOnTouchUpInside(_ sender: UIButton) {
        attemptOpenWithAlertFallback(url: "https://auth.udacity.com/sign-up")
    }
}

import UIKit

final class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.layer.cornerRadius = Constants.Layout.buttonCornerRadius
        
        emailTextField.text = "lund.viktor@gmail.com"
        passwordTextField.text = "saiy.shor0mung4OOSH"
    }
    
    @IBAction func logInButtonOnTouchUpInside(_ sender: UIButton) {
        
        func presentAuthFailError(error: UdacityAPIError) {
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
            DispatchQueue.main.async {
                alert.map { self.present($0, animated: true, completion: nil) }
            }
        }
        
        guard let email = emailTextField.text else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        AppDependencies.udacityAPI.signIn(email: email, password: password) { result in
            switch result {
            case .failure(let error):
                presentAuthFailError(error: error)
            case .success((let session, let accountKey)):
                AppDependencies.udacityAPI.getUser(userId: accountKey) { result in
                    switch result {
                    case .failure(let error):
                        presentAuthFailError(error: error)
                    case .success(let user):
                        DispatchQueue.main.async {
                            AppState.shared.session = session
                            AppState.shared.accountKey = accountKey
                            AppState.shared.user = user
                            self.performSegue(withIdentifier: "tabBarSegue", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func signUpButtonOnTouchUpInside(_ sender: UIButton) {
        
        attemptOpenWithAlertFallback(url: "https://auth.udacity.com/sign-up")
    }
}

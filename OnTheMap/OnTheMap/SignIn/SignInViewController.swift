import UIKit

final class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    
    private var udacityAPI: UdacityAPIProtocol!
    
    override func viewDidLoad() {
        logInButton.layer.cornerRadius = Constants.Layout.buttonCornerRadius
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        udacityAPI = appDelegate.dependencies.udacityAPI
        
        // TODO Remove me!
        emailTextField.text = "lund.viktor@gmail.com"
        passwordTextField.text = "saiy.shor0mung4OOSH"
    }

    @IBAction func logInButtonOnTouchUpInside(_ sender: UIButton) {
        
        guard let email = emailTextField.text else {
            return
        }
        
        guard let password = passwordTextField.text else {
            return
        }
        
        udacityAPI.signIn(email: email, password: password) { result in
            // TODO Is this correct? Is there any less error prone way of
            // handling the threading here?
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
                case .success(let session):
                    
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    
                    appDelegate.state.session = session
                    
                    
                    
                    self.performSegue(withIdentifier: "tabBarSegue", sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func signUpButtonOnTouchUpInside(_ sender: UIButton) {
        // TODO webview sign up link
    }
}

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Foundation

class AuthViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var switchModeButton: UIButton!
    @IBOutlet weak var switchModeLabel: UILabel!
    @IBOutlet weak var signInLabel: UILabel!
    
    var isSignIn = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        updateUI()
        if (Auth.auth().currentUser != nil) {
            goToMain()
        } else {
            displayError(errorMessage: "current user is nil")
        }
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text,
           !email.isEmpty, !password.isEmpty {
            isSignIn ? signIn(email: email, password: password) : signUp(email: email, password: password)
        } else {
            displayError(errorMessage: "Both fields must be filled")
        }
    }

    func signUp(email: String, password: String) {
        if password.count < 8 {
            displayError(errorMessage: "Password should be at least 8 characters long")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.displayError(errorMessage: "Registration failed" + error.localizedDescription)
            } else {
                let usersRef = Database.database().reference().child("AuthorizedUsers")
                let newUserRef = usersRef.childByAutoId()
                newUserRef.setValue([
                    "email": email,
                    "firstName": "",
                    "lastName": "",
                    "gender": "",
                    "birthday": "",
                    "phoneNumber": "",
                    "country": "",
                    "favouriteGenre": "",
                    "favouriteDirector": "",
                    "bio": ""])
                self.goToMain()
            }
        }
    }
    
     func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.displayError(errorMessage: "Incorrect email or password" + error.localizedDescription + authResult.debugDescription)
            } else {
                self.goToMain()
            }
        }
    }
    
    func goToMain() {
        DispatchQueue.main.async {
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        }
    }

    func displayError(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func switchModeButtonTapped(_ sender: UIButton) {
        isSignIn.toggle()
        updateUI()
    }
    
    func updateUI() {
        signInLabel.text = isSignIn ? "Sign in" : "Sign up"
        signInButton.setTitle(isSignIn ? "Sign in" : "Sign up", for: .normal)
        switchModeButton.setTitle(isSignIn ? "Sign up" : "Sign in", for: .normal)
        switchModeLabel.text = isSignIn ? "Don't have an account?" : "Already have an account?"
    }
}


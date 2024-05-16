import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Foundation

class ProfileViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var addInfoTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    
    var ref: DatabaseReference!
    var userKey: String = ""
    var favourites: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        ref =  Database.database().reference().child("AuthorizedUsers");
        loadUserData()
    }
    
    func loadUserData() {
        let currentUserEmail = Auth.auth().currentUser?.email
        emailLabel.text = currentUserEmail
        if let key = Auth.auth().currentUser?.uid{
            let favouritesRef = Database.database().reference().child("AuthorizedUsers/\(key)")
            favouritesRef.observe(.value, with: { snapshot in
                if let value = snapshot.value as? [String: Any] {
                    DispatchQueue.main.async {
                        self.firstNameTextField.text = value["FirstName"] as? String
                        self.lastNameTextField.text = value["LastName"] as? String
                        
                        self.birthdayTextField.text = value["BirthDate"] as? String
                        self.phoneNumberTextField.text = value["PhoneNumber"] as? String
                        
                        self.addInfoTextField.text = value["AddInfo"] as? String
                        self.nickNameTextField.text = value["NickName"] as? String
                        self.favourites = value["favorites"] as? [String] ?? []
                    }
                }
            })
        }
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        let user =  [
            //"email":  Auth.auth().currentUser?.email as Any,
            "FirstName": firstNameTextField.text!,
            "LastName": lastNameTextField.text!,
            
            "BirthDate":  birthdayTextField.text!,
            "PhoneNumber": phoneNumberTextField.text!,
            
            "AddInfo": addInfoTextField.text!,
            "NickName": nickNameTextField.text!,
            "favorites": favourites
        ] as [String : Any]
        if let key = Auth.auth().currentUser?.uid{
            ref.child(key).setValue(user)
        }
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            displayError(errorMessage: signOutError.localizedDescription)
        }
    }
    
    func displayError(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }

}

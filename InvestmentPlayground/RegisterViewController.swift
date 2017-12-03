//
//  Reegister.swift
//  InvestmentPlayground
//
//  Created by Michelle Xu on 12/1/17.
//  Copyright © 2017 Nick DesMarais. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    let db = Firestore.firestore()
    var stocks : [Stock] = []
    
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var newUsername: UITextField!

    @IBOutlet weak var newPassword: UITextField!
    
  
    @IBAction func registerButton(_ sender: Any) {
        let newUsernameText: String = newUsername.text ?? ""
        let newPasswordText: String = newPassword.text ?? ""
        addUser(username: newUsernameText, password: newPasswordText)
        let alertController = UIAlertController(title: "Registration Successful!", message: "Please login using new username and password", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default){ action in
            self.performSegue(withIdentifier: "toLoginView", sender: self)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
    }
    
    override func viewDidLoad() {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func addUser(username: String, password: String) {
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "username": username,
            "password": password
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}

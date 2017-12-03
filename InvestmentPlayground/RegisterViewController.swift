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
    

    @IBOutlet weak var newUsername: UITextField!

    @IBOutlet weak var enter: UIButton!
    
  
    @IBAction func registerButton(_ sender: Any) {
        let newUsernameText: String = newUsername.text ?? ""
        addUser(username: newUsernameText)
        let alertController = UIAlertController(title: "Registration Successful", message: "Hello " + newUsernameText + "!", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default){ action in
            let defaults = UserDefaults.standard
            if let user = self.newUsername.text{
                defaults.set(user, forKey: "username")
            }
            self.performSegue(withIdentifier: "enterGame", sender: self)
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
    

    
    func addUser(username: String) {
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "username": username,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}

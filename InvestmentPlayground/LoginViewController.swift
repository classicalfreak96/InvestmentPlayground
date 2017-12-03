//
//  loginViewController.swift
//  Login Page
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var usernameInput: UITextField!
    
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidLoad() {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
/*
        if (segue.identifier == "clickedPlay") {
            let defaults = UserDefaults.standard
            let nextVC:StocksViewController = (segue.destination as? StocksViewController)!
        }
 
        else if (segue.identifier == "newUserButton"){
            let nextVC:RegisterViewController = (segue.destination as? RegisterViewController)!
        }
 */
        if (segue.identifier == "loginButton") {
            let defaults = UserDefaults.standard
            if let user = usernameInput.text {
                defaults.set(user, forKey: "username")
            }
        }
    }
}

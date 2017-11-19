//
//  loginViewController.swift
//  movie viewer tabbed
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    let db = Firestore.firestore()
    var stocks : [Stock] = []
    
    override func viewDidLoad() {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loginButton"){
            let nextVC:StocksViewController = (segue.destination as?StocksViewController)!
        }
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

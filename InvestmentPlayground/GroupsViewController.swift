//
//  groupsViewController.swift
//  InvestmentPlayground
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class GroupsViewController: UIViewController{
    
    let db = Firestore.firestore()
    @IBOutlet weak var newGameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickedPlay(_ sender: Any) {
            if let gameName = newGameTextField.text {
                let username = UserDefaults.standard.string(forKey: "username")!
                addGame(title: gameName)
                joinGame(title: gameName, username: username)
            }
            else {
                print("nameless")
                return
            }
    }
    
    
    func joinGame(title: String, username: String) {
        db.collection("gameMembers").document("\(username)-\(title)").setData([
            "title": title,
            "username": username
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(username)-\(title)")
            }
        }
    }
    
    func addGame(title: String) {
        var ref: DocumentReference? = nil
        ref = db.collection("games").addDocument(data: [
            "title": title
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}

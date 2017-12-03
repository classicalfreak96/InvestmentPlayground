//
//  groupsViewController.swift
//  movie viewer tabbed
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class GroupsViewController: UIViewController{
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "clickedPlay"){
            let nextVC:GamesViewController = (segue.destination as? GamesViewController)!
        }
    }
    
    func joinGame(title: String, username: String) {
        var ref: DocumentReference? = nil
        ref = db.collection("gameMembers").addDocument(data: [
            "title": title,
            "username": username
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
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

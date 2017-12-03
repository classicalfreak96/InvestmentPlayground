//
//  LeadershipViewController.swift
//  movie viewer tabbed
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class LeadershipViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var leadershipTable: UITableView!
    var game: String = ""
    var users: [String] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if game != "" {
            getUsersForGame(title: game)
        }
        leadershipTable.dataSource = self
        leadershipTable.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //help from https://www.ralfebert.de/tutorials/ios-swift-uitableviewcontroller/#data_swift_arrays
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "leaderCell", for: indexPath) as UITableViewCell
        cell1.textLabel?.text = users[indexPath.row]
        return cell1
    }
    
    // This function pulls all of the stocks for a given user and reloads
    // the table with the tickers of the stocks
    func getUsersForGame(title: String) {
        db.collection("gameMembers").whereField("title", isEqualTo: title)
            .getDocuments() { [unowned self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if let username = document.data()["username"] as? String {
                            self.users.append(username)
                        }
                    }
                    self.leadershipTable.reloadData()
                }
        }
    }
}

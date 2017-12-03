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
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "leaderCell") as! LeaderCell
        cell1.rankingLabel.text = "#" + String(indexPath.row + 1)
        cell1.nameLabel.text = users[indexPath.row]
        var portfolioReturn = 1.234 //@MICHAEL: this should be calculated for users or pulled from database
        if (portfolioReturn < 0) {
            cell1.returnLabel.textColor = UIColor.red
            cell1.returnLabel.text = "-" + String(format: "%.2f", portfolioReturn) + "%"
        }
        else {
            cell1.returnLabel.textColor = UIColor.green
            cell1.returnLabel.text = "+" + String(format: "%.2f", portfolioReturn) + "%"
        }
        return cell1
    }
    
    func sortPortfolioReturn(){
        //pull users portfolios from database and sort here
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

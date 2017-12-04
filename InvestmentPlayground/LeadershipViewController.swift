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
    
    @IBOutlet weak var ranking: UILabel!
    @IBOutlet weak var leadershipTable: UITableView!
    var game: String = ""
    var users: [String] = []
    let db = Firestore.firestore()
    let dp = dataParse()
    override func viewDidLoad() {
        super.viewDidLoad()
        if game != "" {
            getUsersForGame(title: game)
            sortUsers()
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
        cell1.nameLabel.textColor = UIColor(red: 182, green: 192, blue: 210, alpha: 1.0)
        cell1.rankingLabel.textColor = UIColor(red: 182, green: 192, blue: 210, alpha: 1.0)
        cell1.nameLabel.text = users[indexPath.row]
        cell1.rankingLabel.text = "#" + String(indexPath.row + 1)
        
        let returnPort = 1.23 //@MICHAEL: this should be calculated for users
        
        if ( returnPort < 0) {
            cell1.returnLabel.textColor = UIColor.red
            cell1.returnLabel.text = "-" + String(returnPort) + "%"
        }
        else {
            cell1.returnLabel.textColor = UIColor.green
            cell1.returnLabel.text = "+" + String(returnPort) + "%"
        }

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
    func sortUsers() {
        var userPortfolioValues:[String:Double] = [:]
        for user in self.users {
            let currUserStocks = getStocksForUser(username: user)
            for stock in currUserStocks {
                let currPrice = dp.pullCurrentPrice(ticker: stock.ticker)
                
            }
            
        }
    }
    
    
    // This function pulls all of the stocks for a given user and reloads
    // the table with the tickers of the stocks
    func getStocksForUser(username: String) -> [Stock] {
        var stocks:[Stock] = []
        self.db.collection("stocks").whereField("username", isEqualTo: username)
            .getDocuments() { [unowned self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if let ticker = document.data()["ticker"] as? String {
                            if let numShares = document.data()["numShares"] as? Int {
                                if numShares > 0 {
                                    stocks.append(Stock(SMA: [:], ticker: ticker, numShares: numShares))
                                }
                            }
                        }
                    }
                }
        }
        return stocks
    }
    
}

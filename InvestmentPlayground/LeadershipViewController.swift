//
//  LeadershipViewController.swift
//  InvestmentPlayground
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
    var stocks: [String:[Stock]] = [:]
    var userPortfolioValues: [String:Double] = [:]
    var userCashValues: [String:Double] = [:]
    var sortedUsers:[String] = []
    //var tuplesArray: [(name: String, value: Double] = []
    
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
        if !sortedUsers.indices.contains(indexPath.row) {
            return cell1
        }
        cell1.nameLabel.textColor = UIColor(red: 182, green: 192, blue: 210, alpha: 1.0)
        cell1.rankingLabel.textColor = UIColor(red: 182, green: 192, blue: 210, alpha: 1.0)
        cell1.nameLabel.text = self.sortedUsers[indexPath.row]
        cell1.rankingLabel.text = "#" + String(indexPath.row + 1)
        if let returnPort = self.userPortfolioValues[sortedUsers[indexPath.row]] {
            if (returnPort < 10000) {
                cell1.returnLabel.textColor = UIColor.red
                cell1.returnLabel.text = "$" + String(format: "%.2f", returnPort)
            }
            else {
                cell1.returnLabel.textColor = UIColor.green
                cell1.returnLabel.text = "$" + String(format: "%.2f", returnPort)
            }
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
                            self.getStocksForUser(username: username)
                            self.getCashValue(username: username)
                        }
                    }
                    self.sortUsers()
                    self.leadershipTable.reloadData()
                }
        }
    }
    
    
    func sortUsers() {
        for user in self.users {
            userPortfolioValues[user] = calcPortfolioValue(user: user)
        }
    }
    
    func calcPortfolioValue(user: String) -> Double{
        // updates self.stocks
        // start the portfolio value with the amount of cash the user has
        let totalPortfolioValueOptional = self.userCashValues[user]
        var totalPortfolioValue = 0.0
        if totalPortfolioValueOptional != nil {
            totalPortfolioValue = totalPortfolioValueOptional!
        }
        if self.stocks[user] != nil {
            for stock in self.stocks[user]! {
                let (success, currPrice) = dp.pullCurrentPrice(ticker: stock.ticker)
                if success {
                    totalPortfolioValue += (currPrice * Double(stock.numShares))
                }
                else {
                    let alert = UIAlertController(title: "Sorry!", message: "The API call is not currently working, please try again in a few seconds for an accurate portfolio value", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }

        let tuplesArray = userPortfolioValues.sorted{ $0.value > $1.value }
        self.sortedUsers = []
        for (name, portValue) in tuplesArray{
            self.sortedUsers.append(name)
        }
        return totalPortfolioValue
        
    }


    // This function pulls all of the stocks for a given user and reloads
    // the table with the tickers of the stocks
    func getStocksForUser(username: String) {
        stocks[username] = []
        self.db.collection("stocks").whereField("username", isEqualTo: username)
            .getDocuments() { [unowned self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if let ticker = document.data()["ticker"] as? String {
                            if let numShares = document.data()["numShares"] as? Int {
                                if numShares > 0 {
                                    self.stocks[username]?.append(Stock(SMA: [:], ticker: ticker, numShares: numShares))
                                }
                            }
                        }
                    }
                    let portfolioValue = self.calcPortfolioValue(user: username)
                    self.userPortfolioValues[username] = portfolioValue
                    self.leadershipTable.reloadData()
            }
        }
    }
    
    func getCashValue(username: String) {
        self.db.collection("users").document(username).getDocument {
            [unowned self] (document, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let document = document {
                    if let cash = document.data()["cash"] as? Double {
                        self.userCashValues[username] = cash
                    }
                }
            }
            let portfolioValue = self.calcPortfolioValue(user: username)
            self.userPortfolioValues[username] = portfolioValue
            self.leadershipTable.reloadData()
        }
    }
    
}

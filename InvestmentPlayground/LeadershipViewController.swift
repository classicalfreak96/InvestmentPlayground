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
    var stocks:[Stock] = []
    
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
        
        let returnPort = calcPortfolioValue(user: users[indexPath.row])
        
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
            print("inside the users ")

            userPortfolioValues[user] = calcPortfolioValue(user: user)
        }
        
        // taken from https://stackoverflow.com/questions/24090016/sort-dictionary-by-values-in-swift
        // I don't understand what it does
        
        //userPortfolioValues.keys.sorted(by: {$0 > $1}).flatMap({userPortfolioValues[$0]})
        print("PortfolioValues: \(userPortfolioValues)")
        self.stocks = []
        
    }
    
    func calcPortfolioValue(user: String) -> Double{
        getStocksForUser(username: user) // updates self.stocks
        print ("Current User Stocks: \(self.stocks)")
        // start the portfolio value with the amount of cash the user has
        var totalPortfolioValue = self.getCashValue(username: user)
        for stock in self.stocks {
            let currPrice = dp.pullCurrentPrice(ticker: stock.ticker)
            totalPortfolioValue +=  (currPrice * Double(stock.numShares))
        }
        return totalPortfolioValue
    }
    // This function pulls all of the stocks for a given user and reloads
    // the table with the tickers of the stocks
    func getStocksForUser(username: String) {
        self.db.collection("stocks").whereField("username", isEqualTo: username)
            .getDocuments() { [unowned self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if let ticker = document.data()["ticker"] as? String {
                            if let numShares = document.data()["numShares"] as? Int {
                                if numShares > 0 {
                                    self.stocks.append(Stock(SMA: [:], ticker: ticker, numShares: numShares))
                                }
                            }
                        }
                    }
                }
        }
    }
    
    func getCashValue(username: String)->Double {
        var returnCash = 0.0
        self.db.collection("users").document(username).getDocument {
            [unowned self] (document, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let document = document {
                    if let cash = document.data()["cash"] as? Double {
                        returnCash = cash
                    }
                }
            }
        }
        return returnCash
    }
    
}

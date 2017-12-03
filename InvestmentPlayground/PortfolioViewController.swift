//
//  portfolioViewController.swift
//  movie viewer tabbed
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PortfolioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    let db = Firestore.firestore()
    var stocks: [Stock] = []
    let dataParser = dataParse()
    
    @IBOutlet weak var portfolioValue: UILabel!
    
    @IBOutlet weak var portfolioTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let username = UserDefaults.standard.string(forKey: "username")
        if let user = username {
            getStocksForUser(username: user)
        }
        self.view.backgroundColor = .white
        portfolioTable.delegate = self
        portfolioTable.dataSource = self
        //print(self.stocks)
        calculatePortfolioValue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // This might not need to be here
    
    override func viewDidAppear(_ animated: Bool) {
        let username = UserDefaults.standard.string(forKey: "username")
        if let user = username {
            getStocksForUser(username: user)
        }
    }
    
    
    //EVERYTHING NEEDS TO BE CHANGED
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //one to say change
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //help from https://www.ralfebert.de/tutorials/ios-swift-uitableviewcontroller/#data_swift_arrays
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "portfolioCell", for: indexPath) as UITableViewCell
        //cell1.textLabel?.text = "\(stocks[indexPath.row].numShares) shares of \(stocks[indexPath.row].ticker)"
        print(stocks[indexPath.row].numShares)
        cell1.textLabel?.text = stocks[indexPath.row].ticker + "(" + String(stocks[indexPath.row].numShares) + ")"
        print(cell1.textLabel?.text)
        return cell1
    }
    
    // This function pulls all of the stocks for a given user and reloads
    // the table with the tickers of the stocks
    func getStocksForUser(username: String) {
        db.collection("stocks").whereField("username", isEqualTo: username)
            .getDocuments() { [unowned self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if let ticker = document.data()["ticker"] as? String {
                            if let numShares = document.data()["numShares"] as? Int {
                                if let SMA = document.data()["SMA"] as? [Date: Double] {
                                    self.stocks.append(Stock(SMA: SMA, ticker: ticker, numShares: numShares))
                                }
                            }
                        }
                    }
                    self.portfolioTable.reloadData()
                }
        }
    }
    
    func calculatePortfolioValue() {
        var totalVal = 0.0
        
        //for stock in self.stocks {
        //    totalVal = totalVal + (stock.numShares)
        //}
    }
    
}

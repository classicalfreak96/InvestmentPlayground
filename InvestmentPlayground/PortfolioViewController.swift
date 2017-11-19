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
    
    @IBOutlet weak var portfolioTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        portfolioTable.delegate = self
        portfolioTable.dataSource = self
        getStocksForUser(username: "NickD")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //EVERYTHING NEEDS TO BE CHANGED
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //help from https://www.ralfebert.de/tutorials/ios-swift-uitableviewcontroller/#data_swift_arrays
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "portfolioCell", for: indexPath) as UITableViewCell
        cell1.textLabel?.text = "\(stocks[indexPath.row].numShares) shares of \(stocks[indexPath.row].ticker)"
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
                                if let name = document.data()["name"] as? String {
                                    if let midprice = document.data()["midprice"] as? [Float] {
                                        self.stocks.append(Stock(name: name, midprice: midprice, ticker: ticker, numShares: numShares))
                                    }
                                }
                            }
                        }
                    }
                    self.portfolioTable.reloadData()
                }
        }
    }
    
}

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
        let username = UserDefaults.standard.string(forKey: "username")!
        getStocksForUser(username: username)
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
    
    override func viewDidAppear(_ animated: Bool) {
        let username = UserDefaults.standard.string(forKey: "username")!
        getStocksForUser(username: username)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sdvc = segue.destination as! StocksDetailsViewController
        let currentStock = stocks[(portfolioTable.indexPathForSelectedRow?.row)!]
        sdvc.tickerName = currentStock.ticker
        let dp = dataParse()
        let (dollar, percent, volume) = dp.pullStockData(ticker: currentStock.ticker)
        dp.searchEquity(function: "SMA", symbol: currentStock.ticker, interval: "daily", time_period: "100")
        sdvc.stockHold = dp.equityList
        sdvc.dollar = dollar
        sdvc.percent = percent
        sdvc.volume = volume
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //one to say change
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let sell = UITableViewRowAction(style: .normal, title: "Sell") {(action, indexpath) in
            print("CAN SELL")
            let alert = UIAlertController(title: "Sell " + self.stocks[indexPath.row].ticker + " stocks", message: "Enter number of shares: ", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = " "
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                if let text: String = textField?.text {
                    let trimmedString = Int(text.trimmingCharacters(in: .whitespaces))
                    self.stocks[indexPath.row].numShares = self.stocks[indexPath.row].numShares - trimmedString!
                    //NEEDS TO UPDATE STOCK IN DATABASE WITH NEW NUMBER OF STOCKS
                    //print(self.stockHold[0].numShares)
                    let username = UserDefaults.standard.string(forKey: "username")
                    if let user = username {
                        print("inside user = username")
                        //self.addStock(username: user, ticker: self.tickerName, numShares: self.stockHold[0].numShares)
                    }
                }
                //self.performSegue(withIdentifier: "toPortfolioView", sender: self)
                self.portfolioTable.reloadData()
            }))

            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        sell.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        return [sell]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //help from https://www.ralfebert.de/tutorials/ios-swift-uitableviewcontroller/#data_swift_arrays
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "portfolioCell", for: indexPath) as UITableViewCell
        cell1.textLabel?.text = self.stocks[indexPath.row].ticker + "(" + String(self.stocks[indexPath.row].numShares) + ")"
        return cell1
    }
    
    // This function pulls all of the stocks for a given user and reloads
    // the table with the tickers of the stocks
    func getStocksForUser(username: String) {
        self.db.collection("stocks").whereField("username", isEqualTo: username)
            .getDocuments() { [unowned self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.stocks = []
                    for document in querySnapshot!.documents {
                        if let ticker = document.data()["ticker"] as? String {
                            if let numShares = document.data()["numShares"] as? Int {
                                self.stocks.append(Stock(SMA: [:], ticker: ticker, numShares: numShares))
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


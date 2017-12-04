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
    var totalPortfolioValue: Double = 0.0
    
    @IBOutlet weak var portfolioValue: UILabel!
    
    @IBOutlet weak var portfolioTable: UITableView!
    
    @IBOutlet weak var cashLeft: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let username = UserDefaults.standard.string(forKey: "username")!
        
        getStocksForUser(username: username)
        self.view.backgroundColor = .white
        portfolioTable.delegate = self
        portfolioTable.dataSource = self
        calculatePortfolioValue()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let username = UserDefaults.standard.string(forKey: "username")!
        getStocksForUser(username: username)
        calculatePortfolioValue()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sdvc = segue.destination as! StocksDetailsViewController
        let currentStock = stocks[(portfolioTable.indexPathForSelectedRow?.row)!]
        sdvc.tickerName = currentStock.ticker
        let (dollar, percent, volume, open, high, low) = dataParser.pullStockData(append: true, ticker: currentStock.ticker)
        sdvc.stockHold = dataParser.equityList
        sdvc.stockPrice = dataParser.pullCurrentPrice(ticker: currentStock.ticker)
        sdvc.dollar = dollar
        sdvc.percent = percent
        sdvc.volume = volume
        sdvc.open = open
        sdvc.high = high
        sdvc.low = low
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //one to say change
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let sell = UITableViewRowAction(style: .normal, title: "Sell") {(action, indexpath) in
            let alert = UIAlertController(title: "Sell " + self.stocks[indexPath.row].ticker + " stocks", message: "Enter number of shares: ", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = ""
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [unowned self, weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                if let text: String = textField?.text {
                    var trimmedString = Int(text.trimmingCharacters(in: .whitespaces))
                    if trimmedString == nil {
                        trimmedString = 0
                    }
                    if (self.stocks[indexPath.row].numShares - trimmedString! < 0) {
                        let alert = UIAlertController(title: "NO", message: "You cannot sell more stocks than you have", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        if let textInt: Int = Int(text) {
                            self.sellStock(username: UserDefaults.standard.string(forKey: "username")!, ticker: self.stocks[indexPath.row].ticker, numShares: self.stocks[indexPath.row].numShares - Int(textInt))
                        }
                        self.stocks[indexPath.row].numShares = self.stocks[indexPath.row].numShares - trimmedString!
                        let alert = UIAlertController(title: "Profit from selling " + self.stocks[indexPath.row].ticker, message: "You have made " + "12132312123", preferredStyle: .alert) //CHANGE "123123123123"
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)

                    }
                }
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
                                if numShares > 0 {
                                    self.stocks.append(Stock(SMA: [:], ticker: ticker, numShares: numShares))
                                }
                            }
                        }
                    }
                    self.portfolioTable.reloadData()
                }
        }
    }
    
    func calculatePortfolioValue() {
        var totalVal = 0.0 // just set this to total cash initially once nick is done
        let defaults = UserDefaults.standard
        if let stockDict:[String:Int] = defaults.value(forKey: "userStocks") as? [String: Int] {
            for (ticker, numShares) in stockDict {
                if numShares > 0 {
                    let stockValue = Double(numShares) * dataParser.pullCurrentPrice(ticker:ticker)
                    totalVal += stockValue

            }
        }
        totalPortfolioValue = totalVal
        self.portfolioValue.text = "Portfolio Value: $" + String(totalPortfolioValue)
    }
    }
    
    // Ticker is the shorthand name for the stock (i.e. AAPL for Apple)
    func sellStock(username: String, ticker: String, numShares: Int) {
        // We need to update the value in user defaults so that we 
        // have the stock info locally
        let defaults = UserDefaults.standard
        var stockShareDict:[String: Int] = defaults.value(forKey: "userStocks") as! [String:Int]
        // this is ok because the numShares passed in here is former number of shares - shares to be sold
        
        stockShareDict[ticker] = numShares
        defaults.set(stockShareDict, forKey: "userStocks")
        calculatePortfolioValue()
        db.collection("stocks").document("\(username)-\(ticker)").setData([
            "username": username,
            "ticker": ticker,
            "numShares": numShares
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }

    
}


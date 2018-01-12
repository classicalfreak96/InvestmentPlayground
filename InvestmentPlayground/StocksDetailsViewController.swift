//
//  StocksDetailsViewController.swift
//  InvestmentPlayground
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class StocksDetailsViewController: UIViewController{
    
    var tickerName: String = ""
    var userCashValue: Double = 0.0
    var stockHold: [Stock] = []
    var chronoStockPrice: [Double] = []
    var points: [CGPoint] = []
    var shares: Int = 0
    var dollar: Double = 0
    var stockPrice: Double = 0
    var percent: Double = 0
    var volume: Int = 0
    var open: Double = 0
    var high: Double = 0
    var low: Double = 0
    var success:Bool = false
    let db = Firestore.firestore()
    
    
    @IBAction func addPortfolio(_ sender: Any) {
        let alert = UIAlertController(title: "Buy " + tickerName + " stocks", message: "Enter number of shares: ", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = " "
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            if let text: String = textField?.text {
                let trimmedString = Int(text.trimmingCharacters(in: .whitespaces))
                if let numShares = trimmedString {
                    if numShares <= 0 {
                        let nonPositiveNumberAlert = UIAlertController(title: "Error", message: "Please enter a positive number", preferredStyle: .alert)
                        nonPositiveNumberAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(nonPositiveNumberAlert, animated: true, completion: nil)
                    }
                    self.stockHold[0].numShares = numShares
                    let username = UserDefaults.standard.string(forKey: "username")
                    if let user = username {
                        let success = self.buyStock(username: user, ticker: self.tickerName, numShares: self.stockHold[0].numShares)
                        if success {
                            self.performSegue(withIdentifier: "toPortfolioView", sender: self)
                        }
                    }
                }
                else {
                    let noNumberAlert = UIAlertController(title: "Error", message: "Please enter a valid number", preferredStyle: .alert)
                    noNumberAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(noNumberAlert, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var graph: LineChart!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var ticker: UINavigationBar!
    
    @IBOutlet weak var changeDol: UILabel!
    
    @IBOutlet weak var changePercent: UILabel!
    
    @IBOutlet weak var marketCap: UILabel!
    
    @IBOutlet weak var peRatio: UILabel!
    
    @IBOutlet weak var betaValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!success) {
            let alert = UIAlertController(title: "Sorry!", message: "The API is currently not responding, please wait a few seconds before reloading for accurate data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        getCashValue(username: UserDefaults.standard.value(forKey: "username") as! String)
        sortStocks(stockDic: stockHold[0].SMA)
        self.title = tickerName
        price.text = "$" + String(stockPrice)
        changeDol.text = "$" + String(format: "%.2f", dollar)
        changePercent.text = "(" + String(format: "%.5f", percent) + "%" + ")"
        if (percent < 0) {
            changeDol.textColor = UIColor.red
            changePercent.textColor = UIColor.red
        }
        else {
            changeDol.textColor = UIColor.green
            changePercent.textColor = UIColor.green
        }
        price.text = String(stockPrice)
        marketCap.text = "Open: " + String(open)
        peRatio.text = "High: " + String(high)
        betaValue.text = "Low: " + String(low)
        
        var i: Int = 0
        for price in chronoStockPrice {
            let tempPoint = CGPoint(x: Double(i), y: price)
            points.append(tempPoint)
            i += 1
        }
        
        graph.plot(points)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toPortfolioView") {
            let nextVC:PortfolioViewController = (segue.destination as? PortfolioViewController)!
            nextVC.stocks.append(stockHold[0])
        }
        
    }
    
    func sortStocks (stockDic: [Date:Double]) {
        let sorted = stockDic.sorted { $0.0 < $1.0 }
        for (_, price) in sorted {
            chronoStockPrice.append(price)
        }
    }
    
    // Ticker is the shorthand name for the stock (i.e. AAPL for Apple)
    // This will update the stock
    func buyStock(username: String, ticker: String, numShares: Int) -> Bool {
        let dp = dataParse()
        let (success,currentPrice) = dp.pullCurrentPrice(ticker: ticker)
        if success {
            let newCashValue = userCashValue - (currentPrice * Double(numShares))
            let alert = UIAlertController(title: "Error", message: "You don't have enough money to buy \(numShares) of \(ticker).", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            if newCashValue < 0 {
                self.present(alert, animated: true)
                return false
            }
            
            var stockShareDict: [String:Int] = UserDefaults.standard.value(forKey: "userStocks") as! [String : Int]
            
            // The amount they buy will come in, so we need to retrieve
            // how much they already have (if they already own it) in
            // order to update the value correctly
            var newNumShares: Int
            if let oldShareNumber = stockShareDict[ticker] {
                newNumShares = numShares + oldShareNumber
            }
            else {
                newNumShares = numShares
            }
            
            stockShareDict[ticker] = newNumShares
            UserDefaults.standard.set(stockShareDict, forKey: "userStocks")
            
            // Update stock share numbers in the database
            db.collection("stocks").document("\(username)-\(ticker)").setData([
                "username": username,
                "ticker": ticker,
                "numShares": newNumShares
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            
            setCashValue(username: username, newCashValue: newCashValue)
            return true
        }
        else {
            let alert = UIAlertController(title: "Sorry!", message: "The API is currently not responding, please wait a few seconds before repurchasing", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
            
    func getCashValue(username: String) {
        self.db.collection("users").document(username).getDocument
        { [unowned self] (document, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                if let document = document {
                    if let cash = document.data()["cash"] as? Double {
                        self.userCashValue = cash
                    }
                }
            }
        }
    }
    
    func setCashValue(username: String, newCashValue: Double) {
        db.collection("users").document(username).updateData([
            "cash": newCashValue
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}



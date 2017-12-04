//
//  StocksViewController.swift
//  movie viewer tabbed
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class StocksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var equityInfo = dataParse()
    let db = Firestore.firestore()
    var query: String = ""
    var stockHold:[Stock] = []
    var dollar:Double = 0
    var percent:Double = 0
    var volume:Int = 0
    var open:Double = 0
    var high:Double = 0
    var low:Double = 0
    var currentUserStocks: [Stock] = []

    @IBOutlet weak var stocksTable: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchStocksBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stocksTable.dataSource = self
        stocksTable.delegate = self
        stockHold = equityInfo.equityList
        getUsersStocks()
    }
    
    func getUsersStocks() {
        let user = UserDefaults.standard.string(forKey: "username")

        if user != nil {
            getStocksForUser(username: user!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "clickedStock"){
            let nextVC: StocksDetailsViewController = (segue.destination as?StocksDetailsViewController)!
            nextVC.tickerName = query
            nextVC.stockHold = equityInfo.equityList
            nextVC.dollar = dollar
            nextVC.percent = percent
            nextVC.volume = volume
            nextVC.open = open
            nextVC.high = high
            nextVC.low = low
            nextVC.stockPrice = equityInfo.pullCurrentPrice(ticker: query)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return equityInfo.equityList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //help from https://www.ralfebert.de/tutorials/ios-swift-uitableviewcontroller/#data_swift_arrays
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "stocksCell", for: indexPath) as UITableViewCell
        let stock = equityInfo.equityList[indexPath.item]
        cell1.textLabel?.text = stock.ticker
        return cell1
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        equityInfo.equityList.removeAll()
        if let text: String = searchStocksBar.text {
            let trimmedString = text.trimmingCharacters(in: .whitespaces)
            query = trimmedString
        }
        query = query.uppercased()
        (dollar, percent, volume, open, high, low) = equityInfo.pullStockData(append: true, ticker: query)
        stocksTable.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            equityInfo.equityList.removeAll()
            stockHold = equityInfo.equityList
            stocksTable.reloadData()
        }
    }
    
    
    // This function pulls all of the stocks for a given user and reloads
    // the table with the tickers of the stocks
    
    // This method may be better suited for dataParse, as it's already in PortfolioViewController
    // But i edited it a little to store things in UserDefaults
    func getStocksForUser(username: String) {
        self.db.collection("stocks").whereField("username", isEqualTo: username)
            .getDocuments() { [unowned self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let defaults = UserDefaults.standard
                    var stockShareDict:[String: Int] = [:]
                    self.currentUserStocks = []
                    for document in querySnapshot!.documents {
                        if let ticker = document.data()["ticker"] as? String {
                            if let numShares = document.data()["numShares"] as? Int {
                                self.currentUserStocks.append(Stock(SMA: [:], ticker: ticker, numShares: numShares))
                                stockShareDict[ticker] = numShares
                            }
                        }
                    }
                    // if nothing is in the stock dictionary, put an empty string in there
                    // to avoid unwrapping a nil optional
                    if stockShareDict.isEmpty {
                        stockShareDict[""] = 0
                    }
                    defaults.set(stockShareDict, forKey: "userStocks")
                }
        }
    }
}

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
    var stockHold: [Stock] = []
    var dollar: Double = 0
    var percent: Double = 0
    var volume: Int = 0
    var open: Double = 0
    var high: Double = 0
    var low: Double = 0
    
    @IBOutlet weak var stocksTable: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchStocksBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stocksTable.dataSource = self
        stocksTable.delegate = self
        stockHold = equityInfo.equityList
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
    
}

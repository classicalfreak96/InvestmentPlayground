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
    var query:String = ""
    var stockHold:[Stock] = []
    
    @IBOutlet weak var stocksTable: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchStocksBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stocksTable.dataSource = self
        stocksTable.delegate = self
        stockHold = equityInfo.equityList
        print("reached here")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "clickedStock"){
            let  nextVC:StocksDetailsViewController = (segue.destination as?StocksDetailsViewController)!
//            let selectedCell = sender as! UITableViewCell
//            let indexPath = stockHold.indexPath(for: selectedCell)
//            let stock = equityInfo.equityList[indexPath.item]
            nextVC.tickerName = query
            nextVC.stockHold = equityInfo.equityList
            let (dollar, percent, volume) = equityInfo.pullStockData(ticker: query)
            nextVC.dollar = dollar
            nextVC.percent = percent
            nextVC.volume = volume
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
        equityInfo.searchEquity(function: "SMA", symbol: query, interval: "daily", time_period: "100")
        stocksTable.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{                                                                                                                                                    
            equityInfo.equityList.removeAll()
            stockHold = equityInfo.equityList
            
            //pageCount = 1
            stocksTable.reloadData()
        }
    }
    
}

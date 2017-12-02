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
//            let  nextVC:movieDetailed = (segue.destination as?movieDetailed)!
//            let selectedCell = sender as! UICollectionViewCell
//            let indexPath = movies.indexPath(for: selectedCell)
//            let movie = movieInfo.movieList[(indexPath?.row)!]
//            nextVC.movIm = movie.poster_pic
//            nextVC.movTitle = movie.title
//            nextVC.movDesc = movie.overview
//            nextVC.movRelDate = movie.release_date
//            nextVC.movID = movie.ID
        }
        
    }
    
    //EVERYTHING NEEDS TO BE CHANGED
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
    
    // Ticker is the shorthand name for the stock (i.e. AAPL for Apple)
    func addStock(username: String, ticker: String, numShares: Int) {
        var ref: DocumentReference? = nil
        ref = db.collection("stocks").addDocument(data: [
            "username": username,
            "ticker": ticker,
            "numShares": numShares
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        equityInfo.equityList.removeAll()
        query = searchStocksBar.text!
        equityInfo.searchEquity(function: "SMA", symbol: query, interval: "30min", time_period: "20")
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

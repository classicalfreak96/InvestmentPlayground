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
    
    @IBOutlet weak var stocksTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stocksTable.dataSource = self
        stocksTable.delegate = self
        print("reached here")
        equityInfo.searchEquity(function: "MIDPRICE", symbol: "SBUX", interval: "30min", time_period: "20")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "clickedStock"){
            let  nextVC:StocksDetailsViewController = (segue.destination as?StocksDetailsViewController)!
        }
        
    }
    
    //EVERYTHING NEEDS TO BE CHANGED
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //help from https://www.ralfebert.de/tutorials/ios-swift-uitableviewcontroller/#data_swift_arrays
        print("3")
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "stocksCell", for: indexPath) as UITableViewCell
        print("index Path: ")
        print(indexPath.item)
        cell1.textLabel?.text = "hello"
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
}

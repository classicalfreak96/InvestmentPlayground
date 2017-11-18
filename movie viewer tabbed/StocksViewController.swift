//
//  StocksViewController.swift
//  movie viewer tabbed
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit


class StocksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var stocksTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stocksTable.dataSource = self
        stocksTable.delegate = self
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
    
}

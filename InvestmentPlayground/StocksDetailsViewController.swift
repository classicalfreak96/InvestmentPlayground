//
//  StocksDetailsViewController.swift
//  movie viewer tabbed
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit

class StocksDetailsViewController: UIViewController{
    
    var tickerName:String = ""
    var stockHold:[Stock] = []
    var chronoStockPrice:[Double] = []
    var shares:Int = 0
    

    @IBAction func addPortfolio(_ sender: Any) {
        let alert = UIAlertController(title: "Buy " + tickerName + " stocks", message: "Enter number of shares: ", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = " "
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.performSegue(withIdentifier: "toPortfolioView", sender: self)
                        print("!!!!!")
            if let text: String = textField?.text {
                print(text)
                let trimmedString = Int(text.trimmingCharacters(in: .whitespaces))
                print(trimmedString!)
                self.stockHold[0].numShares = trimmedString!
                print(self.stockHold[0].numShares)
            }
//            print(Int(textField!.text!)!)
//                        print("!!!!!")
 //           self.shares = Int((textField?.text)!)!

            //textField.text gets you number of shares they would like to buy
            //print("Text field: \(textField?.text)")
 //           print(self.shares)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var ticker: UINavigationBar!
    
    @IBOutlet weak var changeDol: UILabel!

    @IBOutlet weak var changePercent: UILabel!
    
    @IBOutlet weak var marketCap: UILabel!
    
    @IBOutlet weak var peRatio: UILabel!
    
    @IBOutlet weak var betaValue: UILabel!
    
    @IBOutlet weak var graph: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortStocks(stockDic: stockHold[0].SMA)
        self.title = tickerName
        price.text = String(describing: chronoStockPrice.last)
        changeDol.text = "0.34"
        changePercent.text = "(1.23%)"
        marketCap.text = "Market Capitalization: 13.5 B"
        peRatio.text = "P/E Ratio: 0.94"
        betaValue.text = "Beta: 0.95"
        print("reached")
        print(tickerName)
        print(stockHold)
        
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
        print(sorted)
        for (date, price) in sorted {
            print(date)
            chronoStockPrice.append(price)
        }
    }
}




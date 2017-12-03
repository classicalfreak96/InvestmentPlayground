//
//  StocksDetailsViewController.swift
//  movie viewer tabbed
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class StocksDetailsViewController: UIViewController{
    
    var tickerName:String = ""
    var stockHold:[Stock] = []
    var chronoStockPrice:[Double] = []
    var points:[CGPoint] = []
    var shares:Int = 0
    var dollar:Double = 0
    var percent:Double = 0
    var volume:Int = 0
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
                self.stockHold[0].numShares = trimmedString!
                //print(self.stockHold[0].numShares)
                let username = UserDefaults.standard.string(forKey: "username")
                if let user = username {
                    print("inside user = username")
                    self.addStock(username: user, ticker: self.tickerName, numShares: self.stockHold[0].numShares)
                }
            }
            self.performSegue(withIdentifier: "toPortfolioView", sender: self)
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
        sortStocks(stockDic: stockHold[0].SMA)
        self.title = tickerName
        if let unwrappedPrice = chronoStockPrice.last {
            price.text = String(describing: unwrappedPrice)
        }
        else {
            price.text = "000"
        }
        
        //price.text = String(describing: chronoStockPrice.last!)
        changeDol.text = "$" + String(format: "%.2f", dollar)
        changePercent.text = String(format: "%.5f", percent) + "%"
        if (percent < 0) {
            changeDol.textColor = UIColor.red
            changePercent.textColor = UIColor.red
        }
        else {
            changeDol.textColor = UIColor.green
            changePercent.textColor = UIColor.green
        }
        if let unwrapped = chronoStockPrice.last {
            marketCap.text = "Market Cap: $" + String(volume * Int(unwrapped))
        }
            peRatio.text = "P/E Ratio: 0.94"
        betaValue.text = "Beta: 0.95"
        
        
        
        
        
        
//        let f: (CGFloat) -> CGPoint = {
//            let noiseY = (CGFloat(arc4random_uniform(2)) * 2 - 1) * CGFloat(arc4random_uniform(4))
//            let noiseX = (CGFloat(arc4random_uniform(2)) * 2 - 1) * CGFloat(arc4random_uniform(4))
//            let b: CGFloat = 5
//            let y = 2 * $0 + b + noiseY
//            return CGPoint(x: $0 + noiseX, y: y)
//        }
//        
//        let xs = [Int](1..<20)
//        
//        let points = xs.map(CGPoint(dictionaryRepresentation: {CGFloat($0 * 10)}))
//        
//        graph.deltaX = 20
//        graph.deltaY = 30
        var i: Int = 0
        for price in chronoStockPrice {
            var tempPoint = CGPoint(x: Double(i), y: price)
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
            print("segueing to the portfolio view")
            let nextVC:PortfolioViewController = (segue.destination as? PortfolioViewController)!
            nextVC.stocks.append(stockHold[0])
        }

    }
    
    func sortStocks (stockDic: [Date:Double]) {
        let sorted = stockDic.sorted { $0.0 < $1.0 }
        //print(sorted)
        for (date, price) in sorted {
            //print(date)
            //print("Adding \(price) to chronoStockPrice")
            chronoStockPrice.append(price)
        }
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




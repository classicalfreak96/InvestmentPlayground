//
//  dataParse.swift
//  movie viewer
//
//  Created by labuser on 10/22/17.
//  Copyright © 2017 harrisonlu. All rights reserved.
//

import Foundation
import UIKit

class dataParse{
    
    var path: String = ""
    var equityList: [Stock] = []
    // Michael's api key
    let apiKey = "80FQBZRZNE3Z1FA0"
    // just in case
    let harrisonsKey = "TCAENU31I5Q6X2UU"
    // cause we have three
    let thirdApiKey  = "AA16SBF68AT9U5OS"
    
    let fourthApiKey = "M7UUAHWMRH7SAAN7"
    
    enum MyError: Error {
        case FoundNil(String)
    }
    
    
    
    private func getJSON(path: String) -> JSON {
        guard let url = URL(string: path) else { return JSON.null }
        do {
            let data = try Data(contentsOf: url)
            return try JSON(data: data)
        } catch {
            return JSON.null
        }
    }
    func searchData(function: String, symbol: String, interval: String, time_period: String){
        
    }
    
    func pullCurrentPrice(ticker: String) -> (Bool, Double) {
        var sortedPrices:[Double] = []
        var tempStock = Stock()
        let path = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=" + ticker + "&interval=1min&apikey=" + fourthApiKey
        let results = getJSON(path: path)
        for (date, value) in results["Time Series (1min)"] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date1 = dateFormatter.date(from: date)
            if let unwrappedDate = date1 {
                tempStock.SMA[unwrappedDate] = Double(value["4. close"].string!)!
            }
        }
        let sorted = tempStock.SMA.sorted { $0.0 > $1.0 }
        //print(sorted)
        for (_ , price) in sorted {
            //print(date)
            //print("Adding \(price) to chronoStockPrice")
            sortedPrices.append(price)
        }
        if sortedPrices.count == 0 {
            return (false, 0)
        }
        else {
            return (true, sortedPrices[0])
        }
    }
    
    
    func pullStockData (append: Bool, ticker: String) -> (Double, Double, Int, Double, Double, Double) {
        var tempStock = Stock()
        var validStock: Bool = true
        var dateClose = [Date : (Double, Int, Double, Double, Double)]()
        var sortedClosePrice:[Double] = []
        var sortedVolume:[Int] = []
        var sortedOpen:[Double] = []
        var sortedHigh:[Double] = []
        var sortedLow:[Double] = []
        let path = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=" + ticker + "&apikey=" + "AA16SBF68AT9U5OS"
        let results = getJSON(path: path)
        
        if results.count == 0 {
            validStock = false
        }
        for (key, _) in results {
            if key == "Error Message" {
                validStock = false
            }
        }
        if (validStock) {
            tempStock.ticker = ticker
            for (date, value) in results["Time Series (Daily)"] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date1 = dateFormatter.date(from: date)
                if let unwrappedDate = date1 {
                    tempStock.SMA[unwrappedDate] = Double(value["4. close"].string!)!
                }
                dateClose[date1!] = (Double(value["4. close"].string!)!, Int(value["5. volume"].string!)!, Double(value["1. open"].string!)!, Double(value["2. high"].string!)!, Double(value["3. low"].string!)!)
            }
            
            let sorted = dateClose.sorted { $0.0 > $1.0 }
            for (_, (price, volume, open, high, low)) in sorted {
                sortedClosePrice.append(price)
                sortedVolume.append(volume)
                sortedOpen.append(open)
                sortedHigh.append(high)
                sortedLow.append(low)
            }
            if sortedClosePrice.count != 0 {
                let dollar:Double = sortedClosePrice[0] - sortedClosePrice[1]
                let percent:Double = (sortedClosePrice[0] - sortedClosePrice[1])/sortedClosePrice[1]
                if (append) {
                    equityList.append(tempStock)
                }
                return(dollar, percent, sortedVolume[0], sortedOpen[0], sortedHigh[0], sortedLow[0])
            }
        }
        return(0,0,0,0,0,0)
    }
}

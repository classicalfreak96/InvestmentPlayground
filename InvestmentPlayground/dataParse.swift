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
    
    func searchEquity (function: String, symbol: String, interval: String, time_period: String) {
        var tempStock = Stock()
        var validStock: Bool = true
        path = "https://www.alphavantage.co/query?function=" + function + "&symbol=" + symbol + "&interval=" + interval + "&time_period=" + time_period + "&series_type=close"+"&apikey=" + "AA16SBF68AT9U5OS"
        //print(path)
        let results = getJSON(path: path)
        //print(results)

        if results.count == 0 {
            validStock = false;
            tempStock.ticker = "Invalid Stock Symbol"
        }
        for (key, _) in results {
            if key == "Error Message" {
                print("Error message")
                tempStock.ticker = "Invalid Stock Symbol"
                validStock = false;
            }
        }
        if (validStock) {
            tempStock.ticker = symbol
            print("name is: " + tempStock.ticker)
            print("technical analysis")
            print(results["Technical Analysis: SMA"])
            for (date, SMA) in results["Technical Analysis: SMA"] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date1 = dateFormatter.date(from: date)
                if let unwrappedDate = date1 {
                    tempStock.SMA[unwrappedDate] = Double(SMA["SMA"].string!)!
                }
            }
        }
        equityList.append(tempStock)
    }

    func pullStockData (ticker: String) -> (Double, Double, Int) {
        var dateClose = [Date : (Double, Int)]()
        var sortedClosePrice:[Double] = []
        var sortedVolume:[Int] = []
        let path = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=" + ticker + "&apikey=" + "AA16SBF68AT9U5OS"
        let results = getJSON(path: path)
        print("TIME SERIES DAILY ")
        for (key, value) in results["Time Series (Daily)"] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date1 = dateFormatter.date(from: key)
            dateClose[date1!] = (Double(value["4. close"].string!)!, Int(value["5. volume"].string!)!)
        }
        let sorted = dateClose.sorted { $0.0 > $1.0 }
        for (date, (price, volume)) in sorted {
            //print(date)
            sortedClosePrice.append(price)
            sortedVolume.append(volume)
        }
        //print(sortedClosePrice[0])
        //print(sortedClosePrice[1])
        let dollar:Double = sortedClosePrice[0] - sortedClosePrice[1]
        let percent:Double = (sortedClosePrice[0] - sortedClosePrice[1])/sortedClosePrice[1]
        return(dollar, percent, sortedVolume[0])
    }

    func pullCurrentPrice(ticker: String) -> Double {
        let path = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=" + ticker + "&interval=1min&apikey=" + harrisonsKey
        
        let results = getJSON(path: path)
        let intraDayPrices = results["Time Series (1min)"]
        // TODO: Get the current time, round it down to the nearest minute, and index into the dictionary
        // in the form "2017-12-01 16:00:00"
        
        // after that, call this method in calculatePortfolioValue
        // let currentPrice = intraDayPrices[time]
        
        // also change this return value
        return 0.0
    }
}

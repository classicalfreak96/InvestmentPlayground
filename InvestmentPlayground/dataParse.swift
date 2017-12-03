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
        var validStock:Bool = true;
        path = "https://www.alphavantage.co/query?function=" + function + "&symbol=" + symbol + "&interval=" + interval + "&time_period=" + time_period + "&series_type=close"+"&apikey=" + apiKey
        let results = getJSON(path: path)
        print(results)
        for (key, value) in results {
            if key == "Error Message" {
                tempStock.ticker = "Invalid Stock Symbol"
                validStock = false;
            }
        }
        if (validStock) {
        tempStock.ticker = symbol
        print("name is: " + tempStock.ticker)
        for (date, SMA) in results["Technical Analysis: SMA"] {
            //print("SMA: \(SMA)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let date1 = dateFormatter.date(from: date)
            if let unwrappedDate = date1 {
                print("inside unwrapped date")
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
        let path = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=" + ticker + "&apikey=" + apiKey
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
            print(date)
            sortedClosePrice.append(price)
            sortedVolume.append(volume)
        }
        print(sortedClosePrice[0])
        print(sortedClosePrice[1])
        let dollar:Double = sortedClosePrice[0] - sortedClosePrice[1]
        let percent:Double = (sortedClosePrice[0] - sortedClosePrice[1])/sortedClosePrice[1]
        return(dollar, percent, sortedVolume[0])
    }

    /*
    var movieList: [movie] = []
    var path: String = ""
    
    func getData (path: String) {
        let allMovies = getJSON(path: path)
        let results = allMovies["results"]
        var tempMovie = movie()
        for result in results.arrayValue  {
            tempMovie.title = result["title"].string!
            tempMovie.overview = result["overview"].string!
            tempMovie.release_date = result["release_date"].string!
            tempMovie.ID = result["id"].int!
            if (result["poster_path"] != JSON.null) {
                let imagePath = "https://image.tmdb.org/t/p/w500" + result["poster_path"].string!
            tempMovie.poster_pic = getImage(path: imagePath)
            }
            else {
                tempMovie.poster_pic = #imageLiteral(resourceName: "not-found")
            }
            print(tempMovie.title)
            movieList.append(tempMovie)
        }
    }
    
    func searchMovie (path: String) -> movie {
        let result = getJSON(path: path)
        var tempMovie = movie()
        tempMovie.title = result["title"].string!
        tempMovie.overview = result["overview"].string!
        tempMovie.release_date = result["release_date"].string!
        tempMovie.ID = result["id"].int!
        if (result["poster_path"] != JSON.null) {
            let imagePath = "https://image.tmdb.org/t/p/w500" + result["poster_path"].string!
            tempMovie.poster_pic = getImage(path: imagePath)
        }
        else {
            tempMovie.poster_pic = #imageLiteral(resourceName: "not-found")
        }
        return(tempMovie)
    }
    
    func getImage (path: String) -> UIImage {
        let picture = URL(string: path)
        if (picture != nil) {
            let picData = try? Data(contentsOf: picture!)
            if (picData != nil) {
                let movPoster: UIImage = UIImage(data: picData!)!
                return movPoster
            }
        }
        return #imageLiteral(resourceName: "not-found")
    }
     */
}

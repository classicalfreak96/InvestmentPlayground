//
//  dataParse.swift
//  movie viewer
//
//  Created by labuser on 10/22/17.
//  Copyright © 2017 harrisonlu. All rights reserved.
//

import Foundation
import UIKit

class dataParse{ //change this for stock API
    
    var path: String = ""
    var equityList: [Stock] = []
    
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
        path = "https://www.alphavantage.co/query?function=" + function + "&symbol=" + symbol + "&interval=" + interval + "&time_period=" + time_period + "&series_type=close"+"&apikey=TCAENU31I5Q6X2UU"
        print(path)
        let results = getJSON(path: path)
        for (key, value) in results {
            if key == "Error Message" {
                tempStock.ticker = "Invalid Stock Symbol"
                validStock = false;
            }
        }
        print(results)
        if (validStock) {
        tempStock.ticker = symbol
        print("name is: " + tempStock.ticker)
        for (date, SMA) in results["Technical Analysis: SMA"] {
            print(date)
            print(Double(SMA["SMA"].string!)!)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let date1 = dateFormatter.date(from: date)
            tempStock.SMA[date1!] = Double(SMA["SMA"].string!)!
            print(date1!)
        }
        for result in tempStock.SMA {
            print(result)
        }
        }
        equityList.append(tempStock)
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

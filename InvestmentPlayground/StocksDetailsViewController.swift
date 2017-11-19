//
//  StocksDetailsViewController.swift
//  movie viewer tabbed
//
//  Created by Michelle Xu on 11/18/17.
//  Copyright © 2017 Michelle Xu. All rights reserved.
//

import UIKit

class StocksDetailsViewController: UIViewController{
    

    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var changeDollars: UILabel!
    
    @IBOutlet weak var changePercent: UILabel!
    
    @IBOutlet weak var marketCap: UILabel!
    
    @IBOutlet weak var peRatio: UILabel!
    
    @IBOutlet weak var betaValue: UILabel!
    
    @IBOutlet weak var graph: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        price.text = "87.45"
        changeDollars.text = "0.34"
        changePercent.text = "1.23"
        marketCap.text = "13.5 B"
        peRatio.text = "0.94"
        betaValue.text = "0.95"
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

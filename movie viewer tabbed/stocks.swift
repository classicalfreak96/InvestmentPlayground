//
//  movies.swift
//  movie viewer
//
//  Created by labuser on 10/22/17.
//  Copyright © 2017 harrisonlu. All rights reserved.
//

import Foundation
import UIKit

struct movie { // CHANGE FOR STOCKS
    var title:String
    var overview: String
    var release_date: String
    var poster_pic : UIImage!
    var ID: Int
    
    init() {
        title = ""
        overview = ""
        release_date = ""
        ID = 0
    }
}

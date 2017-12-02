//
//  lineChartExtensions.swift
//  InvestmentPlayground
//
//  Created by Michelle Xu on 12/2/17.
//  Copyright © 2017 Nick DesMarais. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func size(withSystemFontSize pointSize: CGFloat) -> CGSize {
        return (self as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: pointSize)])
    }
}

extension CGPoint {
    func adding(x: CGFloat) -> CGPoint { return CGPoint(x: self.x + x, y: self.y)}
    func adding(y: CGFloat) -> CGPoint { return CGPoint(x: self.x, y: self.y + y)}
}

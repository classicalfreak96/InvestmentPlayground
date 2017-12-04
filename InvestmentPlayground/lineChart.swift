//
//  lineChart.swift
//  InvestmentPlayground
//
//  Created by Michelle Xu on 12/2/17.
//  Copyright © 2017 Nick DesMarais. All rights reserved.
//
//code partially adapted from https://medium.com/@tstenerson/lets-make-a-line-chart-in-swift-3-5e819e6c1a00 royalty-free

import Foundation
import UIKit

class LineChart: UIView {
    
    let lineLayer = CAShapeLayer()
    let circlesLayer = CAShapeLayer()
    
    var chartTransform: CGAffineTransform?              //Matrix transform the point
    
    @IBInspectable var lineColor: UIColor = UIColor.green {
        didSet {
            lineLayer.strokeColor = lineColor.cgColor
        }
    }
    @IBInspectable var lineWidth: CGFloat = 1
    @IBInspectable var showPoints: Bool = true {
        didSet {
            circlesLayer.isHidden = !showPoints
        }
    }
    @IBInspectable var circleColor: UIColor = UIColor.green {
        didSet {
            circlesLayer.fillColor = circleColor.cgColor
        }
    }
    @IBInspectable var circleSizeMultiplier: CGFloat = 3
    @IBInspectable var axisColor: UIColor = UIColor.white
    @IBInspectable var showInnerLines: Bool = true
    @IBInspectable var labelFontSize: CGFloat = 10
    
    var axisLineWidth: CGFloat = 1
    var deltaX: CGFloat = 10
    var deltaY: CGFloat = 15
    var xMax: CGFloat = 100
    var yMax: CGFloat = 100
    var xMin: CGFloat = 0
    var yMin: CGFloat = 0
    var yMaxAbs: CGFloat = 0
    var yMinAbs: CGFloat = 0
    
    var data: [CGPoint]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        combinedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        combinedInit()
    }
    
    func combinedInit() {
        layer.addSublayer(lineLayer)
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = lineColor.cgColor
        
        layer.addSublayer(circlesLayer)
        circlesLayer.fillColor = circleColor.cgColor
        
        layer.borderWidth = 1
        layer.borderColor = axisColor.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = bounds
        circlesLayer.frame = bounds
        
        if let d = data {
            setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
            plot(d)
        }
    }
    
    func setAxisRange(forPoints points: [CGPoint]) {
        guard !points.isEmpty else {return}
        
        setDeltaRange(points: points)
        
        let xs = points.map() {$0.x}
        let ys = points.map() {$0.y}
        
        xMax = ceil(xs.max()! / deltaX) * deltaX
        yMax = ceil(ys.max()! / deltaY) * deltaY
        xMin = floor(xs.min()! / deltaX) * deltaX
        yMin = floor(ys.min()! / deltaY) * deltaY
        yMaxAbs = ys.max()!
        yMinAbs = ys.min()!
        print("yMax is: " + String(describing: yMax))
        print("yMin is: " + String(describing: yMin))
        print("yMaxAbs is: " + String(describing: yMaxAbs))
        print("yMinAbs is: " + String(describing: yMinAbs))
        setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
    }
    
    func setDeltaRange(points: [CGPoint]) {
        
        let ys = points.map() {$0.y}
        
        if ((ys.max()! - ys.min()!) > 100) {
            deltaY = 70
        }
    }
    
    func setTransform(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        let xLabelSize = "\(Int(maxX))".size(withSystemFontSize: labelFontSize)
        let yLabelSize = "\(Int(maxY))".size(withSystemFontSize: labelFontSize)
        
        let xOffset = xLabelSize.height + 2
        let yOffset = yLabelSize.width + 5
        
        let xScale = (bounds.width - yOffset - xLabelSize.width/2 - 2)/(maxX-minX)
        let yScale = (bounds.height - xOffset - yLabelSize.height/2 - 2)/(maxY)
        
        chartTransform = CGAffineTransform(a: xScale, b: 0, c: 0, d: -yScale, tx: yOffset, ty: bounds.height - xOffset)
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let t = chartTransform else {return}
        drawAxes(in: context, usingTransform: t)
    }
    
    func drawAxes(in context: CGContext, usingTransform t: CGAffineTransform) {
        context.saveGState()
        
        let thickerLines = CGMutablePath()
        let thinnerLines = CGMutablePath()
        
        let xAxisPoints = [CGPoint(x: xMin, y:0), CGPoint(x: xMax, y: 0)]
        let yAxisPoints = [CGPoint(x: 0, y: 0), CGPoint(x:0, y: yMax)]
        
        thickerLines.addLines(between: xAxisPoints, transform: t)
        thickerLines.addLines(between: yAxisPoints, transform: t)
        
        for x in stride(from: xMin, through: xMax, by: deltaX) {
            
            let tickPoints = showInnerLines ?
                [CGPoint(x: x, y: 0).applying(t), CGPoint(x: x, y: yMax).applying(t)] :
                [CGPoint(x: x, y: 0).applying(t), CGPoint(x: x, y: 0).applying(t).adding(y: -5)]
            
            
            thinnerLines.addLines(between: tickPoints)
            
            if x != xMin {
                let label = "\(Int(x))" as NSString
                let labelSize = "\(Int(x))".size(withSystemFontSize: labelFontSize)
                let labelDrawPoint = CGPoint(x: x, y: 0).applying(t)
                    .adding(x: -labelSize.width/2)
                    .adding(y: 1)
                
                label.draw(at: labelDrawPoint,
                           withAttributes:
                    [NSFontAttributeName: UIFont.systemFont(ofSize: labelFontSize),
                     NSForegroundColorAttributeName: axisColor])
            }
        }
        
        for y in stride(from: 0, through: yMax, by: deltaY) {
        
            let tickPoints = showInnerLines ?
                [CGPoint(x: xMin, y: y).applying(t), CGPoint(x: xMax, y: y).applying(t)] :
                [CGPoint(x: 0, y: y).applying(t), CGPoint(x: 0, y: y).applying(t).adding(x: 5)]
            
            
            thinnerLines.addLines(between: tickPoints)
                let tempY = yMin + (((y)/yMax) * (yMax - yMin))
                print("tempY is: " + String(describing: tempY))
                let label = "\(Int(tempY))" as NSString
                let labelSize = "\(Int(tempY))".size(withSystemFontSize: labelFontSize)
                let labelDrawPoint = CGPoint(x: 0, y: y).applying(t)
                    .adding(x: -labelSize.width - 1)
                    .adding(y: -labelSize.height/2)
                label.draw(at: labelDrawPoint,
                           withAttributes:
                    [NSFontAttributeName: UIFont.systemFont(ofSize: labelFontSize),
                     NSForegroundColorAttributeName: axisColor])
        }
        
        context.setStrokeColor(axisColor.cgColor)
        context.setLineWidth(axisLineWidth)
        context.addPath(thickerLines)
        context.strokePath()
        
        context.setStrokeColor(axisColor.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(axisLineWidth/2)
        context.addPath(thinnerLines)
        context.strokePath()
        
        context.restoreGState()
    }
    
    func plot(_ points: [CGPoint]) {
        var tempPoints:[CGPoint] = []
        lineLayer.path = nil
        circlesLayer.path = nil
        data = nil
        
        guard !points.isEmpty else {return}
        
        if self.chartTransform == nil {
            setAxisRange(forPoints: points)
        }
        
        self.data = points
        
        for point in points{
            let newY = point.y - ((yMin/(yMax-yMin)) * (yMax - point.y))
            tempPoints.append(CGPoint.init(x: point.x, y: newY))
        }
        
        let linePath = CGMutablePath()
        linePath.addLines(between: tempPoints, transform: chartTransform!)
        
        lineLayer.path = linePath
        
        if showPoints {
            circlesLayer.path = circles(atPoints: tempPoints, withTransform: chartTransform!)
        }
    }
    
    func circles(atPoints points: [CGPoint], withTransform t: CGAffineTransform) -> CGPath {
        
        let path = CGMutablePath()
        let radius = lineLayer.lineWidth * circleSizeMultiplier/2
        for i in points {
            let p = i.applying(t)
            let rect = CGRect(x: p.x - radius, y: p.y - radius, width: radius * 2, height: radius * 2)
            path.addEllipse(in: rect)
            
        }
        
        return path
    }
}

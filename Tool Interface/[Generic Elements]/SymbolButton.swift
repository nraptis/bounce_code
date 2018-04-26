//
//  SymbolButton.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 2/22/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class SymbolButton: DrawableButton {
    
    //Assumed all points range [0.0 - 1.0]
    var symbolPoints = [CGPoint]() { didSet { setNeedsDisplay() } }
    var symbolScale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    var fillColor:UIColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var fillColorDown:UIColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0) { didSet { setNeedsDisplay() } }
    
    deinit {
        
    }
    
    override func setUp() {
        super.setUp()
        backgroundColor = UIColor.clear
        clipsToBounds = false
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        var symbolSize: CGFloat = bounds.width
        if bounds.height < symbolSize {
            symbolSize = bounds.height
        }
        
        symbolSize *= symbolScale
        
        let symbolFrameX: CGFloat = bounds.width / 2.0 - symbolSize / 2.0
        let symbolFrameY: CGFloat = bounds.height / 2.0 - symbolSize / 2.0
        
        
        //context.setFillColor(UIColor(red: 0.5, green: 0.25, blue: 0.12, alpha: 0.4).cgColor)
        //context.fill(CGRect(x: symbolFrameX, y: symbolFrameY, width: symbolSize, height: symbolSize))
        
        
        let path = ApplicationController.path(fromPoints: &symbolPoints, inRect: CGRect(x: symbolFrameX, y: symbolFrameY, width: symbolSize, height: symbolSize))
        
        context.beginPath()
        context.addPath(path.cgPath)
        context.closePath()
        
        context.setFillColor((isPressed ? fillColorDown : fillColor).cgColor)
        
        //context.setShadow(offset: CGSize(width: -1, height: 2), blur: shadowBlur, color: shadowColor.cgColor)
        context.fillPath()
        context.restoreGState()
        
    }
    
    func setSymbolCheckmark() {
        Style.setSymbolCheckmark(arr: &symbolPoints)
        setNeedsDisplay()
    }
    
    func setSymbolCloseX() {
        Style.setSymbolCloseX(arr: &symbolPoints)
        setNeedsDisplay()
    }
    
    func setSymbolChevronLeft() {
        Style.setSymbolChevronLeft(arr: &symbolPoints)
        setNeedsDisplay()
    }
    
    func setSymbolChevronDown() {
        Style.setSymbolChevronDown(arr: &symbolPoints)
        setNeedsDisplay()
    }
    
    func setSymbolChevronRight() {
        Style.setSymbolChevronRight(arr: &symbolPoints)
        setNeedsDisplay()
    }
    
    func setSymbolChevronUp() {
        Style.setSymbolChevronUp(arr: &symbolPoints)
        setNeedsDisplay()
    }
    
    func setSymbolBackspacer() {
        Style.setSymbolBackspacer(arr: &symbolPoints)
        setNeedsDisplay()
    }
    
    /*
    func setSymbolCheckmark() {
        symbolPoints.removeAll()
        symbolPoints.append(CGPoint(x: 0.41, y: 0.54))
        symbolPoints.append(CGPoint(x: 0.43, y: 0.54))
        symbolPoints.append(CGPoint(x: 0.72, y: 0.25))
        symbolPoints.append(CGPoint(x: 0.75, y: 0.25))
        symbolPoints.append(CGPoint(x: 0.86, y: 0.36))
        symbolPoints.append(CGPoint(x: 0.86, y: 0.39))
        symbolPoints.append(CGPoint(x: 0.44, y: 0.81))
        symbolPoints.append(CGPoint(x: 0.40, y: 0.81))
        symbolPoints.append(CGPoint(x: 0.13, y: 0.54))
        symbolPoints.append(CGPoint(x: 0.13, y: 0.51))
        symbolPoints.append(CGPoint(x: 0.24, y: 0.40))
        symbolPoints.append(CGPoint(x: 0.27, y: 0.40))
        setNeedsDisplay()
    }
    
    func setSymbolCloseX() {
        symbolPoints.removeAll()
        symbolPoints.append(CGPoint(x: 0.50, y: 0.38))
        symbolPoints.append(CGPoint(x: 0.77, y: 0.11))
        symbolPoints.append(CGPoint(x: 0.80, y: 0.11))
        symbolPoints.append(CGPoint(x: 0.89, y: 0.20))
        symbolPoints.append(CGPoint(x: 0.89, y: 0.23))
        symbolPoints.append(CGPoint(x: 0.62, y: 0.50))
        symbolPoints.append(CGPoint(x: 0.89, y: 0.77))
        symbolPoints.append(CGPoint(x: 0.89, y: 0.80))
        symbolPoints.append(CGPoint(x: 0.80, y: 0.89))
        symbolPoints.append(CGPoint(x: 0.77, y: 0.89))
        symbolPoints.append(CGPoint(x: 0.50, y: 0.62))
        symbolPoints.append(CGPoint(x: 0.23, y: 0.89))
        symbolPoints.append(CGPoint(x: 0.20, y: 0.89))
        symbolPoints.append(CGPoint(x: 0.11, y: 0.80))
        symbolPoints.append(CGPoint(x: 0.11, y: 0.77))
        symbolPoints.append(CGPoint(x: 0.38, y: 0.50))
        symbolPoints.append(CGPoint(x: 0.11, y: 0.23))
        symbolPoints.append(CGPoint(x: 0.11, y: 0.20))
        symbolPoints.append(CGPoint(x: 0.20, y: 0.11))
        symbolPoints.append(CGPoint(x: 0.23, y: 0.11))
        setNeedsDisplay()
    }
    
    func setSymbolChevronLeft() {
        symbolPoints.removeAll()
        symbolPoints.append(CGPoint(x: 0.21, y: 0.51))
        symbolPoints.append(CGPoint(x: 0.21, y: 0.49))
        symbolPoints.append(CGPoint(x: 0.56, y: 0.14))
        symbolPoints.append(CGPoint(x: 0.59, y: 0.14))
        symbolPoints.append(CGPoint(x: 0.68, y: 0.23))
        symbolPoints.append(CGPoint(x: 0.68, y: 0.26))
        symbolPoints.append(CGPoint(x: 0.44, y: 0.50))
        symbolPoints.append(CGPoint(x: 0.68, y: 0.74))
        symbolPoints.append(CGPoint(x: 0.68, y: 0.77))
        symbolPoints.append(CGPoint(x: 0.59, y: 0.86))
        symbolPoints.append(CGPoint(x: 0.56, y: 0.86))
        setNeedsDisplay()
    }
    
    func setSymbolChevronDown() {
        symbolPoints.removeAll()
        symbolPoints.append(CGPoint(x: 0.50, y: 0.56))
        symbolPoints.append(CGPoint(x: 0.74, y: 0.32))
        symbolPoints.append(CGPoint(x: 0.77, y: 0.32))
        symbolPoints.append(CGPoint(x: 0.86, y: 0.41))
        symbolPoints.append(CGPoint(x: 0.86, y: 0.44))
        symbolPoints.append(CGPoint(x: 0.51, y: 0.79))
        symbolPoints.append(CGPoint(x: 0.49, y: 0.79))
        symbolPoints.append(CGPoint(x: 0.14, y: 0.44))
        symbolPoints.append(CGPoint(x: 0.14, y: 0.41))
        symbolPoints.append(CGPoint(x: 0.23, y: 0.32))
        symbolPoints.append(CGPoint(x: 0.26, y: 0.32))
        setNeedsDisplay()
    }
    
    func setSymbolChevronRight() {
        symbolPoints.removeAll()
        symbolPoints.append(CGPoint(x: 0.41, y: 0.14))
        symbolPoints.append(CGPoint(x: 0.44, y: 0.14))
        symbolPoints.append(CGPoint(x: 0.79, y: 0.49))
        symbolPoints.append(CGPoint(x: 0.79, y: 0.51))
        symbolPoints.append(CGPoint(x: 0.44, y: 0.86))
        symbolPoints.append(CGPoint(x: 0.41, y: 0.86))
        symbolPoints.append(CGPoint(x: 0.32, y: 0.77))
        symbolPoints.append(CGPoint(x: 0.32, y: 0.74))
        symbolPoints.append(CGPoint(x: 0.56, y: 0.50))
        symbolPoints.append(CGPoint(x: 0.32, y: 0.26))
        symbolPoints.append(CGPoint(x: 0.32, y: 0.23))
        setNeedsDisplay()
    }
    
    func setSymbolChevronUp() {
        symbolPoints.removeAll()
        symbolPoints.append(CGPoint(x: 0.49, y: 0.21))
        symbolPoints.append(CGPoint(x: 0.51, y: 0.21))
        symbolPoints.append(CGPoint(x: 0.86, y: 0.56))
        symbolPoints.append(CGPoint(x: 0.86, y: 0.59))
        symbolPoints.append(CGPoint(x: 0.77, y: 0.68))
        symbolPoints.append(CGPoint(x: 0.74, y: 0.68))
        symbolPoints.append(CGPoint(x: 0.50, y: 0.44))
        symbolPoints.append(CGPoint(x: 0.26, y: 0.68))
        symbolPoints.append(CGPoint(x: 0.23, y: 0.68))
        symbolPoints.append(CGPoint(x: 0.14, y: 0.59))
        symbolPoints.append(CGPoint(x: 0.14, y: 0.56))
        setNeedsDisplay()
    }
    */
    
    
}

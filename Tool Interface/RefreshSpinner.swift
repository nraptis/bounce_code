//
//  RefreshSpiner.swift
//  CarSale
//
//  Created by Raptis, Nicholas on 10/6/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit

class RefreshSpinner : UIView
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        backgroundColor = UIColor.clear
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    private let colorRegular = UIColor(red: 0.62, green: 0.62, blue: 0.62, alpha: 0.8)
    private let colorDark1 = UIColor(red: 0.62 * 0.6, green: 0.62 * 0.6, blue: 0.62 * 0.6, alpha: 0.8)
    private let colorDark2 = UIColor(red: 0.62 * 0.7, green: 0.62 * 0.7, blue: 0.62 * 0.7, alpha: 0.8)
    private let colorDark3 = UIColor(red: 0.62 * 0.8, green: 0.62 * 0.8, blue: 0.62 * 0.8, alpha: 0.8)
    private let colorDark4 = UIColor(red: 0.62 * 0.9, green: 0.62 * 0.9, blue: 0.62 * 0.9, alpha: 0.8)
    
    private var _revealPercent: CGFloat = 0.0
    var revealPercent: CGFloat {
        set {
            _revealPercent = newValue
            var count:Int = 0
            if _revealPercent < 0.0 {
                _revealPercent = 0.0
                count = 0
            } else if _revealPercent > 1.0 {
                _revealPercent = 1.0
                count = spokeCount
            } else {
                count = Int(CGFloat(spokeCount) * _revealPercent)
            }
            
            //We don't need to redraw if the number of spokes didn't change.
            if count != _displaySpokeCount {
                _displaySpokeCount = count
                setNeedsDisplay()
            }
        }
        get {
            return _revealPercent
        }
    }
    
    private var _displaySpokeCount:Int = 0
    
    var spokeCount:Int = 10 { didSet { setNeedsDisplay() } }
    
    var thickness: CGFloat = 4.0 { didSet { setNeedsDisplay() } }

    var spokeInnerRadius:CGFloat = 10.0 { didSet { setNeedsDisplay() } }
    var spokeOuterRadius:CGFloat = 15.0 { didSet { setNeedsDisplay() } }
    
    private var _isLoading = false
    var isLoading: Bool {
        set {
            if(newValue && !_isLoading) {
                
                /*
                UIView.animate(withDuration: 1.125, animations: {
                    var t = CGAffineTransform.identity
                    t = t.rotated(by: Math.PI)
                    self.transform = t
                })
                */
            }
            
            _isLoading = newValue
            
            if _isLoading == false {
                reset()
            }
            setNeedsDisplay()
        }
        get {
            return _isLoading
        }
    }
    
    private var _loadAnimationStartIndex = 0
    private var _loadAnimationTimer = 0
    
    private func reset() {
        _isLoading = false
        startRotation = 0.0
        _loadAnimationTimer = 0
        _loadAnimationStartIndex = 0
        self.transform = CGAffineTransform.identity
    }
    
    func update() {
        if _isLoading {
            _loadAnimationTimer += 1
            if _loadAnimationTimer >= 4 {
                _loadAnimationTimer = 0
                _loadAnimationStartIndex += 1
                if _loadAnimationStartIndex >= spokeCount {
                    _loadAnimationStartIndex -= spokeCount
                }
                setNeedsDisplay()
            }
        }
    }
    
    
    private var startRotation: CGFloat = 0.0
    
    override func draw(_ rect: CGRect) {
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        let center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        
        var displayCount = _displaySpokeCount
        if _isLoading { displayCount = spokeCount }
        
        let darkIndex1 = _loadAnimationStartIndex
        var darkIndex2 = _loadAnimationStartIndex - 1
        var darkIndex3 = _loadAnimationStartIndex - 2
        var darkIndex4 = _loadAnimationStartIndex - 3
        
        if darkIndex2 < 0 { darkIndex2 += spokeCount }
        if darkIndex3 < 0 { darkIndex3 += spokeCount }
        if darkIndex4 < 0 { darkIndex4 += spokeCount }
        
        for i in 0..<displayCount {
            let percent = CGFloat(i) / CGFloat(spokeCount)
            var rot = percent * Math.PI2 + startRotation
            if rot > Math.PI2 {
                rot -= Math.PI2
            }
            
            let dir = CGPoint(x: sin(rot), y: -cos(rot))
            
            let p0 = CGPoint(x: center.x + dir.x * spokeInnerRadius, y: center.y + dir.y * spokeInnerRadius)
            let p1 = CGPoint(x: center.x + dir.x * spokeOuterRadius, y: center.y + dir.y * spokeOuterRadius)
            
            let path = UIBezierPath()
            path.addArc(withCenter: p1, radius: thickness / 2.0, startAngle: rot + Math.PI, endAngle: rot, clockwise: true)
            path.addArc(withCenter: p0, radius: thickness / 2.0, startAngle: rot, endAngle: rot - Math.PI, clockwise: true)
            path.close()
            
            context.addPath(path.cgPath)
            
            if _isLoading {
                if i == darkIndex1 { context.setFillColor(colorDark1.cgColor) }
                else if i == darkIndex2 { context.setFillColor(colorDark2.cgColor) }
                else if i == darkIndex3 { context.setFillColor(colorDark3.cgColor) }
                else if i == darkIndex4 { context.setFillColor(colorDark4.cgColor) }
                else { context.setFillColor(colorRegular.cgColor) }
            } else {
                context.setFillColor(colorRegular.cgColor)
            }
            context.fillPath()
            
        }
        context.restoreGState()
    }
}

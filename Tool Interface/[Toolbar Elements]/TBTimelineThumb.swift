//
//  TBTimelineThumb.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/28/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class TBTimelineThumb: UIView {
    
    var maxHeight: CGFloat?
    
    var imageAccessory = UIImage(named: "timeline_accessory_playhead")
    
    var isSelected: Bool = false { didSet { setNeedsDisplay() } }
    
    var cornerUL = true { didSet { setNeedsDisplay() } }
    var cornerUR = true { didSet { setNeedsDisplay() } }
    var cornerDR = true { didSet { setNeedsDisplay() } }
    var cornerDL = true { didSet { setNeedsDisplay() } }
    
    var fill:Bool = true { didSet { setNeedsDisplay() } }
    var fillDown:Bool = true { didSet { setNeedsDisplay() } }
    
    var fillColor:UIColor = styleColorOrange { didSet { setNeedsDisplay() } }
    var fillColorDown:UIColor = styleColorOrangeLight { didSet { setNeedsDisplay() } }
    
    var cornerRadius:CGFloat = 6.0 { didSet { setNeedsDisplay() } }
    
    deinit {
        print("Deinit - TBTimelineThumb")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setUp() {
        cornerRadius = ApplicationController.shared.tbButtonHeight / 12.0
        maxHeight = CGFloat(Int(bounds.size.height * 0.72))
        
        //self.backgroundColor = UIColor(red: 0.666, green: 0.333, blue: 0.125, alpha: 0.4)
        
        self.backgroundColor = UIColor.clear
    }
    
    var drawRect: CGRect {
        var rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(Int(bounds.width + 0.5)), height: CGFloat(Int(bounds.height + 0.5)))
        if let max = maxHeight, rect.height > max {
            rect.size.height = max
            rect.origin.y = CGFloat(Int(bounds.height / 2.0 - max / 2.0))
        }
        return rect
    }
    
    override func draw(_ rect: CGRect) {
        
        //super.drawRect(rect)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        //var rect = drawRect
        
        
        
            let clipPath = UIBezierPath(roundedRect: drawRect, byRoundingCorners: DrawableButton.getCornerType(ul: cornerUL, ur: cornerUR, dr: cornerDR, dl: cornerDL), cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            context.saveGState()
            context.beginPath()
            context.addPath(clipPath)
            context.setFillColor(isSelected ? fillColorDown.cgColor : fillColor.cgColor)
            context.closePath()
            context.fillPath()
            context.restoreGState()
    
    
        if let img = imageAccessory, img.size.width > 2.0 && img.size.height > 2.0 {
            var imageWidth = img.size.width
            var imageHeight = img.size.width
            let maxHeight = drawRect.size.height * 0.85
            let heightScale: CGFloat = imageHeight / maxHeight
            if heightScale > 1.0 {
                imageWidth /= heightScale
                imageHeight /= heightScale
            }
            imageWidth = CGFloat(Int(imageWidth + 0.5))
            imageHeight = CGFloat(Int(imageHeight + 0.5))
            let imageLeft = CGFloat(Int(rect.midX - imageWidth / 2.0))
            let imageTop = CGFloat(Int(rect.midY - imageHeight / 2.0))
            let accRect = CGRect(x: imageLeft, y: imageTop, width: imageWidth, height: imageHeight)
            img.draw(in: accRect, blendMode: .normal, alpha: 0.4)
        }
    }
}

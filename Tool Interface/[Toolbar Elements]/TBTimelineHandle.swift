//
//  TBTimelineHandle.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/28/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class TBTimelineHandle: UIView {
    
    var maxHeight: CGFloat?
    var imageAccessory: UIImage?
    
    var isSelected: Bool = false { didSet { setNeedsDisplay() } }
    var isLeft: Bool = false { didSet { setNeedsDisplay() } }
    var cornerUL = true { didSet { setNeedsDisplay() } }
    var cornerUR = true { didSet { setNeedsDisplay() } }
    var cornerDR = true { didSet { setNeedsDisplay() } }
    var cornerDL = true { didSet { setNeedsDisplay() } }
    
    var fillColor:UIColor = styleColorOrangeDark { didSet { setNeedsDisplay() } }
    var fillColorDown:UIColor = styleColorOrange { didSet { setNeedsDisplay() } }
    
    var cornerRadius:CGFloat = 6.0 { didSet { setNeedsDisplay() } }
    
    deinit {
        print("Deinit - TBTimelineHandle")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setUp(left: Bool) {
        cornerRadius = CGFloat(Int(ApplicationController.shared.tbButtonHeight / 4.0 + 0.25))
        
        isLeft = left
        
        if isLeft {
            cornerDR = false
            cornerUR = false
        } else {
            cornerDL = false
            cornerUL = false
        }
        
        //maxHeight = CGFloat(Int(bounds.size.height * 0.8))
        
        //self.backgroundColor = UIColor.red
        maxHeight = CGFloat(Int(bounds.size.height * 0.76))
        
        if left {
            imageAccessory = UIImage(named: "timeline_accessory_trim_leading")
        } else {
            imageAccessory = UIImage(named: "timeline_accessory_trim_trailing")
        }
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
        
        context.saveGState()
        let clipPath = UIBezierPath(roundedRect: drawRect, byRoundingCorners: DrawableButton.getCornerType(ul: cornerUL, ur: cornerUR, dr: cornerDR, dl: cornerDL), cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        context.beginPath()
        context.addPath(clipPath)
        context.setFillColor(isSelected ? fillColorDown.cgColor : fillColor.cgColor)
        context.closePath()
        context.fillPath()
        context.restoreGState()
        
        if let img = imageAccessory, img.size.width > 2.0 && img.size.height > 2.0 {
            
            let sidePadding: CGFloat = 3.0
            var imageWidth = img.size.width
            var imageHeight = img.size.width
            let maxHeight = rect.size.height * 0.9
            let heightScale: CGFloat = imageHeight / maxHeight
            
            if heightScale > 1.0 {
                imageWidth /= heightScale
                imageHeight /= heightScale
            }
            
            imageWidth = CGFloat(Int(imageWidth + 0.5))
            imageHeight = CGFloat(Int(imageHeight + 0.5))
            let imageTop = CGFloat(Int(rect.midY - imageHeight / 2.0))
            
            if isLeft {
                let imageX: CGFloat = CGFloat(Int(rect.maxX - (sidePadding + imageWidth)))
                let accRect = CGRect(x: imageX, y: imageTop, width: imageWidth, height: imageHeight)
                img.draw(in: accRect, blendMode: .normal, alpha: 0.4)
            } else {
                let imageX: CGFloat = CGFloat(Int(rect.minX + sidePadding))
                let accRect = CGRect(x: imageX, y: imageTop, width: imageWidth, height: imageHeight)
                img.draw(in: accRect, blendMode: .normal, alpha: 0.4)
            }
        }
    }
    
}

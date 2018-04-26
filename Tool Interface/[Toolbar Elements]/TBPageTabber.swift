//
//  TBPageTabber.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/18/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class TBPageTabber: RRButton {
    override func setUp() {
        super.setUp()
        //styleSetToolbarButton()
        //styleSetCheck()
        
    }
    
    var pageImage: UIImage? {
        if isPressed == true && isEnabled == true {
            if let img = pageImageDown {
                return img
            }
            if let img = pageImageUp {
                return img
            }
        } else {
            if let img = pageImageUp {
                return img
            }
            if let img = pageImageDown {
                return img
            }
        }
        return nil
    }
    
    func setPageImages(path: String?, pathSelected: String?) {
        if path != nil { pageImagePathUp = path!; setNeedsDisplay() }
        if pathSelected != nil { pageImagePathDown = pathSelected!; setNeedsDisplay() }
    }
    
    private var _pageImageUp:UIImage?
    var pageImageUp: UIImage? {
        if _pageImageUp == nil && pageImagePathUp != nil {
            _pageImageUp = FileUtils.loadImage(pageImagePathUp)
        }
        return _pageImageUp
    }
    
    private var _pageImageDown:UIImage?
    var pageImageDown: UIImage? {
        if _pageImageDown == nil && pageImagePathDown != nil {
            _pageImageDown = FileUtils.loadImage(pageImagePathDown)
        }
        return _pageImageDown
    }
    
    var pageImagePathUp: String? { didSet { setNeedsDisplay() } }
    var pageImagePathDown: String? { didSet { setNeedsDisplay() } }
    
    
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        var dr = drawRect
        
        
        /*
        var drawStroke:Bool = false
        var drawFill:Bool = false
        
        if isPressed {
            if strokeDown { drawStroke = true }
            if fillDown { drawFill = true }
        } else {
            if stroke { drawStroke = true }
            if fill { drawFill = true }
        }
        if strokeWidth <= 0.0 { drawStroke = false }
        
        
        
        
        
        if drawStroke {
            
            if drawFill {
                
                let clipPath = UIBezierPath(roundedRect: rect, byRoundingCorners: DrawableButton.getCornerType(ul: cornerUL, ur: cornerUR, dr: cornerDR, dl: cornerDL), cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
                context.beginPath()
                context.addPath(clipPath)
                context.setFillColor((isPressed ? strokeColorDown : strokeColor).cgColor)
                context.closePath()
                context.fillPath()
                
                let inset = strokeWidth / 2.0
                rect = rect.insetBy(dx: inset, dy: inset)
            } else {
                
                let inset = strokeWidth / 2.0
                rect = rect.insetBy(dx: inset, dy: inset)
                
                let clipPath = UIBezierPath(roundedRect: rect, byRoundingCorners: DrawableButton.getCornerType(ul: cornerUL, ur: cornerUR, dr: cornerDR, dl: cornerDL), cornerRadii: CGSize(width: cornerRadius - inset, height: cornerRadius - inset)).cgPath
                
                context.beginPath()
                context.addPath(clipPath)
                context.setStrokeColor((isPressed ? strokeColorDown : strokeColor).cgColor)
                context.setLineWidth(strokeWidth)
                context.closePath()
                context.strokePath()
            }
        }
        
        if drawFill {
            let clipPath = UIBezierPath(roundedRect: rect,
                                        byRoundingCorners: DrawableButton.getCornerType(ul: cornerUL, ur: cornerUR, dr: cornerDR, dl: cornerDL),
                                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            context.beginPath()
            context.addPath(clipPath)
            context.setFillColor(isPressed ? fillColorDown.cgColor : fillColor.cgColor)
            context.closePath()
            context.fillPath()
        }
        
        drawImage()
        
        if isLocked {
            if let lockImage = ApplicationController.shared.lockImage {
                if lockImage.size.width > 2.0 && lockImage.size.height > 2.0 {
                    let lockImageRect = CGRect(x: 6.0, y: 6.0, width: lockImage.size.width, height: lockImage.size.height)
                    lockImage.draw(in: lockImageRect, blendMode: .normal, alpha: 1.0)
                }
            }
        }
         */
        
        
        if let pageImg = pageImage {
            let imgRect = CGRect(x: bounds.width / 2.0 - pageImg.size.width / 2.0, y: dr.origin.y + dr.size.height - (pageImg.size.height + strokeWidth), width: pageImg.size.width, height: pageImg.size.height)
            pageImg.draw(in: imgRect, blendMode: .normal, alpha: 1.0)
        }
        
        context.restoreGState()
    }
    
//    func drawImage() {
//        let rect = drawRect
//        if let img = image {
//            var imageAlpha: CGFloat = 1.0
//            if isEnabled == false { imageAlpha = 0.5 }
//            
//            if fitImage {
//                let fit = CGSize(width: rect.size.width, height: rect.size.height).getAspectFit(img.size)
//                let size = fit.size
//                let imgRect = CGRect(x: bounds.width / 2.0 - size.width / 2.0, y: bounds.height / 2.0 - size.height / 2.0, width: size.width, height: size.height)
//                img.draw(in: imgRect, blendMode: .normal, alpha: imageAlpha)
//            } else {
//                let imgRect = CGRect(x: bounds.width / 2.0 - img.size.width / 2.0, y: bounds.height / 2.0 - img.size.height / 2.0, width: img.size.width, height: img.size.height)
//                img.draw(in: imgRect, blendMode: .normal, alpha: imageAlpha)
//            }
//        }
//    }
    
    
    //tb_tab_1_of_3_down
    
}



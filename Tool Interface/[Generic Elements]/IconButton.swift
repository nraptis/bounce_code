//
//  IconButton.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/30/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class IconButton: DrawableButton {
    
    var maxHeight: CGFloat?
    
    var separatorWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    //var symbolPoints = [CGPoint]()
    var symbolPoints = [CGPoint]() { didSet { setNeedsDisplay() } }
    var symbolScale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    var image: UIImage? {
        if isPressed == true && isEnabled == true {
            if let img = imageDown {
                return img
            }
            if let img = imageUp {
                return img
            }
        } else {
            if let img = imageUp {
                return img
            }
            if let img = imageDown {
                return img
            }
        }
        return nil
    }
    
    func setImages(path: String?, pathSelected: String?) {
        
        if path == nil {
            _imageUp = nil
            imagePathUp = ""
        } else {
            if path != imagePathUp {
                _imageUp = nil
                imagePathUp = path
            }
        }
        
        if pathSelected == nil {
            _imageDown = nil
            imagePathUp = ""
        } else {
            if pathSelected != imagePathDown {
                _imageDown = nil
                imagePathDown = pathSelected
            }
        }
        
        //if path != nil { imagePathUp = path! }
        //if pathSelected != nil { imagePathDown = pathSelected! }
        
    }
    
    private var _imageUp:UIImage?
    var imageUp: UIImage? {
        if _imageUp == nil && imagePathUp != nil {
            _imageUp = FileUtils.loadImage(imagePathUp)
        }
        return _imageUp
    }
    
    private var _imageDown:UIImage?
    var imageDown: UIImage? {
        if _imageDown == nil && imagePathDown != nil {
            _imageDown = FileUtils.loadImage(imagePathDown)
        }
        return _imageDown
    }
    
    var fitImage: Bool = false { didSet { setNeedsDisplay() } }
    
    var imagePathUp: String? { didSet { setNeedsDisplay() } }
    var imagePathDown: String? { didSet { setNeedsDisplay() } }
    
    var fillColorLeft:UIColor = UIColor(red: 0.45, green: 0.45, blue: 1.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var fillColorLeftDown:UIColor = UIColor(red: 0.65, green: 0.65, blue: 1.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    
    var fillColorRight:UIColor = UIColor(red: 0.25, green: 0.35, blue: 1.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var fillColorRightDown:UIColor = UIColor(red: 0.25, green: 0.35, blue: 0.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    
    var fillColorSeparator:UIColor = UIColor(red: 0.65, green: 0.66, blue: 1.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var fillColorSeparatorDown:UIColor = UIColor(red: 0.75, green: 0.90, blue: 1.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    
    var stroke:Bool = false { didSet { setNeedsDisplay() } }
    var strokeDown:Bool = false { didSet { setNeedsDisplay() } }
    
    var strokeColor:UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var strokeColorDown:UIColor = UIColor(red: 0.86, green: 0.86, blue: 0.72, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var strokeWidth:CGFloat = 4.0 { didSet { setNeedsDisplay() } }
    
    var cornerRadius:CGFloat = 6.0 { didSet { setNeedsDisplay() } }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override func setUp() {
        super.setUp()
        cornerRadius = ApplicationController.shared.tbButtonHeight / 8.0
        if Device.isTablet { separatorWidth = 2.0 }
        self.backgroundColor = UIColor.clear
    }
    
    func getCornerTypeLeft() -> UIRectCorner {
        var result:UIRectCorner = UIRectCorner(rawValue: 0)
        result = result.union(UIRectCorner.topLeft)
        result = result.union(UIRectCorner.bottomLeft)
        return result;
    }
    
    func getCornerTypeRight() -> UIRectCorner {
        var result:UIRectCorner = UIRectCorner(rawValue: 0)
        result = result.union(UIRectCorner.topRight)
        result = result.union(UIRectCorner.bottomRight)
        return result;
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
        
        var drawStroke:Bool = false
        
        if isPressed {
            if strokeDown { drawStroke = true }
        } else {
            if stroke { drawStroke = true }
        }
        if strokeWidth <= 0.0 { drawStroke = false }
        
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        let frameRect = drawRect
        
        let rightWidth: CGFloat = frameRect.height
        let middleWidth: CGFloat = separatorWidth
        let leftWidth: CGFloat = frameRect.width - (rightWidth + middleWidth)
        let middleX: CGFloat = leftWidth
        let rightX: CGFloat = middleX + middleWidth
        
        var inset: CGFloat = 0.0
        
        if drawStroke {
            
            let clipPath = UIBezierPath(roundedRect: frameRect, byRoundingCorners: DrawableButton.getCornerType(ul: true, ur: true, dr: true, dl: true), cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            context.saveGState()
            context.beginPath()
            context.addPath(clipPath)
            context.setFillColor((isPressed ? strokeColorDown : strokeColor).cgColor)
            context.closePath()
            context.fillPath()
            context.restoreGState()
            
            inset = strokeWidth / 2.0
            
        }
        
        
        if leftWidth > 0.0 {
            let rect = CGRect(x: inset, y: frameRect.origin.y + inset, width: leftWidth - inset, height: frameRect.height - inset * 2.0)
            
            
            let clipPath = UIBezierPath(roundedRect: rect,
                                        byRoundingCorners: getCornerTypeLeft(),
                                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            context.saveGState()
            context.beginPath()
            context.addPath(clipPath)
            context.setFillColor(isPressed ? fillColorLeftDown.cgColor : fillColorLeft.cgColor)
            context.closePath()
            context.fillPath()
            context.restoreGState()
            
            if let img = image {
                var imageAlpha: CGFloat = 1.0
                if isEnabled == false { imageAlpha = 0.5 }
                
                let imgFrame = CGRect(x: 0.0, y: frameRect.origin.y, width: leftWidth, height: frameRect.height)
                let imgRect = CGRect(x: imgFrame.origin.x + imgFrame.size.width / 2.0 - img.size.width / 2.0, y: imgFrame.origin.y + imgFrame.size.height / 2.0 - img.size.height / 2.0, width: img.size.width, height: img.size.height)
                img.draw(in: imgRect, blendMode: .normal, alpha: imageAlpha)
            }
        }
        
        if middleWidth > 0.0 {
            let rect = CGRect(x: middleX, y: frameRect.origin.y + inset, width: middleWidth, height: frameRect.height - inset * 2.0)
            context.setFillColor(isPressed ? fillColorSeparatorDown.cgColor : fillColorSeparator.cgColor)
            context.fill(rect)
        }
        
        if rightWidth > 0.0 {
            let rect = CGRect(x: rightX, y: frameRect.origin.y + inset, width: rightWidth - inset, height: frameRect.height - inset * 2.0)
            let clipPath = UIBezierPath(roundedRect: rect,
                                        byRoundingCorners: getCornerTypeRight(),
                                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            context.saveGState()
            context.beginPath()
            context.addPath(clipPath)
            context.setFillColor(isPressed ? fillColorRightDown.cgColor : fillColorRight.cgColor)
            context.closePath()
            context.fillPath()
            context.restoreGState()
            
            if symbolPoints.count > 0 {
                context.saveGState()
                
                var symbolSize: CGFloat = bounds.width
                if bounds.height < symbolSize {
                    symbolSize = bounds.height
                }
                
                symbolSize *= symbolScale
                
                let symbolFrame = CGRect(x: rightX, y: frameRect.origin.y, width: rightWidth, height: frameRect.height)
                
                
                let symbolFrameX: CGFloat = symbolFrame.origin.x + symbolFrame.size.width / 2.0 - symbolSize / 2.0
                let symbolFrameY: CGFloat = symbolFrame.origin.y + symbolFrame.size.height / 2.0 - symbolSize / 2.0
                
                
                //context.setFillColor(UIColor(red: 0.5, green: 0.25, blue: 0.12, alpha: 0.4).cgColor)
                //context.fill(CGRect(x: symbolFrameX, y: symbolFrameY, width: symbolSize, height: symbolSize))
                
                let path = ApplicationController.path(fromPoints: &symbolPoints, inRect: CGRect(x: symbolFrameX, y: symbolFrameY, width: symbolSize, height: symbolSize))
                //let path = ApplicationController.path(fromPoints: &symbolPoints, inRect: rect)
                
                //let shadowColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.32)
                //let shadowBlur:CGFloat = Device.isTablet ? 2.0 : 1.0
                context.beginPath()
                context.addPath(path.cgPath)
                context.closePath()
                context.setFillColor(UIColor.white.cgColor)
                //context.setShadow(offset: CGSize(width: -1, height: 2), blur: shadowBlur, color: shadowColor.cgColor)
                context.fillPath()
                context.restoreGState()
            }
        }
        
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
    
}

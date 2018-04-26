//
//  RRButton.swift
//  SwiftFunhouse
//
//  Created by Raptis, Nicholas on 7/18/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class RRButton: DrawableButton {
    
    var itemTag: String = ""
    
    var maxHeight: CGFloat?
    
    var text: String?
    
    var image: UIImage? {
        if isEnabled == false {
            if let img = imageDisabled {
                return img
            }
        }
        if isPressed == true {
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
        if path != nil { imagePathUp = path! }
        if pathSelected != nil { imagePathDown = pathSelected! }
    }
    
    func setImages(path: String?, pathSelected: String?, pathDisabled: String?) {
        if path != nil { imagePathUp = path! }
        if pathSelected != nil { imagePathDown = pathSelected! }
        if pathDisabled != nil { imagePathDisabled = pathDisabled! }
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
    
    private var _imageDisabled:UIImage?
    var imageDisabled: UIImage? {
        if _imageDisabled == nil && imagePathDisabled != nil {
            _imageDisabled = FileUtils.loadImage(imagePathDisabled)
        }
        return _imageDown
    }
    
    var fitImage: Bool = false { didSet { setNeedsDisplay() } }
    
    private var _previousImagePathUp:String?
    var imagePathUp: String? {
        didSet {
            if _previousImagePathUp != imagePathUp { _imageUp = nil }
            setNeedsDisplay()
            _previousImagePathUp = imagePathUp
        }
    }
    
    private var _previousImagePathDown:String?
    var imagePathDown: String? {
        didSet {
            if _previousImagePathDown != imagePathDown { _imageDown = nil }
            setNeedsDisplay()
            _previousImagePathDown = imagePathDown
        }
    }
    
    private var _previousImagePathDisabled:String?
    var imagePathDisabled: String? {
        didSet {
            if _previousImagePathDisabled != imagePathDisabled { _imageDisabled = nil }
            setNeedsDisplay()
            _previousImagePathDisabled = imagePathDisabled
        } 
    }
    
    var cornerUL = true { didSet { setNeedsDisplay() } }
    var cornerUR = true { didSet { setNeedsDisplay() } }
    var cornerDR = true { didSet { setNeedsDisplay() } }
    var cornerDL = true { didSet { setNeedsDisplay() } }
    
    var fill:Bool = true { didSet { setNeedsDisplay() } }
    var fillDown:Bool = true { didSet { setNeedsDisplay() } }
    
    var fillColor:UIColor = UIColor(red: 0.45, green: 0.45, blue: 1.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var fillColorDown:UIColor = UIColor(red: 0.65, green: 0.65, blue: 1.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    
    var stroke:Bool = false { didSet { setNeedsDisplay() } }
    var strokeDown:Bool = false { didSet { setNeedsDisplay() } }
    
    var strokeColor:UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var strokeColorDown:UIColor = UIColor(red: 0.86, green: 0.86, blue: 0.72, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var strokeWidth:CGFloat = 4.0 { didSet { setNeedsDisplay() } }
    
    var cornerRadius:CGFloat = 6.0 { didSet { setNeedsDisplay() } }
    
    deinit {
        
    }
    
    override func setUp() {
        super.setUp()
        cornerRadius = ApplicationController.shared.tbButtonHeight / 8.0
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
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        var rect = drawRect
        
        if drawStroke {
            
            if drawFill {
                
                let clipPath = UIBezierPath(roundedRect: rect, byRoundingCorners: DrawableButton.getCornerType(ul: cornerUL, ur: cornerUR, dr: cornerDR, dl: cornerDL), cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
                context.saveGState()
                context.beginPath()
                context.addPath(clipPath)
                context.setFillColor((isPressed ? strokeColorDown : strokeColor).cgColor)
                context.closePath()
                context.fillPath()
                context.restoreGState()
                
                let inset = strokeWidth / 2.0
                rect = rect.insetBy(dx: inset, dy: inset)
            } else {
                
                let inset = strokeWidth / 2.0
                rect = rect.insetBy(dx: inset, dy: inset)
                
                let clipPath = UIBezierPath(roundedRect: rect, byRoundingCorners: DrawableButton.getCornerType(ul: cornerUL, ur: cornerUR, dr: cornerDR, dl: cornerDL), cornerRadii: CGSize(width: cornerRadius - inset, height: cornerRadius - inset)).cgPath
                
                context.saveGState()
                context.beginPath()
                context.addPath(clipPath)
                context.setStrokeColor((isPressed ? strokeColorDown : strokeColor).cgColor)
                context.setLineWidth(strokeWidth)
                context.closePath()
                context.strokePath()
                context.restoreGState()
            }
        }
        
        if drawFill {
            let clipPath = UIBezierPath(roundedRect: rect,
                                        byRoundingCorners: DrawableButton.getCornerType(ul: cornerUL, ur: cornerUR, dr: cornerDR, dl: cornerDL),
                                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
            context.saveGState()
            context.beginPath()
            context.addPath(clipPath)
            context.setFillColor(isPressed ? fillColorDown.cgColor : fillColor.cgColor)
            context.closePath()
            context.fillPath()
            context.restoreGState()
        }
        
        drawImage()
        
        /*
        if isLocked {
            if let lockImage = ApplicationController.shared.lockImageHomeMenu {
                if lockImage.size.width > 2.0 && lockImage.size.height > 2.0 {
                    let lockImageRect = CGRect(x: 6.0, y: 6.0, width: lockImage.size.width, height: lockImage.size.height)
                    lockImage.draw(in: lockImageRect, blendMode: .normal, alpha: 1.0)
                }
            }
            
            //lockImageHomeMenu = UIImage(named: "hm_accessory_small_button_lock")
            //lockImageToolbar = UIImage(named: "tb_accessory_lock_regular")
            //lockImageToolbarSmall = UIImage(named: "tb_accessory_lock_small")
            
        }
        */
        
        
        if let string = text {
            let nameString = string as NSString
            let stringAttributes = [ NSAttributedStringKey.font : Style.fontSliderLabel(), NSAttributedStringKey.foregroundColor : UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0) ]
            let stringSize = nameString.size(withAttributes: stringAttributes)
            let stringRectX: CGFloat = CGFloat(Int(bounds.width / 2.0 - stringSize.width / 2.0))
            let stringRectY: CGFloat = CGFloat(Int(10.0))
            let stringRectWidth: CGFloat = CGFloat(Int(stringSize.width + 0.5))
            let stringRectHeight: CGFloat = CGFloat(Int(stringSize.height + 0.5))
            let stringRect = CGRect(x: stringRectX, y: stringRectY, width: stringRectWidth, height: stringRectHeight)
            nameString.draw(in: stringRect, withAttributes: stringAttributes)
        }
        
        
        context.restoreGState()
    }
    
    func drawImage() {
        let rect = drawRect
        if let img = image {
            var imageAlpha: CGFloat = 1.0
            if isEnabled == false && _imageDisabled === nil { imageAlpha = 0.60 }
            
            if fitImage {
                let fit = CGSize(width: rect.size.width, height: rect.size.height).getAspectFit(img.size)
                let size = fit.size
                let imgRect = CGRect(x: bounds.width / 2.0 - size.width / 2.0, y: bounds.height / 2.0 - size.height / 2.0, width: size.width, height: size.height)
                img.draw(in: imgRect, blendMode: .normal, alpha: imageAlpha)
            } else {
                let imgRect = CGRect(x: bounds.width / 2.0 - img.size.width / 2.0, y: bounds.height / 2.0 - img.size.height / 2.0, width: img.size.width, height: img.size.height)
                img.draw(in: imgRect, blendMode: .normal, alpha: imageAlpha)
            }
        }
    }
    
    func drawImageCenteredEnsuringFit(image: UIImage?, rect centerRect: CGRect) {
        
        if let drawImage = image {
            
            if drawImage.size.width > 2.0 && drawImage.size.height > 2.0 && centerRect.size.width > 2.0 && centerRect.size.height > 2.0 {
                //let context: CGContext = UIGraphicsGetCurrentContext()!
                //context.saveGState()
                
                if drawImage.size.width > centerRect.size.width || drawImage.size.height > centerRect.size.height {
                    let newSize = centerRect.size.getAspectFit(drawImage.size)
                    let imageRect = CGRect(x: centerRect.size.width / 2.0 - newSize.size.width / 2.0,
                                           y: centerRect.size.height / 2.0 - newSize.size.height / 2.0,
                                           width: newSize.size.width,
                                           height: newSize.size.height)
                    drawImage.draw(in: imageRect)
                } else {
                    let imageRect = CGRect(x: centerRect.size.width / 2.0 - drawImage.size.width / 2.0,
                                           y: centerRect.size.height / 2.0 - drawImage.size.height / 2.0,
                                           width: drawImage.size.width,
                                           height: drawImage.size.height)
                    drawImage.draw(in: imageRect)
                }
                //context.restoreGState()
                
            }
        }
    }
    
    
    func styleSetCheck() {
        fill = true
        stroke = false
        strokeDown = true
        fillColor = styleColorMediumGray
        fillColorDown = styleColorMediumGray
        strokeColorDown = UIColor.white
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = ApplicationController.shared.tbStrokeWidth
        setNeedsDisplay()
    }
    
    func styleSetCheckChecked() {
        fill = true
        stroke = true
        strokeDown = true
        fillColor = styleColorMediumGray
        strokeColor = styleColorBlue
        fillColorDown = styleColorMediumGray
        strokeColorDown = UIColor.white
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = ApplicationController.shared.tbStrokeWidth
        setNeedsDisplay()
    }
    
    func styleSetSegment() {
        fill = true
        stroke = true
        strokeDown = true
        fillColor = styleColorDarkGray
        strokeColor = styleColorBlue
        fillColorDown = styleColorBlue
        strokeColorDown = UIColor.white
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = ApplicationController.shared.tbStrokeWidth
        setNeedsDisplay()
    }
    
    func styleSetSegmentSelected() {
        fill = true
        fillDown = true
        stroke = false
        strokeDown = true
        fillColor = styleColorBlue
        fillColorDown = styleColorBlue
        strokeColorDown = UIColor.white
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = ApplicationController.shared.tbStrokeWidth
        setNeedsDisplay()
    }
    
    func styleSetSegmentOrange() {
        styleSetSegment()
        strokeColor = styleColorOrange
        fillColorDown = styleColorOrange
        setNeedsDisplay()
    }
    
    func styleSetSegmentSelectedOrange() {
        styleSetSegmentSelected()
        fillColor = styleColorOrange
        fillColorDown = styleColorOrange
        setNeedsDisplay()
    }
    
    func styleSetToolbarButton() {
        fill = false
        fillDown = true
        stroke = false
        strokeDown = false
        fillColorDown = styleColorBlue
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = 0
        setNeedsDisplay()
    }
    
    
    func styleSetLargeToolbarButton() {
        fill = false
        fillDown = false
        stroke = false
        strokeDown = false
        fillColorDown = styleColorBlue
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = 0
        setNeedsDisplay()
    }
    
    func styleSetHomeMenuButton() {
        fill = true
        fillDown = true
        stroke = false
        strokeDown = true
        strokeWidth = 2.0
        fillColor = styleColorHomeMenuButtonBack
        fillColorDown = styleColorHomeMenuButtonBackDown
        strokeColor = styleColorDarkGray
        strokeColorDown = styleColorOrange
        setNeedsDisplay()
    }
    
    func styleSetRecordButtonOff() {
        fill = false
        fillDown = false
        stroke = true
        strokeDown = true
        strokeColor = styleColorMenuButtonLight
        strokeColorDown = styleColorMenuButtonLightDown
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = 2.0
        setNeedsDisplay()
    }
    
    func styleSetRecordButtonComplete() {
        fill = false
        fillDown = false
        stroke = true
        strokeDown = true
        
        strokeColor = styleColorMenuButtonLight
        strokeColorDown = styleColorMenuButtonLightDown
        
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = 2.0
        setNeedsDisplay()
    }
    
    
    func styleSetRecordButtonOn() {
        fill = false
        fillDown = false
        stroke = true
        strokeDown = true
        //cornerUL = true
        //cornerDL = true
        //cornerUR = true
        //cornerDR = true
        
        strokeColor = styleColorMenuButtonRed
        strokeColorDown = styleColorMenuButtonRedDown
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = 2.0
        setNeedsDisplay()
    }
    
    func styleSetPageTabberRight() {
        
        fill = true
        fillDown = true
        
        stroke = false
        strokeDown = false
        
        cornerUL = false
        cornerDL = false
        cornerUR = true
        cornerDR = true
        
        fillColor = styleColorDarkGray
        fillColorDown = styleColorOrange
        
        //strokeColor = styleColorMediumGray
        //strokeColorDown = UIColor.white
        
        //strokeColorDown = UIColor.white
        
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = 0.0//ApplicationController.shared.tbStrokeWidth
        setNeedsDisplay()
    }
    
    func styleSetPageTabberLeft() {
        fill = true
        fillDown = true
        
        stroke = false
        strokeDown = false
        
        cornerUL = true
        cornerDL = true
        cornerUR = false
        cornerDR = false
        fillColor = styleColorDarkGray
        fillColorDown = styleColorOrange
        
        //strokeColor = styleColorMediumGray
        //strokeColorDown = styleColorFacebookBlueDarker
        
        maxHeight = ApplicationController.shared.tbButtonHeight
        strokeWidth = 0.0//ApplicationController.shared.tbStrokeWidth
        setNeedsDisplay()
    }
    
    
    
}

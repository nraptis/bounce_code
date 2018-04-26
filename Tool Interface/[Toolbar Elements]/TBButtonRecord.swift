//
//  TBButtonAlternate.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/15/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

enum ButtonRecordMode: Int { case off = 0, on = 1, complete = 2 }

class TBButtonRecord: RRButton {
    
    private var _previousMode: ButtonRecordMode = .off
    var mode: ButtonRecordMode = .off {
        didSet {
            if _previousMode != mode {
                if mode == .on {
                    styleSetRecordButtonOn()
                    setImages(path: "tb_btn_recording", pathSelected: "tb_btn_recording_down")
                } else if mode == .off {
                    styleSetRecordButtonOff()
                    setImages(path: "tb_btn_record", pathSelected: "tb_btn_record_down")
                } else if mode == .complete {
                    styleSetRecordButtonComplete()
                    setImages(path: "tb_btn_recording", pathSelected: "tb_btn_recording_down")
                }
                
                _previousMode = mode
                setNeedsDisplay()
            }
        }
    }
    
    var imageRecordCircleOff = UIImage(named: "record_circle_off")
    
    var imageRecordCircle = UIImage(named: "record_circle")
    var imageRecordCircleGlowing = UIImage(named: "record_circle_glowing")
    
    var imageRecordCircleOutline = UIImage(named: "record_circle_outline")
    var imageRecordCircleOutlineGlowing = UIImage(named: "record_circle_outline_glowing")
    
    var flickerTick: Int = 0
    var flickerShowGlow: Bool = false
    
    override func setUp() {
        super.setUp()
        styleSetRecordButtonOff()
        setImages(path: "tb_btn_record", pathSelected: "tb_btn_record_down")
        
        //updateTimer?.invalidate()
        //updateTimer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(TBButtonRecord.update), userInfo: nil, repeats: true)
        //if updateTimer != nil {
        //    RunLoop.main.add(updateTimer!, forMode: RunLoopMode.commonModes)
        //}
        
    }
    
    func update() {
        
        flickerTick += 1
        
        if flickerShowGlow == true {
         
            if flickerTick >= 6 {
                flickerTick = 0
                flickerShowGlow = false
                setNeedsDisplay()
            }
            
        } else {
            if flickerTick >= 6 {
                flickerTick = 0
                flickerShowGlow = true
                setNeedsDisplay()
            }
            
            
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        let rect = drawRect
        
        let circlePoint = CGPoint(x: rect.maxX - rect.midY, y: rect.midY)
        
        if mode == .on {
            if flickerShowGlow {
                centerImage(image: imageRecordCircle, atPoint: circlePoint)
                centerImage(image: imageRecordCircleOutline, atPoint: circlePoint)
            } else {
                centerImage(image: imageRecordCircleGlowing, atPoint: circlePoint)
                centerImage(image: imageRecordCircleOutlineGlowing, atPoint: circlePoint)
            }
        } else if mode == .complete {
            centerImage(image: imageRecordCircle, atPoint: circlePoint)
            centerImage(image: imageRecordCircleOutline, atPoint: circlePoint)
        } else if mode == .off {
            centerImage(image: imageRecordCircleOff, atPoint: circlePoint)
        }
        
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        
        //centerImage(image: UIImage?, atPoint center:
            
        
        //rect
        
        
        
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
        
        
        
        
        var rect = drawRect
        */
        
        
        /*
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
        
        context.restoreGState()
    }
    
    func centerImage(image: UIImage?, atPoint center: CGPoint) {
        
        if let drawImage = image {
            
            if drawImage.size.width > 2.0 && drawImage.size.height > 2.0 {
                

                
                    let imageRect = CGRect(x: center.x - drawImage.size.width / 2.0,
                                           y: center.y - drawImage.size.height / 2.0,
                                           width: drawImage.size.width,
                                           height: drawImage.size.height)
                    drawImage.draw(in: imageRect)
                 
                
            }
        }
    }
    
    
    /*
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
                
                
                let context: CGContext = UIGraphicsGetCurrentContext()!
                context.saveGState()
                
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
                
                context.restoreGState()
                
            }
        }
    }
    */
    
    
    deinit {
     
        print("YEAH RECO BTN DEINIT")
    }
    
    
}



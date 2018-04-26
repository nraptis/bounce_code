//
//  CircleButton.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 1/4/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class CircleButton: DrawableButton {
    
    
    //Padding on all sides, essentially to give a larget hit area than the circle.
    var paddingUp: CGFloat = 4.0
    var paddingDown: CGFloat = 4.0
    
    var fillUp:Bool = true { didSet { setNeedsDisplay() } }
    var fillDown:Bool = true { didSet { setNeedsDisplay() } }
    
    var fillColorUp:UIColor = UIColor(red: 0.45, green: 0.45, blue: 1.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var fillColorDown:UIColor = UIColor(red: 0.65, green: 0.65, blue: 1.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    
    var strokeUp:Bool = true { didSet { setNeedsDisplay() } }
    var strokeDown:Bool = true { didSet { setNeedsDisplay() } }
    
    var strokeColorUp:UIColor = UIColor(red: 1.0, green: 1.0, blue: 0.75, alpha: 0.5) { didSet { setNeedsDisplay() } }
    var strokeColorDown:UIColor = UIColor(red: 0.86, green: 0.86, blue: 0.72, alpha: 0.5) { didSet { setNeedsDisplay() } }
    
    var strokeWidthUp:CGFloat = 4.0 { didSet { setNeedsDisplay() } }
    var strokeWidthDown:CGFloat = 4.0 { didSet { setNeedsDisplay() } }
    
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
        if path != nil { imagePathUp = path! }
        if pathSelected != nil { imagePathDown = pathSelected! }
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
    
    override func draw(_ rect: CGRect) {
        
        let padding = isPressed ? paddingDown : paddingUp
        
        var diameter: CGFloat = bounds.size.width - (padding + padding)
        let altDiameter: CGFloat = bounds.size.height - (padding + padding)
        if altDiameter < diameter { diameter = altDiameter }
        let radius: CGFloat = diameter * 0.5
        
        let center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        
        let fill = isPressed ? fillDown : fillUp
        var stroke = isPressed ? strokeDown : strokeUp
        let fillColor = isPressed ? fillColorDown : fillColorUp
        let strokeColor = isPressed ? strokeColorDown : strokeColorUp
        let strokeWidth = isPressed ? strokeWidthDown : strokeWidthUp
        
        if strokeWidth <= 0 { stroke = false }
        
        let startAngle:CGFloat = 0.0
        let endAngle:CGFloat = Math.PI2
        
        if fill {
            var drawRadius = radius
            if stroke {
                drawRadius -= strokeWidth / 2.0
            }
            
            let pathFill = UIBezierPath(arcCenter: center, radius: drawRadius,
                                        startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            fillColor.setFill()
            pathFill.fill()
        }
        
        if stroke == true {
            let outlineShift:CGFloat = strokeWidth / 2.0
            let pathOutline = UIBezierPath(arcCenter: center, radius: (radius - outlineShift),
                                           startAngle: startAngle, endAngle: endAngle, clockwise: true)
            pathOutline.lineWidth = strokeWidth
            strokeColor.setStroke()
            pathOutline.stroke()
        }
    }
    
    func drawImage() {
        
        let rect = bounds
        
        if let img = image {
            var imageAlpha: CGFloat = 1.0
            if isEnabled == false { imageAlpha = 0.5 }
            
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
}


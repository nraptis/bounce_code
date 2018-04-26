//
//  TBCheckBox.swift
//  SwiftFunhouse
//
//  Created by Raptis, Nicholas on 7/18/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

protocol TBCheckBoxDelegate
{
    func checkBoxToggled(checkBox:TBCheckBox, checked: Bool)
}

class TBCheckBox: RRButton {
    
    var delegate:TBCheckBoxDelegate?
    
    var checked:Bool = false {
        didSet {
            if checked {
                styleSetCheckChecked()
            } else {
                styleSetCheck()
            }
            setNeedsDisplay()
        }
    }
    
    override var image: UIImage? {
        if checked || isPressed {
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
    
    var shapePoints = [CGPoint]()
    
    override func setUp() {
        //Checkmark.
        
        /*
        shapePoints.append(CGPoint(x: 0.41, y: 0.54))
        shapePoints.append(CGPoint(x: 0.43, y: 0.54))
        shapePoints.append(CGPoint(x: 0.72, y: 0.25))
        shapePoints.append(CGPoint(x: 0.75, y: 0.25))
        shapePoints.append(CGPoint(x: 0.86, y: 0.36))
        shapePoints.append(CGPoint(x: 0.86, y: 0.39))
        shapePoints.append(CGPoint(x: 0.44, y: 0.81))
        shapePoints.append(CGPoint(x: 0.40, y: 0.81))
        shapePoints.append(CGPoint(x: 0.13, y: 0.54))
        shapePoints.append(CGPoint(x: 0.13, y: 0.51))
        shapePoints.append(CGPoint(x: 0.24, y: 0.40))
        shapePoints.append(CGPoint(x: 0.27, y: 0.40))
        */
        
        shapePoints.removeAll()
            shapePoints.append(CGPoint(x: 0.41, y: 0.54))
            shapePoints.append(CGPoint(x: 0.43, y: 0.54))
            shapePoints.append(CGPoint(x: 0.72, y: 0.25))
            shapePoints.append(CGPoint(x: 0.75, y: 0.25))
            shapePoints.append(CGPoint(x: 0.86, y: 0.36))
            shapePoints.append(CGPoint(x: 0.86, y: 0.39))
            shapePoints.append(CGPoint(x: 0.44, y: 0.81))
            shapePoints.append(CGPoint(x: 0.40, y: 0.81))
            shapePoints.append(CGPoint(x: 0.13, y: 0.54))
            shapePoints.append(CGPoint(x: 0.13, y: 0.51))
            shapePoints.append(CGPoint(x: 0.24, y: 0.40))
            shapePoints.append(CGPoint(x: 0.27, y: 0.40))
            setNeedsDisplay()
        //}
        //X
        
        //shapePoints.append(CGPoint(x: 0.50, y: 0.38))
        //shapePoints.append(CGPoint(x: 0.77, y: 0.11))
        //shapePoints.append(CGPoint(x: 0.80, y: 0.11))
        //shapePoints.append(CGPoint(x: 0.89, y: 0.20))
        //shapePoints.append(CGPoint(x: 0.89, y: 0.23))
        //shapePoints.append(CGPoint(x: 0.62, y: 0.50))
        //shapePoints.append(CGPoint(x: 0.89, y: 0.77))
        //shapePoints.append(CGPoint(x: 0.89, y: 0.80))
        //shapePoints.append(CGPoint(x: 0.80, y: 0.89))
        //shapePoints.append(CGPoint(x: 0.77, y: 0.89))
        //shapePoints.append(CGPoint(x: 0.50, y: 0.62))
        //shapePoints.append(CGPoint(x: 0.23, y: 0.89))
        //shapePoints.append(CGPoint(x: 0.20, y: 0.89))
        //shapePoints.append(CGPoint(x: 0.11, y: 0.80))
        //shapePoints.append(CGPoint(x: 0.11, y: 0.77))
        //shapePoints.append(CGPoint(x: 0.38, y: 0.50))
        //shapePoints.append(CGPoint(x: 0.11, y: 0.23))
        //shapePoints.append(CGPoint(x: 0.11, y: 0.20))
        //shapePoints.append(CGPoint(x: 0.20, y: 0.11))
        //shapePoints.append(CGPoint(x: 0.23, y: 0.11))
        
        fitImage = false
        
        super.setUp()
        styleSetCheck()
        
        self.addTarget(self, action: #selector(didClick), for: .touchUpInside)
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        
        
        //let checkWidth = frame.size.height / 2.0
        //let checkHeight = frame.size.height / 2.0
        
        //let checkRect = checkRect
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        
        let rect = checkRect
        let clipPath = UIBezierPath(roundedRect: rect,
                                    byRoundingCorners: DrawableButton.getCornerType(ul: true, ur: true, dr: true, dl: true),
                                    cornerRadii: CGSize(width: 4.0, height: 20.0)).cgPath
        
        context.beginPath()
        context.addPath(clipPath)
        
        
        if checked {
            context.setFillColor(styleColorBlue.cgColor)
        } else {
            context.setFillColor(styleColorCheck.cgColor)
        }
        context.closePath()
        context.fillPath()
        
        context.restoreGState()
        
        
        if checked {
            context.saveGState()
            
            let path = UIBezierPath()
            for i in 0..<shapePoints.count {
                var point = shapePoints[i]
                point.x = rect.origin.x + rect.size.width * (point.x)
                point.y = rect.origin.y + rect.size.height * (point.y)
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            
            let shadowColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.32)
            let shadowBlur:CGFloat = Device.isTablet ? 2.0 : 1.0
            
            context.beginPath()
            context.addPath(path.cgPath)
            context.closePath()
            context.setFillColor(UIColor.white.cgColor)
            context.setShadow(offset: CGSize(width: -1, height: 2), blur: shadowBlur, color: shadowColor.cgColor)
            context.fillPath()

            context.restoreGState()
        }
    }
    
    override func drawImage() {
        
        let dr = drawRect
        let cr = checkRect
        
        let rect = CGRect(x: dr.origin.x, y: dr.origin.y, width: cr.origin.x - dr.origin.x, height: dr.size.height)
        
        if let img = image {
            var imageAlpha: CGFloat = 1.0
            if isEnabled == false { imageAlpha = 0.5 }
            if fitImage {
                let fit = CGSize(width: rect.size.width, height: rect.size.height).getAspectFit(img.size)
                let size = fit.size
                let imgRect = CGRect(x: rect.size.width / 2.0 - size.width / 2.0, y: rect.origin.y + rect.size.height / 2.0 - size.height / 2.0, width: size.width, height: size.height)
                img.draw(in: imgRect, blendMode: .normal, alpha: imageAlpha)
            } else {
                let imgRect = CGRect(x: rect.size.width / 2.0 - img.size.width / 2.0, y: rect.origin.y + rect.size.height / 2.0 - img.size.height / 2.0, width: img.size.width, height: img.size.height)
                img.draw(in: imgRect, blendMode: .normal, alpha: imageAlpha)
            }
        }
    }
    
    var checkRect: CGRect {
        
        let rect = drawRect
        
        let checkWidth = rect.size.height / 2.0
        let checkHeight = rect.size.height / 2.0
        
        let checkRect = CGRect(x: (frame.size.width - (checkWidth + (frame.size.height - checkHeight) / 2.0)), y: frame.size.height / 2.0 - checkHeight / 2.0, width: checkWidth, height: checkHeight)
        
        return checkRect
    }
    
    @objc func didClick() {
        
        if ToolActions.allow() == false {
            return
        }
        
        checked = !checked
        delegate?.checkBoxToggled(checkBox: self, checked: checked)
    }
    
}

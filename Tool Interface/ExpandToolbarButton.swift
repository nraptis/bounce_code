//
//  ExpandToolbarButton.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/28/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class ExpandToolbarButton: DrawableButton, UIGestureRecognizerDelegate {
    
    var image: UIImage?
    
    var isAtTopOfScreen: Bool = false
    
    var longPressRecognizer: UILongPressGestureRecognizer!
    
    var isDragging: Bool = false
    
    var dragStartGestureX: CGFloat = 0.0
    var dragStartGestureY: CGFloat = 0.0
    
    var dragStartTranslationX: CGFloat = 0.0
    var dragStartTranslationY: CGFloat = 0.0
    
    var dragMaxX: CGFloat = 0.0
    var dragMinX: CGFloat = 0.0
    
    var translationX: CGFloat = 0.0
    var translationY: CGFloat = 0.0
    
    var dragWobbleSin: CGFloat = 0.0
    var dragWobbleDamper: CGFloat = 0.0
    
    func setUp(top: Bool) {
        super.setUp()
        
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = UIColor.clear
        
        if Device.isPhone {
            if top {
                image = UIImage(named: "button_expand_down_iphone")
            } else {
                image = UIImage(named: "button_expand_up_iphone")
            }
        } else {
            if top {
                image = UIImage(named: "button_expand_down_ipad")
            } else {
                image = UIImage(named: "button_expand_up_ipad")
            }
        }
        
        setNeedsDisplay()
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressRecognizer.cancelsTouchesInView = true
        longPressRecognizer.delegate = self
        addGestureRecognizer(longPressRecognizer)
    }
    
    func update() -> Void {
        
        if isDragging {
            dragWobbleDamper += 0.1525
            if dragWobbleDamper > 1.0 { dragWobbleDamper = 1.0 }
        }
        
        if dragWobbleDamper > 0.0 {
            dragWobbleSin += 0.675
            if dragWobbleSin > Math.PI2 { dragWobbleSin -= Math.PI2 }
            if isDragging == false {
                dragWobbleDamper -= 0.175
                if dragWobbleDamper <= 0.0 {
                    dragWobbleDamper = 0.0
                }
            }
            updateTransform()
        } else {
            dragWobbleSin = Math.PI_2
        }
    }
    
    func updateTransform() {
        var t = CGAffineTransform.identity
        t = t.translatedBy(x: translationX, y: 0.0)
        if dragWobbleDamper <= 0.0 {
            dragWobbleDamper = 0.0
        } else {
            
            let scale: CGFloat = 1.0 + dragWobbleDamper * 0.3
            var rotation: CGFloat = CGFloat(sin(Double(dragWobbleSin))) * 0.0725 * dragWobbleDamper
            if Device.isTablet { rotation *= 0.666 }
            
            var translateAmount: CGFloat = 16.0
            if Device.isTablet { translateAmount = 22.0 }
            
            if !isAtTopOfScreen { translateAmount = -translateAmount }
            else { translateAmount = 0.0 }
            
            translateAmount *= dragWobbleDamper
            
            t = t.translatedBy(x: 0.0, y: translateAmount)
            t = t.rotated(by: rotation)
            t = t.scaledBy(x: scale, y: scale)
        }
        transform = t
    }
    
    override func draw(_ rect: CGRect) {
        
        //let context: CGContext = UIGraphicsGetCurrentContext()!
        //context.setFillColor(UIColor(red: 0.1, green: 0.7825, blue: 0.1125, alpha: 0.3).cgColor)
        //context.fill(bounds)
        
        if let img = image {
            let imageCenterX = bounds.origin.x + bounds.size.width / 2.0
            let imageCenterY = bounds.origin.y + bounds.size.height / 2.0
            let imgRect = CGRect(x: imageCenterX - img.size.width / 2.0, y: imageCenterY - img.size.height / 2.0, width: img.size.width, height: img.size.height)
            if isPressed {
                img.draw(in: imgRect, blendMode: .normal, alpha: 0.75)
            } else {
                img.draw(in: imgRect, blendMode: .normal, alpha: 1.0)
            }
        }
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        
        guard let bounce = ApplicationController.shared.bounce else { return }
        let pos = gesture.location(in: bounce.view)
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            if ToolActions.allow() {
                dragStartGestureX = pos.x
                dragStartGestureY = pos.y
                dragStartTranslationX = translationX
                dragStartTranslationY = translationY
                isDragging = true
            } else {
                isDragging = false
            }
            break
        case UIGestureRecognizerState.changed:
            if isDragging {
                var newX: CGFloat = dragStartTranslationX + (pos.x - dragStartGestureX)
                var newY: CGFloat = dragStartTranslationY + (pos.y - dragStartGestureY)
                let maxX: CGFloat = 0.0
                let minX: CGFloat = -(dragMaxX - dragMinX)
                if newX < minX { newX = minX }
                if newX > maxX { newX = maxX }
                translationX = newX
                translationY = newY
                updateTransform()
            }
            break
        default:
            isDragging = false
            break
        }
    }
}





//
//  SideMenuButton.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 12/1/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class SideMenuButton: UIButton {
    
    var image: UIImage?
    var imagePath: String? {
        didSet {
            if let path = imagePath {
                image = UIImage(named: path)
            }
        }
    }
    
    var imageIcon: UIImage?
    var imageIconPath: String? {
        didSet {
            if let path = imageIconPath {
                imageIcon = UIImage(named: path)
            }
        }
    }
    
    
    
    deinit {
        
    }
        
    var fill:Bool = true { didSet { setNeedsDisplay() } }
    var fillDown:Bool = true { didSet { setNeedsDisplay() } }
    
    var fillColor:UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) { didSet { setNeedsDisplay() } }
    var fillColorDown:UIColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0) { didSet { setNeedsDisplay() } }
    
    var cornerRadius:CGFloat = 6.0 { didSet { setNeedsDisplay() } }
    
    private var _highlightAlpha: CGFloat = 0.0
    var highlightAlpha: CGFloat {
        set {
            if newValue != _highlightAlpha {
                _highlightAlpha = newValue
                setNeedsDisplay()
            }
        }
        get {
            return _highlightAlpha
        }
    }
    
    var isPressed:Bool {
        return isTouchInside && isTracking
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        cornerRadius = ApplicationController.shared.tbButtonHeight / 7.0
        
        self.setTitle("", for: .normal)
        self.setTitle("", for: .highlighted)
        
        self.backgroundColor = UIColor.clear
        
        self.addTarget(self, action: #selector(didToggleControlState), for: .touchDown)
        self.addTarget(self, action: #selector(didToggleControlState), for: .touchDragInside)
        self.addTarget(self, action: #selector(didToggleControlState), for: .touchDragOutside)
        self.addTarget(self, action: #selector(didToggleControlState), for: .touchCancel)
        self.addTarget(self, action: #selector(didToggleControlState), for: .touchUpInside)
        self.addTarget(self, action: #selector(didToggleControlState), for: .touchUpOutside)
        self.addTarget(self, action: #selector(didClick), for: .touchUpInside)
    }
    
    func getCornerType() -> UIRectCorner {
        return .allCorners
    }
    
    func update() -> Void {
        
        if isPressed {
            if highlightAlpha < 1.0 {
                highlightAlpha += 0.14
                if highlightAlpha > 1.0 { highlightAlpha = 1.0 }
            }
            
        } else {
            if highlightAlpha > 0.0 {
                highlightAlpha -= 0.14
                if highlightAlpha < 0.0 { highlightAlpha = 0.0 }
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        drawImages()
        
        context.restoreGState()
    }
    
    func drawImages() {
        
        let rect = bounds
        
        var imageLeft: CGFloat = 0.0
        
        if let img = imageIcon {
            
            var pos = CGPoint.zero
            let cy = rect.size.height / 2.0
            
            let factor: CGFloat = 1.0 - highlightAlpha * 0.135
            
            let imageWidth: CGFloat = img.size.width * factor
            let imageHeight: CGFloat = img.size.height * factor
            
            pos.x = cy - imageWidth / 2.0
            pos.y = cy - imageHeight / 2.0
            
            let imgRect = CGRect(x: pos.x, y: pos.y, width: imageWidth, height: imageHeight)
            img.draw(in: imgRect, blendMode: .normal, alpha: 1.0)
            
            imageLeft += cy * 1.7
            imageLeft -= highlightAlpha * cy * 0.03
        }
        
        if let img = image {
            var pos = CGPoint.zero
            let cy = rect.size.height / 2.0
            pos.x = imageLeft
            pos.y = CGFloat(Int(cy - img.size.height / 2.0 + 0.5))
            let imgRect = CGRect(x: pos.x, y: pos.y, width: img.size.width, height: img.size.height)
            img.draw(in: imgRect, blendMode: .normal, alpha: 1.0)
        }
    }
    
    @objc func didToggleControlState() {
        self.setNeedsDisplay()
    }
    
    @objc func didClick() {
        
    }
}

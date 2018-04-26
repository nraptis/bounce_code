//
//  ImageTiler.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 1/23/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class ImageTiler: UIView {
    
    var image:UIImage?
    var imagePath: String? {
        didSet {
            if let img = FileUtils.loadImage(imagePath) {
                image = img
            }
            setNeedsDisplay()
        }
    }
    
    internal var _offsetX: CGFloat = 0.0
    internal var _offsetY: CGFloat = 0.0
    var offset: CGPoint = CGPoint.zero {
        didSet {
            if _offsetX != offset.x {
                _offsetX = offset.x
                setNeedsDisplay()
            }
            if _offsetY != offset.y {
                _offsetY = offset.y
                setNeedsDisplay()
            }
        }
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
        
        isUserInteractionEnabled = false
        
        //self.backgroundColor = UIColor.clear
        //self.alpha = 0.5
        //self.isHidden = true
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let drawImage = image else {
            return
        }
        guard drawImage.cgImage != nil else {
            return
        }
        
        let imgWidth = drawImage.size.width
        let imgHeight = drawImage.size.height
        
        guard imgWidth > 8.0 && imgHeight > 8.0 else {
            return
        }
        
        let rect = bounds
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        let drawStartX: CGFloat = 0.0
        let drawStartY: CGFloat = 0.0
        
        var drawX: CGFloat = drawStartX
        var drawY: CGFloat = drawStartY
        
        while drawX < rect.width {
            drawY = drawStartY
            while drawY < rect.height {
                drawImage.draw(at: CGPoint(x: drawX, y: drawY), blendMode: .normal, alpha: alpha)
                drawY += imgHeight
            }
            drawX += imgWidth
        }
        context.restoreGState()
    }
}

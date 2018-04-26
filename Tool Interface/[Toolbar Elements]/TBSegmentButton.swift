//
//  TBSegmentButton.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 10/18/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class TBSegmentButton : RRButton {
    
    var isLocked: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var image: UIImage? {
        if isSelected || isPressed {
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
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        var rect = drawRect
        if isLocked {
            
            var checkLockImage: UIImage?
            
            if Device.isTablet {
                checkLockImage = ApplicationController.shared.lockImageToolbar
            } else {
                checkLockImage = ApplicationController.shared.lockImageToolbarSmall
            }
            
            //OLD: Is this rendering in right spot?
            if let lockImage = checkLockImage {
                if lockImage.size.width > 2.0 && lockImage.size.height > 2.0 {
                    if Device.isTablet {
                        let lockImageRect = CGRect(x: 10.0, y: 12.0, width: lockImage.size.width, height: lockImage.size.height)
                        lockImage.draw(in: lockImageRect, blendMode: .normal, alpha: 1.0)
                    } else {
                        let lockImageRect = CGRect(x: 6.0, y: 6.0, width: lockImage.size.width, height: lockImage.size.height)
                        lockImage.draw(in: lockImageRect, blendMode: .normal, alpha: 1.0)
                    }
                }
            }
            
            //lockImageToolbar
            //lockImageToolbarSmall
            
            //lockImageHomeMenu = UIImage(named: "hm_accessory_small_button_lock")
            //lockImageToolbar = UIImage(named: "tb_accessory_lock_regular")
            //lockImageToolbarSmall = UIImage(named: "tb_accessory_lock_small")
            
        }
        
        context.restoreGState()
        
    }
}





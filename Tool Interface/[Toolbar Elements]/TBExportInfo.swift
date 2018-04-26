//
//  TBExportInfo.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 12/14/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class TBExportInfo: UIView {
    
    var imageTextSavingDots0 = UIImage(named: "text_saving_0_dots")
    var imageTextSavingDots1 = UIImage(named: "text_saving_1_dots")
    var imageTextSavingDots2 = UIImage(named: "text_saving_2_dots")
    var imageTextSavingDots3 = UIImage(named: "text_saving_3_dots")
    
    var savingDotTick: Int = 0
    var savingDotIndex: Int = 0
    var savingDotDirection: Int = 1
    
    var itemTag: String = ""
    
    var leftTextSize: SliderTextSize = .medium
    
    private func labelWidthForSize(size: SliderTextSize) -> CGFloat {
        if Device.isTablet {
            if size == .percent {
                return 50.0
            } else if size == .small {
                return 54.0
            } else if size == .medium {
                return 66.0
            }
        } else {
            if size == .percent {
                return 38.0
            } else if size == .small {
                return 36.0
            } else if size == .medium {
                return 48.0
            }
        }
        return 0.0
    }
    
    
    var leftText: String = "" {
        didSet {
            labelLeft.text = leftText
            setNeedsLayout()
        }
    }
    private var labelLeft: UILabel!
    private var labelRight: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override var frame: CGRect {
        didSet { setNeedsLayout() }
    }
    
    func setUp() {
        
        let toolBarHeight = ApplicationController.shared.toolBarHeight

        labelLeft = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: toolBarHeight, height: toolBarHeight))
        //labelLeft.backgroundColor = UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 0.6)
        labelLeft.backgroundColor = UIColor.clear
        labelLeft.font = Style.fontSliderLabel()
        labelLeft.textColor = UIColor.white
        labelLeft.textAlignment = .right
        labelLeft.numberOfLines = 2
        
        labelRight = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: toolBarHeight, height: toolBarHeight))
        //labelRight.backgroundColor = UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 0.6)
        labelRight.backgroundColor = UIColor.clear
        labelRight.font = Style.fontSliderLabel()
        labelRight.textColor = UIColor.white
        labelRight.textAlignment = .left
        labelRight.numberOfLines = 2
        
        self.clearsContextBeforeDrawing = true
        self.isOpaque = false
        
        addSubview(labelLeft)
        addSubview(labelRight)
        
        layoutSubviews()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let leftWidth = labelWidthForSize(size: leftTextSize)
        labelLeft.frame = CGRect(x: 0.0, y: 0.0, width: leftWidth - 2.0, height: bounds.height)
    }
    
    func update() {
        savingDotTick += 1
        
        var animationTime: Int = 8
        if Device.isTablet {
            animationTime = 4
        }
        
        if savingDotTick > animationTime {
            if savingDotDirection > 0 {
                if savingDotIndex >= 3 {
                    savingDotIndex -= 1
                    savingDotDirection = -1
                } else {
                    savingDotIndex += 1
                }
            } else {
                if savingDotIndex <= 0 {
                    savingDotIndex += 1
                    savingDotDirection = 1
                } else {
                    savingDotIndex -= 1
                }
            }
            savingDotTick = 0
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        let rect = bounds
        
        let circlePoint = CGPoint(x: rect.midX - rect.midY, y: rect.midY)
        
        //var shiftX: CGFloat = -5.0 + CGFloat(Randomizer.getFloat()) * 10.0
        //var shiftY: CGFloat = -5.0 + CGFloat(Randomizer.getFloat()) * 10.0
        
        if savingDotIndex == 0 {
            centerImage(image: imageTextSavingDots0, atPoint: circlePoint)
        } else if savingDotIndex == 1 {
            centerImage(image: imageTextSavingDots1, atPoint: circlePoint)
        } else if savingDotIndex == 2 {
            centerImage(image: imageTextSavingDots2, atPoint: circlePoint)
        } else {
            centerImage(image: imageTextSavingDots3, atPoint: circlePoint)
        }
        
        //let context: CGContext = UIGraphicsGetCurrentContext()!
        //context.saveGState()
        //centerImage(image: UIImage?, atPoint center:
        //context.restoreGState()
        
    }
    
    func centerImage(image: UIImage?, atPoint center: CGPoint) {
        if let drawImage = image {
            if drawImage.size.width > 2.0 && drawImage.size.height > 2.0 {
                let imageRect = CGRect( x: center.x - drawImage.size.width / 2.0,
                                        y: center.y - drawImage.size.height / 2.0,
                                    width: drawImage.size.width,
                                   height: drawImage.size.height)
                drawImage.draw(in: imageRect)
            }
        }
    }
    
}


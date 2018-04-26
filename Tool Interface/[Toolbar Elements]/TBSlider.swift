//
//  TBSlider.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/7/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

enum SliderTextSize: Int { case none = 0, percent = 1, small = 2, medium = 3 }

protocol TBSliderDelegate
{
    func sliderDidStart(slider:TBSlider, value: CGFloat)
    func sliderDidChange(slider:TBSlider, value: CGFloat)
    func sliderDidFinish(slider:TBSlider, value: CGFloat)
}

class TBSlider: UIView {
    
    var itemTag: String = ""
    
    
    var isEnabled: Bool {
        set {
            slider.isEnabled = newValue
            setNeedsDisplay()
            
            if newValue {
                labelRight.textColor = UIColor.white
                labelLeft.textColor = UIColor.white
            } else {
                labelRight.textColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1.0)
                labelLeft.textColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1.0)
            }
        }
        get {
            return slider.isEnabled
        }
    }
    
    var minimumValue: CGFloat = 0.0 {
        didSet {
            
            if slider !== nil {
                slider.minimumValue = Float(minimumValue)
                setNeedsDisplay()
                slider.setNeedsDisplay()
            }
        }
    }
    
    var maximumValue: CGFloat = 1.0 {
        didSet {
            if slider !== nil {
                slider.maximumValue = Float(maximumValue)
                setNeedsDisplay()
                slider.setNeedsDisplay()
            }
        }
    }
    
    private var isSliding: Bool = false
    
    private var _value: CGFloat = 0.0
    var value: CGFloat {
        set {
            _value = newValue
            slider.value = Float(_value)
        }
        get {
            return _value
        }
    }
    
    var leftTextSize: SliderTextSize = .none
    var rightTextSize: SliderTextSize = .none
    
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
    
    var rightText: String = "" {
        didSet {
            labelRight.text = rightText
            setNeedsLayout()
        }
    }
    
    
    
    //TBSlider
    
    //var
    
    
    private var slider: UISlider!
    
    private var labelLeft: UILabel!
    private var labelRight: UILabel!
    
    
    var delegate:TBSliderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override var frame: CGRect {
        didSet {
            //print("frame changed")
            setNeedsLayout()
        }
    }
    
    func setUp() {
        
        let toolBarHeight = ApplicationController.shared.toolBarHeight
        
        slider = UISlider(frame: CGRect(x: 0.0, y: 0.0, width: toolBarHeight, height: toolBarHeight))
        slider.backgroundColor = UIColor.clear
        slider.maximumTrackTintColor = styleColorMenuButtonTeal
        slider.minimumTrackTintColor = UIColor.white
        slider.minimumValue = Float(minimumValue)
        slider.maximumValue = Float(maximumValue)
        slider.value = Float(minimumValue + (maximumValue - minimumValue) * 0.5)
        slider.addTarget(self, action: #selector(sliderValueDidChange(slider:withEvent:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDidStop(slider:withEvent:)), for: .touchCancel)
        slider.addTarget(self, action: #selector(sliderDidStop(slider:withEvent:)), for: .touchUpOutside)
        
        labelLeft = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: toolBarHeight, height: toolBarHeight))
        labelLeft.backgroundColor = UIColor.clear
        labelLeft.font = Style.fontSliderLabel()
        labelLeft.textColor = UIColor.white
        labelLeft.textAlignment = .right
        labelLeft.numberOfLines = 2
        
        labelRight = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: toolBarHeight, height: toolBarHeight))
        labelRight.backgroundColor = UIColor.clear
        labelRight.font = Style.fontSliderLabel()
        labelRight.textColor = UIColor.white
        labelRight.textAlignment = .left
        labelRight.numberOfLines = 2
        
        addSubview(labelLeft)
        addSubview(labelRight)
        addSubview(slider)
        
        layoutSubviews()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let leftWidth = labelWidthForSize(size: leftTextSize)
        let rightWidth = labelWidthForSize(size: rightTextSize)
        labelLeft.frame = CGRect(x: 0.0, y: 0.0, width: leftWidth - 2.0, height: bounds.height)
        labelRight.frame = CGRect(x: bounds.width - (rightWidth - 2.0), y: 0.0, width: rightWidth - 2.0, height: bounds.height)
        slider.frame = CGRect(x: leftWidth, y: 0.0, width: bounds.width - (leftWidth + rightWidth), height: bounds.height)
    }
    
    @objc func sliderValueDidChange(slider: UISlider, withEvent event: UIEvent) {
        if let touch = event.allTouches?.first {
            
            _value = CGFloat(slider.value)
            if touch.phase == .began {
                print("Slider Started...")
                isSliding = true
                ApplicationController.shared.addActionBlocker(name: "slider")
                delegate?.sliderDidStart(slider: self, value: _value)
            }
            
            if isSliding {
                delegate?.sliderDidChange(slider: self, value: _value)
            }
            
            if touch.phase == .ended || touch.phase == .cancelled {
                if isSliding {
                    print("Slider Ended...")
                    ApplicationController.shared.removeActionBlocker(name: "slider")
                    delegate?.sliderDidFinish(slider: self, value: _value)
                    isSliding = false
                }
            }
        }
    }
    
    @objc func sliderDidStop(slider: UISlider, withEvent event: UIEvent) {
        if isSliding {
            ApplicationController.shared.removeActionBlocker(name: "slider")
            delegate?.sliderDidFinish(slider: self, value: _value)
            isSliding = false
        }
    }
    
}

//
//  TBSegment.swift
//  SwiftFunhouse
//
//  Created by Raptis, Nicholas on 7/18/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

protocol TBSegmentDelegate
{
    func segmentSelected(segment:TBSegment, index: Int)
}

class TBSegment: UIView {
    
    var itemTag: String = ""
    
    var delegate:TBSegmentDelegate?
    
    var orange: Bool = false {
        didSet {
            for i in 0..<buttons.count {
                if selectedIndex == i {
                    if orange {
                        buttons[i].styleSetSegmentSelectedOrange()
                    } else {
                        buttons[i].styleSetSegmentSelected()
                    }
                } else {
                    if orange {
                        buttons[i].styleSetSegmentOrange()
                    } else {
                        buttons[i].styleSetSegment()
                    }
                }
            }
        }
    }
    
    var selectedIndex:Int? {
        willSet {
            if let index = selectedIndex , index >= 0 && index < buttons.count {
                if orange {
                    buttons[index].styleSetSegmentOrange()
                } else {
                    buttons[index].styleSetSegment()
                }
                
                buttons[index].isSelected = false
            }
        }
        didSet {
            if let index = selectedIndex , index >= 0 && index < buttons.count {
                if orange {
                    buttons[index].styleSetSegmentSelectedOrange()
                } else {
                    buttons[index].styleSetSegmentSelected()
                }
                buttons[index].isSelected = true
            }
        }
    }
    
    private var buttons = [TBSegmentButton]()
    
    func lockSegment(index: Int) -> Void {
        if index >= 0 && index < buttons.count {
            buttons[index].isLocked = true
        }
    }
    
    func unlockSegment(index: Int) -> Void {
        if index >= 0 && index < buttons.count {
            buttons[index].isLocked = false
        }
    }
    
    func setImage(index: Int, path: String?, pathSelected: String?) {
        if index >= 0 && index < buttons.count {
            buttons[index].setImages(path: path, pathSelected: pathSelected)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    private func setUp() {
        self.backgroundColor = UIColor.clear
    }
    
    deinit { }
    
    @objc func clickSegment(_ segment:RRButton) {
        
        if ToolActions.allow() == false { return }
        
        var checkIndex:Int?
        
        for i in 0..<buttons.count {
            if segment == buttons[i] {
                checkIndex = i
            }
        }
        
        if let index = checkIndex, index != selectedIndex {
            if buttons[index].isLocked {
                print("Blocking Action!! You Need Subscribe!! Haha!!!")
                ToolActions.nagToSubscribe()
            } else {
                selectedIndex = index
                delegate?.segmentSelected(segment: self, index: index)
            }
        }
    }
    
    var segmentCount:Int {
        get {
            return buttons.count
        }
        set {
            
            //arrayButtons
            for button:RRButton in buttons {
                button.removeFromSuperview()
                button.removeTarget(self, action: #selector(clickSegment(_:)), for: .touchUpInside)
            }
            buttons.removeAll()
            
            if newValue > 0 {
                for index in 0..<newValue {
                    let button = TBSegmentButton(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
                    buttons.append(button)
                    
                    if index <= 0 {
                        button.cornerUL = true
                        button.cornerDL = true
                        if newValue > 1 {
                            button.cornerUR = false
                            button.cornerDR = false
                        } else {
                            button.cornerUR = true
                            button.cornerDR = true
                        }
                    } else if index < (newValue - 1) {
                        button.cornerUL = false
                        button.cornerDL = false
                        button.cornerUR = false
                        button.cornerDR = false
                        
                    } else {
                        button.cornerUL = false
                        button.cornerDL = false
                        button.cornerUR = true
                        button.cornerDR = true
                    }
                    
                    button.addTarget(self, action: #selector(clickSegment(_:)), for:.touchUpInside)
                    
                    if orange {
                        button.styleSetSegmentOrange()
                    } else {
                        button.styleSetSegment()
                    }
                    
                    addSubview(button)
                }
            }
            layoutButtons()
        }
    }
    
    private func layoutButtons() {
        if segmentCount > 0 {
            let stride = Int(Double(self.frame.size.width) / Double(segmentCount))
            var left = 0.0
            var right = left + Double(stride)
            for index in 0..<segmentCount {
                let button = buttons[index]
                if index == (segmentCount - 1) {
                    right = Double(self.frame.size.width)
                }
                button.frame = CGRect(x: CGFloat(left), y: 0, width: CGFloat(right - left), height: self.frame.size.height)
                button.setNeedsDisplay()
                left = right
                right += Double(stride)
            }
        }
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }
}

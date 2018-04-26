//
//  ToolBar.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/6/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class ToolBar: UIView, TBSegmentDelegate, TBCheckBoxDelegate {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint?
    //@IBOutlet weak var widthConstraint: NSLayoutConstraint?
    //@IBOutlet weak var topConstraint: NSLayoutConstraint?
    //@IBOutlet weak var leftConstraint: NSLayoutConstraint?
    //@IBOutlet weak var rightConstraint: NSLayoutConstraint?
    //@IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false
        isMultipleTouchEnabled = false
    }
    
    @objc func setUp() {
        for subview1 in subviews {
            if subview1.responds(to: #selector(setUp)) {
                subview1.perform(#selector(setUp))
            } else {
                for subview2 in subview1.subviews {
                    if subview2.responds(to: #selector(setUp)) {
                        subview2.perform(#selector(setUp))
                    } else {
                        for subview3 in subview2.subviews {
                            if subview3.responds(to: #selector(setUp)) {
                                subview3.perform(#selector(setUp))
                            } else {
                                for subview4 in subview3.subviews {
                                    if subview4.responds(to: #selector(setUp)) {
                                        subview4.perform(#selector(setUp))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        for subview1 in subviews {
            if ToolBar.isToolElement(view: subview1) == false {
                subview1.backgroundColor = UIColor.clear
                for subview2 in subview1.subviews {
                    if ToolBar.isToolElement(view: subview2) == false {
                        subview2.backgroundColor = UIColor.clear
                        for subview3 in subview2.subviews {
                            if ToolBar.isToolElement(view: subview3) == false {
                                subview3.backgroundColor = UIColor.clear
                            }
                        }
                    }
                }
            }
        }
        
        setNeedsDisplay()
    }
    
    func dismissKeyboard() {
        for subview1 in subviews {
            if subview1 is UITextField || subview1 is UITextView || subview1 is UISearchBar {
                subview1.resignFirstResponder()
            }
            for subview2 in subview1.subviews {
                if subview2 is UITextField || subview2 is UITextView || subview2 is UISearchBar {
                    subview2.resignFirstResponder()
                }
                for subview3 in subview2.subviews {
                    if subview3 is UITextField || subview3 is UITextView || subview3 is UISearchBar {
                        subview3.resignFirstResponder()
                    }
                    for subview4 in subview3.subviews {
                        if subview4 is UITextField || subview4 is UITextView || subview4 is UISearchBar {
                            subview4.resignFirstResponder()
                        }
                    }
                }
            }
        }
    }
    
    class func isToolElement(view: UIView) -> Bool {
        if view is TBButton { return true }
        if view is TBSegment { return true }
        if view is TBCheckBox { return true }
        return false
    }
    
    func segmentSelected(segment:TBSegment, index: Int) {
        
    }
    
    func checkBoxToggled(checkBox:TBCheckBox, checked: Bool) {
        
    }
    
}

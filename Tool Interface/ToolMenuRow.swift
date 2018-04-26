//
//  ToolMenuRow.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/6/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit


class ToolMenuRow: UIView, TBSegmentDelegate, TBCheckBoxDelegate, TBSliderDelegate {
    
    var containerView: UIView!
    
    var shadowImageView: UIImageView?
    var isUpwardFacing: Bool = false
    var isMainBar: Bool = false
    var isBottomBar: Bool = false
    
    fileprivate var didLayoutInterfaceFirstTime = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setUp(main: Bool, up: Bool, shadow: Bool) {
        
        isMainBar = main
        if up {
            isBottomBar = true
        } else {
            isBottomBar = false
        }
        
        clipsToBounds = false
        isUpwardFacing = up
        
        if main {
            backgroundColor = styleColorToolbarMain
        } else {
            backgroundColor = styleColorToolbarRow
            
            
        }
        //frame = CGRect(x: 2, y: frame.origin.y, width: frame.size.width - 4, height: frame.size.height)
        frame = CGRect(x: 0.0, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
        
        containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height))
        containerView.isMultipleTouchEnabled = false
        containerView.backgroundColor = UIColor.clear
        containerView.isOpaque = false
        
        addSubview(containerView)
        
        if shadow {
            var shadowHeight: CGFloat = 4.0
            if Device.isTablet { shadowHeight = 6.0 }
            if up {
                shadowImageView = UIImageView(frame: CGRect(x: 0.0, y: -shadowHeight, width: bounds.size.width, height: shadowHeight))
                addSubview(shadowImageView!)
                shadowImageView!.image = UIImage(named: "shadow_main_bar_up")
            } else {
                shadowImageView = UIImageView(frame: CGRect(x: 0.0, y: bounds.size.height, width: bounds.size.width, height: shadowHeight))
                addSubview(shadowImageView!)
                shadowImageView!.image = UIImage(named: "shadow_main_bar_down")
            }
        }
    }
    
    var animationImageView: UIImageView?
    
    weak var menu: ToolMenu!
    
    var separators = [UIView]()
    
    var buttons = [String: TBButton]()
    var buttonsWide = [String: TBButtonWide]()
    var buttonsUltraWide = [String: TBButtonUltraWide]()
    
    
    var buttonsMedium168 = [String: TBButtonMedium168]()
    var buttonsMedium192 = [String: TBButtonMedium192]()
    var buttonsMedium216 = [String: TBButtonMedium216]()
    
    var tabbers = [String: TBPageTabber]()
    
    //var buttonsRecord = [String: TBButtonRecord]()
    
    //var timelines = [String: TBTimeline]()
    //var exportInfos = [String: TBExportInfo]()
    
    
    //weak
    var buttonRecord: TBButtonRecord?
    //weak
    var exportInfo: TBExportInfo?
    //weak
    //var rateStrip: TBRateStrip?
    //weak
    var timeline: TBTimeline?
    
    
    var segments = [String: TBSegment]()
    var checkBoxes = [String: TBCheckBox]()
    var sliders = [String: TBSlider]()
    
    var tokens = [String]()
    
    func generateInterface(instr: String, dir: Int) {
        
        
        
        var previousTokens = [String]()
        previousTokens.append(contentsOf: tokens)
        tokens.removeAll(keepingCapacity: true)
        
        //print("Generate Interface...")
        //print("^>^>^>^>^>^>^>\nInstr: \(instr)\n^>^>^>^>^>^>^>")
        
        let instructions = instr.trimmingCharacters(in: .whitespaces)
        let columns = instructions.components(separatedBy: "|")
        
        var tokens_left = [String]()
        var tokens_middle = [String]()
        var tokens_right = [String]()
        
        for i in 0..<columns.count {
            let columnString = columns[i]
            let parseTokens = columnString.components(separatedBy: "]")
            for unstrippedToken in parseTokens {
                var strippedToken = unstrippedToken.trimmingCharacters(in: .whitespaces)
                
                strippedToken = strippedToken.trimmingCharacters(in: ["]", "["])
                if strippedToken.count > 0 { strippedToken = strippedToken.trimmingCharacters(in: .whitespaces) }
                
                if strippedToken.count > 0 {
                    if i == 0 {
                        tokens_left.append(strippedToken)
                    } else if i == 1 {
                        tokens_middle.append(strippedToken)
                    } else {
                        tokens_right.append(strippedToken)
                    }
                    tokens.append(String(strippedToken))
                }
            }
        }
        
        for i in 0..<tokens.count {
            let s1 = tokens[i]
            for n in (i+1)..<tokens.count {
                let s2 = tokens[n]
                if s1 == s2 {
                    print("ERROR...")
                    print("NO DUPLICATE TOKENS ALLOWED...")
                    print(instr)
                    print("++++++++++++++++++++++")
                }
            }
        }
        
        var allTokensEqual = true
        if previousTokens.count != tokens.count {
            allTokensEqual = false
        } else {
            for i in 0..<previousTokens.count {
                let token = tokens[i]
                let previousToken = previousTokens[i]
                if token != previousToken {
                    allTokensEqual = false
                }
            }
        }
        
        if allTokensEqual {
            return
        }
        
        //If there was a previous interface, turn it into an image and prepare to animate...
        //Place mechanism such that once the toolbar is animating away, multiple instances of the image cannot
        //be displayed simultaneously.
        //var animatePreviousAway: Bool = false
        
        //if buttons.count > 0 || segments.count > 0 || checkBoxes.count > 0 || separators.count > 0 || sliders.count > 0 {
        //if true {
        
        let animateElements: Bool = menu.isShowing
        
        
        if animationImageView === nil && didLayoutInterfaceFirstTime == true && animateElements == true {
            autoreleasepool {
                let image = containerView.toImage()
                animationImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height))
                addSubview(animationImageView!)
                animationImageView!.image = image
            }
        }
        
        for (_, button) in buttons { button.removeFromSuperview() }
        buttons.removeAll(keepingCapacity: true)
        
        for (_, tabber) in tabbers { tabber.removeFromSuperview() }
        tabbers.removeAll(keepingCapacity: true)
        
        
        
        
        
        for (_, button) in buttonsMedium168 { button.removeFromSuperview() }
        buttonsMedium168.removeAll(keepingCapacity: true)
        
        for (_, button) in buttonsMedium192 { button.removeFromSuperview() }
        buttonsMedium192.removeAll(keepingCapacity: true)
        
        for (_, button) in buttonsMedium216 { button.removeFromSuperview() }
        buttonsMedium216.removeAll(keepingCapacity: true)
        
        for (_, button) in buttonsWide { button.removeFromSuperview() }
        buttonsWide.removeAll(keepingCapacity: true)
        
        for (_, button) in buttonsUltraWide { button.removeFromSuperview() }
        buttonsUltraWide.removeAll(keepingCapacity: true)
        
        //for (_, button) in buttonsRecord { button.removeFromSuperview() }
        //buttonsRecord.removeAll(keepingCapacity: true)
        
        //for (_, exportInfo) in exportInfos { exportInfo.removeFromSuperview() }
        //exportInfos.removeAll(keepingCapacity: true)
        
        //for (_, timeline) in timelines { timeline.removeFromSuperview() }
        //timelines.removeAll(keepingCapacity: true)
        
        
        if let element = timeline {
            element.removeFromSuperview()
            timeline = nil
        }
        
        if let element = buttonRecord {
            element.removeFromSuperview()
            buttonRecord = nil
        }
        
        if let element = exportInfo {
            element.removeFromSuperview()
            exportInfo = nil
        }
        
        //if let element = rateStrip {
        //    element.removeFromSuperview()
        //    rateStrip = nil
        //}
        
        
        
        //weak var buttonRecord: TBButtonRecord?
        //weak var exportInfo: TBExportInfo?
        //weak var rateStrip: TBRateStrip?
        
        
        //var  = [String: TBButtonMedium168]()
        //var  = [String: TBButtonMedium192]()
        //var  = [String: TBButtonMedium216]()
        
        //if view is TBButtonMedium168 { result = ApplicationController.shared.toolBarHeight * 1.3125 }
        //if view is TBButtonMedium192 { result = ApplicationController.shared.toolBarHeight * 1.5 }
        //if view is TBButtonMedium216 { result = ApplicationController.shared.toolBarHeight * 1.6875 }
        
        
        
        for (_, segment) in segments { segment.removeFromSuperview() }
        segments.removeAll(keepingCapacity: true)
        for (_, checkBox) in checkBoxes { checkBox.removeFromSuperview() }
        checkBoxes.removeAll(keepingCapacity: true)
        for (_, slider) in sliders { slider.removeFromSuperview() }
        sliders.removeAll(keepingCapacity: true)
        for separator in separators { separator.removeFromSuperview() }
        separators.removeAll(keepingCapacity: true)
        
        
        var leftViews = [UIView]()
        var middleViews = [UIView]()
        var rightViews = [UIView]()
        
        var allViews = [UIView]()
        
        for token in tokens_left {
            if let item = processToken(token: token) {
                leftViews.append(item)
                allViews.append(item)
                containerView.addSubview(item)
            }
        }
        
        for token in tokens_middle {
            if let item = processToken(token: token) {
                middleViews.append(item)
                allViews.append(item)
                containerView.addSubview(item)
            }
        }
        
        for token in tokens_right {
            if let item = processToken(token: token) {
                rightViews.append(item)
                allViews.append(item)
                containerView.addSubview(item)
            }
        }
        
        layoutInterface(leftViews: leftViews, middleViews: middleViews, rightViews: rightViews)
        
        placeSeparators(viewSequence: leftViews)
        placeSeparators(viewSequence: middleViews)
        placeSeparators(viewSequence: rightViews)
        
        
        
        
        if didLayoutInterfaceFirstTime == false {
            didLayoutInterfaceFirstTime = true
        } else {
            
            if animateElements {
                
                if dir == 0 {
                    ApplicationController.shared.addActionBlocker(name: "tool_row_anim")
                    containerView.alpha = 0.0
                    UIView.animate(withDuration: 0.175, animations: {
                        self.animationImageView?.alpha = 0.0
                    }, completion: { (finished:Bool) in
                        self.animationImageView?.removeFromSuperview()
                        self.animationImageView = nil
                        UIView.animate(withDuration: 0.175, animations: {
                            self.containerView.alpha = 1.0
                        }, completion: { (finished:Bool) in
                            ApplicationController.shared.removeActionBlocker(name: "tool_row_anim")
                        })
                    })
                } else if dir > 0 {
                    ApplicationController.shared.addActionBlocker(name: "tool_row_anim")
                    containerView.transform = CGAffineTransform.init(translationX: -bounds.width, y: 0.0)
                    UIView.animate(withDuration: 0.35, animations: {
                        self.containerView.transform = CGAffineTransform.identity
                        self.animationImageView?.transform = CGAffineTransform.init(translationX: self.bounds.width, y: 0.0)
                    }, completion: { (finished:Bool) in
                        self.animationImageView?.removeFromSuperview()
                        self.animationImageView = nil
                        ApplicationController.shared.removeActionBlocker(name: "tool_row_anim")
                    })
                } else {
                    ApplicationController.shared.addActionBlocker(name: "tool_row_anim")
                    containerView.transform = CGAffineTransform.init(translationX: bounds.width, y: 0.0)
                    UIView.animate(withDuration: 0.35, animations: {
                        self.containerView.transform = CGAffineTransform.identity
                        self.animationImageView?.transform = CGAffineTransform.init(translationX: -self.bounds.width, y: 0.0)
                    }, completion: { (finished:Bool) in
                        self.animationImageView?.removeFromSuperview()
                        self.animationImageView = nil
                        ApplicationController.shared.removeActionBlocker(name: "tool_row_anim")
                    })
                }
            } else {
                
                
                
            }
        }
    }
    
    func processToken(token: String) -> UIView? {
        
        var result = ToolMenuRowHelper.processToken(token: token)
        
        if result === nil {
            print("@@@@@@ NO ITEM FOR TOKEN @@@@@@")
            print("@@@@@@ \(token) @@@@@@")
            print("@@@@@@ NO ITEM FOR TOKEN @@@@@@")
            
            //return nil
        }
        
        if let tabber = result as? TBPageTabber {
            tabber.itemTag = String(token)
            tabber.addTarget(self, action: #selector(clickPageTabber(tabber:)), for: .touchUpInside)
            tabbers[tabber.itemTag] = tabber
        }
        
        if let button = result as? TBButton {
            button.itemTag = String(token)
            button.addTarget(self, action: #selector(clickButton(button:)), for: .touchUpInside)
            buttons[button.itemTag] = button
        }
        
        if let button = result as? TBButtonMedium168 {
            button.itemTag = String(token)
            button.addTarget(self, action: #selector(clickButtonMedium(button:)), for: .touchUpInside)
            buttonsMedium168[button.itemTag] = button
        }
        
        if let button = result as? TBButtonMedium192 {
            button.itemTag = String(token)
            button.addTarget(self, action: #selector(clickButtonMedium(button:)), for: .touchUpInside)
            buttonsMedium192[button.itemTag] = button
        }
        
        if let button = result as? TBButtonMedium216 {
            button.itemTag = String(token)
            button.addTarget(self, action: #selector(clickButtonMedium(button:)), for: .touchUpInside)
            buttonsMedium216[button.itemTag] = button
        }
        
        if let button = result as? TBButtonWide {
            button.itemTag = String(token)
            button.addTarget(self, action: #selector(clickButtonWide(button:)), for: .touchUpInside)
            buttonsWide[button.itemTag] = button
        }
        
        if let button = result as? TBButtonUltraWide {
            button.itemTag = String(token)
            button.addTarget(self, action: #selector(clickButtonUltraWide(button:)), for: .touchUpInside)
            buttonsUltraWide[button.itemTag] = button
        }
        
        if let segment = result as? TBSegment {
            segment.itemTag = String(token)
            segment.delegate = self
            segments[segment.itemTag] = segment
        }
        
        if let checkBox = result as? TBCheckBox {
            checkBox.itemTag = String(token)
            checkBox.delegate = self
            checkBoxes[checkBox.itemTag] = checkBox
        }
        
        if let slider = result as? TBSlider {
            slider.itemTag = String(token)
            slider.delegate = self
            sliders[slider.itemTag] = slider
        }
        
        if let ei = result as? TBExportInfo {
            exportInfo = ei
        }
        
        if let tl = result as? TBTimeline {
            timeline = tl
        }
        
        if let rb = result as? TBButtonRecord {
            buttonRecord = rb
            rb.addTarget(self, action: #selector(clickButtonRecord(button:)), for: .touchUpInside)
        }
        
        //if let rs = result as? TBRateStrip {
        //    rateStrip = rs
        //}
        
        return result
    }
    
    
    
    
    func placeSeparators(viewSequence views: [UIView]) {
        var prev: UIView?
        for view in views {
            if view is TBButton || view is TBButtonWide || view is TBButtonMedium168 || view is TBButtonMedium192 || view is TBButtonMedium216 {
                if prev !== nil {
                    
                    let centerX = Int(prev!.frame.maxX + view.frame.minX + 0.5) / 2
                    var verticalInset: CGFloat = 6.0
                    var verticalShift: CGFloat = 0.0
                    if Device.isPhone { verticalInset = 4.0 }
                    
                    //For the top main bar, we have "safeAreaInsetTop"
                    //extra padding on top of the functional bar...
                    if isMainBar == true && isBottomBar == false {
                        var safeAreaTop = Device.safeAreaInsetTopPortrait
                        if ApplicationController.shared.isSceneLandscape {
                            safeAreaTop = Device.safeAreaInsetTopLandscape
                        }
                        verticalShift = safeAreaTop
                    }
                    
                    let separator = UIView(frame: CGRect(x: CGFloat(centerX - 1), y: verticalInset + verticalShift, width: 2.0, height: ApplicationController.shared.toolBarHeight - (verticalInset + verticalInset)))
                    containerView.addSubview(separator)
                    separators.append(separator)
                    separator.isUserInteractionEnabled = false
                    separator.backgroundColor = styleColorToolbarSeparator
                }
                prev = view
            } else {
                prev = nil
            }
        }
    }
    
    func layoutInterface(leftViews: [UIView], middleViews: [UIView], rightViews: [UIView]) {
        
        var layoutNodes = [LayoutNode]()
        
        for view in leftViews {
            let layoutNode = LayoutNode()
            layoutNode.view = view
            layoutNode.side = .left
            layoutNodes.append(layoutNode)
        }
        
        for view in middleViews {
            let layoutNode = LayoutNode()
            layoutNode.view = view
            layoutNode.side = .middle
            layoutNodes.append(layoutNode)
        }
        
        for view in rightViews {
            let layoutNode = LayoutNode()
            layoutNode.view = view
            layoutNode.side = .right
            layoutNodes.append(layoutNode)
        }
        
        for node in layoutNodes {
            if let button = node.view as? TBButton { node.name = String(button.itemTag) }
            if let segment = node.view as? TBSegment { node.name = String(segment.itemTag) }
            if let checkBox = node.view as? TBCheckBox { node.name = String(checkBox.itemTag) }
            if let slider = node.view as? TBSlider { node.name = String(slider.itemTag) }
            
            
            node.preferredWidth = ToolMenuRowHelper.preferredWidthForItem(view: node.view)
            node.minimumWidth = ToolMenuRowHelper.minimumWidthForItem(view: node.view)
            node.flexibleWidth = ToolMenuRowHelper.flexibleWidthForItem(view: node.view)
        }
        
        guard layoutNodes.count > 0 else { return }
        
        if layoutNodes.count == 1 {
            layoutNodes[0].spacingLeft = ToolMenuRowHelper.leftSpacingForItem(item: layoutNodes[0].view)
            layoutNodes[0].spacingRight = ToolMenuRowHelper.rightSpacingForItem(item: layoutNodes[0].view)
        } else {
            let firstNode = layoutNodes[0]
            let lastNode = layoutNodes[layoutNodes.count - 1]
            
            firstNode.spacingLeft = ToolMenuRowHelper.leftSpacingForItem(item: firstNode.view)
            lastNode.spacingRight = ToolMenuRowHelper.rightSpacingForItem(item: lastNode.view)
            
            for i in 0..<(layoutNodes.count) {
                
                let node = layoutNodes[i]
                var prevNode: LayoutNode?
                var nextNode: LayoutNode?
                
                if i > 0 {
                    prevNode = layoutNodes[i - 1]
                }
                if i < (layoutNodes.count - 1) {
                    nextNode = layoutNodes[i + 1]
                }
                if prevNode != nil {
                    let s = ToolMenuRowHelper.spacingBetweenItems(item1: prevNode!.view, item2: node.view)
                    prevNode!.spacingRight = s
                    node.spacingLeft = s
                }
                if nextNode != nil {
                    let s = ToolMenuRowHelper.spacingBetweenItems(item1: node.view, item2: nextNode!.view)
                    node.spacingRight = s
                    nextNode!.spacingLeft = s
                }                
            }
        }
        layoutInterface(nodes: layoutNodes)
    }
    
    //Preconditions:
    //The following parameters of each node are at their final value:
    //minimumWidth, preferredWidth, flexibleWidth, spacingLeft, spacingRight
    
    //All of the nodes have their spacing computed.
    //All of the nodes have their minimum and preferred widths computed.
    //All of the nodes have their flexibility status computed.
    
    func layoutInterface(nodes: [LayoutNode]) {
        
        guard nodes.count > 0 else { return }
        
        let safeAreaTop = ApplicationController.safeAreaInsetTop
        let safeAreaRight = ApplicationController.safeAreaInsetRight
        //let safeAreaBottom = ApplicationController.safeAreaInsetBottom
        let safeAreaLeft = ApplicationController.safeAreaInsetLeft
        
        LayoutNode.layout(nodes: nodes, width: Int(bounds.width - (safeAreaRight + safeAreaLeft) + 0.5))
        
        for i in 0..<nodes.count {
            let node = nodes[i]
            if isMainBar {
                if isBottomBar {
                    node.view.frame = CGRect(x: safeAreaLeft + CGFloat(node.x), y: 0.0, width: CGFloat(node.width), height: ApplicationController.shared.toolBarHeight)
                } else {
                    node.view.frame = CGRect(x: safeAreaLeft + CGFloat(node.x), y: safeAreaTop, width: CGFloat(node.width), height: ApplicationController.shared.toolBarHeight)
                }
            } else {
                node.view.frame = CGRect(x: safeAreaLeft + CGFloat(node.x), y: 0.0, width: CGFloat(node.width), height: ApplicationController.shared.toolBarHeight)
            }
            node.view.setNeedsDisplay()
        }
    }
    
    @objc func clickPageTabber(tabber: RRButton!) -> Void {
        if tabber.itemTag == ToolItem.anim_tools_next.rawValue {
            if ToolActions.allow() { ToolActions.nextAnimationMenu() }
        } else if tabber.itemTag == ToolItem.anim_tools_prev.rawValue {
            if ToolActions.allow() { ToolActions.prevAnimationMenu() }
        }
    }
    
    @objc func clickButtonRecord(button: RRButton!) -> Void {
        ToolActions.recordButtonAction()
    }
    
    @objc func clickButtonWide(button: RRButton!) -> Void {
        if button.itemTag == ToolItem.rate.rawValue {
            if ToolActions.allow() {
                ToolActions.showRatingsDialog()
            }
        }
        
        if button.itemTag == ToolItem.purchase.rawValue {
            if ToolActions.allow() {
                ToolActions.showStoreScreen(autobuy: true)
            }
        }
        
        if button.itemTag == ToolItem.record_menu.rawValue {
            if ToolActions.allow() {
                ToolActions.setActiveMenusRecord()
            }
        }
        
        if button.itemTag == ToolItem.record_cancel.rawValue {
            if ToolActions.allow() {
                ToolActions.recordCancel()
            }
        }
        
        if button.itemTag == ToolItem.timeline_cancel.rawValue {
            if ToolActions.allow() {
                ToolActions.timelineCancel()
            }
        }
        
        if button.itemTag == ToolItem.export_video.rawValue {
            if ToolActions.allow() {
                ToolActions.beginExport()
            }
        }
        
        if button.itemTag == ToolItem.export_cancel.rawValue {
            if ToolActions.allow() {
                ToolActions.cancelExport()
            }
        }
        
        if button.itemTag == ToolItem.export_done.rawValue {
            if ToolActions.allow() {
                ToolActions.finishExport()
            }
        }
        
        if button.itemTag == ToolItem.reset_default_bb.rawValue {
            if ToolActions.allow() {
                ToolActions.resetDefaultAnimationBulgeBouncer()
            }
        }
        
        if button.itemTag == ToolItem.reset_default_twister.rawValue {
            if ToolActions.allow() {
                ToolActions.resetDefaultAnimationTwister()
            }
        }
        
        if button.itemTag == ToolItem.reset_default_random.rawValue {
            if ToolActions.allow() {
                ToolActions.resetDefaultAnimationRandom()
            }
        }
    }
    
    @objc func clickButtonUltraWide(button: RRButton!) -> Void {
        
    }
    
    @objc func clickButtonMedium(button: RRButton!) -> Void {
        
        if button.itemTag == ToolItem.collapse_bottom.rawValue {
            if ToolActions.allow() { ToolActions.hideBottomMenu() }
        }
        if button.itemTag == ToolItem.collapse_top.rawValue {
            if ToolActions.allow() { ToolActions.hideTopMenu() }
        }
        
        if button.itemTag == ToolItem.export_share_email.rawValue {
            if ToolActions.allow() && ToolActions.isShowingPopover() == false { ToolActions.videoExportShareEmail() }
        }
        
        if button.itemTag == ToolItem.export_share_facebook.rawValue {
            if ToolActions.allow() && ToolActions.isShowingPopover() == false { ToolActions.videoExportShareFacebook() }
        }
        
        if button.itemTag == ToolItem.export_share_twitter.rawValue {
            if ToolActions.allow() && ToolActions.isShowingPopover() == false { ToolActions.videoExportShareTwitter() }
        }
        
        
        if button.itemTag == ToolItem.delete_blob.rawValue {
            if ToolActions.allow() { ToolActions.deleteBlob() }
        }
        if button.itemTag == ToolItem.clone_blob.rawValue {
            if ToolActions.allow() { ToolActions.cloneBlob() }
        }
        if button.itemTag == ToolItem.send_forward.rawValue {
            if ToolActions.allow() { ToolActions.sendForward() }
        }
        if button.itemTag == ToolItem.send_backward.rawValue {
            if ToolActions.allow() { ToolActions.sendBackward() }
        }
        if button.itemTag == ToolItem.send_front.rawValue {
            if ToolActions.allow() { ToolActions.sendFront() }
        }
        if button.itemTag == ToolItem.send_back.rawValue {
            if ToolActions.allow() { ToolActions.sendBack() }
        }
        
        if button.itemTag == ToolItem.reset_zoom.rawValue {
            if ToolActions.allow() { ToolActions.resetZoom() }
        }
    }
    
    @objc func clickButton(button: RRButton!) -> Void {
        if button.itemTag == ToolItem.menu.rawValue {
            if ToolActions.allow() { ToolActions.toggleSideMenu(completion: nil) }
        }
        if button.itemTag == ToolItem.undo.rawValue {
            if ToolActions.allow() { ToolActions.undo() }
        }
        if button.itemTag == ToolItem.redo.rawValue {
            if ToolActions.allow() { ToolActions.redo() }
        }
        if button.itemTag == ToolItem.add_blob.rawValue {
            if ToolActions.allow() { ToolActions.addBlob() }
        }
        if button.itemTag == ToolItem.prev_blob.rawValue {
            if ToolActions.allow() { ToolActions.selectPreviousBlob() }
        }
        if button.itemTag == ToolItem.next_blob.rawValue {
            if ToolActions.allow() { ToolActions.selectNextBlob() }
        }
        if button.itemTag == ToolItem.prev_point.rawValue {
            if ToolActions.allow() { ToolActions.selectPreviousPoint() }
        }
        if button.itemTag == ToolItem.next_point.rawValue {
            if ToolActions.allow() { ToolActions.selectNextPoint() }
        }
        if button.itemTag == ToolItem.add_point.rawValue {
            if ToolActions.allow() { ToolActions.addPoint() }
        }
        if button.itemTag == ToolItem.delete_point.rawValue {
            if ToolActions.allow() { ToolActions.deletePoint() }
        }
        if button.itemTag == ToolItem.flip_h.rawValue {
            if ToolActions.allow() { ToolActions.flipH() }
        }
        if button.itemTag == ToolItem.flip_v.rawValue {
            if ToolActions.allow() { ToolActions.flipV() }
        }
        if button.itemTag == ToolItem.freeze.rawValue {
            if ToolActions.allow() { ToolActions.freezeSelected() }
        }
        if button.itemTag == ToolItem.unfreeze.rawValue {
            if ToolActions.allow() { ToolActions.unfreezeAll() }
        }
        
        
        if button.itemTag == ToolItem.timeline_play.rawValue {
            if ToolActions.allow() { ToolActions.timelinePlayPause() }
        }
        
        if button.itemTag == ToolItem.timeline_next_frame.rawValue {
            if ToolActions.allow() { ToolActions.timelineNextFrame() }
        }
        
        if button.itemTag == ToolItem.timeline_prev_frame.rawValue {
            if ToolActions.allow() { ToolActions.timelinePreviousFrame() }
        }
        
        
        
        
    }
    
    
    //MARK: TBSegmentDelegate
    
    func segmentSelected(segment:TBSegment, index: Int) {
        
        if segment.itemTag == ToolItem.scene_mode.rawValue {
            if segment.selectedIndex == 0 {
                ApplicationController.shared.sceneMode = .edit
            } else {
                ApplicationController.shared.sceneMode = .view
            }
            return
        }
        
        if segment.itemTag == ToolItem.edit_mode.rawValue {
            if segment.selectedIndex == 0 {
                ApplicationController.shared.editMode = .affine
            } else if segment.selectedIndex == 1 {
                ApplicationController.shared.editMode = .shape
            } else {
                ApplicationController.shared.editMode = .distribution
            }
            return
        }
        
        if segment.itemTag == ToolItem.animation_mode.rawValue {
            if segment.selectedIndex == 0 {
                ApplicationController.shared.animationMode = .bounce
            } else if segment.selectedIndex == 1 {
                ApplicationController.shared.animationMode = .twist
            } else {
                ApplicationController.shared.animationMode = .random
            }
            return
        }
        
    }
    
    //MARK: TBCheckBoxDelegate
    
    func checkBoxToggled(checkBox:TBCheckBox, checked: Bool) {
        if checkBox.itemTag == ToolItem.zoom.rawValue {
            ToolActions.setZoomEnabled(zoomEnabled: checkBox.checked)
        } else if checkBox.itemTag == ToolItem.stereoscopic.rawValue {
            ToolActions.setStereoscopicEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.gyro.rawValue {
            ToolActions.setGyroEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.animation.rawValue {
            ToolActions.setAnimationEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.show_markers.rawValue {
            ToolActions.setShowingMarkers(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_bb_bounce_enabled.rawValue {
            ToolActions.setAnimationBulgeBouncerBounceEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_bb_reverse_enabled.rawValue {
            ToolActions.setAnimationBulgeBouncerReverseEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_bb_ellipse_enabled.rawValue {
            ToolActions.setAnimationBulgeBouncerEllipseEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_bb_alternate_enabled.rawValue {
            ToolActions.setAnimationBulgeBouncerAlternateEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_bb_twist_enabled.rawValue {
            ToolActions.setAnimationBulgeBouncerTwistEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_bb_inflate_enabled.rawValue {
            ToolActions.setAnimationBulgeBouncerInflateEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_bb_horizontal_enabled.rawValue {
            ToolActions.setAnimationBulgeBouncerHorizontalEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_tw_reverse_enabled.rawValue {
            ToolActions.setAnimationTwisterReverseEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_tw_ellipse_enabled.rawValue {
            ToolActions.setAnimationTwisterEllipseEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_tw_alternate_enabled.rawValue {
            ToolActions.setAnimationTwisterAlternateEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_tw_inflate_enabled.rawValue {
            ToolActions.setAnimationTwisterInflateEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_rd_reverse_enabled.rawValue {
            ToolActions.setAnimationRandomReverseEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_rd_ellipse_enabled.rawValue {
            ToolActions.setAnimationRandomEllipseEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_rd_alternate_enabled.rawValue {
            ToolActions.setAnimationRandomAlternateEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_rd_twist_enabled.rawValue {
            ToolActions.setAnimationRandomTwistEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_rd_inflate_enabled.rawValue {
            ToolActions.setAnimationRandomInflateEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.a_rd_horizontal_enabled.rawValue {
            ToolActions.setAnimationRandomHorizontalEnabled(checkBox.checked)
        } else if checkBox.itemTag == ToolItem.export_audio.rawValue {
            Config.shared.exportAudio = checkBox.checked
            Config.shared.save()
        }
        
        
    }
    
    //MARK: TBSliderDelegate
    func sliderDidStart(slider:TBSlider, value: CGFloat) {
        guard let engine = ApplicationController.shared.engine else { return }
        if slider.itemTag == ToolItem.bulge_edge_factor.rawValue {
            engine.bulgeWeightEdgeSliderStart()
        } else if slider.itemTag == ToolItem.bulge_center_factor.rawValue {
            engine.bulgeWeightCenterSliderStart()
        } else if slider.itemTag == ToolItem.bulge_center_factor.rawValue {
            engine.bulgeWeightEdgeSliderStart()
        } else if slider.itemTag == ToolItem.animation_speed.rawValue {
            engine.animationSpeedSliderStart()
        } else if slider.itemTag == ToolItem.animation_power.rawValue {
            engine.animationPowerSliderStart()
        } else if slider.itemTag == ToolItem.a_bb_power.rawValue {
            engine.animationBulgeBouncerPowerSliderStart()
        } else if slider.itemTag == ToolItem.a_bb_speed.rawValue {
            engine.animationBulgeBouncerSpeedSliderStart()
        } else if slider.itemTag == ToolItem.a_bb_ellipse_factor.rawValue {
            engine.animationBulgeBouncerEllipseFactorSliderStart()
        } else if slider.itemTag == ToolItem.a_bb_inflation_factor.rawValue {
            engine.animationBulgeBouncerInflationFactorSliderStart()
        } else if slider.itemTag == ToolItem.a_bb_inflation_start_factor.rawValue {
            engine.animationBulgeBouncerBounceStartSliderStart()
        } else if slider.itemTag == ToolItem.a_bb_bounce_factor.rawValue {
            engine.animationBulgeBouncerBounceSliderStart()
        } else if slider.itemTag == ToolItem.a_tw_speed.rawValue {
            engine.animationTwisterTwistSpeedSliderStart()
        } else if slider.itemTag == ToolItem.a_tw_power.rawValue {
            engine.animationTwisterTwistPowerSliderStart()
        } else if slider.itemTag == ToolItem.a_tw_inflation_factor_1.rawValue {
            engine.animationTwisterInflationFactor1SliderStart()
        } else if slider.itemTag == ToolItem.a_tw_inflation_factor_2.rawValue {
            engine.animationTwisterInflationFactor2SliderStart()
        } else if slider.itemTag == ToolItem.a_rd_speed.rawValue {
            engine.animationRandomSpeedSliderStart()
        } else if slider.itemTag == ToolItem.a_rd_power.rawValue {
            engine.animationRandomPowerSliderStart()
        } else if slider.itemTag == ToolItem.a_rd_inflation_factor_1.rawValue {
            engine.animationRandomInflationFactor1SliderStart()
        } else if slider.itemTag == ToolItem.a_rd_inflation_factor_2.rawValue {
            engine.animationRandomInflationFactor2SliderStart()
        } else if slider.itemTag == ToolItem.a_rd_twist_factor.rawValue {
            engine.animationRandomTwistFactorSliderStart()
        } else if slider.itemTag == ToolItem.a_rd_randomness_factor.rawValue {
            engine.animationRandomRandomnessFactorSliderStart()
        }
    }
    
    func sliderDidFinish(slider:TBSlider, value: CGFloat) {
        
        guard let engine = ApplicationController.shared.engine else { return }
        
        if slider.itemTag == ToolItem.bulge_edge_factor.rawValue {
            engine.bulgeWeightEdgeSliderEnd()
        } else if slider.itemTag == ToolItem.bulge_center_factor.rawValue {
            engine.bulgeWeightCenterSliderEnd()
        } else if slider.itemTag == ToolItem.animation_speed.rawValue {
            engine.animationSpeedSliderEnd()
        } else if slider.itemTag == ToolItem.animation_power.rawValue {
            engine.animationPowerSliderEnd()
        } else if slider.itemTag == ToolItem.a_bb_power.rawValue {
            engine.animationBulgeBouncerPowerSliderEnd()
        } else if slider.itemTag == ToolItem.a_bb_speed.rawValue {
            engine.animationBulgeBouncerSpeedSliderEnd()
        } else if slider.itemTag == ToolItem.a_bb_ellipse_factor.rawValue {
            engine.animationBulgeBouncerEllipseFactorSliderEnd()
        } else if slider.itemTag == ToolItem.a_bb_inflation_factor.rawValue {
            engine.animationBulgeBouncerInflationFactorSliderEnd()
        } else if slider.itemTag == ToolItem.a_bb_inflation_start_factor.rawValue {
            engine.animationBulgeBouncerBounceStartSliderEnd()
        } else if slider.itemTag == ToolItem.a_bb_bounce_factor.rawValue {
            engine.animationBulgeBouncerBounceSliderEnd()
        } else if slider.itemTag == ToolItem.a_tw_speed.rawValue {
            engine.animationTwisterTwistSpeedSliderEnd()
        } else if slider.itemTag == ToolItem.a_tw_power.rawValue {
            engine.animationTwisterTwistPowerSliderEnd()
        } else if slider.itemTag == ToolItem.a_tw_inflation_factor_1.rawValue {
            engine.animationTwisterInflationFactor1SliderEnd()
        } else if slider.itemTag == ToolItem.a_tw_inflation_factor_2.rawValue {
            engine.animationTwisterInflationFactor2SliderEnd()
        } else if slider.itemTag == ToolItem.a_rd_speed.rawValue {
            engine.animationRandomSpeedSliderEnd()
        } else if slider.itemTag == ToolItem.a_rd_power.rawValue {
            engine.animationRandomPowerSliderEnd()
        } else if slider.itemTag == ToolItem.a_rd_inflation_factor_1.rawValue {
            engine.animationRandomInflationFactor1SliderEnd()
        } else if slider.itemTag == ToolItem.a_rd_inflation_factor_2.rawValue {
            engine.animationRandomInflationFactor2SliderEnd()
        } else if slider.itemTag == ToolItem.a_rd_twist_factor.rawValue {
            engine.animationRandomTwistFactorSliderEnd()
        } else if slider.itemTag == ToolItem.a_rd_randomness_factor.rawValue {
            engine.animationRandomRandomnessFactorSliderEnd()
        }
    }
    
    func sliderDidChange(slider:TBSlider, value: CGFloat) {
        
        guard let engine = ApplicationController.shared.engine else { return }
        guard let bounce = ApplicationController.shared.bounce else { return }
        
        if slider.itemTag == ToolItem.zoom_scale.rawValue {
            bounce.setZoom(CGFloat(slider.value))
            refreshSliderZoomScaleText()
        } else if slider.itemTag == ToolItem.animation_power.rawValue {
            engine.animationPower = slider.value
            refreshSliderAnimationPowerText()
        } else if slider.itemTag == ToolItem.animation_speed.rawValue {
            engine.animationSpeed = slider.value
            refreshSliderAnimationSpeedText()
        } else if slider.itemTag == ToolItem.bulge_edge_factor.rawValue {
            if let blob = engine.selectedBlob {
                blob.bulgeEdgeFactor = slider.value
            }
            refreshSliderBulgeEdgeFactorText()
        } else if slider.itemTag == ToolItem.bulge_center_factor.rawValue {
            if let blob = engine.selectedBlob { blob.bulgeCenterFactor = slider.value }
            refreshSliderBulgeCenterFactorText()
        } else if slider.itemTag == ToolItem.a_bb_power.rawValue {
            engine.animationBulgeBouncerPower = slider.value
            refreshSliderBulgeBouncerPowerText()
        } else if slider.itemTag == ToolItem.a_bb_speed.rawValue {
            engine.animationBulgeBouncerSpeed = slider.value
            refreshSliderBulgeBouncerSpeedText()
        } else if slider.itemTag == ToolItem.a_bb_inflation_start_factor.rawValue {
            engine.animationBulgeBouncerInflationStartFactor = slider.value
            refreshSliderBulgeBouncerInflationStartFactorText()
        } else if slider.itemTag == ToolItem.a_bb_ellipse_factor.rawValue {
            engine.animationBulgeBouncerEllipseFactor = slider.value
            refreshSliderBulgeBouncerEllipseFactorText()
        } else if slider.itemTag == ToolItem.a_bb_inflation_factor.rawValue {
            engine.animationBulgeBouncerInflationFactor = slider.value
            refreshSliderBulgeBouncerInflationFactorText()
        } else if slider.itemTag == ToolItem.a_bb_bounce_factor.rawValue {
            engine.animationBulgeBouncerBounceFactor = slider.value
            refreshSliderBulgeBouncerBounceFactorText()
        } else if slider.itemTag == ToolItem.a_tw_speed.rawValue {
            engine.animationTwisterTwistSpeed = slider.value
            refreshSliderTwisterSpeedText()
        } else if slider.itemTag == ToolItem.a_tw_power.rawValue {
            engine.animationTwisterTwistPower = slider.value
            refreshSliderTwisterPowerText()
        } else if slider.itemTag == ToolItem.a_tw_inflation_factor_1.rawValue {
            engine.animationTwisterInflationFactor1 = slider.value
            refreshSliderTwisterInflationFactor1Text()
        } else if slider.itemTag == ToolItem.a_tw_inflation_factor_2.rawValue {
            engine.animationTwisterInflationFactor2 = slider.value
            refreshSliderTwisterInflationFactor2Text()
        } else if slider.itemTag == ToolItem.a_rd_speed.rawValue {
            engine.animationRandomSpeed = slider.value
            refreshSliderRandomSpeedText()
        } else if slider.itemTag == ToolItem.a_rd_power.rawValue {
            engine.animationRandomPower = slider.value
            refreshSliderRandomPowerText()
        } else if slider.itemTag == ToolItem.a_rd_twist_factor.rawValue {
            engine.animationRandomTwistFactor = slider.value
            refreshSliderRandomTwistFactorText()
        } else if slider.itemTag == ToolItem.a_rd_randomness_factor.rawValue {
            engine.animationRandomRandomnessFactor = slider.value
            refreshSliderRandomRandomnessFactorText()
        } else if slider.itemTag == ToolItem.a_rd_inflation_factor_1.rawValue {
            engine.animationRandomInflationFactor1 = slider.value
            refreshSliderRandomInflationFactor1Text()
        } else if slider.itemTag == ToolItem.a_rd_inflation_factor_2.rawValue {
            engine.animationRandomInflationFactor2 = slider.value
            refreshSliderRandomInflationFactor2Text()
        }
        
        refreshButtonResetDefaultBulgeBouncer()
        refreshButtonResetDefaultRandom()
        refreshButtonResetDefaultTwister()
    }
    
    func handleSubscriptionStateChanged() -> Void {
        refreshSegmentEditMode()
        refreshButtonPurchase()
    }
    
    func handleZoomEnabledChanged() {
        refreshCheckBoxZoom()
    }
    
    func handleBlobSelectionChanged() {
        refreshButtonDeleteBlob()
        refreshButtonCloneBlob()
        refreshButtonAddPoint()
        refreshButtonDeletePoint()
        refreshButtonPreviousPoint()
        refreshButtonNextPoint()
        refreshButtonFreeze()
        refreshButtonUnfreezeAll()
        
        refreshButtonSendForward()
        refreshButtonSendFront()
        refreshButtonSendBackward()
        refreshButtonSendBack()
        
        refreshButtonFlipH()
        refreshButtonFlipV()
        refreshButtonNextBlob()
        refreshButtonPrevBlob()
        
        
        refreshSliderBulgeCenterFactor()
        refreshSliderBulgeEdgeFactor()
    }
    
    func handleBlobCountChanged() {
        refreshCheckBoxAnimationBulgeBouncerAlternateEnabled()
        refreshCheckBoxAnimationRandomAlternateEnabled()
        refreshCheckBoxAnimationTwisterAlternateEnabled()
        refreshButtonNextBlob()
        refreshButtonPrevBlob()
    }
    
    func handleZoomEnabledChangedForced() {
        refreshButtonResetZoom()
    }
    
    func handleZoomScaleChanged() {
        refreshSliderZoomScale()
        refreshButtonResetZoom()
    }
    
    func handleHistoryChanged() {
        
        refreshSegmentSceneMode()
        refreshSegmentEditMode()
        refreshSegmentAnimationMode()
        
        refreshButtonRedo()
        refreshButtonUndo()
        refreshButtonResetDefaultBulgeBouncer()
        refreshButtonResetDefaultRandom()
        refreshButtonResetDefaultTwister()
        
        refreshCheckBoxAnimationEnabled()
        refreshCheckBoxAnimationBulgeBouncerHorizontalEnabled()
        refreshCheckBoxAnimationBulgeBouncerInflateEnabled()
        refreshCheckBoxAnimationBulgeBouncerTwistEnabled()
        refreshCheckBoxAnimationBulgeBouncerAlternateEnabled()
        refreshCheckBoxAnimationBulgeBouncerEllipseEnabled()
        refreshCheckBoxAnimationBulgeBouncerReverseEnabled()
        refreshCheckBoxAnimationBulgeBouncerBounceEnabled()
        refreshCheckBoxAnimationTwisterReverseEnabled()
        refreshCheckBoxAnimationTwisterEllipseEnabled()
        refreshCheckBoxAnimationTwisterAlternateEnabled()
        refreshCheckBoxAnimationTwisterInflateEnabled()
        refreshCheckBoxAnimationRandomReverseEnabled()
        refreshCheckBoxAnimationRandomEllipseEnabled()
        refreshCheckBoxAnimationRandomHorizontalEnabled()
        refreshCheckBoxAnimationRandomInflateEnabled()
        refreshCheckBoxAnimationRandomTwistEnabled()
        refreshCheckBoxAnimationRandomAlternateEnabled()
        
        refreshSliderAnimationPower()
        refreshSliderAnimationSpeed()
        refreshSliderBulgeEdgeFactor()
        refreshSliderBulgeCenterFactor()
        refreshSliderBulgeBouncerPower()
        refreshSliderBulgeBouncerSpeed()
        refreshSliderBulgeBouncerEllipseFactor()
        refreshSliderBulgeBouncerInflationFactor()
        refreshSliderBulgeBouncerInflationStartFactor()
        refreshSliderBulgeBouncerBounceFactor()
        refreshSliderTwisterSpeed()
        refreshSliderTwisterPower()
        refreshSliderTwisterInflationFactor1()
        refreshSliderTwisterInflationFactor2()
        refreshSliderRandomSpeed()
        refreshSliderRandomPower()
        refreshSliderRandomTwistFactor()
        refreshSliderRandomRandomnessFactor()
        refreshSliderRandomInflationFactor1()
        refreshSliderRandomInflationFactor2()
    }
    
    func handleStackOrderChanged() {
        refreshButtonSendForward()
        refreshButtonSendFront()
        
        refreshButtonSendBackward()
        refreshButtonSendBack()
    }
    
    
    func handleSceneModeChanged() {
        refreshSegmentSceneMode()
        refreshCheckBoxStereoscopic()
    }
    
    func handleEditModeChanged() {
        refreshSegmentEditMode()
    }
    
    func handleAnimationModeChanged() {
        
    }
    
    func handleAnimationEnabledChanged() {
        
    }
    
    
    func handleAnimationAlternationEnabledChanged() {
        refreshCheckBoxAnimationBulgeBouncerAlternateEnabled()
        refreshCheckBoxAnimationRandomAlternateEnabled()
        refreshCheckBoxAnimationTwisterAlternateEnabled()
        
    }
    
    func handleAnimationBounceEnabledChanged() {
        refreshSliderBulgeBouncerBounceFactor()
    }
    
    func handleAnimationReverseEnabledChanged() {
        
        
    }
    
    func handleAnimationTwistEnabledChanged() {
        
        
    }
    
    func handleAnimationEllipseEnabledChanged() {
        
        
    }
    
    func handleAnimationInflateEnabledChanged() {
        
        
    }
    
    func handleAnimationHorizontalEnabledChanged() {
        
    }
    
    func handleShowingMarkersChanged() {
        
    }
    
    func handleFrozenStateChanged() {
        refreshButtonUnfreezeAll()
    }
    
    func handlePointCountChanged() {
        refreshButtonAddPoint()
        refreshButtonDeletePoint()
    }
    
    func handleAltMenuBulgeBouncerChanged() {
        
    }
    
    func handleAltMenuTwisterChanged() {
        
    }
    
    func handleAltMenuRandomChanged() {
        
    }
    
    func handleRecordEnabledChanged() -> Void {
        refreshButtonRecord()
    }
    
    func handleTimelineEnabledChanged() -> Void {
        refreshTimeline()
        refreshButtonRecord()
    }
    
    func handletimelineFrameChanged() -> Void {
        if let tl = timeline {
            tl.placeThumb()
        }
    }
    
    //Doubtful this will be used..
    func handleTimelineHandleChanged() -> Void {
        
    }
    
    func handleVideoExportFrameChanged() {
        refreshExportInfo()
    }
    
    func handleVideoExportBegin() {
        refreshButtonExportCancel()
        refreshButtonExportDone()
        refreshExportInfo()
    }
    
    func handleVideoExportComplete() -> Void {
        refreshButtonExportCancel()
        refreshButtonExportDone()
        refreshExportInfo()
    }
    
    func handleVideoExportError() {
        
    }
    
    func handleTimelinePlaybackEnabledChanged() {
        refreshButtonTimelinePlay()
    }
    
    
    func handleTimelinePlaybackRestart() {
        
    }
    
    func refreshAllElements() {
        
        refreshSegmentSceneMode()
        refreshSegmentEditMode()
        refreshSegmentAnimationMode()
        
        refreshCheckBoxZoom()
        refreshCheckBoxGyro()
        refreshCheckBoxStereoscopic()
        refreshCheckBoxShowMarkers()
        refreshCheckBoxExportAudio()
        
        refreshCheckBoxAnimationEnabled()
        refreshCheckBoxAnimationBulgeBouncerHorizontalEnabled()
        refreshCheckBoxAnimationBulgeBouncerInflateEnabled()
        refreshCheckBoxAnimationBulgeBouncerTwistEnabled()
        refreshCheckBoxAnimationBulgeBouncerAlternateEnabled()
        refreshCheckBoxAnimationBulgeBouncerEllipseEnabled()
        refreshCheckBoxAnimationBulgeBouncerReverseEnabled()
        refreshCheckBoxAnimationBulgeBouncerBounceEnabled()
        refreshCheckBoxAnimationTwisterReverseEnabled()
        refreshCheckBoxAnimationTwisterEllipseEnabled()
        refreshCheckBoxAnimationTwisterAlternateEnabled()
        refreshCheckBoxAnimationTwisterInflateEnabled()
        refreshCheckBoxAnimationRandomReverseEnabled()
        refreshCheckBoxAnimationRandomEllipseEnabled()
        refreshCheckBoxAnimationRandomHorizontalEnabled()
        refreshCheckBoxAnimationRandomInflateEnabled()
        refreshCheckBoxAnimationRandomTwistEnabled()
        refreshCheckBoxAnimationRandomAlternateEnabled()
        
        refreshButtonRedo()
        refreshButtonUndo()
        refreshButtonDeleteBlob()
        refreshButtonCloneBlob()
        refreshButtonAddPoint()
        refreshButtonDeletePoint()
        refreshButtonPreviousPoint()
        refreshButtonNextPoint()
        refreshButtonFreeze()
        refreshButtonResetZoom()
        refreshButtonUnfreezeAll()
        refreshButtonSendForward()
        refreshButtonSendFront()
        refreshButtonSendBackward()
        refreshButtonSendBack()
        refreshButtonResetDefaultBulgeBouncer()
        refreshButtonResetDefaultRandom()
        refreshButtonResetDefaultTwister()
        refreshButtonExportCancel()
        refreshButtonExportDone()
        refreshButtonTimelinePlay()
        refreshButtonFlipH()
        refreshButtonFlipV()
        refreshButtonNextBlob()
        refreshButtonPrevBlob()
        refreshButtonPurchase()
        
        refreshSliderZoomScale()
        refreshSliderBulgeCenterFactor()
        refreshSliderBulgeEdgeFactor()
        refreshSliderAnimationPower()
        refreshSliderAnimationSpeed()
        refreshSliderBulgeCenterFactor()
        refreshSliderBulgeEdgeFactor()
        refreshSliderBulgeBouncerPower()
        refreshSliderBulgeBouncerSpeed()
        refreshSliderBulgeBouncerEllipseFactor()
        refreshSliderBulgeBouncerInflationFactor()
        refreshSliderBulgeBouncerInflationStartFactor()
        refreshSliderBulgeBouncerBounceFactor()
        refreshSliderTwisterSpeed()
        refreshSliderTwisterPower()
        refreshSliderTwisterInflationFactor1()
        refreshSliderTwisterInflationFactor2()
        refreshSliderRandomSpeed()
        refreshSliderRandomPower()
        refreshSliderRandomTwistFactor()
        refreshSliderRandomRandomnessFactor()
        refreshSliderRandomInflationFactor1()
        refreshSliderRandomInflationFactor2()
        
        refreshButtonRecord()
        
        refreshTimeline()
        
        refreshExportInfo()
    }
    
    private func refreshButtonEnableIfBlobIsSelected(item: ToolItem) {
        if let button = buttons[item.rawValue], let engine = ApplicationController.shared.engine {
            if engine.selectedBlob !== nil {
                button.isEnabled = true
            } else {
                button.isEnabled = false
            }
        }
    }
    
    func refreshButtonDeleteBlob() {
        if let button = buttonsMedium168[ToolItem.delete_blob.rawValue], let engine = ApplicationController.shared.engine {
            if engine.selectedBlob !== nil {
                button.isEnabled = true
            } else {
                button.isEnabled = false
            }
        }
    }
    
    func refreshButtonCloneBlob() {
        if let button = buttonsMedium168[ToolItem.clone_blob.rawValue], let engine = ApplicationController.shared.engine {
            if engine.selectedBlob !== nil {
                button.isEnabled = true
            } else {
                button.isEnabled = false
            }
        }
    }
    
    func refreshButtonResetZoom() {
        if let button = buttonsMedium168[ToolItem.reset_zoom.rawValue], let bounce = ApplicationController.shared.bounce, let engine = ApplicationController.shared.engine {
            
            if engine.zoomEnabled == true && (bounce.isAnyGestureRecognizerActive) {
                button.isEnabled = true
            } else {
                
                var dx: CGFloat = bounce.screenTranslation.x
                if dx < 0.0 { dx = -dx }
                
                var dy: CGFloat = bounce.screenTranslation.y
                if dy < 0.0 { dy = -dy }
                
                var ds: CGFloat = 1.0 - bounce.screenScale
                if ds < 0.0 { ds = -ds }
                
                if dx < Math.epsilon && dy < Math.epsilon && ds < Math.epsilon {
                    button.isEnabled = false
                } else {
                    button.isEnabled = true
                }
            }
        }
    }
    
    func refreshButtonPreviousPoint() {
        refreshButtonEnableIfBlobIsSelected(item: ToolItem.prev_point)
    }
    
    func refreshButtonNextPoint() {
        refreshButtonEnableIfBlobIsSelected(item: ToolItem.next_point)
    }
    
    func refreshButtonUndo() {
        if let button = buttons[ToolItem.undo.rawValue], let engine = ApplicationController.shared.engine {
            if engine.canUndo() {
                button.isEnabled = true
            } else {
                button.isEnabled = false
            }
        }
    }
    
    func refreshButtonRedo() {
        if let button = buttons[ToolItem.redo.rawValue], let engine = ApplicationController.shared.engine {
            if engine.canRedo() {
                button.isEnabled = true
            } else {
                button.isEnabled = false
            }
        }
    }
    
    func refreshButtonFreeze() {
        if let button = buttons[ToolItem.freeze.rawValue], let engine = ApplicationController.shared.engine {
            if engine.selectedBlob !== nil {
                if engine.selectedBlob!.frozen {
                    button.isEnabled = false
                } else {
                    button.isEnabled = true
                }
            } else {
                button.isEnabled = false
            }
        }
    }
    
    func refreshButtonAddPoint() {
        if let button = buttons[ToolItem.add_point.rawValue], let engine = ApplicationController.shared.engine {
            if let blob = engine.selectedBlob {
                if blob.spline.controlPointCount < ApplicationController.shared.maxPointCount {
                    button.isEnabled = true
                } else {
                    button.isEnabled = false
                }
            } else {
                button.isEnabled = false
            }
        }
    }
    
    func refreshButtonDeletePoint() {
        if let button = buttons[ToolItem.delete_point.rawValue], let engine = ApplicationController.shared.engine {
            if let blob = engine.selectedBlob {
                if blob.spline.controlPointCount > ApplicationController.shared.minPointCount {
                    button.isEnabled = true
                } else {
                    button.isEnabled = false
                }
            } else {
                button.isEnabled = false
            }
        }
    }
    
    func refreshButtonExportCancel() {
        if let button = buttonsWide[ToolItem.export_cancel.rawValue], let bounce = ApplicationController.shared.bounce {
            if bounce.isExporting {
                button.isHidden = false
            } else {
                button.isHidden = true
            }
        }
    }
    
    func refreshButtonExportDone() {
        if let button = buttonsWide[ToolItem.export_done.rawValue], let bounce = ApplicationController.shared.bounce {
            if bounce.isExporting {
                button.isHidden = true
            } else {
                button.isHidden = false
            }
        }
    }
    
    func refreshButtonTimelinePlay() {
        if let button = buttons[ToolItem.timeline_play.rawValue], let bounce = ApplicationController.shared.bounce {
            if bounce.timelinePlaying {
                button.setImages(path: "tb_btn_pause", pathSelected: "tb_btn_pause_down")
            } else {
                button.setImages(path: "tb_btn_resume", pathSelected: "tb_btn_resume_down")
            }
            button.isHidden = bounce.isExporting
        }
    }
    
    
    
    
    func refreshButtonUnfreezeAll() {
        if let button = buttons[ToolItem.unfreeze.rawValue], let engine = ApplicationController.shared.engine {
            button.isEnabled = engine.isAnyBlobFrozen
        }
    }
    
    func refreshButtonSendForward() {
        if let button = buttonsMedium192[ToolItem.send_forward.rawValue], let engine = ApplicationController.shared.engine {
            button.isEnabled = engine.canSendForward()
        }
    }
    
    func refreshButtonSendBackward() {
        if let button = buttonsMedium192[ToolItem.send_backward.rawValue], let engine = ApplicationController.shared.engine {
            button.isEnabled = engine.canSendBackward()
            
        }
    }
    
    func refreshButtonSendFront() {
        if let button = buttonsMedium216[ToolItem.send_front.rawValue], let engine = ApplicationController.shared.engine {
            button.isEnabled = engine.canSendFront()
        }
    }
    
    func refreshButtonSendBack() {
        if let button = buttonsMedium216[ToolItem.send_back.rawValue], let engine = ApplicationController.shared.engine {
            button.isEnabled = engine.canSendBack()
        }
    }
    
    func refreshButtonFlipV() {
        if let button = buttons[ToolItem.flip_v.rawValue], let engine = ApplicationController.shared.engine {
            if engine.selectedBlob !== nil {
                button.isEnabled = true
            } else {
                button.isEnabled = false
            }
        }
    }
    
    func refreshButtonFlipH() {
        if let button = buttons[ToolItem.flip_h.rawValue], let engine = ApplicationController.shared.engine {
            if engine.selectedBlob !== nil {
                button.isEnabled = true
            } else {
                button.isEnabled = false
            }
        }
    }
    
    func shouldEnableNextOrPreviousBlobButton() -> Bool {
        if let engine = ApplicationController.shared.engine {
            let selected: Bool = (engine.selectedBlob !== nil)
            if engine.blobs.count <= 0 {
                return false
            } else if engine.blobs.count == 1 {
                return !selected
            } else {
                return true
            }
        }
        return false
    }
    
    func refreshButtonNextBlob() {
        if let button = buttons[ToolItem.next_blob.rawValue] {
            button.isEnabled = shouldEnableNextOrPreviousBlobButton()
        }
    }
    
    func refreshButtonPrevBlob() {
        if let button = buttons[ToolItem.prev_blob.rawValue] {
            button.isEnabled = shouldEnableNextOrPreviousBlobButton()
        }
    }
    
    func refreshButtonResetDefaultBulgeBouncer() {
        if let button = buttonsWide[ToolItem.reset_default_bb.rawValue], let engine = ApplicationController.shared.engine {
            if engine.isAnimationBulgeBouncerAtDefaultValues {
                button.isEnabled = false
            } else {
                button.isEnabled = true
            }
        }
    }
    
    func refreshButtonResetDefaultTwister() {
        if let button = buttonsWide[ToolItem.reset_default_twister.rawValue], let engine = ApplicationController.shared.engine {
            if engine.isAnimationTwisterAtDefaultValues {
                button.isEnabled = false
            } else {
                button.isEnabled = true
            }
        }
    }
    
    func refreshButtonResetDefaultRandom() {
        if let button = buttonsWide[ToolItem.reset_default_random.rawValue], let engine = ApplicationController.shared.engine {
            if engine.isAnimationRandomAtDefaultValues {
                button.isEnabled = false
            } else {
                button.isEnabled = true
            }
        }
    }
    
    func refreshButtonPurchase() {
        if let button = buttonsWide[ToolItem.purchase.rawValue] {
            if PurchaseManager.shared.isPaidSubscriptionActive {
                 button.isHidden = true
            } else {
                button.isHidden = false
            }
        }
    }
    
    func refreshSegmentSceneMode() {
        if let segment = segments[ToolItem.scene_mode.rawValue], let engine = ApplicationController.shared.engine {
            if engine.sceneMode == .edit {
                segment.selectedIndex = 0
            } else {
                segment.selectedIndex = 1
            }
        }
    }
    
    func refreshSegmentEditMode() {
        if let segment = segments[ToolItem.edit_mode.rawValue], let engine = ApplicationController.shared.engine {
            if PurchaseManager.isSubscribed {
                segment.unlockSegment(index: 1)
                segment.unlockSegment(index: 2)
            } else {
                segment.lockSegment(index: 1)
                segment.lockSegment(index: 2)
            }
            
            if engine.editMode == .affine {
                segment.selectedIndex = 0
            } else if engine.editMode == .shape {
                segment.selectedIndex = 1
            } else {
                segment.selectedIndex = 2
            }
        }
    }
    
    func refreshSegmentAnimationMode() {
        if let segment = segments[ToolItem.animation_mode.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationMode == .bounce {
                segment.selectedIndex = 0
            } else if engine.animationMode == .twist {
                segment.selectedIndex = 1
            } else {
                segment.selectedIndex = 2
            }
        }
    }
    
    func refreshCheckBoxZoom() {
        if let checkBox = checkBoxes[ToolItem.zoom.rawValue], let engine = ApplicationController.shared.engine {
            if engine.zoomEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxGyro() {
        if let checkBox = checkBoxes[ToolItem.gyro.rawValue], let engine = ApplicationController.shared.engine {
            if engine.gyro {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxStereoscopic() {
        if let checkBox = checkBoxes[ToolItem.stereoscopic.rawValue], let engine = ApplicationController.shared.engine {
            if engine._stereoscopic {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxShowMarkers() {
        if let checkBox = checkBoxes[ToolItem.show_markers.rawValue], let engine = ApplicationController.shared.engine {
            if engine.isShowingMarkers {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxExportAudio() {
        if let checkBox = checkBoxes[ToolItem.export_audio.rawValue] {
            checkBox.checked = Config.shared.exportAudio
        }
    }
    
    
    
    //Config.shared.exportAudio = checkBox.checked
    
    func refreshCheckBoxAnimationEnabled() {
        if let checkBox = checkBoxes[ToolItem.animation.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationBulgeBouncerBounceEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_bb_bounce_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationBulgeBouncerBounceEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationBulgeBouncerReverseEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_bb_reverse_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationBulgeBouncerReverseEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationBulgeBouncerEllipseEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_bb_ellipse_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationBulgeBouncerEllipseEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationBulgeBouncerAlternateEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_bb_alternate_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.isAlternateAvailable {
                checkBox.isEnabled = true
                if engine.animationBulgeBouncerAlternateEnabled {
                    checkBox.checked = true
                } else {
                    checkBox.checked = false
                }
            } else {
                checkBox.isEnabled = false
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationBulgeBouncerTwistEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_bb_twist_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationBulgeBouncerTwistEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    
    func refreshCheckBoxAnimationBulgeBouncerInflateEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_bb_inflate_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationBulgeBouncerInflateEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationBulgeBouncerHorizontalEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_bb_horizontal_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationBulgeBouncerHorizontalEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationTwisterReverseEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_tw_reverse_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationTwisterReverseEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationTwisterEllipseEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_tw_ellipse_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationTwisterEllipseEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationTwisterAlternateEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_tw_alternate_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.isAlternateAvailable {
                checkBox.isEnabled = true
                if engine.animationTwisterAlternateEnabled {
                    checkBox.checked = true
                } else {
                    checkBox.checked = false
                }
            } else {
                checkBox.isEnabled = false
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationTwisterInflateEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_tw_inflate_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationTwisterInflateEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationRandomReverseEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_rd_reverse_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationRandomReverseEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationRandomEllipseEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_rd_ellipse_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationRandomEllipseEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationRandomAlternateEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_rd_alternate_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.isAlternateAvailable {
                checkBox.isEnabled = true
                if engine.animationRandomAlternateEnabled {
                    checkBox.checked = true
                } else {
                    checkBox.checked = false
                }
            } else {
                checkBox.isEnabled = false
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationRandomTwistEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_rd_twist_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationRandomTwistEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationRandomInflateEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_rd_inflate_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationRandomInflateEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshCheckBoxAnimationRandomHorizontalEnabled() {
        if let checkBox = checkBoxes[ToolItem.a_rd_horizontal_enabled.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationRandomHorizontalEnabled {
                checkBox.checked = true
            } else {
                checkBox.checked = false
            }
        }
    }
    
    func refreshSliderZoomScale() {
        if let slider = sliders[ToolItem.zoom_scale.rawValue], let bounce = ApplicationController.shared.bounce {
            slider.value = bounce.screenScale
            refreshSliderZoomScaleText()
        }
    }
    
    func refreshSliderZoomScaleText() {
        if let slider = sliders[ToolItem.zoom_scale.rawValue], let bounce = ApplicationController.shared.bounce {
            let percentInt = Int(Float(bounce.screenScale * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderBulgeEdgeFactor() {
        if let slider = sliders[ToolItem.bulge_edge_factor.rawValue] {
            if let blob = ApplicationController.shared.selectedBlob {
                slider.isEnabled = true
                slider.value = blob.bulgeEdgeFactor
                refreshSliderBulgeEdgeFactorText()
            } else {
                slider.isEnabled = false
            }
        }
    }
    
    func refreshSliderBulgeEdgeFactorText() {
        if let slider = sliders[ToolItem.bulge_edge_factor.rawValue], let blob = ApplicationController.shared.selectedBlob {
            let percentInt = Int(Float(blob.bulgeEdgeFactor * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderBulgeCenterFactor() {
        if let slider = sliders[ToolItem.bulge_center_factor.rawValue] {
            if let blob = ApplicationController.shared.selectedBlob {
                slider.isEnabled = true
                slider.value = blob.bulgeCenterFactor
                refreshSliderBulgeCenterFactorText()
            } else {
                slider.isEnabled = false
            }
        }
    }
    
    func refreshSliderBulgeCenterFactorText() {
        if let slider = sliders[ToolItem.bulge_center_factor.rawValue], let blob = ApplicationController.shared.selectedBlob {
            let percentInt = Int(Float(blob.bulgeCenterFactor * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshButtonRecord() {
        if let button = buttonRecord {
            guard let bounce = ApplicationController.shared.bounce else { return }
            if bounce.isRecording {
                button.mode = .on
            } else {
                
                if bounce.timelineEnabled {
                    button.mode = .complete
                } else {
                    button.mode = .off
                }
                
                
            }
        }
    }
    
    func refreshTimeline() {
        if let tl = timeline {
            tl.didLayout = false
            tl.layoutElements()
        }
    }
    
    func refreshSliderAnimationPower() {
        if let slider = sliders[ToolItem.animation_power.rawValue], let engine = ApplicationController.shared.engine {
            slider.value = engine.animationPower
            refreshSliderAnimationPowerText()
        }
    }
    
    func refreshSliderAnimationPowerText() {
        if let slider = sliders[ToolItem.animation_power.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationPower * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderAnimationSpeed() {
        if let slider = sliders[ToolItem.animation_speed.rawValue], let engine = ApplicationController.shared.engine {
            slider.value = engine.animationSpeed
            refreshSliderAnimationSpeedText()
        }
    }
    
    func refreshSliderAnimationSpeedText() {
        if let slider = sliders[ToolItem.animation_speed.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationSpeed * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
            slider.value = engine.animationSpeed
        }
    }
    
    func refreshSliderBulgeBouncerPower() {
        if let slider = sliders[ToolItem.a_bb_power.rawValue], let engine = ApplicationController.shared.engine {
            slider.value = engine.animationBulgeBouncerPower
            refreshSliderBulgeBouncerPowerText()
        }
    }
    
    func refreshSliderBulgeBouncerPowerText() {
        if let slider = sliders[ToolItem.a_bb_power.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationBulgeBouncerPower * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderBulgeBouncerSpeed() {
        if let slider = sliders[ToolItem.a_bb_speed.rawValue], let engine = ApplicationController.shared.engine {
            slider.value = engine.animationBulgeBouncerSpeed
            refreshSliderBulgeBouncerSpeedText()
        }
    }
    
    func refreshSliderBulgeBouncerSpeedText() {
        if let slider = sliders[ToolItem.a_bb_speed.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationBulgeBouncerSpeed * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderBulgeBouncerBounceFactor() {
        if let slider = sliders[ToolItem.a_bb_bounce_factor.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationBulgeBouncerBounceEnabled {
                slider.isEnabled = true
            } else {
                slider.isEnabled = false
            }
            slider.value = engine.animationBulgeBouncerBounceFactor
            refreshSliderBulgeBouncerBounceFactorText()
        }
    }
    
    func refreshSliderBulgeBouncerBounceFactorText() {
        if let slider = sliders[ToolItem.a_bb_bounce_factor.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationBulgeBouncerBounceFactor * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderBulgeBouncerInflationStartFactor() {
        if let slider = sliders[ToolItem.a_bb_inflation_start_factor.rawValue], let engine = ApplicationController.shared.engine {
            
            if engine.animationBulgeBouncerInflateEnabled {
                slider.isEnabled = true
            } else {
                slider.isEnabled = false
            }
            
            slider.value = engine.animationBulgeBouncerInflationStartFactor
            refreshSliderBulgeBouncerInflationStartFactorText()
        }
    }
    
    func refreshSliderBulgeBouncerInflationStartFactorText() {
        if let slider = sliders[ToolItem.a_bb_inflation_start_factor.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationBulgeBouncerInflationStartFactor * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderBulgeBouncerInflationFactor() {
        if let slider = sliders[ToolItem.a_bb_inflation_factor.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationBulgeBouncerInflateEnabled { slider.isEnabled = true } else { slider.isEnabled = false }
            slider.value = engine.animationBulgeBouncerInflationFactor
            refreshSliderBulgeBouncerInflationFactorText()
        }
    }
    
    func refreshSliderBulgeBouncerInflationFactorText() {
        if let slider = sliders[ToolItem.a_bb_inflation_factor.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationBulgeBouncerInflationFactor * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderBulgeBouncerEllipseFactor() {
        if let slider = sliders[ToolItem.a_bb_ellipse_factor.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationBulgeBouncerEllipseEnabled { slider.isEnabled = true } else { slider.isEnabled = false }
            slider.value = engine.animationBulgeBouncerEllipseFactor
            refreshSliderBulgeBouncerEllipseFactorText()
        }
    }
    
    func refreshSliderBulgeBouncerEllipseFactorText() {
        if let slider = sliders[ToolItem.a_bb_ellipse_factor.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationBulgeBouncerEllipseFactor * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderTwisterSpeed() {
        if let slider = sliders[ToolItem.a_tw_speed.rawValue], let engine = ApplicationController.shared.engine {
            slider.value = engine.animationTwisterTwistSpeed
            refreshSliderTwisterSpeedText()
        }
    }
    
    func refreshSliderTwisterSpeedText() {
        if let slider = sliders[ToolItem.a_tw_speed.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationTwisterTwistSpeed * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderTwisterPower() {
        if let slider = sliders[ToolItem.a_tw_power.rawValue], let engine = ApplicationController.shared.engine {
            slider.value = engine.animationTwisterTwistPower
            refreshSliderTwisterPowerText()
        }
    }
    
    func refreshSliderTwisterPowerText() {
        if let slider = sliders[ToolItem.a_tw_power.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationTwisterTwistPower * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderTwisterInflationFactor1() {
        if let slider = sliders[ToolItem.a_tw_inflation_factor_1.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationTwisterInflateEnabled { slider.isEnabled = true } else { slider.isEnabled = false }
            slider.value = engine.animationTwisterInflationFactor1
            refreshSliderTwisterInflationFactor1Text()
        }
    }
    
    func refreshSliderTwisterInflationFactor1Text() {
        if let slider = sliders[ToolItem.a_tw_inflation_factor_1.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationTwisterInflationFactor1 * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderTwisterInflationFactor2() {
        if let slider = sliders[ToolItem.a_tw_inflation_factor_2.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationTwisterInflateEnabled { slider.isEnabled = true } else { slider.isEnabled = false }
            slider.value = engine.animationTwisterInflationFactor2
            refreshSliderTwisterInflationFactor2Text()
        }
    }
    
    func refreshSliderTwisterInflationFactor2Text() {
        if let slider = sliders[ToolItem.a_tw_inflation_factor_2.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationTwisterInflationFactor2 * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderRandomSpeed() {
        if let slider = sliders[ToolItem.a_rd_speed.rawValue], let engine = ApplicationController.shared.engine {
            slider.value = engine.animationRandomSpeed
            refreshSliderRandomSpeedText()
        }
    }
    
    func refreshSliderRandomSpeedText() {
        if let slider = sliders[ToolItem.a_rd_speed.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationRandomSpeed * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderRandomPower() {
        if let slider = sliders[ToolItem.a_rd_power.rawValue], let engine = ApplicationController.shared.engine {
            slider.value = engine.animationRandomPower
            refreshSliderRandomPowerText()
        }
    }
    
    func refreshSliderRandomPowerText() {
        if let slider = sliders[ToolItem.a_rd_power.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationRandomPower * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderRandomTwistFactor() {
        if let slider = sliders[ToolItem.a_rd_twist_factor.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationRandomTwistEnabled { slider.isEnabled = true} else { slider.isEnabled = false }
            slider.value = engine.animationRandomTwistFactor
            refreshSliderRandomTwistFactorText()
        }
    }
    
    func refreshSliderRandomTwistFactorText() {
        if let slider = sliders[ToolItem.a_rd_twist_factor.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationRandomTwistFactor * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderRandomRandomnessFactor() {
        if let slider = sliders[ToolItem.a_rd_randomness_factor.rawValue], let engine = ApplicationController.shared.engine {
            slider.value = engine.animationRandomRandomnessFactor
            refreshSliderRandomRandomnessFactorText()
        }
    }
    
    func refreshSliderRandomRandomnessFactorText() {
        if let slider = sliders[ToolItem.a_rd_randomness_factor.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationRandomRandomnessFactor * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderRandomInflationFactor1() {
        if let slider = sliders[ToolItem.a_rd_inflation_factor_1.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationRandomInflateEnabled { slider.isEnabled = true} else { slider.isEnabled = false }
            slider.value = engine.animationRandomInflationFactor1
            refreshSliderRandomInflationFactor1Text()
        }
    }
    
    func refreshSliderRandomInflationFactor1Text() {
        if let slider = sliders[ToolItem.a_rd_inflation_factor_1.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationRandomInflationFactor1 * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshSliderRandomInflationFactor2() {
        if let slider = sliders[ToolItem.a_rd_inflation_factor_2.rawValue], let engine = ApplicationController.shared.engine {
            if engine.animationRandomInflateEnabled { slider.isEnabled = true} else { slider.isEnabled = false }
            slider.value = engine.animationRandomInflationFactor2
            refreshSliderRandomInflationFactor2Text()
        }
    }
    
    func refreshSliderRandomInflationFactor2Text() {
        if let slider = sliders[ToolItem.a_rd_inflation_factor_2.rawValue], let engine = ApplicationController.shared.engine {
            let percentInt = Int(Float(engine.animationRandomInflationFactor2 * 100.0 + 0.5))
            slider.rightText = "\(percentInt)%"
        }
    }
    
    func refreshExportInfo() {
        
        if let ei = exportInfo, let bounce = ApplicationController.shared.bounce {
            //..? Do.. ?
        }
        
    }
    
    func update() {
        buttonRecord?.update()
        exportInfo?.update()
    }
    
}















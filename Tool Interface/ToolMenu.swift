//
//  ToolMenu.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/6/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

//Tool menu is a menu that sits at either the top or bottom of the screen.
enum ToolItem:String {
    
    //rating strip
    //case rate_strip = "rate_strip"// TBRateStrip
    
    
    case rate = "rate"
    
    //micro buttons
    case anim_tools_prev = "anim_tools_prev"
    case anim_tools_next = "anim_tools_next"
    
    //regular buttons
    case menu = "menu"
    case undo = "undo"
    case redo = "redo"
    case add_blob = "add_blob"
    
    case collapse_top = "collapse_top"
    case collapse_bottom = "collapse_bottom"
    
    
    case reset_zoom = "reset_zoom"
    case prev_blob = "prev_blob"
    case next_blob = "next_blob"
    case prev_point = "prev_point"
    case next_point = "next_point"
    case add_point = "add_point"
    case delete_point = "delete_point"
    case flip_h = "flip_h"
    case flip_v = "flip_v"
    case freeze = "freeze"
    case unfreeze = "unfreeze"
    
    
    //medium buttons 168
    case delete_blob = "delete_blob"
    case clone_blob = "clone_blob"
    case export_share_email = "export_share_email"
    case export_share_facebook = "export_share_facebook"
    case export_share_twitter = "export_share_twitter"
    
    //medium buttons 216
    case send_forward = "send_forward"
    case send_backward = "send_backward"
    case send_front = "send_front"
    case send_back = "send_back"
    
    //large buttons
    case purchase = "purchase"
    case record_menu = "record_menu"

    case record = "record"
    case record_cancel = "record_cancel"
    case timeline_cancel = "timeline_cancel"
    case export_video = "export_video"
    case export_cancel = "export_cancel"
    case export_done = "export_done"
    
    //case share_facebook = "share_facebook"
    //case share_email = "share_email"
    //case share_twitter = "share_twitter"
    
    //segments
    case scene_mode = "scene_mode"
    case edit_mode = "edit_mode"
    case animation_mode = "animation_mode"
    
    
    //var bulgeBouncerSpeed: CGFloat = 0.5
    //var bulgeBouncerEllipseFactor: CGFloat = 0.5
    //var bulgeBouncerExpandFactor: CGFloat = 0.5
    
    //var bulgeBouncerBounceEnabled: Bool = true
    //var bulgeBouncerStagger: Bool = true
    
    
    
    //checkboxes
    case zoom = "zoom" /* Zoom Mode */
    case stereoscopic = "stereoscopic"
    case gyro = "gyro"
    case show_markers = "show_markers"
    case animation = "animation" /* Animation Mode */
    case inflate = "inflate" //Bake inflate into automatic animation..
    case twist = "twist" //Bake twist into automatic animation..
    case export_audio = "export_audio"
    
    case reset_default_bb = "reset_default_bb"
    case reset_default_twister = "reset_default_twister"
    case reset_default_random = "reset_default_random"
    
    //sliders...
    case zoom_scale = "zoom_scale"
    case animation_power = "animation_power"
    case animation_speed = "animation_speed"
    case bulge_edge_factor = "bulge_edge_factor"
    case bulge_center_factor = "bulge_center_factor"
    
    
    
    case a_bb_power = "a_bb_power"
    case a_bb_speed = "a_bb_speed"
    case a_bb_inflation_start_factor = "a_bb_inflation_start_factor"
    case a_bb_ellipse_factor = "a_bb_ellipse_factor"
    case a_bb_inflation_factor = "a_bb_inflation_factor"
    case a_bb_bounce_factor = "a_bb_bounce_factor"
    
    case a_bb_bounce_enabled = "a_bb_bounce_enabled"
    case a_bb_reverse_enabled = "a_bb_reverse_enabled"
    case a_bb_ellipse_enabled = "a_bb_ellipse_enabled"
    case a_bb_alternate_enabled = "a_bb_alternate_enabled"
    case a_bb_twist_enabled = "a_bb_twist_enabled"
    case a_bb_inflate_enabled = "a_bb_inflate_enabled"
    case a_bb_horizontal_enabled = "a_bb_horizontal_enabled"
    
    case a_tw_speed = "a_tw_speed"
    case a_tw_power = "a_tw_power"
    case a_tw_inflation_factor_1 = "a_tw_inflation_factor_1"
    case a_tw_inflation_factor_2 = "a_tw_inflation_factor_2"
    
    case a_tw_reverse_enabled = "a_tw_reverse_enabled"
    case a_tw_ellipse_enabled = "a_tw_ellipse_enabled"
    case a_tw_alternate_enabled = "a_tw_alternate_enabled"
    case a_tw_inflate_enabled = "a_tw_inflate_enabled"
    
    case a_rd_speed = "a_rd_speed"
    case a_rd_power = "a_rd_power"
    case a_rd_inflation_factor_1 = "a_rd_inflation_factor_1"
    case a_rd_inflation_factor_2 = "a_rd_inflation_factor_2"
    case a_rd_twist_factor = "a_rd_twist_factor"
    case a_rd_randomness_factor = "a_rd_randomness_factor"
    
    case a_rd_reverse_enabled = "a_rd_reverse_enabled"
    case a_rd_ellipse_enabled = "a_rd_ellipse_enabled"
    case a_rd_alternate_enabled = "a_rd_alternate_enabled"
    case a_rd_twist_enabled = "a_rd_twist_enabled"
    case a_rd_inflate_enabled = "a_rd_inflate_enabled"
    case a_rd_horizontal_enabled = "a_rd_horizontal_enabled"

    case timeline = "timeline"
    
    case timeline_play = "timeline_play"
    case timeline_next_frame = "timeline_next_frame"
    case timeline_prev_frame = "timeline_prev_frame"
    
    //TBExportInfo
    case export_info = "export_info"
    
    
    
}

class ToolMenu: UIView, TBSegmentDelegate, TBCheckBoxDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var shadowImageView: UIImageView?
    var isUpwardFacing: Bool = false
    
    var rows = [ToolMenuRow]()
    
    var expandedHeight: CGFloat = 0.0
    func setUp(parentFrame: CGRect, top: Bool, rowCount: Int, landscape: Bool) {
        
        clipsToBounds = false
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleSubscriptionStateChangedBT(notification:)),
                       name: NSNotification.Name(PurchaseManagerNotification.subscriptionStateChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleBlobSelectionChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.blobSelectionChanged.rawValue), object: nil)
        
        nc.addObserver(self, selector: #selector(handleBlobCountChangedBT),
                       name: NSNotification.Name(BounceNotification.blobCountChanged.rawValue), object: nil)
        
        
        nc.addObserver(self, selector: #selector(handleShowingMarkersChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.showingMarkersChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleZoomEnabledChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.zoomEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleZoomEnabledChangedForcedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.zoomEnabledChangedForced.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleZoomScaleChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.zoomScaleChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleHistoryChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.historyChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleStackOrderChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.blobStackOrderChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleSceneModeChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.sceneModeChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleEditModeChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.editModeChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationModeChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.animationModeChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationEnabledChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.animationEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleFrozenStateChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.frozenStateChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handlePointCountChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.pointCountChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAltMenuBulgeBouncerChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.altMenuBulgeBouncerChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAltMenuTwisterChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.altMenuTwisterChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAltMenuRandomChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.altMenuRandomChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleRecordEnabledChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.recordEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleTimelineEnabledChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.timelineEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handletimelineFrameChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.timelineFrameChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleTimelineHandleChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.timelineHandleChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleVideoExportCompleteBT(notification:)),
                       name: NSNotification.Name(BounceNotification.videoExportComplete.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleVideoExportBeginBT(notification:)),
                       name: NSNotification.Name(BounceNotification.videoExportBegin.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleVideoExportErrorBT(notification:)),
                       name: NSNotification.Name(BounceNotification.videoExportError.rawValue), object: nil)
        
        nc.addObserver(self, selector: #selector(handleVideoExportFrameChangedBT(notification:)),
                       name: NSNotification.Name(BounceNotification.videoExportFrameChanged.rawValue), object: nil)
    
        
        
        nc.addObserver(self, selector: #selector(handleAnimationAlternationEnabledChangedBT),
                       name: NSNotification.Name(BounceNotification.animationAlternationEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationBounceEnabledChangedBT),
                       name: NSNotification.Name(BounceNotification.animationBounceEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationReverseEnabledChangedBT),
                       name: NSNotification.Name(BounceNotification.animationReverseEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationEllipseEnabledChangedBT),
                       name: NSNotification.Name(BounceNotification.animationEllipseEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationInflateEnabledChangedBT),
                       name: NSNotification.Name(BounceNotification.animationInflateEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationHorizontalEnabledChangedBT),
                       name: NSNotification.Name(BounceNotification.animationHorizontalEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationTwistEnabledChangedBT),
                       name: NSNotification.Name(BounceNotification.animationTwistEnabledChanged.rawValue), object: nil)
        
        
        
        
        nc.addObserver(self, selector: #selector(handleTimelinePlaybackEnabledChangedBT),
                       name: NSNotification.Name(BounceNotification.timelinePlaybackEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleTimelinePlaybackRestartBT),
                       name: NSNotification.Name(BounceNotification.timelinePlaybackRestart.rawValue), object: nil)
        
        
        
        
        isTopMenu = top
        expandedHeight = 0
        
        let safeAreaTop = ApplicationController.safeAreaInsetTop
        //let safeAreaRight = ApplicationController.safeAreaInsetRight
        let safeAreaBottom = ApplicationController.safeAreaInsetBottom
        //let safeAreaLeft = ApplicationController.safeAreaInsetLeft
        
        for i in 0..<rowCount {
            let toolRow = ToolMenuRow(frame: CGRect(x: 0.0, y: expandedHeight, width: parentFrame.size.width, height: ApplicationController.shared.toolBarHeight))
            
            if isTopMenu {
                if i == 0 {
                    toolRow.frame = CGRect(x: 0.0, y: expandedHeight, width: parentFrame.size.width, height: ApplicationController.shared.toolBarHeight + safeAreaTop)
                }
            } else {
                if i == rowCount - 1 {
                    toolRow.frame = CGRect(x: 0.0, y: expandedHeight, width: parentFrame.size.width, height: ApplicationController.shared.toolBarHeight + safeAreaBottom)
                }
            }
            
            toolRow.menu = self
            rows.append(toolRow)
            
            if top {
                insertSubview(toolRow, at: 0)
            } else {
                addSubview(toolRow)
            }
            
            //expandedHeight += ApplicationController.shared.toolBarHeight
            
            expandedHeight += toolRow.frame.size.height
        }
        
        //if let bounce = ApplicationController.shared.bounce {
            
            if isTopMenu {
                frame = CGRect(x: 0.0, y: 0.0, width: parentFrame.size.width, height: expandedHeight)
            } else {
                frame = CGRect(x: 0.0, y: parentFrame.size.height - expandedHeight, width: parentFrame.size.width, height: expandedHeight)
            }
        
        //}
    }
    
    //Is the menu at the top of the screen or the bottom?
    var isTopMenu: Bool = true
    var isBottomMenu: Bool {
        return isTopMenu == false
    }
    
    var isShowing: Bool = true
    
    func showAnimated(completion:(() -> Swift.Void)?) {
    
        if isShowing == true {
            completion?()
            return 
        }
        isShowing = true
        
        isHidden = false
        
        // var translationOffset: CGFloat = bounds.size.height
        
        //if isTopMenu {
        //    translationOffset = -(bounds.size.height)
        //}
        
        UIView.animate(withDuration: 0.36, animations: {
            self.transform = CGAffineTransform.identity
            self.shadowImageView?.alpha = 1.0
        }) { (finished: Bool) in
            completion?()
        }
    }
    
    func show() {
        if isShowing == true { return }
        isShowing = true
        isHidden = false
        transform = CGAffineTransform.identity
        shadowImageView?.alpha = 1.0
    }
    
    func hideAnimated(completion:(() -> Swift.Void)?) {
        if isShowing == false {
            completion?()
            return
        }
        isShowing = false
        var translationOffset: CGFloat = bounds.size.height
        if isTopMenu { translationOffset = -(bounds.size.height) }
        UIView.animate(withDuration: 0.36, animations: {
            self.transform = CGAffineTransform(translationX: 0.0, y: translationOffset)
            self.shadowImageView?.alpha = 0.0
        }) { (finished: Bool) in
            if self.isShowing == false { self.isHidden = true }
            completion?()
        }
    }
    
    func hide() {
        if isShowing == false { return }
        isShowing = false
        
        var translationOffset: CGFloat = bounds.size.height
        if isTopMenu {
            translationOffset = -(bounds.size.height)
        }
        
        transform = CGAffineTransform(translationX: 0.0, y: translationOffset)
        shadowImageView?.alpha = 0.0
        isHidden = true
    }
    
    
    func addTopShadow() {
        var shadowHeight: CGFloat = 6.0
        if Device.isTablet { shadowHeight = 9.0 }
        
        shadowImageView = UIImageView(frame: CGRect(x: 0.0, y: -shadowHeight, width: bounds.size.width, height: shadowHeight))
        shadowImageView!.image = UIImage(named: "shadow_top")
        addSubview(shadowImageView!)
    }
    
    func addBottomShadow() {
        var shadowHeight: CGFloat = 6.0
        if Device.isTablet { shadowHeight = 9.0 }
        
        shadowImageView = UIImageView(frame: CGRect(x: 0.0, y: bounds.size.height, width: bounds.size.width, height: shadowHeight))
        shadowImageView!.image = UIImage(named: "shadow_bottom")
        addSubview(shadowImageView!)
    }
    
    func segmentSelected(segment:TBSegment, index: Int) {
        
    }
    
    func checkBoxToggled(checkBox:TBCheckBox, checked: Bool) {
        
    }
    
    @objc func handleSubscriptionStateChangedBT(notification: Notification) -> Void {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleSubscriptionStateChanged() }
            return
        }
        self.handleSubscriptionStateChanged()
    }
    
    @objc func handleZoomEnabledChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleZoomEnabledChanged() }
            return
        }
        self.handleZoomEnabledChanged()
    }
    
    @objc func handleBlobSelectionChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleBlobSelectionChanged() }
            return
        }
        self.handleBlobSelectionChanged()
    }
    
    @objc func handleBlobCountChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleBlobCountChanged() }
            return
        }
        self.handleBlobCountChanged()
    }
    
    
    
    @objc func handleShowingMarkersChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleShowingMarkersChanged() }
            return
        }
        self.handleShowingMarkersChanged()
    }
    
    
    @objc func handleZoomEnabledChangedForcedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleZoomEnabledChangedForced() }
            return
        }
        self.handleZoomEnabledChangedForced()
    }
    
    @objc func handleZoomScaleChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleZoomScaleChanged() }
            return
        }
        self.handleZoomScaleChanged()
    }
    
    @objc func handleHistoryChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleHistoryChanged() }
            return
        }
        self.handleHistoryChanged()
    }
    
    @objc func handleStackOrderChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleStackOrderChanged() }
            return
        }
        self.handleStackOrderChanged()
    }
    
    
    @objc func handleSceneModeChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleSceneModeChanged() }
            return
        }
        self.handleSceneModeChanged()
    }
    
    @objc func handleEditModeChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleEditModeChanged() }
            return
        }
        self.handleEditModeChanged()
    }
    
    @objc func handleAnimationModeChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAnimationModeChanged() }
            return
        }
        self.handleAnimationModeChanged()
    }
    
    @objc func handleAnimationEnabledChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAnimationEnabledChanged() }
            return
        }
        self.handleAnimationEnabledChanged()
    }
    
    @objc func handleFrozenStateChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleFrozenStateChanged() }
            return
        }
        self.handleFrozenStateChanged()
    }
    
    @objc func handlePointCountChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handlePointCountChanged() }
            return
        }
        self.handlePointCountChanged()
    }
    
    @objc func handleAltMenuBulgeBouncerChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAltMenuBulgeBouncerChanged() }
            return
        }
        self.handleAltMenuBulgeBouncerChanged()
    }
    
    @objc func handleAltMenuTwisterChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAltMenuTwisterChanged() }
            return
        }
        self.handleAltMenuTwisterChanged()
    }
    
    @objc func handleAltMenuRandomChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAltMenuRandomChanged() }
            return
        }
        self.handleAltMenuRandomChanged()
    }
    
    @objc func handleRecordEnabledChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleRecordEnabledChanged() }
            return
        }
        self.handleRecordEnabledChanged()
    }
    
    @objc func handleTimelineEnabledChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleTimelineEnabledChanged() }
            return
        }
        self.handleTimelineEnabledChanged()
    }
    
    @objc func handletimelineFrameChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handletimelineFrameChanged() }
            return
        }
        self.handletimelineFrameChanged()
    }
    
    @objc func handleTimelineHandleChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleTimelineHandleChanged() }
            return
        }
        self.handleTimelineHandleChanged()
    }
    
    @objc func handleVideoExportFrameChangedBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleVideoExportFrameChanged() }
            return
        }
        self.handleVideoExportFrameChanged()
    } 
    
    @objc func handleVideoExportBeginBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleVideoExportBegin() }
            return
        }
        self.handleVideoExportBegin()
    }
    
    
    @objc func handleVideoExportErrorBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleVideoExportError() }
            return
        }
        self.handleVideoExportError()
    }
    
    
    
    
    @objc func handleVideoExportCompleteBT(notification: Notification) {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleVideoExportComplete() }
            return
        }
        self.handleVideoExportComplete()
    }
    
    
    //
    @objc func handleAnimationAlternationEnabledChangedBT() {
        
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAnimationAlternationEnabledChanged() }
            return
        }
        self.handleAnimationAlternationEnabledChanged()
        
    }
    
    @objc func handleAnimationBounceEnabledChangedBT() {
        
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAnimationBounceEnabledChanged() }
            return
        }
        self.handleAnimationBounceEnabledChanged()
        
    }
    
    @objc func handleAnimationReverseEnabledChangedBT() {
        
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAnimationReverseEnabledChanged() }
            return
        }
        self.handleAnimationReverseEnabledChanged()
        
    }
    
    @objc func handleAnimationTwistEnabledChangedBT() {
        
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAnimationTwistEnabledChanged() }
            return
        }
        self.handleAnimationTwistEnabledChanged()
        
    }
    
    @objc func handleAnimationEllipseEnabledChangedBT() {
        
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAnimationEllipseEnabledChanged() }
            return
        }
        self.handleAnimationEllipseEnabledChanged()
        
    }
    
    @objc func handleAnimationInflateEnabledChangedBT() {
        
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAnimationInflateEnabledChanged() }
            return
        }
        //self.
        handleAnimationInflateEnabledChanged()
    }
    
    @objc func handleAnimationHorizontalEnabledChangedBT() {
        
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleAnimationHorizontalEnabledChanged() }
            return
        }
        //self.
        handleAnimationHorizontalEnabledChanged()
    }
    
    
    
    @objc func handleTimelinePlaybackEnabledChangedBT() {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleTimelinePlaybackEnabledChanged() }
            return
        }
        handleTimelinePlaybackEnabledChanged()
    }
    
    
    @objc func handleTimelinePlaybackRestartBT() {
        if Thread.isMainThread == false {
            DispatchQueue.main.sync { self.handleTimelinePlaybackRestart() }
            return
        }
        handleTimelinePlaybackRestart()
    }
    
    
    
    func handleSubscriptionStateChanged() -> Void {
        for row in rows {
            row.handleSubscriptionStateChanged()
        }
    }
    
    func handleZoomEnabledChanged() {
        for row in rows {
            row.handleZoomEnabledChanged()
        }
    }
    
    func handleBlobSelectionChanged() {
        for row in rows {
            row.handleBlobSelectionChanged()
        }
    }
    
    func handleBlobCountChanged() {
        for row in rows {
            row.handleBlobCountChanged()
        }
    }    
    
    func handleShowingMarkersChanged() {
        for row in rows {
            row.handleShowingMarkersChanged()
        }
    }
    
    func handleZoomEnabledChangedForced() {
        for row in rows {
            row.handleZoomEnabledChangedForced()
        }
    }
    
    func handleZoomScaleChanged() {
        for row in rows {
            row.handleZoomScaleChanged()
        }
    }
    
    func handleHistoryChanged() {
        for row in rows {
            row.handleHistoryChanged()
        }
    }
    
    func handleStackOrderChanged() {
        for row in rows {
            row.handleStackOrderChanged()
        }
    }
    
    func handleSceneModeChanged() {
        for row in rows {
            row.handleSceneModeChanged()
        }
    }
    
    func handleEditModeChanged() {
        for row in rows {
            row.handleEditModeChanged()
        }
    }
    
    func handleAnimationModeChanged() {
        for row in rows {
            row.handleAnimationModeChanged()
        }
    }
    
    func handleAnimationEnabledChanged() {
        for row in rows {
            row.handleAnimationEnabledChanged()
        }
    }
    
    
    
    func handleAnimationAlternationEnabledChanged() {
        for row in rows {
            row.handleAnimationAlternationEnabledChanged()
        }
    }
    
    func handleAnimationBounceEnabledChanged() {
        for row in rows {
            row.handleAnimationBounceEnabledChanged()
        }
    }
    
    func handleAnimationReverseEnabledChanged() {
        for row in rows {
            row.handleAnimationReverseEnabledChanged()
        }
    }
    
    func handleAnimationTwistEnabledChanged() {
        for row in rows {
            row.handleAnimationTwistEnabledChanged()
        }
    }
    
    func handleAnimationEllipseEnabledChanged() {
        for row in rows {
            row.handleAnimationEllipseEnabledChanged()
        }
    }
    
    func handleAnimationInflateEnabledChanged() {
        for row in rows {
            row.handleAnimationInflateEnabledChanged()
        }
    }
    
    func handleAnimationHorizontalEnabledChanged() {
        for row in rows { row.handleAnimationHorizontalEnabledChanged() }
    }
    
    
    
    func handleFrozenStateChanged() {
        for row in rows {
            row.handleFrozenStateChanged()
        }
    }
    
    func handlePointCountChanged() {
        for row in rows {
            row.handlePointCountChanged()
        }
    }
    
    func handleAltMenuBulgeBouncerChanged() {
        for row in rows {
            row.handleAltMenuBulgeBouncerChanged()
        }
    }
    
    func handleAltMenuTwisterChanged() {
        for row in rows {
            row.handleAltMenuTwisterChanged()
        }
    }
    
    func handleAltMenuRandomChanged() {
        for row in rows {
            row.handleAltMenuRandomChanged()
        }
    }
    
    func handleRecordEnabledChanged() -> Void {
        for row in rows {
            row.handleRecordEnabledChanged()
        }
    }
    
    func handleTimelineEnabledChanged() -> Void {
        for row in rows {
            row.handleTimelineEnabledChanged()
        }
    }
    
    func handletimelineFrameChanged() -> Void {
        for row in rows {
            row.handletimelineFrameChanged()
        }
    }
    
    func handleTimelineHandleChanged() -> Void {
        for row in rows {
            row.handleTimelineHandleChanged()
        }
    }
    
    func handleVideoExportFrameChanged() {
        for row in rows {
            row.handleVideoExportFrameChanged()
        }
    }
    
    func handleVideoExportBegin() {
        for row in rows {
            row.handleVideoExportBegin()
        }
    }
    
    func handleVideoExportComplete() {
        for row in rows {
            row.handleVideoExportComplete()
        }
    }
    
    func handleVideoExportError() {
        for row in rows {
            row.handleVideoExportError()
        }
    }
    
    
    
    
    
    
    func handleTimelinePlaybackEnabledChanged() {
        for row in rows {
            row.handleTimelinePlaybackEnabledChanged()
        }
    }
    
    
    func handleTimelinePlaybackRestart() {
        for row in rows {
            row.handleTimelinePlaybackRestart()
        }
    }
    
    func update() {
        for i: Int in 0..<rows.count {
            rows[i].update()
        }
    }
    
}

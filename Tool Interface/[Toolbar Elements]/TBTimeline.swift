//
//  TBTimeline.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/28/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

//Direction: 

// Rule 1: The thumb is always at its exact 1:1 position mapping
// percent along recording slices to percent along UI component (exactly)

// Rule 2: The  minumum space between the handles is always
// (thumb width) + (width of mimumum frame count

// Rule 3: The handles will have their individual min and max positions
// pre-computed. These will factor in the size of the thumb, and the size
// of the minimum frame gap (translated to UI size).

import UIKit

class TBTimeline: UIView {
    
    var itemTag: String = ""
    
    var maxHeight: CGFloat?
    
    var didLayout: Bool = false
    var layoutWidth: CGFloat = 0.0
    
    weak var dragTouch: UITouch?
    
    var dragTouchStartX: CGFloat = 0.0
    var dragTouchStartY: CGFloat = 0.0
    
    var dragObjectStartX: CGFloat = 0.0
    var dragObjectStartY: CGFloat = 0.0
    
    var draggingLeftHandle: Bool = false
    var draggingRightHandle: Bool = false
    var draggingThumb: Bool = false
    
    var handleDragMinX: CGFloat = 0.0
    var handleDragMaxX: CGFloat = 0.0
    
    var recentlySelectedHandleLeft: Bool = true
    
    var thumb: TBTimelineThumb!
    
    var handleLeft: TBTimelineHandle!
    var handleRight: TBTimelineHandle!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    private func setUp() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.autoresizesSubviews = false
        self.clearsContextBeforeDrawing = true
        self.isOpaque = false
    }
    
    //Theoretically there's no telling how many times this may be called...
    internal override func layoutSubviews() {
        super.layoutSubviews()
        cancelTouches()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dragTouch !== nil { return }
        guard let bounce = ApplicationController.shared.bounce else { return }
        for  touch:UITouch in touches {
            if touch.phase == .began {
                if dragTouch !== nil { return }
                let location = touch.location(in: self)
                if location.x >= handleLeft.frame.minX && location.x <= handleLeft.frame.maxX {
                    draggingLeftHandle = true
                    dragTouch = touch
                    dragObjectStartX = handleLeft.frame.minX
                    dragObjectStartY = handleLeft.frame.minY
                    recentlySelectedHandleLeft = true
                    beginDraggingLeftHandle()
                    bounce.timelineStartDraggingLeftHandle()
                    handleLeft.isSelected = true
                } else if location.x >= handleRight.frame.minX && location.x <= handleRight.frame.maxX {
                    draggingRightHandle = true
                    dragTouch = touch
                    dragObjectStartX = handleRight.frame.minX
                    dragObjectStartY = handleRight.frame.minY
                    recentlySelectedHandleLeft = false
                    beginDraggingRightHandle()
                    bounce.timelineStartDraggingRightHandle()
                    handleRight.isSelected = true
                } else if location.x >= thumb.frame.minX && location.x <= thumb.frame.maxX {
                    draggingThumb = true
                    dragTouch = touch
                    dragObjectStartX = thumb.frame.minX
                    dragObjectStartY = thumb.frame.minY
                    bounce.timelineStartDraggingThumb()
                    thumb.isSelected = true
                }
                
                if draggingLeftHandle || draggingRightHandle || draggingThumb {
                    dragTouchStartX = location.x
                    dragTouchStartY = location.y
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if draggingLeftHandle || draggingRightHandle || draggingThumb {
            guard let bounce = ApplicationController.shared.bounce else { return }
            let height = bounds.height
            
            for touch:UITouch in touches {
                if touch.phase == .moved && dragTouch == touch {
                    let location = touch.location(in: self)
                    let dx: CGFloat = location.x - dragTouchStartX
                    
                    if draggingLeftHandle {
                        var targetX: CGFloat = dragObjectStartX + dx
                        if targetX < handleDragMinX { targetX = handleDragMinX }
                        if targetX > handleDragMaxX { targetX = handleDragMaxX }
                        handleLeft.frame = CGRect(x: targetX, y: 0.0, width: TBTimeline.handleWidth, height: height)
                        let handlePercent = (targetX - getActiveHandleLeft()) / getActiveHandleSpan()
                        bounce.timelinePlaceLeftHandle(handlePercent)
                        placeThumb()
                    }
                    
                    if draggingRightHandle {
                        var targetX: CGFloat = dragObjectStartX + dx
                        if targetX < handleDragMinX { targetX = handleDragMinX }
                        if targetX > handleDragMaxX { targetX = handleDragMaxX }
                        handleRight.frame = CGRect(x: targetX, y: 0.0, width: TBTimeline.handleWidth, height: height)
                        let handlePercent = (targetX - getActiveHandleLeft()) / getActiveHandleSpan()
                        bounce.timelinePlaceRightHandle(handlePercent)
                        placeThumb()
                    }
                    
                    if draggingThumb {
                        var targetX: CGFloat = dragObjectStartX + dx
                        if targetX < handleLeft.frame.maxX {
                            targetX = handleLeft.frame.maxX
                        }
                        if targetX > (handleRight.frame.minX - TBTimeline.thumbWidth) {
                            targetX = (handleRight.frame.minX - TBTimeline.thumbWidth)
                        }
                        thumb.frame = CGRect(x: targetX, y: 0.0, width: TBTimeline.thumbWidth, height: height)
                        let thumbPercent = (targetX - getActiveThumbLeft()) / (getActiveThumbSpan())
                        bounce.timelinePlaceTicker(thumbPercent)
                        setNeedsDisplay()
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelTouches()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelTouches()
    }
    
    func cancelTouches() {
        guard let bounce = ApplicationController.shared.bounce else { return }
        draggingLeftHandle = false
        draggingRightHandle = false
        draggingThumb = false
        handleLeft.isSelected = false
        handleRight.isSelected = false
        thumb.isSelected = false
        bounce.timelineStopDraggingThumb()
        bounce.timelineStopDraggingHandle()
    }
    
    func beginDraggingLeftHandle() {
        guard let bounce = ApplicationController.shared.bounce else { return }
        handleDragMinX = getActiveHandleLeft()
        let max1 = handleRight.frame.minX - (TBTimeline.thumbWidth + TBTimeline.handleWidth + 24)
        let max2Percent =  bounce.getTimelineRightHandlePercent() - bounce.getTimelineMinTimelineFrameSpanPercent()
        let max2: CGFloat = getActiveHandleLeft() + max2Percent * getActiveHandleSpan()
        if max2 < max1 {
            handleDragMaxX = max2
        } else {
            handleDragMaxX = max1
        }
    }
    
    func beginDraggingRightHandle() {
        guard let bounce = ApplicationController.shared.bounce else { return }
        handleDragMaxX = getActiveHandleLeft() + getActiveHandleSpan()
        let min1 = handleLeft.frame.maxX + (TBTimeline.thumbWidth + 24)
        let min2Percent =  bounce.getTimelineLeftHandlePercent() + bounce.getTimelineMinTimelineFrameSpanPercent()
        let min2: CGFloat = getActiveHandleLeft() + min2Percent * getActiveHandleSpan()
        if min2 < min1 {
            handleDragMinX = min1
        } else {
            handleDragMinX = min2
        }
    }
    
    func getActiveHandleLeft() -> CGFloat {
        return TBTimeline.paddingHorizontal
    }
    
    func getActiveHandleRight() -> CGFloat {
        let width = bounds.width
        return width - (TBTimeline.paddingHorizontal + TBTimeline.handleWidth)
    }
    
    func getActiveHandleSpan() -> CGFloat {
        return (getActiveHandleRight() - getActiveHandleLeft())
    }
    
    func getActiveThumbLeft() -> CGFloat {
        return handleLeft.frame.maxX
    }
    
    func getActiveThumbRight() -> CGFloat {
        return handleRight.frame.minX - TBTimeline.thumbWidth
    }
    
    func getActiveThumbSpan() -> CGFloat {
        return (getActiveThumbRight() - getActiveThumbLeft())
    }
    
    class var thumbWidth: CGFloat {
        if Device.isTablet {
            return 54.0
        } else {
            if Device.isSmall {
                return 36.0
            } else {
                return 40.0
            }
        }
    }
    
    class var handleWidth: CGFloat {
        if Device.isTablet {
            return 64.0
        } else {
            if Device.isSmall {
                return 42.0
            } else {
                return 46.0
            }
        }
    }
    
    class var paddingHorizontal: CGFloat {
        if Device.isTablet {
            return 92.0
        } else {
            if Device.isSmall {
                return 6.0
                //3
            } else {
                return 12.0
                //4
            }
        }
    }
    
    class var barHeight: CGFloat {
        if Device.isTablet {
            return 14.0
        } else {
            if Device.isSmall {
                return 7.0
            } else {
                return 9.0
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        let handleLeftCenterX: CGFloat = CGFloat(Int(handleLeft.frame.midX + 0.5))
        let handleRightCenterX: CGFloat = CGFloat(Int(handleRight.frame.midX + 0.5))
        let handleLeftMinX: CGFloat = CGFloat(Int(handleLeft.frame.minX + 0.5))
        let handleLeftMaxX: CGFloat = CGFloat(Int(handleLeft.frame.maxX + 0.5))
        let handleRightMinX: CGFloat = CGFloat(Int(handleRight.frame.minX + 0.5))
        let handleRightMaxX: CGFloat = CGFloat(Int(handleRight.frame.maxX + 0.5))
       
        let thumbCenterX: CGFloat = CGFloat(Int(thumb.frame.midX + 0.5))
        let thumbMinX: CGFloat = CGFloat(Int(thumb.frame.minX + 0.5))
        let thumbMaxX: CGFloat = CGFloat(Int(thumb.frame.maxX + 0.5))
       
        let wholeBarHeight: CGFloat = CGFloat(Int(bounds.size.height * 0.6))
        let wholeBarLeftX: CGFloat = CGFloat(Int(TBTimeline.paddingHorizontal - 1))
        let wholeBarRightX: CGFloat = CGFloat(Int(bounds.size.width - (TBTimeline.paddingHorizontal - 1)))
        let wholeBarWidth: CGFloat = CGFloat(Int(wholeBarRightX - wholeBarLeftX))
        let wholeBarTop: CGFloat = CGFloat(Int(bounds.size.height / 2.0 - wholeBarHeight / 2.0))
        let wholeBarRect = CGRect(x: wholeBarLeftX, y: wholeBarTop, width: wholeBarWidth, height: wholeBarHeight)
        
        let outsideLeftRect = CGRect(x: wholeBarRect.origin.x, y: wholeBarTop, width: CGFloat(Int(handleLeftCenterX - wholeBarRect.origin.x)), height: wholeBarHeight)
        let outsideRightRect = CGRect(x: handleRightCenterX, y: wholeBarTop, width: CGFloat(Int(wholeBarRect.maxX - handleRightCenterX + 0.5)), height: wholeBarHeight)
        
        context.setFillColor(UIColor(red: 0.1825, green: 0.1825, blue: 0.215, alpha: 1.0).cgColor)
        context.fill(outsideLeftRect)
        context.fill(outsideRightRect)
        
        let activeRectWidth: CGFloat = CGFloat(Int((handleRightCenterX - handleLeftCenterX) + 0.5))
        let activeRect = CGRect(x: handleLeftCenterX, y: wholeBarTop, width: activeRectWidth, height: wholeBarHeight)
        let activeRectLeftWidth: CGFloat = CGFloat(Int((thumbCenterX - activeRect.minX) + 0.5))
        let activeRectRightWidth: CGFloat = CGFloat(Int((activeRect.maxX - thumbCenterX) + 0.5))
        let activeRectLeft = CGRect(x: activeRect.minX, y: wholeBarTop, width: activeRectLeftWidth, height: wholeBarHeight)
        let activeRectRight = CGRect(x: thumbCenterX, y: wholeBarTop, width: activeRectRightWidth, height: wholeBarHeight)
        
        context.setFillColor(styleColorBlue.cgColor)
        context.fill(activeRectLeft)
        context.setFillColor(styleColorBlueLight.cgColor)
        context.fill(activeRectRight)
        
        let leftWallRect = CGRect(x: TBTimeline.paddingHorizontal - 2, y: 0.0, width: 2.0, height: bounds.size.height)
        let rightWallRect = CGRect(x: CGFloat(Int(bounds.size.width - TBTimeline.paddingHorizontal + 0.5)), y: 0.0, width: 2.0, height: bounds.size.height)
        
        
        context.setFillColor(UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.0).cgColor)
        context.fill(leftWallRect)
        context.fill(rightWallRect)
        context.restoreGState()
        drawShine(context: context, rect: wholeBarRect, startX: wholeBarRect.minX, endX: handleLeftMinX)
        drawShine(context: context, rect: wholeBarRect, startX: handleLeftMaxX, endX: thumbMinX)
        drawShine(context: context, rect: wholeBarRect, startX: thumbMaxX, endX: handleRightMinX)
        drawShine(context: context, rect: wholeBarRect, startX: handleRightMaxX, endX: wholeBarRect.maxX)
    }
    
    func drawShine(context: CGContext, rect: CGRect, startX: CGFloat, endX: CGFloat) {
        if (endX - startX) > 8.0 {
            context.saveGState()
            let shineHeight = CGFloat(4.0)
            let shineTop = CGFloat(rect.origin.y + 2.0)
            let shineLeft = CGFloat(Int(startX + 2.0))
            let shineRight = CGFloat(Int(endX - 3.0))
            let shineWidth = CGFloat(Int(shineRight - shineLeft))
            let radius = 3.0
            let shineRect = CGRect(x: shineLeft, y: shineTop, width: shineWidth, height: shineHeight)
            let clipPath = UIBezierPath(roundedRect: shineRect,
                                        byRoundingCorners: DrawableButton.getCornerType(ul: true, ur: true, dr: true, dl: true),
                                        cornerRadii: CGSize(width: radius, height: radius)).cgPath
            context.beginPath()
            context.addPath(clipPath)
            context.setFillColor(UIColor(red: 1.0, green: 1.0, blue: 0.98, alpha: 0.2626).cgColor)
            context.closePath()
            context.fillPath()
            context.restoreGState()
        }
    }
    
    func placeThumb() {
        guard let bounce = ApplicationController.shared.bounce else { return }
        let height = bounds.height
        let activeThumbLeft: CGFloat = getActiveThumbLeft()
        let activeThumbSpan: CGFloat = getActiveThumbSpan()
        let percent = bounce.getTimelineThumbPercent()
        let thumbX: CGFloat = activeThumbLeft + percent * activeThumbSpan
        thumb.frame = CGRect(x: thumbX, y: 0.0, width: TBTimeline.thumbWidth, height: height)
        setNeedsDisplay()
    }
    
    func placeLeftHandle() {
        guard let bounce = ApplicationController.shared.bounce else { return }
        let height = bounds.height
        let activeHandleLeft: CGFloat = getActiveHandleLeft()
        let activeHandleSpan = getActiveHandleSpan()
        let percent = bounce.getTimelineLeftHandlePercent()
        let handleX: CGFloat = activeHandleLeft + percent * activeHandleSpan
        handleLeft.frame = CGRect(x: handleX, y: 0.0, width: TBTimeline.handleWidth, height: height)
        placeThumb()
        setNeedsDisplay()
    }
    
    func placeRightHandle() {
        guard let bounce = ApplicationController.shared.bounce else { return }
        let height = bounds.height
        let activeHandleLeft: CGFloat = getActiveHandleLeft()
        let activeHandleSpan = getActiveHandleSpan()
        let percent = bounce.getTimelineRightHandlePercent()
        let handleX: CGFloat = activeHandleLeft + percent * activeHandleSpan
        handleRight.frame = CGRect(x: handleX, y: 0.0, width: TBTimeline.handleWidth, height: height)
        placeThumb()
        setNeedsDisplay()
    }
    
    func layoutElements() {
        ensureHandlesAndThumbArePlaced()
        placeLeftHandle()
        placeRightHandle()
        placeThumb()
        setNeedsDisplay()
    }
    
    func ensureHandlesAndThumbArePlaced() {
        let height = bounds.height
        if thumb === nil {
            thumb = TBTimelineThumb(frame: CGRect(x: 0.0, y: 0.0, width: TBTimeline.thumbWidth, height: height))
            addSubview(thumb)
            thumb.setUp()
        }
        if handleLeft === nil {
            handleLeft = TBTimelineHandle(frame: CGRect(x: 0.0, y: 0.0, width: TBTimeline.handleWidth, height: height))
            addSubview(handleLeft)
            handleLeft.setUp(left: true)
        }
        if handleRight === nil {
            handleRight = TBTimelineHandle(frame: CGRect(x: 0.0, y: 0.0, width: TBTimeline.handleWidth, height: height))
            addSubview(handleRight)
            handleRight.setUp(left: false)
        }
    }
}

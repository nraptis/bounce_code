//
//  BlobMotionControllerAutoLooper.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/21/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class BlobMotionControllerBulgeBouncer: BlobMotionController {
    
    static var defaultAnimationSpeed: CGFloat = 0.75
    static var defaultAnimationPower: CGFloat = 0.33
    static var defaultAnimationInflationStartFactor: CGFloat = 0.5
    static var defaultAnimationEllipseFactor: CGFloat = 0.0
    static var defaultAnimationInflationFactor: CGFloat = 0.35
    static var defaultAnimationBounceFactor: CGFloat = 0.5
    
    static var defaultAnimationBounceEnabled: Bool = false
    static var defaultAnimationReverseEnabled: Bool = false
    static var defaultAnimationAlternateEnabled: Bool = false
    static var defaultAnimationInflateEnabled: Bool = true
    static var defaultAnimationHorizontalEnabled: Bool = false
    
    //Unused
    static var defaultAnimationTwistEnabled: Bool = true
    static var defaultAnimationEllipseEnabled: Bool = true
    
    fileprivate var isBouncing: Bool = false
    fileprivate var bounceIndex: Int = 0
    
    fileprivate var animationProgress: CGFloat = 0.0
    
    fileprivate var animationLoopSpeed: CGFloat = 0.0
    
    fileprivate var mainOrbitLoopMax: CGFloat = 72.0
    fileprivate var secondaryOrbitLoopMax: CGFloat = 26.0
    
    
    
    var bounceAmount: CGFloat = 0.1825
    
    // Basically just 1 or 0 now...
    fileprivate var bounceCount: Int = 0
    
    override init() {
        super.init()
    }
    
    override func update() {
        super.update()
        
        guard  let engine = ApplicationController.shared.engine else { return }
        
        let powerPercent: CGFloat = engine.animationBulgeBouncerPower
        let speedPercent: CGFloat = engine.animationBulgeBouncerSpeed
        let ellipseFactor: CGFloat = engine.animationBulgeBouncerEllipseFactor
        let inflateFactor: CGFloat = engine.animationBulgeBouncerInflationFactor
        let inflationStartFactor: CGFloat = engine.animationBulgeBouncerInflationStartFactor
        let bounceFactor: CGFloat = engine.animationBulgeBouncerBounceFactor
        
        //let isAnimationBounceEnabled: Bool = engine.animationBulgeBouncerBounceEnabled
        let isAnimationReverseEnabled: Bool = engine.animationBulgeBouncerReverseEnabled
        let isAnimationHorizontalEnabled: Bool = engine.animationBulgeBouncerHorizontalEnabled
        //let isAnimationEllipseEnabled: Bool = engine.animationBulgeBouncerEllipseEnabled
        let isAnimationInflateEnabled: Bool = engine.animationBulgeBouncerInflateEnabled
        //let isAnimationTwistEnabled: Bool = engine.animationBulgeBouncerTwistEnabled
        
        let minAnimationLoopSpeed: CGFloat = 1.35
        let maxAnimationLoopSpeed: CGFloat = 4.75
        
        animationLoopSpeed = minAnimationLoopSpeed + (maxAnimationLoopSpeed - minAnimationLoopSpeed) * speedPercent
        
        bounceAmount = 0.15 + 0.32 * bounceFactor
        secondaryOrbitLoopMax = 26.0 + 24 * bounceFactor
        //fileprivate var secondaryOrbitLoopMax: CGFloat = 26.0
        //var bounceAmount: CGFloat = 0.1825
        
        let mainRadius: CGFloat = dragFalloffDampenStart * 0.35 + (dragFalloffDampenResultMax - dragFalloffDampenStart) * powerPercent * 1.0
        let secondaryRadius: CGFloat = mainRadius * bounceAmount
        
        var cyclePercent: CGFloat = 0.0
        
        let totalBounceTime: CGFloat = CGFloat(bounceCount) * secondaryOrbitLoopMax
        let totalMainTime: CGFloat = mainOrbitLoopMax
        let totalTime: CGFloat = totalBounceTime + totalMainTime
        var totalProgress: CGFloat = 0.0
        
        if isBouncing == false {
            totalProgress = animationProgress
        } else {
            totalProgress = mainOrbitLoopMax + CGFloat(bounceIndex) * secondaryOrbitLoopMax + animationProgress
        }
        
        cyclePercent = (totalProgress + totalBounceTime * 0.5) / totalTime
        while cyclePercent < 0.0 { cyclePercent += 1.0 }
        while cyclePercent > 1.0 { cyclePercent -= 1.0 }
        
        cyclePercent = CGFloat(sin( cyclePercent * Math.PI2 ))
        
        animationProgress += animationLoopSpeed
        if isBouncing == false {
            if animationProgress >= mainOrbitLoopMax {
                animationProgress -= mainOrbitLoopMax
                if bounceCount > 0 {
                    bounceIndex = 0
                    isBouncing = true
                }
            }
        } else {
            if animationProgress >= secondaryOrbitLoopMax {
                animationProgress -= secondaryOrbitLoopMax
                bounceIndex += 1
                if bounceIndex >= bounceCount {
                    bounceIndex = 0
                    isBouncing = false
                }
            }
        }
        
        var orbitPercent: CGFloat = 0.0
        if isBouncing == false {
            orbitPercent = animationProgress / mainOrbitLoopMax
        } else {
            orbitPercent = animationProgress / secondaryOrbitLoopMax
        }
        
        let orbitFactor = CGFloat(sin( Math.PI_2 + orbitPercent * Math.PI2 ))
        
        var offsetX: CGFloat = 0.0
        var offsetY: CGFloat = 0.0
        
        if isBouncing == false {
            offsetY = mainRadius * orbitFactor
        } else {
            let secondaryCenter = CGPoint(x: 0.0, y: mainRadius - secondaryRadius)
            offsetY = secondaryCenter.y + secondaryRadius * orbitFactor
        }
        
        offsetX = cyclePercent * mainRadius * 0.8 * ellipseFactor
        var verticalPercent: CGFloat = (mainRadius + offsetY) / (mainRadius + mainRadius)
        
        if isAnimationReverseEnabled {
            offsetY = -offsetY
            if isAlt == false {
                offsetX = -offsetX
            }
        } else {
            if isAlt == true {
                offsetX = -offsetX
            }
        }
        
        if verticalPercent < 0.0 { verticalPercent = 0.0 }
        if verticalPercent > 1.0 { verticalPercent = 1.0 }
        
        if isAnimationHorizontalEnabled {
            let hold: CGFloat = offsetX
            offsetX = offsetY
            offsetY = hold
        }
        
        animationTargetOffset = CGPoint(x: offsetX, y: offsetY)
        
        let minInflationVerticalPercent: CGFloat = 0.25 + 0.45 * inflationStartFactor
        let maxInflationVerticalPercent: CGFloat = 1.0
        
        let minInflateAmount: CGFloat = 1.0
        let maxInflateAmount: CGFloat = 1.0 + ( 0.36 * inflateFactor )
        
        if isAnimationInflateEnabled {
            if verticalPercent <= minInflationVerticalPercent {
                inflateScale = minInflateAmount
            } else if verticalPercent >= maxInflationVerticalPercent {
                inflateScale = maxInflateAmount
            } else {
                var inflateScaleFactor: CGFloat = (verticalPercent - minInflationVerticalPercent) / (maxInflationVerticalPercent - minInflationVerticalPercent)
                inflateScaleFactor = CGFloat(sin(Math.PI_2 * inflateScaleFactor))
                inflateScale = minInflateAmount + (maxInflateAmount - minInflateAmount) * inflateScaleFactor
            }
        } else {
            inflateScale = 1.0
        }
    }
    
    override func reset(alt: Bool) {
        super.reset(alt: alt)
        
        if alt {
            let totalBounceTime: CGFloat = CGFloat(bounceCount) * secondaryOrbitLoopMax
            let totalMainTime: CGFloat = mainOrbitLoopMax
            animationProgress = (totalMainTime + totalBounceTime) / 2.0
        } else {
            animationProgress = 0.0
        }
    }
    
    func enableBounce() {
        isBouncing = false
        bounceCount = 1
        bounceIndex = 0
    }
    
    func disableBounce() {
        isBouncing = false
        bounceCount = 0
        bounceIndex = 0
    }
    
    override func drawMarkers() {
        super.drawMarkers()
    }
    
}





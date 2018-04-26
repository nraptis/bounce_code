//
//  BlobMotionControllerTwister.swift
//  Bounce
//
//  Created by Nicholas Raptis on 11/2/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class BlobMotionControllerTwister: BlobMotionController {
    
    static var defaultAnimationTwistSpeed: CGFloat = 0.5
    static var defaultAnimationTwistPower: CGFloat = 0.5
    static var defaultAnimationInflationFactor1: CGFloat = 0.46
    static var defaultAnimationInflationFactor2: CGFloat = 0.75
    
    static var defaultAnimationReverseEnabled: Bool = false
    static var defaultAnimationEllipseEnabled: Bool = false
    static var defaultAnimationAlternateEnabled: Bool = false
    static var defaultAnimationInflateEnabled: Bool = false
    
    fileprivate var animationProgress: CGFloat = 0.0
    fileprivate var animationLoopSpeed: CGFloat = 0.0
    fileprivate var mainTwistLoopMax: CGFloat = 72.0
    
    // Basically just 1 or 0 now...
    fileprivate var bounceCount: Int = 0
    
    override init() {
        super.init()
    }
    
    override func update() {
        super.update()
        
        guard  let engine = ApplicationController.shared.engine else { return }
        
        //let isAnimationBounceEnabled: Bool = engine.animationBulgeBouncerBounceEnabled
        let isAnimationReverseEnabled: Bool = engine.animationTwisterReverseEnabled
        //let isAnimationEllipseEnabled: Bool = engine.animationTwisterEllipseEnabled
        let isAnimationInflateEnabled: Bool = engine.animationTwisterInflateEnabled
        //let isAnimationTwistEnabled: Bool = engine.animationBulgeBouncerTwistEnabled
        
        let twistFactor: CGFloat = engine.animationTwisterTwistPower
        let twistSpeed: CGFloat = engine.animationTwisterTwistSpeed
        
        let twistStartInflationFactor: CGFloat = engine.animationTwisterInflationFactor1
        let twistEndInflationFactor: CGFloat = engine.animationTwisterInflationFactor2
        
        let minAnimationLoopSpeed: CGFloat = 1.85
        let maxAnimationLoopSpeed: CGFloat = 4.5
        
        animationLoopSpeed = minAnimationLoopSpeed + (maxAnimationLoopSpeed - minAnimationLoopSpeed) * twistSpeed
        
        animationProgress += animationLoopSpeed
        if animationProgress >= mainTwistLoopMax { animationProgress -= mainTwistLoopMax }
        
        var twistPercent: CGFloat = 0.0
        twistPercent = animationProgress / mainTwistLoopMax
        
        let twistCycleFactor = CGFloat(sin(twistPercent * Math.PI2 ))
        
        let twistFactorMin: CGFloat = 0.25
        let twistFactorMax: CGFloat = ApplicationController.shared.inflateScaleMax
        
        let appliedTwistFactor: CGFloat = twistFactorMin + (twistFactorMax - twistFactorMin) * twistFactor
        
        if isAnimationReverseEnabled {
            twistRotation = twistCycleFactor * Math.PI_2 * appliedTwistFactor
        } else {
            twistRotation = twistCycleFactor * Math.PI_2 * -appliedTwistFactor
        }
        
        let inflateFactorMin: CGFloat = 1.0 - 0.3125
        let inflateFactorMax: CGFloat = 1.0 + 0.3125
        
        let inflateStart: CGFloat = inflateFactorMin + (inflateFactorMax - inflateFactorMin) * twistStartInflationFactor
        let inflateEnd: CGFloat = inflateFactorMin + (inflateFactorMax - inflateFactorMin) * twistEndInflationFactor
        
        let inflatePercent = (twistCycleFactor + 1.0) / 2.0
        
        if isAnimationInflateEnabled {
            inflateScale = inflateStart + (inflateEnd - inflateStart) * inflatePercent
        } else {
            inflateScale = 1.0
        }
    }
    
    override func reset(alt: Bool) {
        
        super.reset(alt: alt)
        
        if alt {
            animationProgress = mainTwistLoopMax / 2.0
        } else {
            animationProgress = 0.0
        }
        
    }
    
    override func drawMarkers() {
        super.drawMarkers()
    }
    
}





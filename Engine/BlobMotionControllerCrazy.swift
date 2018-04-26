//
//  BlobMotionControllerCrazy.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/8/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class BlobMotionControllerCrazy: BlobMotionController {
    
    static var defaultAnimationSpeed: CGFloat = 0.75
    static var defaultAnimationPower: CGFloat = 0.33
    static var defaultAnimationInflationFactor1: CGFloat = 0.3333333333
    static var defaultAnimationInflationFactor2: CGFloat = 0.3333333333
    static var defaultAnimationTwistFactor: CGFloat = 0.5
    static var defaultAnimationRandomnessFactor: CGFloat = 0.5
    
    static var defaultAnimationReverseEnabled: Bool = false
    static var defaultAnimationEllipseEnabled: Bool = false
    static var defaultAnimationAlternateEnabled: Bool = false
    static var defaultAnimationTwistEnabled: Bool = true
    static var defaultAnimationInflateEnabled: Bool = true
    static var defaultAnimationHorizontalEnabled: Bool = false
    
    static let loopCount: Int = 9
    
    static let globalLoopSegmentMax: CGFloat = 74.0
    static let globalLoopMax: CGFloat = globalLoopSegmentMax * CGFloat(loopCount)
    
    fileprivate var spline = CubicSplineManualTangents()
    fileprivate var splineAlt = CubicSpline()
    
    fileprivate var splineIndex: Int = 0
    
    fileprivate var previousRandomFactor: CGFloat = 0.0
    fileprivate var previousTwistFactor: CGFloat = 0.0
    fileprivate var previousInflationFactor1: CGFloat = 0.0
    fileprivate var previousInflationFactor2: CGFloat = 0.0
    
    ////////////////////////////////////////////////////////
    //                                                    //
    //                    Tweakable Values                //
    //                                                    //
    
    fileprivate let loopKnotVariance: CGFloat = 16.0
    
    fileprivate let tanLengthBase: CGFloat = 2.75
    fileprivate let tanLengthRandom: CGFloat = 1.0
    fileprivate let tanDirRandom: CGFloat = Math.PI / 15.0
    
    fileprivate let pointDistance: CGFloat = 0.75
    fileprivate let pointRandomLengthX: CGFloat = 0.25
    fileprivate let pointRandomLengthY: CGFloat = 0.25
    
    fileprivate let twistStartBase: CGFloat = -0.26
    fileprivate let twistStartRandom: CGFloat = -0.26
    
    fileprivate let twistEndBase: CGFloat = 0.125
    fileprivate let twistEndRandom: CGFloat = 0.125
    
    fileprivate let inflateRandom: CGFloat = 0.09
    
    //                                                     //
    /////////////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////////
    //                                                   //
    //                Just spline stuff                  //
    //                                                   //
    
    //Control Points..
    fileprivate var loopPosStartBase = [CGPoint](repeating: CGPoint(x: 0.0, y: 0.0), count: loopCount + 1)
    fileprivate var loopPosStartRandom = [CGPoint](repeating: CGPoint(x: 0.0, y: 0.0), count: loopCount + 1)
    
    fileprivate var loopPosEndBase = [CGPoint](repeating: CGPoint(x: 0.0, y: 0.0), count: loopCount)
    fileprivate var loopPosEndRandom = [CGPoint](repeating: CGPoint(x: 0.0, y: 0.0), count: loopCount)
    
    //The direction out will always be the direction in + pi...
    fileprivate var loopTanDirStartBase = [CGFloat](repeating: 0.0, count: loopCount + 1)
    fileprivate var loopTanDirStartRandom = [CGFloat](repeating: 0.0, count: loopCount + 1)
    
    fileprivate var loopTanDirEndBase = [CGFloat](repeating: 0.0, count: loopCount)
    fileprivate var loopTanDirEndRandom = [CGFloat](repeating: 0.0, count: loopCount)
    
    fileprivate var loopTanInLengthStartBase = [CGFloat](repeating: 0.0, count: loopCount + 1)
    fileprivate var loopTanInLengthStartRandom = [CGFloat](repeating: 0.0, count: loopCount + 1)
    fileprivate var loopTanOutLengthStartBase = [CGFloat](repeating: 0.0, count: loopCount + 1)
    fileprivate var loopTanOutLengthStartRandom = [CGFloat](repeating: 0.0, count: loopCount + 1)
    
    fileprivate var loopTanInLengthEndBase = [CGFloat](repeating: 0.0, count: loopCount)
    fileprivate var loopTanInLengthEndRandom = [CGFloat](repeating: 0.0, count: loopCount)
    fileprivate var loopTanOutLengthEndBase = [CGFloat](repeating: 0.0, count: loopCount)
    fileprivate var loopTanOutLengthEndRandom = [CGFloat](repeating: 0.0, count: loopCount)
    
    //                                                       //
    ///////////////////////////////////////////////////////////
    
    
    /////////////////////////////////////////////////////////
    //                                                     //
    //                 Alt spline stuff                    //
    //                                                     //
    
    //Twisting..
    fileprivate var loopTwistStartBase = [CGFloat](repeating: 0.0, count: loopCount + 1)
    fileprivate var loopTwistStartRandom = [CGFloat](repeating: 0.0, count: loopCount + 1)
    fileprivate var loopTwistEndBase = [CGFloat](repeating: 0.0, count: loopCount)
    fileprivate var loopTwistEndRandom = [CGFloat](repeating: 0.0, count: loopCount)
    
    //Inflating..
    fileprivate var loopInflateStartBaseMin = [CGFloat](repeating: 1.0, count: loopCount + 1)
    fileprivate var loopInflateStartBaseMax = [CGFloat](repeating: 1.0, count: loopCount + 1)
    fileprivate var loopInflateStartRandom = [CGFloat](repeating: 1.0, count: loopCount + 1)
    
    fileprivate var loopInflateEndBaseMin = [CGFloat](repeating: 1.0, count: loopCount)
    fileprivate var loopInflateEndBaseMax = [CGFloat](repeating: 1.0, count: loopCount)
    fileprivate var loopInflateEndRandom = [CGFloat](repeating: 1.0, count: loopCount)
    
    //                                                 //
    /////////////////////////////////////////////////////
    
    /////////////////////////////////////////////
    //                                         //
    //               Timing Control            //
    //                                         //
    
    fileprivate var loopKnotBase = [CGFloat](repeating: 0, count: loopCount + 1)
    fileprivate var loopKnotRandom = [CGFloat](repeating: 0, count: loopCount + 1)
    fileprivate var loopKnot = [CGFloat](repeating: 0, count: loopCount + 1)
    
    //                                         //
    /////////////////////////////////////////////
    
    
    fileprivate var animationProgress: CGFloat = 0.0
    fileprivate var animationLoopSpeed: CGFloat = 0.0
    
    override init() {
        super.init()
        self.reset(alt: false)
    }
    
    override func update() {
        super.update()
        
        var needsRecompute: Bool = false
        
        guard let engine = ApplicationController.shared.engine else { return }
        
        let powerPercent: CGFloat = engine.animationRandomPower
        
        let isAnimationReverseEnabled: Bool = engine.animationRandomReverseEnabled
        let isAnimationHorizontalEnabled: Bool = engine.animationRandomHorizontalEnabled
        let isAnimationTwistEnabled: Bool = engine.animationRandomTwistEnabled
        let isAnimationInflateEnabled: Bool = engine.animationRandomInflateEnabled
        //let isAnimationEllipseEnabled: Bool = engine.animationRandomEllipseEnabled
        
        
        //let speedPercent: CGFloat = engine.animationSpeed
        //let ellipseFactor: CGFloat = engine.animationEllipseFactor
        //let inflateFactor: CGFloat = engine.animationInflateFactor
        
        let randomFactor: CGFloat = engine.animationRandomRandomnessFactor
        let twistFactor: CGFloat = engine.animationRandomTwistFactor
        let inflationFactor1: CGFloat = engine.animationRandomInflationFactor1
        let inflationFactor2: CGFloat = engine.animationRandomInflationFactor2
        
        
        //var animationRandomPower: CGFloat = BlobMotionControllerCrazy.defaultAnimationPower { didSet { for blob in blobs { blob.setNeedsComputeAffine() } } }
        //var animationRandomSpeed: CGFloat = BlobMotionControllerCrazy.defaultAnimationSpeed
        //var animationRandomInflationFactor1: CGFloat = BlobMotionControllerCrazy.defaultAnimationInflationFactor1
        //var animationRandomInflationFactor2: CGFloat = BlobMotionControllerCrazy.defaultAnimationInflationFactor2
        //var animationRandomTwistFactor: CGFloat = BlobMotionControllerCrazy.defaultAnimationTwistFactor
        //var animationRandomRandomnessFactor: CGFloat = BlobMotionControllerCrazy.defaultAnimationRandomnessFactor
        
        
        
        if previousRandomFactor != randomFactor {
            previousRandomFactor = randomFactor
            needsRecompute = true
        }
        
        if previousTwistFactor != twistFactor {
            previousTwistFactor = twistFactor
            needsRecompute = true
        }
        
        if previousInflationFactor1 != inflationFactor1 {
            previousInflationFactor1 = inflationFactor1
            needsRecompute = true
        }
        
        if previousInflationFactor2 != inflationFactor2 {
            previousInflationFactor2 = inflationFactor2
            needsRecompute = true
        }
        
        let radius: CGFloat = dragFalloffDampenStart * 0.35 + (dragFalloffDampenResultMax - dragFalloffDampenStart) * powerPercent
        //radius *= 0.825
        
        let splinePos = getPos()
        
        var unitDir = spline.get(splinePos)
        
        if isAnimationReverseEnabled {
            unitDir.x = -unitDir.x
        }
        
        var offsetX: CGFloat = unitDir.x * radius
        var offsetY: CGFloat = unitDir.y * radius

        /*
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
        */
        
        if isAnimationHorizontalEnabled {
            let hold: CGFloat = offsetX
            offsetX = offsetY
            offsetY = hold
        }
        
        animationTargetOffset = CGPoint(x: offsetX, y: offsetY)
        
        let altNode = splineAlt.get(splinePos)
        
        if isAnimationTwistEnabled {
            
            //isAlt = alt
            
            if isAnimationReverseEnabled {
                twistRotation = altNode.x
            } else {
                twistRotation = -altNode.x
            }
        } else {
            twistRotation = 0.0
        }
        
        if isAnimationInflateEnabled {
            inflateScale = 1.0 + altNode.y
        }
        else {
            inflateScale = 1.0
        }
        
        if needsRecompute { recomputeSpline() }
    }
    
    func getPos() -> CGFloat {
        
        guard let engine = ApplicationController.shared.engine else { return 0.0 }
        
        var result: CGFloat = 0.0
        let globalProgress = engine.globalCrazyMotionControllerAnimationProgress
        
        
        var index1: Int = -1
        var index2: Int = -1
        for i: Int in 0..<BlobMotionControllerCrazy.loopCount {
            if globalProgress >= loopKnot[i] && globalProgress <= loopKnot[i + 1] {
                index1 = i
                index2 = i + 1
                break
            }
        }
        if index1 != -1 {
            let percent = (globalProgress - loopKnot[index1]) / (loopKnot[index2] - loopKnot[index1])
            result = (CGFloat(index1) + percent) * 2.0
        } else {
            if globalProgress < loopKnot[0] {
                return 0.0
            } else {
                return spline.maxPos
            }
        }
        
        return result
    }
    
    override func reset(alt: Bool) {
        
        super.reset(alt: alt)
        
        //First reset, which will not reset the first "start" data points.
        resetLooping(alt: alt)
        
        //Now we do an additional looping reset so that we can fill in the first "start" data
        //points with the previously computed "end" data points.
        resetLooping(alt: alt)
        
        //Now we recompute the spline.. and the reset is complete!
        recomputeSpline()
    }
    
    func resetLooping(alt: Bool) {
        
        /////////////////////////////////////////////////////
        //                                                 //
        //                   Knot Stuff                    //
        //                                                 //
        //                                                 //
        
        var knotTime: CGFloat = 0.0
        for i in 0..<(BlobMotionControllerCrazy.loopCount + 1) {
            loopKnotBase[i] = knotTime
            loopKnotRandom[i] = -(loopKnotVariance / 2.0) + CGFloat(Randomizer.getFloat()) * loopKnotVariance
            
            knotTime += BlobMotionControllerCrazy.globalLoopSegmentMax
        }
        loopKnotRandom[0] = 0
        loopKnotRandom[BlobMotionControllerCrazy.loopCount] = 0
        
        //                                                 //
        /////////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////////////
        //                                                    //
        //            Spline Control Point Stuff              //
        //                                                    //
        
        loopPosStartRandom[0].x = loopPosStartRandom[BlobMotionControllerCrazy.loopCount].x
        loopPosStartRandom[0].y = loopPosStartRandom[BlobMotionControllerCrazy.loopCount].y
        
        for i in 1..<(BlobMotionControllerCrazy.loopCount+1) {
            loopPosStartRandom[i].x = -pointRandomLengthX
                + (CGFloat(Randomizer.getFloat()) * (pointRandomLengthX * 2.0))
            loopPosStartRandom[i].y = -pointRandomLengthY
                + (CGFloat(Randomizer.getFloat()) * (pointRandomLengthY * 2.0))
        }
        
        for i in 0..<(BlobMotionControllerCrazy.loopCount) {
            loopPosEndRandom[i].x = -pointRandomLengthX
                + (CGFloat(Randomizer.getFloat()) * (pointRandomLengthX * 2.0))
            loopPosEndRandom[i].y = -pointRandomLengthY
                + (CGFloat(Randomizer.getFloat()) * (pointRandomLengthY * 2.0))
        }
        
        loopPosStartBase[0].x = loopPosStartBase[BlobMotionControllerCrazy.loopCount].x
        loopPosStartBase[0].y = loopPosStartBase[BlobMotionControllerCrazy.loopCount].y
        
        if alt {
            for i in 1..<(BlobMotionControllerCrazy.loopCount + 1) {
                loopPosStartBase[i].x = 0.0
                loopPosStartBase[i].y = pointDistance
            }
            for i in 0..<(BlobMotionControllerCrazy.loopCount) {
                loopPosEndBase[i].x = 0.0
                loopPosEndBase[i].y = -pointDistance
            }
        } else {
            for i in 1..<(BlobMotionControllerCrazy.loopCount + 1) {
                loopPosStartBase[i].x = 0.0
                loopPosStartBase[i].y = -pointDistance
            }
            for i in 0..<(BlobMotionControllerCrazy.loopCount) {
                loopPosEndBase[i].x = 0.0
                loopPosEndBase[i].y = pointDistance
            }
        }
        
        //                                                 //
        /////////////////////////////////////////////////////
        
        
        
        
        
        
        /////////////////////////////////////////////////////////////////
        //                                                             //
        //                   Spline Tangent Directions                 //
        //                                                             //
        
        loopTanDirStartBase[0] = loopTanDirStartBase[BlobMotionControllerCrazy.loopCount]
        loopTanDirStartRandom[0] = loopTanDirStartRandom[BlobMotionControllerCrazy.loopCount]
        loopTanInLengthStartBase[0] = loopTanInLengthStartBase[BlobMotionControllerCrazy.loopCount]
        loopTanInLengthStartRandom[0] = loopTanInLengthStartRandom[BlobMotionControllerCrazy.loopCount]
        loopTanOutLengthStartBase[0] = loopTanOutLengthStartBase[BlobMotionControllerCrazy.loopCount]
        loopTanOutLengthStartRandom[0] = loopTanOutLengthStartRandom[BlobMotionControllerCrazy.loopCount]
        
        for i in 1..<(BlobMotionControllerCrazy.loopCount+1) {
            loopTanInLengthStartBase[i] = tanLengthBase
            loopTanInLengthStartRandom[i] = CGFloat(Randomizer.getFloat()) * tanLengthRandom
            loopTanOutLengthStartBase[i] = tanLengthBase
            loopTanOutLengthStartRandom[i] = CGFloat(Randomizer.getFloat()) * tanLengthRandom
            loopTanDirStartRandom[i] = CGFloat(Randomizer.getFloat()) * tanDirRandom
        }
        
        for i in 0..<(BlobMotionControllerCrazy.loopCount) {
            loopTanInLengthEndBase[i] = tanLengthBase
            loopTanInLengthEndRandom[i] = CGFloat(Randomizer.getFloat()) * tanLengthRandom
            loopTanOutLengthEndBase[i] = tanLengthBase
            loopTanOutLengthEndRandom[i] = CGFloat(Randomizer.getFloat()) * tanLengthRandom
            loopTanDirEndRandom[i] = CGFloat(Randomizer.getFloat()) * tanDirRandom
        }
        
        let tanDir1 = Math.PI_2
        let tanDir2 = Math.PI + Math.PI_2
        
        if alt {
            for i in 1..<(BlobMotionControllerCrazy.loopCount + 1) {
                loopTanDirStartBase[i] = tanDir2
            }
            for i in 0..<(BlobMotionControllerCrazy.loopCount) {
                loopTanDirEndBase[i] = tanDir1
            }
        } else {
            for i in 1..<(BlobMotionControllerCrazy.loopCount + 1) {
                loopTanDirStartBase[i] = tanDir1
            }
            for i in 0..<(BlobMotionControllerCrazy.loopCount) {
                loopTanDirEndBase[i] = tanDir2
            }
        }
        
        //                                                        //
        //                                                        //
        //                                                        //
        //                                                        //
        //                                                        //
        //                                                        //
        ////////////////////////////////////////////////////////////
     
        

        /////////////////////////////////////////////////////////
        //                                                     //
        //                 Alt spline stuff                    //
        //                                                     //
        
        loopTwistStartBase[0] = loopTwistStartBase[BlobMotionControllerCrazy.loopCount]
        loopTwistStartRandom[0] = loopTwistStartRandom[BlobMotionControllerCrazy.loopCount]
        loopInflateStartBaseMin[0] = loopInflateStartBaseMin[BlobMotionControllerCrazy.loopCount]
        loopInflateStartBaseMax[0] = loopInflateStartBaseMax[BlobMotionControllerCrazy.loopCount]
        
        //fileprivate var loopInflateStartBaseMin = [CGFloat](repeating: 1.0, count: loopCount + 1)
        //fileprivate var loopInflateStartBaseMax = [CGFloat](repeating: 1.0, count: loopCount + 1)
        //fileprivate var loopInflateStartRandom = [CGFloat](repeating: 1.0, count: loopCount + 1)
        
        //fileprivate var loopInflateEndBaseMin = [CGFloat](repeating: 1.0, count: loopCount)
        //fileprivate var loopInflateEndBaseMax = [CGFloat](repeating: 1.0, count: loopCount)
        //fileprivate var loopInflateEndRandom = [CGFloat](repeating: 1.0, count: loopCount)
        
        loopInflateStartRandom[0] = loopInflateStartRandom[BlobMotionControllerCrazy.loopCount]
        
        //inflateRandom
        let infBaseMin: CGFloat = -0.07
        let infBaseMax: CGFloat = 0.18
        
        
        for i in 1..<(BlobMotionControllerCrazy.loopCount+1) {
            loopTwistStartBase[i] = twistStartBase
            loopTwistStartRandom[i] = CGFloat(Randomizer.getFloat()) * twistStartRandom
            //loopInflateStartBaseMin[i] = -infBaseRandom / 2.0 + infBaseMin + infBaseRandom * CGFloat(Randomizer.getFloat())
            //loopInflateStartBaseMax[i] = -infBaseRandom / 2.0 + infBaseMax + infBaseRandom * CGFloat(Randomizer.getFloat())
            
            loopInflateStartBaseMin[i] = infBaseMin
            loopInflateStartBaseMax[i] = infBaseMax
            
            
            loopInflateStartRandom[i] = -inflateRandom / 2.0 + CGFloat(Randomizer.getFloat()) * inflateRandom
        }
        
        for i in 0..<(BlobMotionControllerCrazy.loopCount) {
            loopTwistEndBase[i] = twistEndBase
            loopTwistEndRandom[i] = CGFloat(Randomizer.getFloat()) * twistEndBase
            //loopInflateEndBaseMin[i] = -infBaseRandom / 2.0 + infBaseMin + infBaseRandom * CGFloat(Randomizer.getFloat())
            //loopInflateEndBaseMax[i] = -infBaseRandom / 2.0 + infBaseMax + infBaseRandom * CGFloat(Randomizer.getFloat())
            loopInflateEndBaseMin[i] = infBaseMin
            loopInflateEndBaseMax[i] = infBaseMax
            
            loopInflateEndRandom[i] = -inflateRandom / 2.0 + CGFloat(Randomizer.getFloat()) * inflateRandom
        }
        
        //fileprivate let twistStartBase: CGFloat = -0.15
        //fileprivate let twistStartRandom: CGFloat = -0.15
        
        //fileprivate let twistEndBase: CGFloat = 0.15
        //fileprivate let twistEndBase: CGFloat = 0.15
        
        //                                                 //
        /////////////////////////////////////////////////////
        
    }
    
    
    func recomputeSpline() {
        
        guard let engine = ApplicationController.shared.engine else { return }
        
        let randomFactor: CGFloat = engine.animationRandomRandomnessFactor
        let twistFactor: CGFloat = engine.animationRandomTwistFactor
        let inflationFactor1: CGFloat = engine.animationRandomInflationFactor1
        let inflationFactor2: CGFloat = engine.animationRandomInflationFactor2
        
        for i in 0..<(BlobMotionControllerCrazy.loopCount + 1) {
            loopKnot[i] = loopKnotBase[i] + loopKnotRandom[i] * randomFactor
        }
        
        var index: Int = 0
        for i in 0..<BlobMotionControllerCrazy.loopCount {
            let startX: CGFloat = loopPosStartBase[i].x + loopPosStartRandom[i].x * randomFactor
            let startY: CGFloat = loopPosStartBase[i].y + loopPosStartRandom[i].y * randomFactor
            
            let endX: CGFloat = loopPosEndBase[i].x + loopPosEndRandom[i].x * randomFactor
            let endY: CGFloat = loopPosEndBase[i].y + loopPosEndRandom[i].y * randomFactor
            
            spline.set(index, x: startX, y: startY)
            index += 1
            
            spline.set(index, x: endX, y: endY)
            index += 1
        }
        let finalStartX: CGFloat = loopPosStartBase[BlobMotionControllerCrazy.loopCount].x +
            loopPosStartRandom[BlobMotionControllerCrazy.loopCount].x * randomFactor
        let finalStartY: CGFloat = loopPosStartBase[BlobMotionControllerCrazy.loopCount].y +
            loopPosStartRandom[BlobMotionControllerCrazy.loopCount].y * randomFactor
        spline.set(index, x: finalStartX, y: finalStartY)
        
        index = 0
        for i in 0..<BlobMotionControllerCrazy.loopCount {
            let angleStartIn = (loopTanDirStartBase[i] + Math.PI) + loopTanDirStartRandom[i] * randomFactor
            let angleStartOut = loopTanDirStartBase[i] + loopTanDirStartRandom[i] * randomFactor            
            let startLengthIn = loopTanInLengthStartBase[i] + loopTanInLengthStartRandom[i] * randomFactor
            let startLengthOut = loopTanOutLengthStartBase[i] + loopTanOutLengthStartRandom[i] * randomFactor
            
            spline.setTanIn(index, tanx: Math.sinr(radians: angleStartIn) * startLengthIn,
                            tany: -Math.cosr(radians: angleStartIn) * startLengthIn)
            spline.setTanOut(index, tanx: Math.sinr(radians: angleStartOut) * startLengthOut,
                             tany: -Math.cosr(radians: angleStartOut) * startLengthOut)
            index += 1
            
            let angleEndIn = (loopTanDirEndBase[i] + Math.PI) + loopTanDirEndRandom[i] * randomFactor
            let angleEndOut = loopTanDirEndBase[i] + loopTanDirEndRandom[i] * randomFactor
            let endLengthIn = loopTanInLengthEndBase[i] + loopTanInLengthEndRandom[i] * randomFactor
            let endLengthOut = loopTanOutLengthEndBase[i] + loopTanOutLengthEndRandom[i] * randomFactor
            
            spline.setTanIn(index, tanx: Math.sinr(radians: angleEndIn) * endLengthIn, tany: -Math.cosr(radians: angleEndIn) * endLengthIn)
            spline.setTanOut(index, tanx: Math.sinr(radians: angleEndOut) * endLengthOut, tany: -Math.cosr(radians: angleEndOut) * endLengthOut)
            index += 1
        }
        
        let finalAngleStartIn = (loopTanDirStartBase[BlobMotionControllerCrazy.loopCount] + Math.PI) +
            loopTanDirStartRandom[BlobMotionControllerCrazy.loopCount] * randomFactor
        let finalAngleStartOut = loopTanDirStartBase[BlobMotionControllerCrazy.loopCount] +
            loopTanDirStartRandom[BlobMotionControllerCrazy.loopCount] * randomFactor            
        let finalStartLengthIn = loopTanInLengthStartBase[BlobMotionControllerCrazy.loopCount] +
            loopTanInLengthStartRandom[BlobMotionControllerCrazy.loopCount] * randomFactor
        let finalStartLengthOut = loopTanOutLengthStartBase[BlobMotionControllerCrazy.loopCount] +
            loopTanOutLengthStartRandom[BlobMotionControllerCrazy.loopCount] * randomFactor
        
        spline.setTanIn(index, tanx: Math.sinr(radians: finalAngleStartIn) * finalStartLengthIn,
                        tany: -Math.cosr(radians: finalAngleStartIn) * finalStartLengthIn)
        spline.setTanOut(index, tanx: Math.sinr(radians: finalAngleStartOut) * finalStartLengthOut,
                         tany: -Math.cosr(radians: finalAngleStartOut) * finalStartLengthOut)
        spline.closed = false
        
        index = 0
        for i in 0..<BlobMotionControllerCrazy.loopCount {
            let loopTwistStart = loopTwistStartBase[i] + loopTwistStartRandom[i] * randomFactor
            var loopInflateStart = loopInflateStartBaseMin[i] + (loopInflateStartBaseMax[i] - loopInflateStartBaseMin[i]) * inflationFactor1
            loopInflateStart += loopInflateStartRandom[i] * randomFactor
            
            splineAlt.set(index, x: loopTwistStart * twistFactor, y: loopInflateStart)
            index += 1
            
            let loopTwistEnd = loopTwistEndBase[i] + loopTwistEndRandom[i] * randomFactor
            var loopInflateEnd = loopInflateEndBaseMin[i] + (loopInflateEndBaseMax[i] - loopInflateEndBaseMin[i]) * inflationFactor2
            loopInflateEnd += loopInflateEndRandom[i] * randomFactor
            
            splineAlt.set(index, x: loopTwistEnd * twistFactor, y: loopInflateEnd)
            index += 1
        }
        
        let finalLoopTwistStart = loopTwistStartBase[BlobMotionControllerCrazy.loopCount]
            + loopTwistStartRandom[BlobMotionControllerCrazy.loopCount] * randomFactor
        
        var finalLoopInflateStart =   loopInflateStartBaseMin[BlobMotionControllerCrazy.loopCount] + (loopInflateStartBaseMax[BlobMotionControllerCrazy.loopCount] - loopInflateStartBaseMin[BlobMotionControllerCrazy.loopCount]) * inflationFactor1
        finalLoopInflateStart += loopInflateStartRandom[BlobMotionControllerCrazy.loopCount] * randomFactor
        
        splineAlt.set(index, x: finalLoopTwistStart * twistFactor, y: finalLoopInflateStart)
        splineAlt.closed = false
    }
    
    override func drawMarkers() {
        super.drawMarkers()
        
        //let unitPos = spline.get(getPos())
        
        
        /*
        ShaderProgramSimple.shared.use()
        
        
        guard  let engine = ApplicationController.shared.engine else { return }
        
        let powerPercent: CGFloat = engine.animationPower
        let speedPercent: CGFloat = engine.animationSpeed
        let ellipseFactor: CGFloat = engine.animationRandom
        let inflateFactor: CGFloat = engine.animationInflateFactor
        
        let radius: CGFloat = dragFalloffDampenStart + (dragFalloffDampenResultMax - dragFalloffDampenStart) * powerPercent
        
        
        
        let c = center
        
        for i in 0..<spline.controlPointCount {
            let po = spline.getControlPoint(i)
            let p = CGPoint(x: po.x * radius + c.x, y: po.y * radius + c.y)
            
            ShaderProgramSimple.shared.colorSet(r: 0.0, g: 0.2, b: 0.2, a: 0.9)
            ShaderProgramSimple.shared.pointDraw(point: p, size: 14)
            
            ShaderProgramSimple.shared.colorSet(r: 0.5, g: 1.0, b: 0.2, a: 0.9)
            ShaderProgramSimple.shared.pointDraw(point: p, size: 9)
            
            
        }
        
        
        for i in 0..<spline.controlPointCount {
            let po = spline.getControlPoint(i)
            let p = CGPoint(x: po.x * radius + c.x, y: po.y * radius + c.y)
            
            let to = spline.getControlPointTanOut(i)
            let ti = spline.getControlPointTanIn(i)
            
            var t = CGPoint(x: p.x + to.x * radius * 0.25, y: p.y + to.y * radius * 0.25)
            
            ShaderProgramSimple.shared.colorSet(r: 0.0, g: 0.2, b: 0.2, a: 0.9)
            ShaderProgramSimple.shared.pointDraw(point: t, size: 8)
            
            ShaderProgramSimple.shared.colorSet(r: 1.0, g: 0.0, b: 0.25, a: 0.9)
            ShaderProgramSimple.shared.pointDraw(point: t, size: 5)
            
            
            ShaderProgramSimple.shared.lineDraw(p1: p, p2: t, thickness: 3.0)
            
            
            t = CGPoint(x: p.x + ti.x * radius * 0.25, y: p.y + ti.y * radius * 0.25)
            
            ShaderProgramSimple.shared.colorSet(r: 0.0, g: 0.2, b: 0.2, a: 0.9)
            ShaderProgramSimple.shared.pointDraw(point: t, size: 8)
            
            ShaderProgramSimple.shared.colorSet(r: 0.0, g: 0.9, b: 0.5, a: 0.9)
            ShaderProgramSimple.shared.pointDraw(point: t, size: 5)
            
            ShaderProgramSimple.shared.lineDraw(p1: p, p2: t, thickness: 3.0)
            
        }
        
        let step = CGFloat(0.025)
        var prevPoint = spline.get(0.0)
        let lastPoint = spline.get(spline.maxPos)
        
        for pos:CGFloat in stride(from: step, to: CGFloat(spline.maxPos), by: step) {
            let point = spline.get(pos)
            let p = CGPoint(x: point.x * radius + c.x, y: point.y * radius + c.y)

            ShaderProgramSimple.shared.colorSet(r: 0.33, g: 0.88, b: 0.33, a: 0.65)
            ShaderProgramSimple.shared.pointDraw(point: p, size: 4)
            
        }
        
        
        let poso = spline.get(getPos())
        let pos = CGPoint(x: poso.x * radius + c.x, y: poso.y * radius + c.y)
        
        ShaderProgramSimple.shared.colorSet(r: 1.0, g: 1.0, b: 1.0, a: 0.9)
        ShaderProgramSimple.shared.pointDraw(point: pos, size: 20)
        
        
        ShaderProgramSimple.shared.colorSet(r: 0.0, g: 0.0, b: 1.0, a: 0.9)
        ShaderProgramSimple.shared.pointDraw(point: pos, size: 16)
        
        
        //getControlPointTangent(
        
        
        ShaderProgramMesh.shared.use()
        
        
        //spline
        
        
        */
        
    }
}
















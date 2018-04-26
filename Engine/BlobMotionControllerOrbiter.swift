//
//  BlobMotionControllerOrbiter.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 6/14/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class BlobMotionControllerOrbiter: BlobMotionController {
    
    //The major axis for our ellipse.. Our animation target will "orbit"
    //about the center point in a rotated ellipse, based on a looping sine
    //function, such that we can easily control the speed and size of the
    //path of motion.
    var orbitMajorAxisRotation: CGFloat = 0.0
    
    //This will ALWAYS be a positive number, the orbiting point
    //essentially freely swings around its trajectory as long as
    //we are not grabbed. Higher speed for smaller radius and higher
    //bounce speed percent. Lower speed for larger radius and
    //higher bounce speed percent.
    var orbitMajorAxisRotationSpeed: CGFloat = 0.0
    
    //This will control clock-wise versus counter-clock-wise motion.
    //CCW (-1)    CW (1)   Everything in between gets smoothed over.
    var orbitDirectionFactor: CGFloat = 0.0
    
    //The actual orbiting object's rotatio (theta)
    var orbitRotation: CGFloat = 0.0
    
    var orbitRotationSpeed: CGFloat = 0.0
    
    //This is a very important number to tweak to the exact
    //right sweet spot - basically, we will stop rotations past the
    //cutoff (since the orbiting will already account for the effect
    //of the substantial rotation - we don't want to rotate at double
    //or half speed when we are doing intense flinging or device thrashing...)
    internal var orbitLockAxisRotationCutoffRatio: CGFloat = 0.60
    
    //Between the slow-down ratio and the cutoff ratio, we will slow down
    // the speed at which the orbit axis approaches the closest spoke.
    internal var orbitLockAxisRotationSlowdownRatio: CGFloat = 0.65
    
    //The radius of the ellipse along the major axis. The major axis
    //radius will always be >= the minor axis radius.
    var orbitMajorAxisRadius: CGFloat = 0.0
    
    var orbitMinorAxisFactor: CGFloat = 0.5
    
    var orbitDirection: Int = 1
    
    internal var orbitWidthHeightRatio: CGFloat = 0.5
    
    //Used as termination condition for stuff that requires a
    //decent bit of previous motion to start calculating..
    internal var guideHistoryDistanceSum: CGFloat = 0.0
    
    //The axis trackers are essentially 2 arms that point to
    internal var axisTrackerSpokeRotationSpeed: CGFloat = 0.0
    internal var axisTrackerSpoke1: CGFloat = 0.0
    internal var axisTrackerSpoke2: CGFloat = Math.PI
    
    //Based on animation guide history, the closest fitting rotation
    //that draws a line closest to all history points..
    internal var guideRotation:CGFloat = 0.0
    
    var inflateScaleSpeed: CGFloat = 0.0
    
    var twistRotationSpeed: CGFloat = 0.0
    
    internal var radiusDecayTicks: Int = 0
    
    //These are the transformed points, rotated such that they
    //are rotated by guideRotation (close as possible to a h or v bar)
    internal var animationGuideHistoryBestFit = [CGPoint]()
    
    internal var animationGuideDistanceSorted = [CGFloat]()
    
    internal var gyroHistoryCount: Int = 0
    internal var gyroHistorySize: Int = 29
    internal var gyroHistoryTop = [Bool]()
    internal var gyroHistoryRight = [Bool]()
    
    internal var gyroHistoryDir = [CGPoint]()
    
    internal var gyroDirectionSwapCountH: Int = 0
    internal var gyroDirectionSwapCountV: Int = 0
    
    //[0 .. 1] This is how "thrashy" our movement is.
    var wildFactor: CGFloat = 0.0
    
    //How long have we been in grab mode?
    private var consecutiveGrabbedTicks: Int = 0
    
    //When we are grabbed and registered at least one drag..
    private var didDrag: Bool = false
    
    //Distance between center and animationTargetOffset
    private var dragLength: CGFloat = 0.0
    
    var animationGuideOffset:CGPoint = CGPoint(x: 0.0, y: 0.0)
    var animationGuideVelocity:CGPoint = CGPoint(x: 0.0, y: 0.0)
    var animationGuideOffsetDistance: CGFloat = 0.0
    
    internal var animationGuideReleaseDir = CGPoint.zero
    internal var animationGuideReleaseSpeed: CGFloat = 0.0
    internal var animationGuideReleaseDecay: CGFloat = 0.0
    
    internal var finalReleasePoint = CGPoint.zero
    internal var finalRelease: Bool = false
    
    var animationGuideHistory = [CGPoint]()
    
    var animationGuideHistoryCount: Int = 0
    
    //The number of history ticks we want to store. Changing
    //this will effect the way some motion controllers behave.
    var animationGuideHistorySize: Int = 12
    
    override init() {
        
        super.init()
        
        for _ in 0..<(animationGuideHistorySize) {
            animationGuideHistoryBestFit.append(CGPoint(x: 0.0, y: 0.0))
            animationGuideDistanceSorted.append(0.0)
        }
        
        for _ in 0..<gyroHistorySize {
            gyroHistoryTop.append(false)
            gyroHistoryRight.append(false)
            gyroHistoryDir.append(CGPoint.zero)
        }
        
        for _ in 0..<(animationGuideHistorySize) {
            animationGuideHistory.append(CGPoint(x: 0.0, y: 0.0))
        }
        
    }
    
    override func update() {
        
        guard let engine = ApplicationController.shared.engine else { return}
        
        super.update()
        
        if isGrabbed {
            
            consecutiveGrabbedTicks += 1
            if consecutiveGrabbedTicks > 100000 { consecutiveGrabbedTicks = 100000 }
            
            let holdStillThreshold: Int = 8
            if consecutiveGrabbedTicks > 18 && animationGuideHistoryCount > holdStillThreshold {
                
                var maxDist: CGFloat = 0.0
                var averageDist: CGFloat = 0.0
                
                var prevPoint = animationGuideHistory[0]
                for i in 1..<holdStillThreshold {
                    let point = animationGuideHistory[i]
                    let diffX: CGFloat = point.x - prevPoint.x
                    let diffY: CGFloat = point.y - prevPoint.y
                    var dist: CGFloat = diffX * diffX + diffY * diffY
                    if dist > Math.epsilon { dist = CGFloat(sqrtf(Float(dist))) }
                    if dist > maxDist { maxDist = dist }
                    averageDist += dist
                    prevPoint = point
                }
                averageDist /= CGFloat(holdStillThreshold - 1)
                
                
                var maxDistThreshold: CGFloat = 8.0
                var averageDistThreshold: CGFloat = 4.0
                
                if Device.isTablet {
                    maxDistThreshold = 10.0
                    averageDistThreshold = 5.0
                }
                
                //If we haven't been moving our finger much.
                if maxDist <= maxDistThreshold && averageDist <= averageDistThreshold {
                    for i:Int in 1..<animationGuideHistoryCount {
                        animationGuideHistory[i] = animationGuideHistory[0]
                    }
                    
                    //Reset out consecutive grabs, we just "halt" at this one spot..
                    consecutiveGrabbedTicks = 0
                }
            }
        } else {
            consecutiveGrabbedTicks = 0
        }
        
        var diffX = -animationGuideOffset.x
        var diffY = -animationGuideOffset.y
        animationGuideOffsetDistance = diffX * diffX + diffY * diffY
        if animationGuideOffsetDistance > Math.epsilon {
            animationGuideOffsetDistance = CGFloat(sqrtf(Float(animationGuideOffsetDistance)))
            diffX /= animationGuideOffsetDistance
            diffY /= animationGuideOffsetDistance
        } else {
            diffX = 0.0
            diffY = 0.0
        }
        
        if isGrabbed == false {
            
            //Fizz down the release decay.
            animationGuideReleaseDecay *= 0.950
            animationGuideReleaseDecay -= 0.025
            if animationGuideReleaseDecay < 0.0 {
                animationGuideReleaseDecay = 0.0
            }
            
            let gyroDir = ApplicationController.shared.gyroDir
            
            //var gyroPercent = (gyroFactor - gyroFactorMin) / (gyroFactorMax - gyroFactorMin)
            //print("Gyro Factor: \(gyroFactor) Gyro Percent: \(gyroPercent)")
            
            //var targetGyroFactor = gyroFactorMin
            //if gyroDirectionSwapCountV >= 8 || gyroDirectionSwapCountH >= 8 {
            //    targetGyroFactor = gyroFactorMax
            //}
            
            //if gyroFactor < targetGyroFactor {
            //    gyroFactor += (targetGyroFactor - gyroFactor) / 16.0
            //    gyroFactor += 0.099
            
            let releaseFactor: CGFloat = (1.0 - animationGuideReleaseDecay)
            let speedDecay: CGFloat = 0.9425
            
            animationGuideVelocity.x *= speedDecay
            animationGuideVelocity.y *= speedDecay
            
            animationGuideVelocity.x += diffX * animationGuideOffsetDistance * 0.2
            animationGuideVelocity.y += diffY * animationGuideOffsetDistance * 0.2
            
            animationGuideOffset.x += animationGuideVelocity.x * releaseFactor
            animationGuideOffset.y += animationGuideVelocity.y * releaseFactor
            
            //gyro
            //BounceEngine
            if engine.gyro {
                let gyroFactor: CGFloat = 1.75
                animationGuideVelocity.x += gyroDir.x * gyroFactor
                animationGuideVelocity.y += gyroDir.y * gyroFactor
            }
            
            if animationGuideReleaseDecay > 0.0 && animationGuideReleaseSpeed > 0.0 {
                animationGuideOffset.x += animationGuideReleaseDir.x * animationGuideReleaseSpeed * animationGuideReleaseDecay
                animationGuideOffset.y += animationGuideReleaseDir.y * animationGuideReleaseSpeed * animationGuideReleaseDecay
            }
            
            recordAnimationGuideHistory()
            updateAnimationGuide(moving: true)
            
        } else {
            cancelAnimationGuideMotion()
            if didDrag {
                recordAnimationGuideHistory()
                updateAnimationGuide(moving: false)
            }
        }
        
        if isGrabbed {
            
            gyroHistoryCount = 0
            
            gyroDirectionSwapCountH = 0
            gyroDirectionSwapCountV = 0
            
            var offsetDir = CGPoint(x: animationGuideOffset.x, y: animationGuideOffset.y)
            var offSetLength: CGFloat = animationGuideOffset.x * animationGuideOffset.x + animationGuideOffset.y * animationGuideOffset.y
            if offSetLength > Math.epsilon {
                offSetLength = CGFloat(sqrtf(Float(offSetLength)))
                offsetDir = CGPoint(x: offsetDir.x / offSetLength, y: offsetDir.y / offSetLength)
            }
            
            radiusDecayTicks = 0
            
            //Offset length is dampened.
            offSetLength = BounceEngine.fallOffDampen(input: offSetLength, falloffStart: dragFalloffDampenStart, resultMax: dragFalloffDampenResultMax, inputMax: dragFalloffDampenInputMax)
            animationTargetOffset = CGPoint(x: offsetDir.x * offSetLength, y: offsetDir.y * offSetLength)
            
            orbitMajorAxisRadius = offSetLength
            
            orbitMajorAxisRotation = Math.faceTarget(target: animationTargetOffset)
            axisTrackerSpoke1 = orbitMajorAxisRotation
            axisTrackerSpoke2 = Math.constrainAngle(radians: axisTrackerSpoke1 + Math.PI)
            
            orbitRotation = 0.0
        } else {
            
            twistRotationSpeed -= twistRotation * 0.0925
            twistRotation *= 0.9425
            twistRotation += twistRotationSpeed
            
            var adjustedInflateScale: CGFloat = (inflateScale - 1.0)
            inflateScaleSpeed -= adjustedInflateScale * 0.08965
            adjustedInflateScale *= 0.9425
            adjustedInflateScale += inflateScaleSpeed
            inflateScale = (adjustedInflateScale + 1.0)
            
            updateOrbitRadius()
            
            //If the blobs sit idle for long enough, synchronize the orbit rotations.
            let idleStopOrbitingTime: Int = 34
            if radiusDecayTicks > idleStopOrbitingTime {
                orbitRotation = 0.0
            }
            
            //If we have too round of an orbit, the major axis rotation loses its effect,
            //se we stop rotating the axis. (Otherwise there will be some weirdness in the motion)
            if orbitWidthHeightRatio < orbitLockAxisRotationCutoffRatio {
                updateOrbitTrackerSpokes()
                updateOrbitMajorAxisRotation()
            }
        }
        
        guideHistoryDistanceSum = 0.0
        for i in 0..<animationGuideHistoryCount {
            let point = animationGuideHistory[i]
            guideHistoryDistanceSum += point.x * point.x + point.y * point.y
        }
        
        computeAnimationGuideRotation()
        updateBestFitHistory()
        updateOrbitAxisFactor()
        computeOrbitDirection()
        updateOrbitDirectionFactor()
        updateOrbitRotationSpeed()
        
        if isGrabbed == false {
            orbitRotation = Math.loopAngle(radians: orbitRotation, amount: orbitRotationSpeed)
            animationTargetOffset = ellipsePoint(radians: orbitRotation, considerDirectionFactor: true)
        }
        
        var wildness: Int = 0
        
        if isGrabbed == false {
            
            let gyroDir = ApplicationController.shared.gyroDir
            
            if guideHistoryDistanceSum < 64.0 {
                gyroDirectionSwapCountV = 0
                gyroDirectionSwapCountH = 0
                gyroHistoryCount = 0
            } else {
                recordGyroDirectionHistory(gyroDir)
                computeGyroDirectionSwapSpeedFactor()
            }
            
            if gyroDirectionSwapCountV >= 8 || gyroDirectionSwapCountH >= 8 {
                if animationGuideHistoryCount > 2 {
                    var dist1 = animationGuideDistanceSorted[animationGuideHistoryCount - 1]
                    var dist2 = animationGuideDistanceSorted[animationGuideHistoryCount - 2]
                    var dist3 = animationGuideDistanceSorted[animationGuideHistoryCount - 3]
                    
                    if dist1 > Math.epsilon { dist1 = CGFloat(sqrtf(Float(dist1))) }
                    if dist2 > Math.epsilon { dist2 = CGFloat(sqrtf(Float(dist2))) }
                    if dist3 > Math.epsilon { dist3 = CGFloat(sqrtf(Float(dist3))) }
                    
                    let distAverage: CGFloat = (dist1 + dist2 + dist3) / 3.0
                    
                    var wildThrashingDistanceThreshold:CGFloat = 18.0
                    if Device.isTablet { wildThrashingDistanceThreshold = 24.0 }
                    
                    if distAverage > wildThrashingDistanceThreshold {
                        if gyroDirectionSwapCountV >= 10 || gyroDirectionSwapCountH >= 10 {
                            wildness = 4
                        } else {
                            wildness = 3
                        }
                    }
                }
            }
        }
        
        let targetWildFactor: CGFloat = CGFloat(wildness) / CGFloat(4.0)
        if wildFactor > targetWildFactor {
            wildFactor -= (wildFactor - targetWildFactor) / 36.0
            wildFactor -= 0.02
            if wildFactor < targetWildFactor { wildFactor = targetWildFactor }
        } else if targetWildFactor > wildFactor {
            wildFactor += (targetWildFactor - wildFactor) / 36.0
            wildFactor += 0.02
            if wildFactor > targetWildFactor { wildFactor = targetWildFactor }
        }
    }
    
    override func reset(alt: Bool) {
        super.reset(alt: alt)
        
        cancelAnimationGuideMotion()
        
        animationGuideHistoryCount = 0
        didDrag = false
        dragLength = 0.0
        
        animationGuideOffset = CGPoint.zero
        
        orbitRotation = 0.0
        orbitMajorAxisRadius = 0.0
        orbitMinorAxisFactor = 0.5
        orbitRotationSpeed = 0.0
        orbitWidthHeightRatio = 0.5
    }
    
    func drag(withGuideOffset newOffset: CGPoint) {
        
        didDrag = true
        animationGuideOffset = CGPoint(x: newOffset.x, y: newOffset.y)
        
        var offsetDir = newOffset
        var offSetLength: CGFloat = newOffset.x * newOffset.x + newOffset.y * newOffset.y
        if offSetLength > Math.epsilon {
            offSetLength = CGFloat(sqrtf(Float(offSetLength)))
            offsetDir = CGPoint(x: offsetDir.x / offSetLength, y: offsetDir.y / offSetLength)
        }
        offSetLength = BounceEngine.fallOffDampen(input: offSetLength, falloffStart: dragFalloffDampenStart, resultMax: dragFalloffDampenResultMax, inputMax: dragFalloffDampenInputMax)
        animationTargetOffset = CGPoint(x: offsetDir.x * offSetLength, y: offsetDir.y * offSetLength)
        dragLength = offSetLength
    }
    
    func ellipsePoint(radians rotation: CGFloat, considerDirectionFactor: Bool) -> CGPoint {
        let directionBase = Math.angleToVector(radians: rotation)
        
        var result = CGPoint(x: 0.0, y: directionBase.y * orbitMajorAxisRadius)
        
        if considerDirectionFactor {
            result.x = directionBase.x * orbitMinorAxisFactor * orbitMajorAxisRadius * orbitDirectionFactor
        } else {
            result.x = directionBase.x * orbitMinorAxisFactor * orbitMajorAxisRadius
        }
        
        return Math.rotatePoint(point: result, radians: orbitMajorAxisRotation)
    }
    
    
    func updateOrbitTrackerSpokes() {
        
        let angleDistance1 = Math.distanceBetweenAngles(radians1: axisTrackerSpoke1, radians2: guideRotation)
        let angleDistance2 = Math.distanceBetweenAngles(radians1: axisTrackerSpoke2, radians2: guideRotation)
        
        //let angleSwivelFactor: CGFloat = 0.0945
        let angleSwivelFactor: CGFloat = 0.1105
        
        if fabsf(Float(angleDistance1)) < fabsf(Float(angleDistance2)) {
            axisTrackerSpoke1 += angleDistance1 * angleSwivelFactor
            axisTrackerSpoke2 = Math.loopAngle(radians: axisTrackerSpoke1, amount: Math.PI)
        } else {
            axisTrackerSpoke2 += angleDistance2 * angleSwivelFactor
            axisTrackerSpoke1 = Math.loopAngle(radians: axisTrackerSpoke2, amount: -Math.PI)
        }
    }
    
    func updateOrbitDirectionFactor() {
        
        var measuredOrbitDirectionFactor: CGFloat = orbitDirectionFactor
        
        if orbitDirection == -1 {
            measuredOrbitDirectionFactor = -1.0
        } else if orbitDirection == 1 {
            measuredOrbitDirectionFactor = 1.0
        }
        
        if isGrabbed {
            orbitDirectionFactor = measuredOrbitDirectionFactor
        } else {
            if orbitDirectionFactor > measuredOrbitDirectionFactor {
                orbitDirectionFactor -= (orbitDirectionFactor - measuredOrbitDirectionFactor) / 28.0
                orbitDirectionFactor -= 0.08
                if orbitDirectionFactor < measuredOrbitDirectionFactor {
                    orbitDirectionFactor = measuredOrbitDirectionFactor
                }
            } else if orbitDirectionFactor < measuredOrbitDirectionFactor {
                orbitDirectionFactor += (measuredOrbitDirectionFactor - orbitDirectionFactor) / 28.0
                orbitDirectionFactor += 0.08
                if orbitDirectionFactor > measuredOrbitDirectionFactor {
                    orbitDirectionFactor = measuredOrbitDirectionFactor
                }
            }
        }
    }
    
    func updateOrbitMajorAxisRotation() {
        
        let angleDiff1: CGFloat = Math.distanceBetweenAngles(radians1: orbitMajorAxisRotation, radians2: axisTrackerSpoke1)
        let angleDiff2: CGFloat = Math.distanceBetweenAngles(radians1: orbitMajorAxisRotation, radians2: axisTrackerSpoke2)
        
        var spokeRotation: CGFloat = 0.0
        var angleDiff: CGFloat = 0.0
        
        if fabsf(Float(angleDiff1)) < fabsf(Float(angleDiff2)) {
            //using spoke 1, and angular difference 1
            spokeRotation = axisTrackerSpoke1
            angleDiff = angleDiff1
        } else {
            //using spoke 2, and angular difference 2
            spokeRotation = axisTrackerSpoke2
            angleDiff = angleDiff2
        }
        
        let rotFixedStep: CGFloat = 0.010125
        var rot: CGFloat = orbitMajorAxisRotation
        
        let lockWiggleThreshold: CGFloat = 0.06
        
        if CGFloat(fabsf(Float(angleDiff))) > lockWiggleThreshold {
            if angleDiff < 0 {
                while rot < spokeRotation { rot += Math.PI2 }
                while rot > (spokeRotation + Math.PI2) { rot -= Math.PI2 }
                rot += angleDiff / 16.0
                rot -= rotFixedStep
                if rot < spokeRotation { rot = spokeRotation }
            } else if angleDiff > 0 {
                while rot > spokeRotation { rot -= Math.PI2 }
                while rot < (spokeRotation - Math.PI2) { rot += Math.PI2 }
                rot += angleDiff / 16.0
                rot += rotFixedStep
                if rot > spokeRotation { rot = spokeRotation }
            }
        }
        orbitMajorAxisRotation = Math.constrainAngle(radians: rot)
    }
    
    func updateOrbitRadius() {
        let samplePointCount: Int = 5
        guard animationGuideHistoryCount >= samplePointCount else { return }
        
        for i in 0..<animationGuideHistoryCount {
            let point = animationGuideHistory[i]
            let px: CGFloat = point.x
            let py: CGFloat = point.y
            animationGuideDistanceSorted[i] = px * px + py * py
        }
        
        var j: Int = 0
        var hold: CGFloat = 0.0
        for i: Int in 0..<animationGuideHistoryCount {
            j = i
            while j > 0 && animationGuideDistanceSorted[j] < animationGuideDistanceSorted[j-1] {
                hold = animationGuideDistanceSorted[j]
                animationGuideDistanceSorted[j] = animationGuideDistanceSorted[j-1]
                animationGuideDistanceSorted[j-1] = hold
                j -= 1
            }
        }
        
        var distanceSum: CGFloat = 0.0
        
        for i in (animationGuideHistoryCount - samplePointCount)..<animationGuideHistoryCount {
            var dist = animationGuideDistanceSorted[i]
            dist = CGFloat(sqrtf(Float(dist)))
            distanceSum += dist
        }
        
        //We sample some of the longer distances and average them together.
        var measuredOrbitRadius: CGFloat = distanceSum / CGFloat(samplePointCount)
        
        if let engine = ApplicationController.shared.engine {
            let minRadius = measuredOrbitRadius * 0.75
            let maxRadius = measuredOrbitRadius * 1.25
            measuredOrbitRadius = minRadius + (maxRadius - minRadius) * engine.animationPower
        }
        
        //We are shaking the device violently! Double the radius!
        if wildFactor > 0.0 {
            measuredOrbitRadius += (measuredOrbitRadius * wildFactor)
        }
        
        //The radius is then dampened.
        measuredOrbitRadius = BounceEngine.fallOffDampen(input: measuredOrbitRadius, falloffStart: dragFalloffDampenStart, resultMax: dragFalloffDampenResultMax, inputMax: dragFalloffDampenInputMax)
        
        if isGrabbed {
            orbitMajorAxisRadius = measuredOrbitRadius
        } else {
            
            //Ease the radius to the measured radius.
            //(The measured radius generally reduces in
            //a stepping fashion, so we smooth over the
            //inconsistencies and keep the motion fluid).
            var radiusDecayThreshold: CGFloat = 3.0
            let radiusIncrementUpstep: CGFloat = 1.3
            let radiusIncrementDownstep: CGFloat = 1.15
            
            if Device.isTablet { radiusDecayThreshold = 5.0 }
            if measuredOrbitRadius < radiusDecayThreshold {
                orbitMajorAxisRadius *= 0.96
                orbitMajorAxisRadius -= 0.085
                if orbitMajorAxisRadius < 0.0 { orbitMajorAxisRadius = 0.0 }
                if measuredOrbitRadius < (radiusDecayThreshold * 0.4) {
                    radiusDecayTicks += 1
                    if radiusDecayTicks > 1000 { radiusDecayTicks = 1000 }
                } else {
                    radiusDecayTicks = 0
                }
            } else {
                radiusDecayTicks = 0
                if orbitMajorAxisRadius < measuredOrbitRadius {
                    let radiusDiff: CGFloat = (measuredOrbitRadius - orbitMajorAxisRadius)
                    orbitMajorAxisRadius += radiusDiff / 12.0
                    orbitMajorAxisRadius += radiusIncrementUpstep
                    if orbitMajorAxisRadius > measuredOrbitRadius { orbitMajorAxisRadius = measuredOrbitRadius }
                } else if orbitMajorAxisRadius > measuredOrbitRadius {
                    let radiusDiff: CGFloat = (orbitMajorAxisRadius - measuredOrbitRadius)
                    orbitMajorAxisRadius -= radiusDiff / 14.0
                    orbitMajorAxisRadius -= radiusIncrementDownstep
                    if orbitMajorAxisRadius < measuredOrbitRadius { orbitMajorAxisRadius = measuredOrbitRadius }
                }
            }
        }
    }
    
    var previousMeasuredOrbitDirection: Int = 0
    var consecutiveMeasuredOrbitDirectionTicks: Int = 0
    
    func computeOrbitDirection() {
        if animationGuideHistoryCount < 2 { return }
        if guideHistoryDistanceSum < 64.0 { return }
        
        var index1 = 0
        var index2 = 1
        var crossSum: CGFloat = 0.0
        while index2 < animationGuideHistoryCount {
            if Math.distSquared(p1: animationGuideHistory[index1], p2: animationGuideHistory[index2]) > 2.0 {
                crossSum += Math.crossProduct(p1: animationGuideHistory[index1], p2: animationGuideHistory[index2])
                index1 = index2
            }
            index2 += 1
        }
        
        var measuredDirection: Int = 0
        let crossSumThreshold:CGFloat = 1500.0
        if crossSum < -crossSumThreshold { measuredDirection = -1 }
        if crossSum > crossSumThreshold { measuredDirection = 1 }
        
        if isGrabbed {
            if measuredDirection != 0 {
                consecutiveMeasuredOrbitDirectionTicks = 20
                orbitDirection = measuredDirection
                previousMeasuredOrbitDirection = measuredDirection
            }
        } else {
            if measuredDirection == 0 {
                consecutiveMeasuredOrbitDirectionTicks = 0
                previousMeasuredOrbitDirection = orbitDirection
            } else {
                if measuredDirection == previousMeasuredOrbitDirection {
                    consecutiveMeasuredOrbitDirectionTicks += 1
                    if consecutiveMeasuredOrbitDirectionTicks >= 20 {
                        consecutiveMeasuredOrbitDirectionTicks = 20
                        orbitDirection = measuredDirection
                    }
                } else {
                    consecutiveMeasuredOrbitDirectionTicks = 0
                }
                previousMeasuredOrbitDirection = measuredDirection
            }
        }
    }
    
    func computeAnimationGuideRotation() {
        
        //This computes a "best fitting line" that passes through the origin
        //and comes as close as possible to as many points as possible.
        
        //It is different from standard "line of best fit" computations,
        //especially when points are clustered along the Y axis.
        
        if animationGuideHistoryCount > 2 {
            
            //If all the distances are tiny, we are hovering near the origin,
            //so don't bother continuing. (It will flicker uncontrollably)
            //var totalDistance: CGFloat = 0.0
            //for i in 0..<animationGuideHistoryCount {
            //    let point = animationGuideHistory[i]
            //    totalDistance += point.x * point.x + point.y * point.y
            //}
            
            if guideHistoryDistanceSum < 64.0 { return }
            
            //Exhaustively find the rotation for which
            //the sum of the distances to all points
            //is minimized...
            var bestRotation: CGFloat = 0.0
            var tryRotation: CGFloat = 0.0
            var bestDistanceSum: CGFloat = 999999999000000000000000000.0
            
            //Loop through 1/2 circle.
            while tryRotation < Math.PI {
                
                //Make a line segment that passes through the origin..
                let dir = Math.angleToVector(radians: tryRotation)
                let spokeLength: CGFloat = 100.0
                let pointStart = CGPoint(x: -dir.x * spokeLength, y: -dir.y * spokeLength)
                let pointEnd = CGPoint(x: dir.x * spokeLength, y: dir.y * spokeLength)
                
                //Compute distance between all points and our line segment.
                //var lineLength = lineDiffX * lineDiffX + lineDiffY * lineDiffY
                //lineLength = CGFloat(sqrtf(Float(lineLength)))
                let lineLength = spokeLength + spokeLength
                
                //let lineDiffX = dir.x//(pointEnd.x - pointStart.x) / lineLength
                //let lineDiffY = dir.y//(pointEnd.y - pointStart.y) / lineLength
                
                var distanceSum: CGFloat = 0.0
                for i in 0..<animationGuideHistoryCount {
                    let point = animationGuideHistory[i]
                    var closestPoint = CGPoint(x: pointStart.x, y: pointStart.y)
                    
                    //Project the point onto the line...
                    let projX = (point.x - pointStart.x)
                    let projY = (point.y - pointStart.y)
                    let scalar = dir.x * projX + dir.y * projY
                    if scalar < 0.0 {
                        //Trim to pointStart
                        closestPoint.x = pointStart.x
                        closestPoint.y = pointStart.y
                    } else if scalar > lineLength {
                        //Trim to pointEnd
                        closestPoint.x = pointEnd.x
                        closestPoint.y = pointEnd.y
                    } else {
                        //Closest point is between pointStart and pointEnd
                        closestPoint.x = pointStart.x + dir.x * scalar
                        closestPoint.y = pointStart.y + dir.y * scalar
                    }
                    
                    //Find the distance of the closest point to the
                    //line segment.
                    let diffX: CGFloat = closestPoint.x - point.x
                    let diffY: CGFloat = closestPoint.y - point.y
                    var distance = diffX * diffX + diffY * diffY
                    
                    //Note: Results will be skewed from outliars if we
                    //do not square root them. This is expensive, but
                    //necessary to prevent excess rotational "skipping"..
                    if distance > Math.epsilon { distance = CGFloat(sqrtf(Float(distance))) }
                    
                    //Add to the sum of all distances.
                    distanceSum += distance
                }
                
                //If the sum of all distances of smaller than before,
                //we have a better fitting line, so hang on to it..
                if distanceSum < bestDistanceSum {
                    bestDistanceSum = distanceSum
                    bestRotation = tryRotation
                }
                tryRotation += 0.02454369
            }
            //Joy, we have our best fitting rotation.
            guideRotation = bestRotation
        }
    }
    
    func recordAnimationGuideHistory() {
        //Update the history of the animation guide. This will be used to calculate
        //"direction" of movement and "width" (straight line up and down? circular?)
        if animationGuideHistoryCount < animationGuideHistorySize {
            animationGuideHistory[animationGuideHistoryCount].x = animationGuideOffset.x
            animationGuideHistory[animationGuideHistoryCount].y = animationGuideOffset.y
            animationGuideHistoryCount += 1
            
        } else {
            for i in 1..<animationGuideHistorySize {
                animationGuideHistory[i-1].x = animationGuideHistory[i].x
                animationGuideHistory[i-1].y = animationGuideHistory[i].y
            }
            animationGuideHistory[animationGuideHistorySize - 1].x = animationGuideOffset.x
            animationGuideHistory[animationGuideHistorySize - 1].y = animationGuideOffset.y
        }
    }
    
    
    func cancelAnimationGuideMotion() {
        animationGuideVelocity = CGPoint.zero
        animationGuideReleaseDir = CGPoint.zero
        animationGuideReleaseSpeed = 0.0
    }
    
    func updateAnimationGuide(moving: Bool) {
        
    }
    
    func captureFinalRelease(point: CGPoint) {
        finalRelease = true
        finalReleasePoint = CGPoint(x: point.x, y: point.y)
    }
    
    func resetFinalRelease() {
        finalRelease = false
    }
    
    func releaseGrabFling() {
        
        animationGuideVelocity = CGPoint.zero
        animationGuideReleaseSpeed = 0.0
        
        animationGuideReleaseDir = CGPoint.zero
        animationGuideReleaseSpeed = 0.0
        animationGuideReleaseDecay = 0.0
        
        if animationGuideHistoryCount > 1 {
            
            let lastPoint = animationGuideHistory[animationGuideHistoryCount - 1]
            
            //So, if we have one extra data point to tack on to the end
            //of our history, add it on (if it's not a duplicate of most recent recorded point...)
            if finalRelease {
                let finalReleaseDist = Math.distSquared(p1: finalReleasePoint, p2: lastPoint)
                if finalReleaseDist > 4.0 {
                    recordAnimationGuideHistory()
                    animationGuideHistory[animationGuideHistoryCount - 1].x = finalReleasePoint.x
                    animationGuideHistory[animationGuideHistoryCount - 1].y = finalReleasePoint.y
                }
            }
            
            var threshDist: CGFloat = 6.0
            if Device.isTablet {
                threshDist = 8.0
            }
            
            //Distance squared..
            threshDist *= threshDist
            
            let finalPoint = animationGuideHistory[animationGuideHistoryCount - 1]
            var stepBackCount: Int = 1
            
            for i in 1..<(animationGuideHistoryCount - 1) {
                
                let checkPoint = animationGuideHistory[animationGuideHistoryCount - (i + 1)]
                var diffX = finalPoint.x - checkPoint.x
                var diffY = finalPoint.y - checkPoint.y
                var dist = diffX * diffX + diffY * diffY
                
                if dist > threshDist {
                    
                    dist = CGFloat(sqrtf(Float(dist)))
                    
                    diffX /= dist
                    diffY /= dist
                    
                    var maxReleaseSpeed:CGFloat = 52.0
                    if Device.isTablet == false { maxReleaseSpeed = 39.0 }
                    
                    let stepBackFactor: CGFloat = CGFloat(sqrtf(Float(stepBackCount)))
                    var releaseSpeed: CGFloat = dist / stepBackFactor
                    
                    if releaseSpeed > maxReleaseSpeed { releaseSpeed = maxReleaseSpeed }
                    
                    animationGuideReleaseDir = CGPoint(x: diffX, y: diffY)
                    animationGuideReleaseSpeed = releaseSpeed
                    animationGuideReleaseDecay = 1.0
                    
                    return
                }
                stepBackCount += 1
            }
        }
    }
    
    
    func updateBestFitHistory() {
        guard animationGuideHistoryCount >= 1 else {
            return
        }
        var sumY: CGFloat = 0.0
        for i in 0..<animationGuideHistoryCount {
            let point = animationGuideHistory[i]
            let rotatedPoint = Math.rotatePoint(point: point, radians: -guideRotation)
            sumY += rotatedPoint.y
            animationGuideHistoryBestFit[i] = CGPoint(x: rotatedPoint.x, y: rotatedPoint.y)
        }
    }
    
    func updateOrbitAxisFactor() {
        
        guard animationGuideHistoryCount >= 6 else { return }
        
        var guideMinX: CGFloat = animationGuideHistoryBestFit[0].x
        var guideMinY: CGFloat = animationGuideHistoryBestFit[0].y
        var guideMaxX: CGFloat = guideMinX
        var guideMaxY: CGFloat = guideMinY
        
        for i in 1..<animationGuideHistoryCount {
            let point = animationGuideHistoryBestFit[i]
            if point.x < guideMinX { guideMinX = point.x }
            if point.x > guideMaxX { guideMaxX = point.x }
            if point.y < guideMinY { guideMinY = point.y }
            if point.y > guideMaxY { guideMaxY = point.y }
            
            //Experimental: 
            //Elongate the ellipse by also factoring in the flipped point.
            //This will exaggerate the narrowness of narrow orbits and have
            //no effect on more circular orbits..
            
            let flipPoint = CGPoint(x: -point.x, y: -point.y)
            if flipPoint.x < guideMinX { guideMinX = flipPoint.x }
            if flipPoint.x > guideMaxX { guideMaxX = flipPoint.x }
            if flipPoint.y < guideMinY { guideMinY = flipPoint.y }
            if flipPoint.y > guideMaxY { guideMaxY = flipPoint.y }
            
        }
        
        let bestFitSpanX: CGFloat = guideMaxX - guideMinX
        let bestFitSpanY: CGFloat = guideMaxY - guideMinY
        
        //Constrain orbitWidthHeightRatio to [0 .. 1].
        //The smaller range divided by the larger range..
        
        var measuredOrbitWidthHeightRatio: CGFloat = orbitWidthHeightRatio
        
        if bestFitSpanY > 4.0 || bestFitSpanX > 4.0  {
            if bestFitSpanY > bestFitSpanX {
                measuredOrbitWidthHeightRatio = bestFitSpanX / bestFitSpanY
            } else {
                measuredOrbitWidthHeightRatio = bestFitSpanY / bestFitSpanX
            }
        }
        
        if isGrabbed {
            orbitWidthHeightRatio = measuredOrbitWidthHeightRatio
        } else {
            if orbitWidthHeightRatio > measuredOrbitWidthHeightRatio {
                orbitWidthHeightRatio -= (orbitWidthHeightRatio - measuredOrbitWidthHeightRatio) / 14.0
            } else if orbitWidthHeightRatio < measuredOrbitWidthHeightRatio {
                orbitWidthHeightRatio += (measuredOrbitWidthHeightRatio - orbitWidthHeightRatio) / 14.0
            }
        }
        
        //A very small ratio is 0, this will prevent some unsightly
        //bob & weave for nearly straight line bouncing...
        let noiseFloor: CGFloat = 0.065
        
        var percent: CGFloat = (orbitWidthHeightRatio - noiseFloor) / (orbitLockAxisRotationCutoffRatio - noiseFloor)
        if percent < 0.0 { percent = 0.0 }
        if percent > 1.0 { percent = 1.0 }
        
        orbitMinorAxisFactor = sin(percent * Math.PI_2)
    }
    
    
    func updateOrbitRotationSpeed() {
        
        guard let engine = ApplicationController.shared.engine else { return }
        
        let minSizeSpeedFalloffCap: CGFloat = dragFalloffDampenResultMax * 0.1
        
        var sizeFactor: CGFloat = (orbitMajorAxisRadius - minSizeSpeedFalloffCap) / (dragFalloffDampenResultMax - minSizeSpeedFalloffCap)
        if sizeFactor < 0.0 { sizeFactor = 0.0 }
        if sizeFactor > 1.0 { sizeFactor = 1.0 }
        
        let csSmallMin: CGFloat = ApplicationController.shared.cycleSpeedSmallMin
        let csSmallMax: CGFloat = ApplicationController.shared.cycleSpeedSmallMax
        let csLargeMin: CGFloat = ApplicationController.shared.cycleSpeedLargeMin
        let csLargeMax: CGFloat = ApplicationController.shared.cycleSpeedLargeMax
        
        let targetOrbitRotationSpeedMin: CGFloat = csSmallMin + (csLargeMin - csSmallMin) * sizeFactor
        let targetOrbitRotationSpeedMax: CGFloat = csSmallMax + (csLargeMax - csSmallMax) * sizeFactor
        
        let speedFactor: CGFloat = engine.animationSpeed
        
        var targetOrbitRotationSpeed = targetOrbitRotationSpeedMin + (targetOrbitRotationSpeedMax - targetOrbitRotationSpeedMin) * speedFactor
        if wildFactor > 0.0 {
            targetOrbitRotationSpeed += wildFactor * targetOrbitRotationSpeed * 0.66
        }
        
        if isGrabbed {
            orbitRotationSpeed = targetOrbitRotationSpeed
        } else {
            if orbitRotationSpeed > targetOrbitRotationSpeed {
                orbitRotationSpeed += 0.01
                orbitRotationSpeed += (orbitRotationSpeed - targetOrbitRotationSpeed) / 15.0
                if orbitRotationSpeed > targetOrbitRotationSpeed { orbitRotationSpeed = targetOrbitRotationSpeed }
            } else if orbitRotationSpeed < targetOrbitRotationSpeed {
                
            }
            orbitRotationSpeed = targetOrbitRotationSpeed
        }
    }
    
    
    func recordGyroDirectionHistory(_ gyroDir: CGPoint) {
        
        let top: Bool = gyroDir.y < 0.0
        let right: Bool = gyroDir.x >= 0.0
        
        //Update the history of the animation guide. This will be used to calculate
        //"direction" of movement and "width" (straight line up and down? circular?)
        if gyroHistoryCount < gyroHistorySize {
            gyroHistoryTop[gyroHistoryCount] = top
            gyroHistoryRight[gyroHistoryCount] = right
            gyroHistoryDir[gyroHistoryCount].x = gyroDir.x
            gyroHistoryDir[gyroHistoryCount].y = gyroDir.y
            gyroHistoryCount += 1
        } else {
            for i in 1..<gyroHistorySize {
                gyroHistoryTop[i-1] = gyroHistoryTop[i]
                gyroHistoryRight[i-1] = gyroHistoryRight[i]
                
                gyroHistoryDir[i-1].x = gyroHistoryDir[i].x
                gyroHistoryDir[i-1].y = gyroHistoryDir[i].y
            }
            gyroHistoryTop[gyroHistorySize - 1] = top
            gyroHistoryRight[gyroHistorySize - 1] = right
            gyroHistoryDir[gyroHistorySize - 1].x = gyroDir.x
            gyroHistoryDir[gyroHistorySize - 1].y = gyroDir.y
        }
    }
    
    func computeGyroDirectionSwapSpeedFactor() {
        
        guard gyroHistoryCount >= 3 else {
            return
        }
        
        var prevDirV: Bool = false
        var prevDirH: Bool = false
        
        let jerkThreshold: CGFloat = 2.5
        
        var hIndex: Int = 0
        var vIndex: Int = 0
        
        gyroDirectionSwapCountH = 0
        
        while hIndex < gyroHistoryCount {
            var d = gyroHistoryDir[hIndex].x
            if d < 0 { d = -d }
            if d > jerkThreshold {
                prevDirH = gyroHistoryRight[hIndex]
                gyroDirectionSwapCountH = 1
                break
            }
            hIndex += 1
        }
        
        while hIndex < gyroHistoryCount {
            var d = gyroHistoryDir[hIndex].x
            if d < 0 { d = -d }
            if d > jerkThreshold {
                
                if gyroHistoryRight[hIndex] != prevDirH {
                    prevDirH = !prevDirH
                    gyroDirectionSwapCountH += 1
                }
            }
            hIndex += 1
        }
        
        while vIndex < gyroHistoryCount {
            var d = gyroHistoryDir[vIndex].y
            if d < 0 { d = -d }
            if d > jerkThreshold {
                prevDirV = gyroHistoryTop[vIndex]
                gyroDirectionSwapCountV = 1
                break
            }
            vIndex += 1
        }
        
        while vIndex < gyroHistoryCount {
            var d = gyroHistoryDir[vIndex].y
            if d < 0 { d = -d }
            if d > jerkThreshold {
                
                if gyroHistoryTop[vIndex] != prevDirV {
                    prevDirV = !prevDirV
                    gyroDirectionSwapCountV += 1
                }
            }
            vIndex += 1
        }
    }
    
    override func drawMarkers() {
        
        /*
         
         super.drawMarkers()
         
         
         
         //Animation Guide Rotation...
         //(Computed, Changed Rapidly)
         
         
         if true {
         ShaderProgramSimple.shared.use()
         let dir = Math.angleToVector(radians: guideRotation)
         let start = CGPoint(x: center.x + dir.x * 600.0, y: center.y + dir.y * 600.0)
         let end = CGPoint(x: center.x - dir.x * 600.0, y: center.y - dir.y * 600.0)
         ShaderProgramSimple.shared.colorSet(r: 0.5, g: 1.0, b: 1.0, a: 1.5)
         ShaderProgramSimple.shared.lineDraw(p1: start, p2: end, thickness: 0.25)
         ShaderProgramMesh.shared.use()
         }
         
         
         
         if true {
         ShaderProgramSimple.shared.use()
         let bestDir = Math.angleToVector(radians: guideRotation)
         let p0 = CGPoint(x: center.x, y: center.y)
         let p1 = CGPoint(x: center.x + bestDir.x * 300.0, y: center.y + bestDir.y * 300.0)
         let p2 = CGPoint(x: center.x - bestDir.x * 300.0, y: center.y - bestDir.y * 300.0)
         ShaderProgramSimple.shared.colorSet(r: 0.3, g: 0.3, b: 0.3, a: 0.5)
         ShaderProgramSimple.shared.lineDraw(p1: p0, p2: p1, thickness: 2.5)
         ShaderProgramSimple.shared.colorSet(r: 0.6, g: 0.6, b: 0.6, a: 0.5)
         ShaderProgramSimple.shared.lineDraw(p1: p0, p2: p2, thickness: 1.25)
         ShaderProgramMesh.shared.use()
         }
         
         
         //Orbital major axis
         
         if true {
         ShaderProgramSimple.shared.use()
         
         let majorAxisDirection = Math.angleToVector(radians: orbitMajorAxisRotation)
         let majorAxisNormal = Math.angleToVector(radians: orbitMajorAxisRotation + Math.PI_2)
         let segmentLength: CGFloat = 220.0
         let handleLength: CGFloat = 12.0
         
         let p0: CGPoint = CGPoint(x: center.x + majorAxisDirection.x * segmentLength, y: center.y + majorAxisDirection.y * segmentLength)
         let p1: CGPoint = CGPoint(x: center.x - majorAxisDirection.x * segmentLength, y: center.y - majorAxisDirection.y * segmentLength)
         //let p00: CGPoint = CGPoint(x: p0.x - majorAxisNormal.x * handleLength, y: p0.y - majorAxisNormal.y * handleLength)
         //let p01: CGPoint = CGPoint(x: p0.x + majorAxisNormal.x * handleLength, y: p0.y + majorAxisNormal.y * handleLength)
         
         let p0_shadow: CGPoint = CGPoint(x: center.x + majorAxisDirection.x * (segmentLength + 4.0), y: center.y + majorAxisDirection.y * (segmentLength + 4.0))
         let p1_shadow: CGPoint = CGPoint(x: center.x - majorAxisDirection.x * (segmentLength + 4.0), y: center.y - majorAxisDirection.y * (segmentLength + 4.0))
         let p00_shadow: CGPoint = CGPoint(x: p0_shadow.x - majorAxisNormal.x * (handleLength + 4.0), y: p0_shadow.y - majorAxisNormal.y * (handleLength + 4.0))
         let p01_shadow: CGPoint = CGPoint(x: p0_shadow.x + majorAxisNormal.x * (handleLength + 4.0), y: p0_shadow.y + majorAxisNormal.y * (handleLength + 4.0))
         
         ShaderProgramSimple.shared.colorSet(r: 0.25, g: 0.25, b: 0.25, a: 1.0)
         
         
         ShaderProgramSimple.shared.lineDraw(p1: p0_shadow, p2: p1_shadow, thickness: 7.0)
         ShaderProgramSimple.shared.lineDraw(p1: p00_shadow, p2: p01_shadow, thickness: 5.0)
         
         
         ShaderProgramSimple.shared.colorSet(r: 0.74, g: 0.74, b: 0.15, a: 1.0)
         
         ShaderProgramSimple.shared.lineDraw(p1: center, p2: p0, thickness: 4.0)
         ShaderProgramSimple.shared.lineDraw(p1: p00_shadow, p2: p01_shadow, thickness: 3.0)
         ShaderProgramSimple.shared.colorSet(r: 0.05, g: 0.65, b: 0.08, a: 1.0)
         ShaderProgramSimple.shared.lineDraw(p1: center, p2: p1, thickness: 3.0)
         
         ShaderProgramMesh.shared.use()
         }
         
         //Ellipsoid orbit ratio bar.
         if true {
         
         ShaderProgramSimple.shared.use()
         
         let barCenter = CGPoint(x: center.x, y: center.y + 80)
         
         let height: CGFloat = 24.0
         let maxWidth: CGFloat = 100.0
         
         
         let underlayStartX = barCenter.x - (maxWidth + 4.0)
         let underlayStartY = barCenter.y - (height / CGFloat(2.0) + CGFloat(4.0))
         let underlayWidth = maxWidth * 2 + 8.0
         let underlayHeight = height + 8.0
         
         ShaderProgramSimple.shared.colorSet(r: 0.15, g: 0.15, b: 0.15, a: 1.0)
         ShaderProgramSimple.shared.rectDraw(x: underlayStartX, y: underlayStartY, width: underlayWidth, height: underlayHeight)
         
         let emptyStrokeStartX = barCenter.x - (maxWidth + 1)
         let emptyStrokeStartY = barCenter.y - (height / CGFloat(2.0) + 1)
         let emptyStrokeWidth = maxWidth * 2 + 2
         let emptyStrokeHeight = height + 2
         
         ShaderProgramSimple.shared.colorSet(r: 0.05, g: 0.05, b: 0.1, a: 1.0)
         ShaderProgramSimple.shared.rectDraw(x: emptyStrokeStartX, y: emptyStrokeStartY, width: emptyStrokeWidth, height: emptyStrokeHeight)
         
         let emptyStartX = barCenter.x - (maxWidth)
         let emptyStartY = barCenter.y - (height / CGFloat(2.0))
         let emptyWidth = maxWidth * 2
         let emptyHeight = height
         
         ShaderProgramSimple.shared.colorSet(r: 0.425, g: 0.425, b: 0.425, a: 1.0)
         ShaderProgramSimple.shared.rectDraw(x: emptyStartX, y: emptyStartY, width: emptyWidth, height: emptyHeight)
         
         let factorStartX = barCenter.x - (maxWidth)
         let factorStartY = barCenter.y - (height / CGFloat(2.0))
         let factorWidth = maxWidth * orbitMinorAxisFactor * 2.0
         let factorHeight = height
         
         ShaderProgramSimple.shared.colorSet(r: 0.45, g: 0.80, b: 0.425, a: 1.0)
         ShaderProgramSimple.shared.rectDraw(x: factorStartX, y: factorStartY, width: factorWidth, height: factorHeight)
         
         let fullStartX = barCenter.x - (maxWidth)
         let fullStartY = barCenter.y - (height / CGFloat(2.0))
         let fullWidth = maxWidth * orbitWidthHeightRatio * 2.0
         let fullHeight = height
         
         ShaderProgramSimple.shared.colorSet(r: 0.08, g: 0.66, b: 0.11, a: 1.0)
         ShaderProgramSimple.shared.rectDraw(x: fullStartX, y: fullStartY, width: fullWidth, height: fullHeight)
         
         ShaderProgramMesh.shared.use()
         }
         
         
         
         
         //Axis Trackers
         
         if true {
         ShaderProgramSimple.shared.use()
         
         let dir1 = Math.angleToVector(radians: axisTrackerSpoke1)
         let dir2 = Math.angleToVector(radians: axisTrackerSpoke2)
         let p1 = CGPoint(x: center.x + dir1.x * 122.0, y: center.y + dir1.y * 122.0)
         let p2 = CGPoint(x: center.x + dir2.x * 122.0, y: center.y + dir2.y * 122.0)
         let p1_shadow = CGPoint(x: center.x + dir1.x * 124.0, y: center.y + dir1.y * 124.0)
         let p2_shadow = CGPoint(x: center.x + dir2.x * 124.0, y: center.y + dir2.y * 124.0)
         
         ShaderProgramSimple.shared.colorSet(r: 0.25, g: 0.25, b: 0.25, a: 0.5)
         ShaderProgramSimple.shared.lineDraw(p1: center, p2: p1_shadow, thickness: 3.0)
         ShaderProgramSimple.shared.pointDraw(point: p1_shadow, size: 24.0)
         ShaderProgramSimple.shared.lineDraw(p1: center, p2: p2_shadow, thickness: 3.0)
         ShaderProgramSimple.shared.pointDraw(point: p2_shadow, size: 10)
         ShaderProgramSimple.shared.colorSet(r: 0.78, g: 0.08, b: 0.14, a: 0.5)
         ShaderProgramSimple.shared.lineDraw(p1: center, p2: p1, thickness: 1.6)
         ShaderProgramSimple.shared.pointDraw(point: p1, size: 6.8)
         ShaderProgramSimple.shared.colorSet(r: 0.33, g: 0.33, b: 0.33, a: 0.5)
         ShaderProgramSimple.shared.lineDraw(p1: center, p2: p2, thickness: 1.6)
         ShaderProgramSimple.shared.pointDraw(point: p2, size: 6.8)
         ShaderProgramMesh.shared.use()
         }
         
         
         
         
         //Orbit ellipse..
         
         if true {
         
         ShaderProgramSimple.shared.use()
         
         //let radius = orbitMajorAxisRadius
         //let rotation = orbitMajorAxisRotation
         
         ShaderProgramSimple.shared.colorSet(r: 0.5, g: 0.075, b: 0.075, a: 0.65)
         
         var lastPoint = CGPoint(x: 0.0, y: 0.0)
         var didLoop: Bool = false
         for angle:CGFloat in stride(from: 0.0, to: Math.PI2 + Math.PI2 * 0.02, by: Math.PI2 * 0.01) {
         let point = ellipsePoint(radians: angle, considerDirectionFactor: false)
         if didLoop == false {
         didLoop = true
         } else {
         let p1 = CGPoint(x: lastPoint.x + center.x, y: lastPoint.y + center.y)
         let p2 = CGPoint(x: point.x + center.x, y: point.y + center.y)
         ShaderProgramSimple.shared.lineDraw(p1: p1, p2: p2, thickness: 2.0)
         }
         lastPoint = point
         }
         
         ShaderProgramSimple.shared.colorSet(r: 1.0, g: 0.1, b: 0.1, a: 0.80)
         lastPoint = CGPoint(x: 0.0, y: 0.0)
         didLoop = false
         for angle:CGFloat in stride(from: 0.0, to: Math.PI2 + Math.PI2 * 0.02, by: Math.PI2 * 0.01) {
         let point = ellipsePoint(radians: angle, considerDirectionFactor: true)
         if didLoop == false {
         didLoop = true
         } else {
         let p1 = CGPoint(x: lastPoint.x + center.x, y: lastPoint.y + center.y)
         let p2 = CGPoint(x: point.x + center.x, y: point.y + center.y)
         ShaderProgramSimple.shared.lineDraw(p1: p1, p2: p2, thickness: 1.0)
         }
         lastPoint = point
         }
         
         
         
         ShaderProgramMesh.shared.use()
         }
         
         
         
         //The direction we are facing.. (ARROW!!!)
         if true {
         
         ShaderProgramSimple.shared.use()
         
         let startPos = CGPoint(x: center.x, y: center.y - 50.0)
         var endPos = CGPoint(x: startPos.x + 70.0, y: startPos.y)
         
         if orbitDirection != 1 {
         endPos = CGPoint(x: startPos.x - 70.0, y: startPos.y)
         }
         
         ShaderProgramSimple.shared.colorSet(r: 0.09, g: 0.12, b: 0.15, a: 1.0)
         ShaderProgramSimple.shared.arrowDraw(start: startPos, end: endPos, thickness: 5.0)
         
         ShaderProgramSimple.shared.colorSet(r: 0.6, g: 0.4, b: 0.04, a: 1.0)
         ShaderProgramSimple.shared.arrowDraw(start: startPos, end: endPos, thickness: 3.0)
         
         ShaderProgramMesh.shared.use()
         }
         
         
         
         //Best Fit Animation Guide History
         if true {
         ShaderProgramSimple.shared.use()
         ShaderProgramSimple.shared.colorSet(r: 1.0, g: 0.75, b: 0.0, a: 0.7)
         for i in 0..<animationGuideHistoryCount {
         let ap = animationGuideHistoryBestFit[i]
         let p = CGPoint(x: ap.x + center.x, y: ap.y + center.y)
         ShaderProgramSimple.shared.pointDraw(point: p, size: 8.0)
         }
         ShaderProgramMesh.shared.use()
         }
         
         */
        
    }
}

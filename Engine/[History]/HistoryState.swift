//
//  HistoryState.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 10/24/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

enum HistoryType: UInt32 {
    case unknown = 0,
    blobAdd = 1,
    blobDelete = 2,
    blobChangeAffine = 3,
    blobChangeShape = 4,
    
    blobChangeBulgeCenter = 5,
    blobChangeBulgeEdgeFactor = 6,
    blobChangeBulgeCenterFactor = 7,
    
    blobFreeze = 8,
    unfreezeAll = 9,
    
    animationSpeed = 50,
    animationPower = 51,
    
    animationBulgeBouncerSpeed = 60,
    animationBulgeBouncerPower = 61,
    animationBulgeBouncerInflationFactor = 62,
    animationBulgeBouncerInflationStartFactor = 63,
    animationBulgeBouncerBounceFactor = 64,
    animationBulgeBouncerEllipseFactor = 65,
    animationBulgeBouncerBounceEnabled = 66,
    animationBulgeBouncerReverseEnabled = 67,
    animationBulgeBouncerEllipseEnabled = 68,
    animationBulgeBouncerAlternateEnabled = 69,
    animationBulgeBouncerTwistEnabled = 70,
    animationBulgeBouncerInflateEnabled = 71,
    animationBulgeBouncerHorizontalEnabled = 72,
    //73 .. 78
    animationBulgeBouncerResetDefault = 79,
    
    
    animationTwisterSpeed = 80,
    animationTwisterPower = 81,
    animationTwisterInflationFactor1 = 82,
    animationTwisterInflationFactor2 = 83,
    animationTwisterReverseEnabled = 84,
    animationTwisterEllipseEnabled = 85,
    animationTwisterAlternateEnabled = 86,
    animationTwisterInflateEnabled = 87,
    //88..98
    animationTwisterResetDefault = 99,
    
    
    
    animationRandomSpeed = 100,
    animationRandomPower = 101,
    animationRandomInflationFactor1 = 102,
    animationRandomInflationFactor2 = 103,
    animationRandomTwistFactor = 104,
    animationRandomRandomnessFactor = 105,
    animationRandomReverseEnabled = 106,
    animationRandomEllipseEnabled = 107,
    animationRandomAlternateEnabled = 108,
    animationRandomTwistEnabled = 109,
    animationRandomInflateEnabled = 110,
    animationRandomHorizontalEnabled = 111,
    //112-118
    animationRandomResetDefault = 119
    
}

class HistoryState : NSObject
{
    override init() {
        super.init()
    }
    
    var type: HistoryType = .unknown
    
    var blobIndex: Int?
    var startSelectedBlobIndex: Int?
    var startSelectedControlPointIndex: Int?
    
    var startSceneMode: SceneMode = .edit
    var startEditMode: EditMode = .affine
    var startAltMenuBulgeBouncer: Int = 0
    var startAltMenuTwister: Int = 0
    var startAltMenuRandom: Int = 0
    var startAnimationEnabled:Bool = false
    var startAnimationMode:AnimationMode = .bounce
    
    //var endBlobIndex: Int?
    var endSelectedBlobIndex: Int?
    var endSelectedControlPointIndex: Int?
    var endSceneMode: SceneMode = .edit
    var endEditMode: EditMode = .affine
    var endAltMenuBulgeBouncer: Int = 0
    var endAltMenuTwister: Int = 0
    var endAltMenuRandom: Int = 0
    var endAnimationEnabled:Bool = false
    var endAnimationMode:AnimationMode = .bounce
    
    var blobData: [String: AnyObject]?
    
    func recordStart(withBlob recordBlob: Blob?) {
        if let engine = ApplicationController.shared.engine {
            startSceneMode = engine.sceneMode
            startEditMode = engine.editMode
            startAltMenuBulgeBouncer = engine.altMenuBulgeBouncer
            startAltMenuTwister = engine.altMenuTwister
            startAltMenuRandom = engine.altMenuRandom
            startAnimationEnabled = engine.animationEnabled
            startAnimationMode = engine.animationMode
            if let selectedBlob = engine.selectedBlob {
                startSelectedBlobIndex = engine.indexOf(blob: selectedBlob)
                startSelectedControlPointIndex = selectedBlob.selectedControlPointIndex
            }
        }
    }
    
    func recordEnd(withBlob recordBlob: Blob?) {
        if let engine = BounceEngine.shared {
            endSceneMode = engine.sceneMode
            endEditMode = engine.editMode
            endAltMenuBulgeBouncer = engine.altMenuBulgeBouncer
            endAltMenuTwister = engine.altMenuTwister
            endAltMenuRandom = engine.altMenuRandom
            endAnimationEnabled = engine.animationEnabled
            endAnimationMode = engine.animationMode
            if let selectedBlob = engine.selectedBlob {
                endSelectedBlobIndex = engine.indexOf(blob: engine.selectedBlob)
                endSelectedControlPointIndex = selectedBlob.selectedControlPointIndex
            }
        }
    }
}





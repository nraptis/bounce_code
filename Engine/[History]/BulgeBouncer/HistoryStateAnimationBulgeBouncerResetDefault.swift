//
//  HistoryStateAnimationBulgeBouncerResetHistory.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 12/11/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateAnimationBulgeBouncerResetDefault: HistoryState {

    override init() {
        super.init()
        type = .animationBulgeBouncerResetDefault
    }
    
    var startPower: CGFloat = 0.0
    var startSpeed: CGFloat = 0.0
    var startBounceStartFactor: CGFloat = 0.0
    var startEllipseFactor: CGFloat = 0.0
    var startInflationFactor: CGFloat = 0.0
    var startBounceFactor: CGFloat = 0.0
    var startBounceEnabled: Bool = false
    var startReverseEnabled: Bool = false
    var startEllipseEnabled:Bool = false
    var startAlternateEnabled:Bool = false
    var startTwistEnabled:Bool = false
    var startInflateEnabled:Bool = false
    var startHorizontalEnabled:Bool = false
    
    var endPower: CGFloat = 0.0
    var endSpeed: CGFloat = 0.0
    var endBounceStartFactor: CGFloat = 0.0
    var endEllipseFactor: CGFloat = 0.0
    var endInflationFactor: CGFloat = 0.0
    var endBounceFactor: CGFloat = 0.0
    var endBounceEnabled: Bool = false
    var endReverseEnabled: Bool = false
    var endEllipseEnabled:Bool = false
    var endAlternateEnabled:Bool = false
    var endTwistEnabled:Bool = false
    var endInflateEnabled:Bool = false
    var endHorizontalEnabled:Bool = false
    
    /*
    var animationBulgeBouncerPower: CGFloat
    var animationBulgeBouncerSpeed: CGFloat
    var animationBulgeBouncerInflationStartFactor: CGFloat
    var animationBulgeBouncerEllipseFactor: CGFloat
    var animationBulgeBouncerInflationFactor: CGFloat
    var animationBulgeBouncerBounceFactor: CGFloat
    
    var animationBulgeBouncerBounceEnabled: Bool
    var animationBulgeBouncerReverseEnabled: Bool
    var animationBulgeBouncerEllipseEnabled:Bool
    var animationBulgeBouncerAlternateEnabled:Bool
    var animationBulgeBouncerTwistEnabled:Bool
    var animationBulgeBouncerInflateEnabled:Bool
    var animationBulgeBouncerHorizontalEnabled:Bool
    */
    
}

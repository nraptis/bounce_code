//
//  HistoryStateAnimationBulgeBouncerSpeed.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 12/5/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateAnimationBulgeBouncerSpeed: HistoryState {
    override init() {
        super.init()
        type = .animationBulgeBouncerSpeed
    }
    var startValue: CGFloat = 1.0
    var endValue: CGFloat = 1.0
}

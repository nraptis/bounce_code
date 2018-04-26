//
//  HistoryStateAnimationSpeed.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/17/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateAnimationSpeed : HistoryState
{
    override init() {
        super.init()
        type = .animationSpeed
    }
    var startAnimationSpeed: CGFloat = 1.0
    var endAnimationSpeed: CGFloat = 1.0
}


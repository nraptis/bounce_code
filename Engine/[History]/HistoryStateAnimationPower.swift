//
//  HistoryStateAnimationPower.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/17/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateAnimationPower : HistoryState
{
    override init() {
        super.init()
        type = .animationPower
    }
    
    var startAnimationPower: CGFloat = 1.0
    var endAnimationPower: CGFloat = 1.0
    
}



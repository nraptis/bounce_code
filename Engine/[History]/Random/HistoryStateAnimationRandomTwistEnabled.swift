//
//  HistoryStateAnimationRandomTwistEnabled.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 12/6/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateAnimationRandomTwistEnabled: HistoryState {
    override init() {
        super.init()
        type = .animationRandomTwistEnabled
    }
    
    var startEnabled: Bool = false
    var endEnabled: Bool = false
}



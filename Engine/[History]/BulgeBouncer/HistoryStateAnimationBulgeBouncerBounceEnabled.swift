//
//  HistoryStateAnimationBulgeBouncerBounceEnabled.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 12/6/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateAnimationBulgeBouncerBounceEnabled: HistoryState {
    override init() {
        super.init()
        type = .animationBulgeBouncerBounceEnabled
    }
    
    var startEnabled: Bool = false
    var endEnabled: Bool = false
}

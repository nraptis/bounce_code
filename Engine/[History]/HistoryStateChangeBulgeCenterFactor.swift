//
//  HistoryStateChangeBulgeCenterFactor.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/17/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateChangeBulgeCenterFactor : HistoryState
{
    override init() {
        super.init()
        type = .blobChangeBulgeCenterFactor
    }
    var startCenterFactor: CGFloat = 1.0
    var endCenterFactor: CGFloat = 1.0
}



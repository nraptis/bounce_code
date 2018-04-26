//
//  HistoryStateChangeAffine.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 10/25/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateChangeAffine : HistoryState
{
    override init() {
        super.init()
        type = .blobChangeAffine
    }
    var startPos = CGPoint.zero
    var startScale: CGFloat = 1.0
    var startRotation: CGFloat = 0.0
    var endPos = CGPoint.zero
    var endScale: CGFloat = 1.0
    var endRotation: CGFloat = 0.0
}


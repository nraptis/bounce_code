//
//  HistoryStateChangeBulgeWeight.swift
//  Bounce
//
//  Created by Nicholas Raptis on 12/31/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateChangeBulgeCenter : HistoryState
{
    override init() {
        super.init()
        type = .blobChangeBulgeCenter
    }
    var startOffset = CGPoint.zero
    //var startScale: CGFloat = 1.0
    //var startRotation: CGFloat = 0.0
    
    var endOffset = CGPoint.zero
    //var endScale: CGFloat = 1.0
    //var endRotation: CGFloat = 0.0
}

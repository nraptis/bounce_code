//
//  HistoryStateChangeBulgeEdgeFactor.swift
//  Bounce
//
//  Created by Nicholas Raptis on 12/31/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateChangeBulgeEdgeFactor : HistoryState
{
    override init() {
        super.init()
        type = .blobChangeBulgeEdgeFactor
    }
    var startEdgeFactor: CGFloat = 1.0
    var endEdgeFactor: CGFloat = 1.0
}

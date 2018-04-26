//
//  HistoryStateFreeze.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 2/7/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

// = 7,
//unfreezeAll = 8

import UIKit

class HistoryStateFreeze : HistoryState
{
    override init() {
        super.init()
        type = .blobFreeze
    }
}





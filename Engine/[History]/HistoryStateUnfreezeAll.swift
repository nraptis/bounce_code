//
//  HistoryStateUnfreezeAll.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 2/7/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateUnfreezeAll : HistoryState
{
    override init() {
        super.init()
        type = .unfreezeAll
    }
    
    var frozenIndeces = [Int]()
    
}


//
//  HistoryStateAddBlob.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 10/24/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import Foundation

class HistoryStateAddBlob : HistoryState
{
    override init() {
        super.init()
        type = .blobAdd
    }
}

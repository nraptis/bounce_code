//
//  RecordBottomMenu.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/21/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class RecordBottomMenu: ToolMenu {
    
    override func setUp(parentFrame: CGRect, top: Bool, rowCount: Int, landscape: Bool) {
        super.setUp(parentFrame: parentFrame, top: top, rowCount: rowCount, landscape: landscape)
        rows[rowCount-1].setUp(main: true, up: true, shadow: true)
        for i in 0..<(rowCount-1) {
            rows[i].setUp(main: false, up: true, shadow: i != 0)
        }
        reloadInterface()
        addTopShadow()
    }
    
    override func handleSubscriptionStateChanged() -> Void {
        super.handleSubscriptionStateChanged()
    }
    
    func reloadInterface() {
        rows[0].generateInterface(instr: "[record_cancel]|[record]|", dir: -1)
    }
}










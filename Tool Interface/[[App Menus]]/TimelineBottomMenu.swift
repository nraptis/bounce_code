//
//  TimelineBottomMenu.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/21/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class TimelineBottomMenu: ToolMenu {
    
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
        
        //guard let engine = ApplicationController.shared.engine else { return }
        //let isThreeLine: Bool = (rows.count > 2)
        
        rows[0].generateInterface(instr: "[timeline_cancel]||[export_audio][export_video]", dir: -1)
        for row in rows {
            row.refreshAllElements()
        }
    }
}













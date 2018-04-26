//
//  TimelineTopMenu.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/21/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class TimelineTopMenu: ToolMenu {
    
    override func setUp(parentFrame: CGRect, top: Bool, rowCount: Int, landscape: Bool) {
        super.setUp(parentFrame: parentFrame, top: top, rowCount: rowCount, landscape: landscape)
        rows[0].setUp(main: true, up: false, shadow: true)
        for i in 1..<rowCount {
            rows[i].setUp(main: false, up: false, shadow: i < (rowCount - 1))
        }
        reloadInterface()
        addBottomShadow()
    }
    
    override func handleSubscriptionStateChanged() -> Void {
        super.handleSubscriptionStateChanged()
    }
    
    func reloadInterface() {
        
        for row in rows {
            row.refreshAllElements()
        }
        
        //timeline
        let isTwoLine: Bool = (rows.count > 1)
        
        if isTwoLine {
            rows[0].generateInterface(instr: "|[timeline]|", dir: -1)
            rows[1].generateInterface(instr: "|[timeline_prev_frame][timeline_play][timeline_next_frame]", dir: -1)
        } else {
            rows[0].generateInterface(instr: "[timeline_prev_frame][timeline_play][timeline_next_frame]||[timeline]", dir: -1)
        }
        
        for row in rows {
            row.refreshAllElements()
        }
    }
}



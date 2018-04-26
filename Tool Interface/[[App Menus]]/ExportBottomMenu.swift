//
//  ExportBottomMenu.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 12/14/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class ExportBottomMenu: ToolMenu {

    override func setUp(parentFrame: CGRect, top: Bool, rowCount: Int, landscape: Bool) {
        super.setUp(parentFrame: parentFrame, top: top, rowCount: rowCount, landscape: landscape)
        rows[rowCount-1].setUp(main: true, up: true, shadow: true)
        for i in 0..<(rowCount-1) {
            rows[i].setUp(main: false, up: true, shadow: i != 0)
        }
        reloadInterface()
        addTopShadow()
    }
    
    override func handleVideoExportComplete() {
        //print("ExportBottomMenu::handleVideoExportComplete(ex: \(ApplicationController.shared.bounce!.isExporting) er: \(ApplicationController.shared.bounce!.exportError) fn: \(ApplicationController.shared.bounce!.exportFinished)")
        super.handleVideoExportComplete()
        reloadInterface()
    }
    
    override func handleVideoExportError() {
        //print("ExportBottomMenu::handleVideoExportComplete(ex: \(ApplicationController.shared.bounce!.isExporting) er: \(ApplicationController.shared.bounce!.exportError) fn: \(ApplicationController.shared.bounce!.exportFinished)")
        
        super.handleVideoExportError()
        reloadInterface()
    }
    
    func reloadInterface() {
        //print("ExportBottomMenu::reloadInterface(ex: \(ApplicationController.shared.bounce!.isExporting) er: \(ApplicationController.shared.bounce!.exportError) fn: \(ApplicationController.shared.bounce!.exportFinished)")
        
        if let bounce = ApplicationController.shared.bounce {
            if bounce.exportFinished {
                rows[0].generateInterface(instr: "[export_share_email][export_share_facebook][export_share_twitter]||[export_done]", dir: -1)
            } else if bounce.exportError {
                rows[0].generateInterface(instr: "[export_cancel]||[export_video]", dir: -1)
            } else {
                rows[0].generateInterface(instr: "|[export_info]|", dir: -1)
            }
        }
    }
}

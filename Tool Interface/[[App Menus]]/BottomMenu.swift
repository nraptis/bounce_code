//
//  BottomMenu.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/6/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class BottomMenu: ToolMenu {
    
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
    
    override func handleZoomEnabledChanged() {
        reloadInterface()
        super.handleZoomEnabledChanged()
    }
    
    override func handleBlobSelectionChanged() {
        super.handleBlobSelectionChanged()
        
    }
    
    override func handleShowingMarkersChanged() {
        super.handleShowingMarkersChanged()
    }
    
    override func handleZoomEnabledChangedForced() {
        super.handleZoomEnabledChangedForced()
    }
    
    override func handleZoomScaleChanged() {
        super.handleZoomScaleChanged()
    }
    
    override func handleHistoryChanged() {
        super.handleHistoryChanged()
    }
    
    override func handleStackOrderChanged() {
        super.handleStackOrderChanged()
    }
    
    override func handleSceneModeChanged() {
        reloadInterface()
        super.handleSceneModeChanged()
    }
    
    override func handleEditModeChanged() {
        super.handleEditModeChanged()
    }
    
    override func handleAnimationModeChanged() {
        reloadInterface()
        super.handleAnimationModeChanged()
    }
    
    override func handleAnimationEnabledChanged() {
        reloadInterface()
        super.handleAnimationEnabledChanged()
    }
    
    override func handleAltMenuBulgeBouncerChanged() {
        super.handleAltMenuBulgeBouncerChanged()
    }
    
    func reloadInterface() {
        
        guard let engine = ApplicationController.shared.engine else { return }
        let isThreeLine: Bool = (rows.count > 2)
        
        if isThreeLine {
            rows[2].generateInterface(instr: "[undo][redo]|[scene_mode]|[collapse_bottom]", dir: -1)
        } else {
            rows[1].generateInterface(instr: "[undo][redo]|[scene_mode]|[collapse_bottom]", dir: -1)
        }
        
        if engine.zoomEnabled {
            if isThreeLine {
                rows[0].generateInterface(instr: "||[reset_zoom][zoom]", dir: -1)
                rows[1].generateInterface(instr: "[zoom_scale]||", dir: -1)
            } else {
                rows[0].generateInterface(instr: "[zoom_scale]||[reset_zoom][zoom]", dir: -1)
            }
        } else {
            if engine.sceneMode == .edit {
                if engine.editMode == .affine {
                    if isThreeLine {
                        rows[0].generateInterface(instr: "[add_blob][delete_blob][clone_blob]||[reset_zoom][zoom]", dir: -1)
                        rows[1].generateInterface(instr: "|[edit_mode]|", dir: -1)
                    } else {
                        rows[0].generateInterface(instr: "[add_blob][delete_blob][clone_blob]|[edit_mode]|[reset_zoom][zoom]", dir: -1)
                    }
                } else if engine.editMode == .shape {
                    if isThreeLine {
                        rows[0].generateInterface(instr: "[add_blob][delete_blob][clone_blob]||[reset_zoom][zoom]", dir: -1)
                        rows[1].generateInterface(instr: " |[edit_mode]| ", dir: -1)
                    } else {
                        rows[0].generateInterface(instr: "[add_blob][delete_blob][clone_blob]|[edit_mode]|[reset_zoom][zoom]", dir: -1)
                    }
                } else if engine.editMode == .distribution {
                    if isThreeLine {
                        rows[0].generateInterface(instr: "[add_blob][delete_blob][clone_blob]||[reset_zoom][zoom]", dir: -1)
                        rows[1].generateInterface(instr: " |[edit_mode]| ", dir: -1)
                    } else {
                        rows[0].generateInterface(instr: "[add_blob][delete_blob][clone_blob]|[edit_mode]|[reset_zoom][zoom]", dir: -1)
                    }
                }
            } else if engine.sceneMode == .view {
                
                if engine.animationEnabled {
                    if isThreeLine {
                        rows[0].generateInterface(instr: "[stereoscopic][animation]||[show_markers][record_menu] ", dir: -1)
                        rows[1].generateInterface(instr: "|[animation_mode]|", dir: -1)
                    } else {
                        rows[0].generateInterface(instr: "[stereoscopic][animation]|[animation_mode]|[show_markers][record_menu] ", dir: -1)
                    }
                } else {
                    if isThreeLine {
                        rows[0].generateInterface(instr: "[stereoscopic][animation]||[record_menu] ", dir: -1)
                        rows[1].generateInterface(instr: "[show_markers][gyro]|| ", dir: -1)
                    } else {
                        rows[0].generateInterface(instr: "[stereoscopic][animation][gyro][show_markers]||[record_menu]", dir: -1)
                    }
                }
            }
        }
        for row in rows {
            row.refreshAllElements()
        }
    }
}

































//
//  TopMenu.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/6/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class TopMenu: ToolMenu {
    
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
        reloadInterface()
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
        reloadInterface()
        super.handleAltMenuBulgeBouncerChanged()
    }
    
    override func handleAltMenuTwisterChanged() {
        reloadInterface()
        super.handleAltMenuTwisterChanged()
    }
    
    override func handleAltMenuRandomChanged() {
        reloadInterface()
        super.handleAltMenuRandomChanged()
    }
    
    func reloadInterface() {
        
        guard let engine = ApplicationController.shared.engine else { return }
        let isThreeLine: Bool = (rows.count > 2)
        
        var middleButton = "[purchase]"
        
        if engine.scene.isWebScene {
            middleButton = "[rate]"
        } else if PurchaseManager.shared.isPaidSubscriptionActive {
            middleButton = ""
        }
        
        
        rows[0].generateInterface(instr: "[menu]|\(middleButton)|[collapse_top]", dir: 1)
        
        if engine.zoomEnabled {
            if isThreeLine {
                rows[1].generateInterface(instr: "", dir: -1)
                rows[2].generateInterface(instr: "", dir: -1)
            } else {
                rows[1].generateInterface(instr: "", dir: -1)
            }
        } else {
            if engine.sceneMode == .edit {
                if engine.editMode == .affine {
                    if isThreeLine {
                        rows[1].generateInterface(instr: "[prev_blob][next_blob][flip_h][flip_v]||[unfreeze]", dir: 1)
                        rows[2].generateInterface(instr: "[send_front][send_forward][send_backward][send_back]||[freeze]", dir: 1)
                    } else {
                        rows[1].generateInterface(instr: "[prev_blob][next_blob][flip_h][flip_v][send_front][send_forward][send_backward][send_back][freeze][unfreeze]", dir: 1)
                    }
                } else if engine.editMode == .shape {
                    if isThreeLine {
                        rows[1].generateInterface(instr: "[add_point][delete_point][prev_point][next_point]", dir: 1)
                        rows[2].generateInterface(instr: "||[freeze][unfreeze]", dir: 1)
                    } else {
                        rows[1].generateInterface(instr: "[add_point][delete_point][prev_point][next_point]||[freeze][unfreeze]", dir: 1)
                    }
                } else if engine.editMode == .distribution {
                    if isThreeLine {
                        rows[1].generateInterface(instr: "[bulge_edge_factor]||[freeze]", dir: 1)
                        rows[2].generateInterface(instr: "[bulge_center_factor]||[unfreeze]", dir: 1)
                    } else {
                        rows[1].generateInterface(instr: "[bulge_edge_factor][bulge_center_factor]||[freeze][unfreeze]", dir: 1)
                    }
                }
            } else if engine.sceneMode == .view {
                if engine.animationEnabled {
                    let animationDirection = ApplicationController.shared.animationToolbarAnimationDirection
                    if engine.animationMode == .bounce {
                        if engine.altMenuBulgeBouncer == 0 {
                            if isThreeLine {
                                rows[1].generateInterface(instr: "[anim_tools_prev][reset_default_bb][a_bb_speed]||[anim_tools_next]", dir: animationDirection)
                                rows[2].generateInterface(instr: "[anim_tools_prev][a_bb_alternate_enabled][a_bb_power]||[anim_tools_next]", dir: animationDirection)
                            } else {
                                rows[1].generateInterface(instr: "[anim_tools_prev][reset_default_bb][a_bb_alternate_enabled]||[a_bb_speed][a_bb_power][anim_tools_next]", dir: animationDirection)
                            }
                        } else if engine.altMenuBulgeBouncer == 1 {
                            if isThreeLine {
                                rows[1].generateInterface(instr: "[anim_tools_prev][a_bb_inflate_enabled][a_bb_inflation_factor]||[anim_tools_next]", dir: animationDirection)
                                rows[2].generateInterface(instr: "[anim_tools_prev][a_bb_horizontal_enabled][a_bb_inflation_start_factor]||[anim_tools_next]", dir: animationDirection)
                            } else {
                                rows[1].generateInterface(instr: "[anim_tools_prev][a_bb_horizontal_enabled][a_bb_inflate_enabled]||[a_bb_inflation_factor][a_bb_inflation_start_factor][anim_tools_next] ", dir: animationDirection)
                            }
                        } else {
                            if isThreeLine {
                                rows[1].generateInterface(instr: "[anim_tools_prev][a_bb_bounce_enabled][a_bb_bounce_factor] [anim_tools_next]", dir: animationDirection)
                                rows[2].generateInterface(instr: "[anim_tools_prev][a_bb_reverse_enabled][a_bb_ellipse_factor][anim_tools_next]", dir: animationDirection)
                            } else {
                                rows[1].generateInterface(instr: "[anim_tools_prev][a_bb_reverse_enabled][a_bb_bounce_enabled]||[a_bb_bounce_factor][a_bb_ellipse_factor][anim_tools_next]", dir: animationDirection)
                            }
                        }
                    } else if engine.animationMode == .twist {
                        if engine.altMenuTwister == 0 {
                            if isThreeLine {
                                rows[1].generateInterface(instr: "[anim_tools_prev][reset_default_twister]||[a_tw_speed][anim_tools_next]", dir: animationDirection)
                                rows[2].generateInterface(instr: "[anim_tools_prev][a_tw_alternate_enabled][a_tw_power]||[anim_tools_next]", dir: animationDirection)
                            } else {
                                rows[1].generateInterface(instr: "[anim_tools_prev][reset_default_twister][a_tw_alternate_enabled]| | [a_tw_speed][a_tw_power][anim_tools_next] ", dir: animationDirection)
                            }
                        } else {
                            if isThreeLine {
                                rows[1].generateInterface(instr: "[anim_tools_prev][a_tw_inflate_enabled][a_tw_inflation_factor_1][anim_tools_next]", dir: animationDirection)
                                rows[2].generateInterface(instr: "[anim_tools_prev][a_tw_reverse_enabled][a_tw_inflation_factor_2][anim_tools_next]", dir: animationDirection)
                            } else {
                                rows[1].generateInterface(instr: "[anim_tools_prev][a_tw_reverse_enabled][a_tw_inflate_enabled]||[a_tw_inflation_factor_1][a_tw_inflation_factor_2][anim_tools_next]", dir: animationDirection)
                            }
                        }
                    } else {
                        if engine.altMenuRandom == 0 {
                            if isThreeLine {
                                rows[1].generateInterface(instr: "[anim_tools_prev][reset_default_random][a_rd_speed][anim_tools_next]", dir: animationDirection)
                                rows[2].generateInterface(instr: "[anim_tools_prev][a_rd_alternate_enabled][a_rd_power][anim_tools_next]", dir: animationDirection)
                            } else {
                                rows[1].generateInterface(instr: "[anim_tools_prev][reset_default_random][a_rd_alternate_enabled]||[a_rd_speed] [a_rd_power][anim_tools_next]", dir: animationDirection)
                            }
                        } else if engine.altMenuRandom == 1 {
                            if isThreeLine {
                                rows[1].generateInterface(instr: "[anim_tools_prev][a_rd_inflate_enabled][a_rd_inflation_factor_1] [anim_tools_next]", dir: animationDirection)
                                rows[2].generateInterface(instr: "[anim_tools_prev][a_rd_reverse_enabled][a_rd_inflation_factor_2] [anim_tools_next]", dir: animationDirection)
                            } else {
                                rows[1].generateInterface(instr: "[anim_tools_prev] [a_rd_reverse_enabled] [a_rd_inflate_enabled]|| [a_rd_inflation_factor_1][a_rd_inflation_factor_2][anim_tools_next]", dir: animationDirection)
                            }
                        } else {
                            if isThreeLine {
                                rows[1].generateInterface(instr: "[anim_tools_prev][a_rd_twist_enabled][a_rd_twist_factor][anim_tools_next]", dir: animationDirection)
                                rows[2].generateInterface(instr: "[anim_tools_prev][a_rd_horizontal_enabled][a_rd_randomness_factor][anim_tools_next]", dir: animationDirection)
                            } else {
                                rows[1].generateInterface(instr: "[anim_tools_prev][a_rd_twist_enabled][a_rd_horizontal_enabled]|| [a_rd_twist_factor][a_rd_randomness_factor][anim_tools_next]", dir: animationDirection)
                            }
                        }
                    }
                } else {
                    if isThreeLine {
                        rows[1].generateInterface(instr: "[animation_speed]", dir: 1)
                        rows[2].generateInterface(instr: "[animation_power]", dir: 1)
                    } else {
                        rows[1].generateInterface(instr: "[animation_speed]||[animation_power]", dir: 1)
                    }
                }
            }
        }
        for row in rows {
            row.refreshAllElements()
        }
    }
}

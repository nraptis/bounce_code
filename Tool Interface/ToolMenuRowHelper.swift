//
//  ToolMenuRowHelper.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/18/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class ToolMenuRowHelper: UIView {
    
    class func processToken(token: String) -> UIView? {
        
        var result: UIView?
        
        let defaultFrame = CGRect(x: 0.0, y: 0.0, width: ApplicationController.shared.toolBarHeight, height: ApplicationController.shared.toolBarHeight)
        
        if token == ToolItem.undo.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_undo", pathSelected: "tb_btn_undo_down")
            result = button
        } else if token == ToolItem.redo.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_redo", pathSelected: "tb_btn_redo_down")
            result = button
        } else if token == ToolItem.add_blob.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_add_blob", pathSelected: "tb_btn_add_blob_down")
            result = button
        } else if token == ToolItem.menu.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_menu", pathSelected: "tb_btn_menu_down")
            result = button
        } else if token == ToolItem.prev_blob.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_select_previous_blob", pathSelected: "tb_btn_select_previous_blob_down")
            result = button
        } else if token == ToolItem.next_blob.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_select_next_blob", pathSelected: "tb_btn_select_next_blob_down")
            result = button
        } else if token == ToolItem.prev_point.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_select_previous_point", pathSelected: "tb_btn_select_previous_point_down")
            result = button
        } else if token == ToolItem.next_point.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_select_next_point", pathSelected: "tb_btn_select_next_point_down")
            result = button
        } else if token == ToolItem.add_point.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_add_point", pathSelected: "tb_btn_add_point_down")
            result = button
        } else if token == ToolItem.delete_point.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_delete_point", pathSelected: "tb_btn_delete_point_down")
            result = button
        } else if token == ToolItem.flip_h.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_flip_h", pathSelected: "tb_btn_flip_h_down")
            result = button
        } else if token == ToolItem.flip_v.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_flip_v", pathSelected: "tb_btn_flip_v_down")
            result = button
        } else if token == ToolItem.unfreeze.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_unfreeze_all", pathSelected: "tb_btn_unfreeze_all_down")
            result = button
        } else if token == ToolItem.freeze.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_freeze_selected", pathSelected: "tb_btn_freeze_selected_down")
            result = button
        } else if token == ToolItem.timeline_play.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_pause", pathSelected: "tb_btn_pause_down")
            result = button
        } else if token == ToolItem.timeline_next_frame.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_next_frame", pathSelected: "tb_btn_next_frame_down")
            result = button
        } else if token == ToolItem.timeline_prev_frame.rawValue {
            let button = TBButton(frame: defaultFrame)
            button.setImages(path: "tb_btn_prev_frame", pathSelected: "tb_btn_prev_frame_down")
            result = button
        }
        
        if token == ToolItem.delete_blob.rawValue {
            let button = TBButtonMedium168(frame: defaultFrame)
            button.setImages(path: "tb_btn_delete_blob", pathSelected: "tb_btn_delete_blob_down")
            result = button
        } else if token == ToolItem.clone_blob.rawValue {
            let button = TBButtonMedium168(frame: defaultFrame)
            button.setImages(path: "tb_btn_clone_blob", pathSelected: "tb_btn_clone_blob_down")
            result = button
        } else if token == ToolItem.reset_zoom.rawValue {
            let button = TBButtonMedium168(frame: defaultFrame)
            button.setImages(path: "tb_btn_reset_zoom", pathSelected: "tb_btn_reset_zoom_down")
            result = button
        } else if token == ToolItem.collapse_bottom.rawValue {
            let button = TBButtonMedium168(frame: defaultFrame)
            button.setImages(path: "tb_btn_collapse_down_arrow", pathSelected: "tb_btn_collapse_down_arrow_down")
            result = button
        } else if token == ToolItem.collapse_top.rawValue {
            let button = TBButtonMedium168(frame: defaultFrame)
            button.setImages(path: "tb_btn_collapse_up_arrow", pathSelected: "tb_btn_collapse_up_arrow_down")
            result = button
        }
        
        if token == ToolItem.send_forward.rawValue {
            let button = TBButtonMedium192(frame: defaultFrame)
            button.setImages(path: "tb_btn_send_forward", pathSelected: "tb_btn_send_forward_down")
            result = button
        } else if token == ToolItem.send_backward.rawValue {
            let button = TBButtonMedium192(frame: defaultFrame)
            button.setImages(path: "tb_btn_send_backward", pathSelected: "tb_btn_send_backward_down")
            result = button
        }
        
        if token == ToolItem.send_front.rawValue {
            let button = TBButtonMedium216(frame: defaultFrame)
            button.setImages(path: "tb_btn_send_front", pathSelected: "tb_btn_send_front_down")
            result = button
        } else if token == ToolItem.send_back.rawValue {
            let button = TBButtonMedium216(frame: defaultFrame)
            button.setImages(path: "tb_btn_send_back", pathSelected: "tb_btn_send_back_down")
            result = button
        } else if token == ToolItem.export_share_email.rawValue {
            let button = TBButtonMedium216(frame: defaultFrame)
            button.setImages(path: "tb_btn_share_mail", pathSelected: "tb_btn_share_mail_down")
            result = button
        } else if token == ToolItem.export_share_facebook.rawValue {
            let button = TBButtonMedium216(frame: defaultFrame)
            button.setImages(path: "tb_btn_share_facebook", pathSelected: "tb_btn_share_facebook_down")
            result = button
        } else if token == ToolItem.export_share_twitter.rawValue {
            let button = TBButtonMedium216(frame: defaultFrame)
            button.setImages(path: "tb_btn_share_twitter", pathSelected: "tb_btn_share_twitter_down")
            result = button
        }
        
        if token == ToolItem.record.rawValue {
            let button = TBButtonRecord(frame: defaultFrame)
            result = button
        }
        
        if token == ToolItem.purchase.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            button.setImages(path: "tb_btn_purchase", pathSelected: "tb_btn_purchase_down")
            //button.text = "Purchase"
            result = button
        } else if token == ToolItem.record_menu.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            button.setImages(path: "tb_btn_record_movie", pathSelected: "tb_btn_record_movie_down")
            result = button
        } else if token == ToolItem.record_cancel.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            //button.setImages(path: "tb_btn_record_movie", pathSelected: "tb_btn_record_movie_down")
            button.setImages(path: "tb_icn_btn_cancel", pathSelected: "tb_icn_btn_cancel_down")
            
            //button.text = "Record Cancel"
            result = button
        } else if token == ToolItem.export_video.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            button.setImages(path: "tb_button_export_movie", pathSelected: "tb_button_export_movie_down")
            result = button
        } else if token == ToolItem.timeline_cancel.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            button.setImages(path: "tb_icn_btn_cancel", pathSelected: "tb_icn_btn_cancel_down")
            result = button
        } else if token == ToolItem.export_cancel.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            //button.setImages(path: "tb_btn_record_movie", pathSelected: "tb_btn_record_movie_down")
            button.setImages(path: "tb_btn_cancel", pathSelected: "tb_btn_cancel_down")
            result = button
        } else if token == ToolItem.export_done.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            //button.setImages(path: "tb_btn_record_movie", pathSelected: "tb_btn_record_movie_down")
            button.setImages(path: "tb_icn_btn_done_down", pathSelected: "tb_icn_btn_done_down")
            //button.text = "EX-DONE"
            result = button
        } else if token == ToolItem.reset_default_bb.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            button.setImages(path: "tb_btn_reset_defaults", pathSelected: "tb_btn_reset_defaults_down")
            result = button
        } else if token == ToolItem.reset_default_twister.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            button.setImages(path: "tb_btn_reset_defaults", pathSelected: "tb_btn_reset_defaults_down")
            result = button
        } else if token == ToolItem.reset_default_random.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            button.setImages(path: "tb_btn_reset_defaults", pathSelected: "tb_btn_reset_defaults_down")
            result = button
        } else if token == ToolItem.rate.rawValue {
            let button = TBButtonWide(frame: defaultFrame)
            button.setImages(path: "tb_btn_rate_scene", pathSelected: "tb_btn_rate_scene_down")
            result = button
        }
        
        
        
        if token == ToolItem.scene_mode.rawValue {
            let segment = TBSegment(frame: defaultFrame)
            segment.segmentCount = 2
            segment.orange = true
            segment.setImage(index: 0, path: "tb_seg_edit", pathSelected: "tb_seg_edit_selected")
            segment.setImage(index: 1, path: "tb_seg_view", pathSelected: "tb_seg_view_selected")
            segment.selectedIndex = 0
            result = segment
        } else if token == ToolItem.edit_mode.rawValue {
            let segment = TBSegment(frame: defaultFrame)
            segment.segmentCount = 3
            segment.setImage(index: 0, path: "tb_seg_edit_affine", pathSelected: "tb_seg_edit_affine_selected")
            segment.setImage(index: 1, path: "tb_seg_edit_shape", pathSelected: "tb_seg_edit_shape_selected")
            segment.setImage(index: 2, path: "tb_seg_edit_weight", pathSelected: "tb_seg_edit_weight_selected")
            segment.selectedIndex = 0
            result = segment
        } else if token == ToolItem.animation_mode.rawValue {
            let segment = TBSegment(frame: defaultFrame)
            segment.segmentCount = 3
            segment.setImage(index: 0, path: "tb_seg_anim_bulge_bouncer", pathSelected: "tb_seg_anim_bulge_bouncer_selected")
            segment.setImage(index: 1, path: "tb_seg_anim_twister", pathSelected: "tb_seg_anim_twister_selected")
            segment.setImage(index: 2, path: "tb_seg_anim_crazy", pathSelected: "tb_seg_anim_crazy_selected")
            segment.selectedIndex = 0
            result = segment
        }
        
        if token == ToolItem.zoom.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_zoom_disabled", pathSelected: "tb_cb_zoom_enabled")
            result = checkBox
        } else if token == ToolItem.stereoscopic.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_3d_disabled", pathSelected: "tb_cb_3d_enabled")
            result = checkBox
        } else if token == ToolItem.gyro.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_gyro_enabled_unchecked", pathSelected: "tb_cb_gyro_enabled_checked")
            result = checkBox
        } else if token == ToolItem.show_markers.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_show_markers_unchecked", pathSelected: "tb_cb_show_markers_checked")
            result = checkBox
        } else if token == ToolItem.animation.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_animation_mode_unchecked", pathSelected: "tb_cb_animation_mode_checked")
            result = checkBox
        } else if token == ToolItem.a_bb_bounce_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_bounce_enabled_unchecked", pathSelected: "tb_cb_anim_bounce_enabled_checked")
            result = checkBox
        } else if token == ToolItem.a_bb_reverse_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_reverse_enabled_unchecked", pathSelected: "tb_cb_anim_reverse_enabled_checked")
            result = checkBox
        } else if token == ToolItem.a_bb_ellipse_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            result = checkBox
        } else if token == ToolItem.a_bb_alternate_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_alternate_enabled_unchecked", pathSelected: "tb_cb_anim_alternate_enabled_checked", pathDisabled: "tb_cb_anim_alternate_enabled_disabled")
            result = checkBox
        } else if token == ToolItem.a_bb_twist_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_twist_enabled_unchecked", pathSelected: "tb_cb_anim_twist_enabled_checked")
            result = checkBox
        } else if token == ToolItem.a_bb_inflate_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_inflate_enabled_unchecked", pathSelected: "tb_cb_anim_inflate_enabled_checked")
            result = checkBox
        } else if token == ToolItem.a_bb_horizontal_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_horizontal_enabled_unchecked", pathSelected: "tb_cb_anim_horizontal_enabled_checked")
            result = checkBox
        } else if token == ToolItem.a_tw_reverse_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_reverse_enabled_unchecked", pathSelected: "tb_cb_anim_reverse_enabled_checked")
            result = checkBox
        } else if token == ToolItem.a_tw_ellipse_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            //checkBox.setImages(path: "tb_cb_3d_disabled", pathSelected: "tb_cb_3d_disabled")
            checkBox.text = "ELLI"
            result = checkBox
        } else if token == ToolItem.a_tw_alternate_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_alternate_enabled_unchecked", pathSelected: "tb_cb_anim_alternate_enabled_checked", pathDisabled: "tb_cb_anim_alternate_enabled_disabled")
            result = checkBox
        } else if token == ToolItem.a_tw_inflate_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_inflate_enabled_unchecked", pathSelected: "tb_cb_anim_inflate_enabled_checked")
            result = checkBox
        } else if token == ToolItem.a_rd_reverse_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_reverse_enabled_unchecked", pathSelected: "tb_cb_anim_reverse_enabled_checked")
            result = checkBox
        } else if token == ToolItem.a_rd_ellipse_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            //checkBox.setImages(path: "tb_cb_3d_disabled", pathSelected: "tb_cb_3d_disabled")
            checkBox.text = "ELLI"
            result = checkBox
        } else if token == ToolItem.a_rd_alternate_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_alternate_enabled_unchecked", pathSelected: "tb_cb_anim_alternate_enabled_checked", pathDisabled: "tb_cb_anim_alternate_enabled_disabled")
            result = checkBox
        } else if token == ToolItem.a_rd_twist_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_twist_enabled_unchecked", pathSelected: "tb_cb_anim_twist_enabled_checked")
            result = checkBox
        } else if token == ToolItem.a_rd_inflate_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_inflate_enabled_unchecked", pathSelected: "tb_cb_anim_inflate_enabled_checked")
            result = checkBox
        } else if token == ToolItem.a_rd_horizontal_enabled.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_anim_horizontal_enabled_unchecked", pathSelected: "tb_cb_anim_horizontal_enabled_checked")
            result = checkBox
        } else if token == ToolItem.export_audio.rawValue {
            let checkBox = TBCheckBox(frame: defaultFrame)
            checkBox.setImages(path: "tb_cb_export_sound_unchecked", pathSelected: "tb_cb_export_sound_checked")
            result = checkBox
        }
        
        if token == ToolItem.zoom_scale.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .small
            slider.rightTextSize = .percent
            slider.leftText = "Zoom"
            slider.rightText = "99%"
            slider.minimumValue = ApplicationController.shared.zoomMin
            slider.maximumValue = ApplicationController.shared.zoomMax
            result = slider
        } else if token == ToolItem.animation_power.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Bounce Power"
            slider.rightText = "99%"
            result = slider
        } else if token == ToolItem.animation_speed.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Bounce Speed"
            slider.rightText = "99%"
            result = slider
        } else if token == ToolItem.bulge_edge_factor.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Edge Factor"
            slider.rightText = "99%"
            result = slider
        } else if token == ToolItem.bulge_center_factor.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "B-Cen Factor:"
            slider.rightText = "99%"
            result = slider
        } else if token == ToolItem.a_bb_power.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Power"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_bb_speed.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Speed"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_bb_inflation_start_factor.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Bulge Incline"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_bb_ellipse_factor.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Circle Factor"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_bb_inflation_factor.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Bulge Size"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_bb_bounce_factor.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Bounce Size"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_tw_speed.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Twist Speed"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_tw_power.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Twist Power"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_tw_inflation_factor_1.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Bulge Start"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_tw_inflation_factor_2.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Bulge Finish"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_rd_speed.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Cycle Speed"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_rd_power.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Move Power"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_rd_inflation_factor_1.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Bulge Start"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_rd_inflation_factor_2.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Bulge Finish"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_rd_twist_factor.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Twist Factor"
            slider.rightText = "100%"
            result = slider
        } else if token == ToolItem.a_rd_randomness_factor.rawValue {
            let slider = TBSlider(frame: defaultFrame)
            slider.leftTextSize = .medium
            slider.rightTextSize = .percent
            slider.leftText = "Random Effect"
            slider.rightText = "100%"
            result = slider
        }
        
        //if token == ToolItem.rate_strip.rawValue {
        //    let rateStrip = TBRateStrip(frame: defaultFrame)
        //    result = rateStrip
        //}
        
        if token == ToolItem.export_info.rawValue {
            let exportInfo = TBExportInfo(frame: defaultFrame)
            result = exportInfo
        }
        
        if token == ToolItem.timeline.rawValue {
            let timeline = TBTimeline(frame: defaultFrame)
            result = timeline
        }
        
        //if token == ToolItem.rate_strip.rawValue {
        //    let rateStrip = TBRateStrip(frame: defaultFrame)
        //    result = rateStrip
        //}
        
        if token == ToolItem.anim_tools_prev.rawValue || token == ToolItem.anim_tools_next.rawValue {
            if let engine = ApplicationController.shared.engine {
                
                var page: Int = 0
                var pageCount: Int = 1
                if engine.animationMode == .bounce {
                    page = engine.altMenuBulgeBouncer
                    pageCount = 3
                } else if engine.animationMode == .twist {
                    page = engine.altMenuTwister
                    pageCount = 2
                } else if engine.animationMode == .random {
                    page = engine.altMenuRandom
                    pageCount = 3
                }
                
                if token == ToolItem.anim_tools_prev.rawValue {
                    let tabber = TBPageTabber(frame: defaultFrame)
                    tabber.setImages(path: "tb_tab_prev", pathSelected: "tb_tab_prev_down")
                    if pageCount == 3 {
                        if page == 0 {
                            tabber.setPageImages(path: "tb_tab_3_of_3", pathSelected: "tb_tab_3_of_3_down")
                        } else if page == 1 {
                            tabber.setPageImages(path: "tb_tab_1_of_3", pathSelected: "tb_tab_1_of_3_down")
                        } else {
                            tabber.setPageImages(path: "tb_tab_2_of_3", pathSelected: "tb_tab_2_of_3_down")
                        }
                    } else if pageCount == 2 {
                        if page == 0 {
                            tabber.setPageImages(path: "tb_tab_2_of_2", pathSelected: "tb_tab_2_of_2_down")
                        } else {
                            tabber.setPageImages(path: "tb_tab_1_of_2", pathSelected: "tb_tab_1_of_2_down")
                        }
                    }
                    
                    tabber.styleSetPageTabberLeft()
                    result = tabber
                    
                } else if token == ToolItem.anim_tools_next.rawValue {
                    let tabber = TBPageTabber(frame: defaultFrame)
                    tabber.setImages(path: "tb_tab_next", pathSelected: "tb_tab_next_down")
                    if pageCount == 3 {
                        if page == 0 {
                            tabber.setPageImages(path: "tb_tab_2_of_3", pathSelected: "tb_tab_2_of_3_down")
                        } else if page == 1 {
                            tabber.setPageImages(path: "tb_tab_3_of_3", pathSelected: "tb_tab_3_of_3_down")
                        } else {
                            tabber.setPageImages(path: "tb_tab_1_of_3", pathSelected: "tb_tab_1_of_3_down")
                        }
                    } else if pageCount == 2 {
                        if page == 0 {
                            tabber.setPageImages(path: "tb_tab_2_of_2", pathSelected: "tb_tab_2_of_2_down")
                        } else {
                            tabber.setPageImages(path: "tb_tab_1_of_2", pathSelected: "tb_tab_1_of_2_down")
                        }
                    }
                    tabber.styleSetPageTabberRight()
                    result = tabber
                }
            }
        }
        
        return result
    }
    
    
    class func minimumWidthForItem(view: UIView) -> Int {
        
        var result: CGFloat = ApplicationController.shared.toolBarHeight
        
        if view is TBPageTabber {
            if Device.isTablet {
                result = ApplicationController.shared.toolBarHeight * 0.5
            } else {
                result = ApplicationController.shared.toolBarHeight * 0.75
            }
        }
        
        //if view is TBPageTabber { result = ApplicationController.shared.toolBarHeight * 0.75 }
        
        if view is TBButtonWide { result = ApplicationController.shared.toolBarHeight * 1.85 }
        
        if view is TBButtonMedium168 { result = ApplicationController.shared.toolBarHeight * 1.3125 }
        if view is TBButtonMedium192 { result = ApplicationController.shared.toolBarHeight * 1.5 }
        if view is TBButtonMedium216 { result = ApplicationController.shared.toolBarHeight * 1.6875 }
        
        if (view is TBButtonRecord || view is TBExportInfo || view is TBButtonUltraWide) { result = ApplicationController.shared.toolBarHeight * 4.0 }
        
        if view is TBTimeline { result = ApplicationController.shared.toolBarHeight * 2.0 }
        
        if let segment = view as? TBSegment { result = ApplicationController.shared.toolBarHeight * CGFloat(segment.segmentCount) * 1.58 }
        
        /*
        if view is TBRateStrip {
            var starWidth: CGFloat = 32.0
            if let starImage = ApplicationController.shared.imageRateStarFull {
                starWidth = starImage.size.width
            }
            result = ApplicationController.shared.toolBarHeight + starWidth * 5.0
        }
        */
        
        if view is TBCheckBox { result = ApplicationController.shared.toolBarHeight * 1.85 }
        
        if view is TBSlider {
            if Device.isPhone {
                result = 85.0
            } else {
                result = 160.0
            }
        }
        return Int(result + 0.5)
    }
    
    class func preferredWidthForItem(view: UIView) -> Int {
        var result: CGFloat = ApplicationController.shared.toolBarHeight
        
        if view is TBPageTabber { 
            
            if Device.isTablet {
                result = ApplicationController.shared.toolBarHeight * 0.5
            } else {
                result = ApplicationController.shared.toolBarHeight * 0.75
            }
        }
        
        if view is TBButton { result = ApplicationController.shared.toolBarHeight * 1.0 }
        
        if view is TBButtonMedium168 { result = ApplicationController.shared.toolBarHeight * 1.3125 }
        if view is TBButtonMedium192 { result = ApplicationController.shared.toolBarHeight * 1.5 }
        if view is TBButtonMedium216 { result = ApplicationController.shared.toolBarHeight * 1.6875 }
        if view is TBTimeline { result = ApplicationController.shared.toolBarHeight * 4.0 }
        
        
        /*if view is TBRateStrip {
            var starWidth: CGFloat = 32.0
            if let starImage = ApplicationController.shared.imageRateStarFull {
                starWidth = starImage.size.width
            }
            result = ApplicationController.shared.toolBarHeight + starWidth * 5.0
        }
         */
        
        if view is TBButtonWide { result = ApplicationController.shared.toolBarHeight * 2.125 }
        if let segment = view as? TBSegment { result = ApplicationController.shared.toolBarHeight * CGFloat(segment.segmentCount) * 2.5 }
        if view is TBCheckBox { result = ApplicationController.shared.toolBarHeight * 2.125 }
        if view is TBButtonRecord { result = ApplicationController.shared.toolBarHeight * 4.0 }
        
        if view is TBSlider { result = 200.0 }
        return Int(result + 0.5)
    }
    
    class func flexibleWidthForItem(view: UIView) -> Bool {
        if view is TBSlider { return true }
        if view is TBTimeline { return true }
        return false
    }
    
    class func leftSpacingForItem(item: UIView) -> Int {
        if item is TBButton || item is TBButtonWide {
            if Device.isTablet { return 6 } else { return 2 }
        }
        
        if item is TBButtonMedium168 || item is TBButtonMedium192 || item is TBButtonMedium216 {
            if Device.isTablet { return 6 } else { return 2 }
        }
        
        if item is TBPageTabber {
            if Device.isTablet { return 5 } else { return 3 }
        }
        
        
        
        //case anim_tools_prev = "anim_tools_prev"
        //case anim_tools_next = "anim_tools_next"
        
        
        if item is TBCheckBox {
            if Device.isTablet { return 4 } else { return 2 }
        }
        if item is TBSegment {
            if Device.isTablet { return 4 } else { return 2 }
        }
        if item is TBSlider {
            if Device.isTablet { return 4 } else { return 2 }
        }
        return 4
    }
    
    class func rightSpacingForItem(item: UIView) -> Int {
        return leftSpacingForItem(item: item)
    }
    
    class func spacingBetweenItems(item1: UIView, item2: UIView) -> Int {
        if item1 is TBSegment || item2 is TBSegment || item1 is TBSlider || item2 is TBSlider {
            if Device.isPhone {
                if Device.isSmall {
                    return 2
                } else {
                    return 4
                }
            } else {
                return 6
            }
        }
        if Device.isPhone {
            if Device.isSmall {
                return 2
            } else {
                return 4
            }
        } else {
            return 6
        }
    }
    
}

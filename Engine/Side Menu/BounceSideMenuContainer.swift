//
//  BounceSideMenuContainer.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/2/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class BounceSideMenuContainer: UIView, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var sideMenu:BounceSideMenu!
    
    var tapRecognizer:UITapGestureRecognizer!
    
    func setUp() {
        isExclusiveTouch = false
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tapRecognizer.delegate = self
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapRecognizer)
        
        sideMenu.setUp()
    }
    
    @objc func didTapMainThread(_ gr:UITapGestureRecognizer) -> Void {
        if ToolActions.allow() {
            ToolActions.toggleSideMenu(completion: nil)
        }
    }
    
    @objc func didTap(_ gr:UITapGestureRecognizer) -> Void {
        self.performSelector(onMainThread: #selector(didTapMainThread(_:)), with: gr, waitUntilDone: true, modes: [RunLoopMode.commonModes.rawValue])
    }
    
    func update() {
        sideMenu.update()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pos = gestureRecognizer.location(in: self)
        if let bounce = ApplicationController.shared.bounce {
            if bounce.sideMenu.frame.contains(pos) {
                return false
            }
        }
        return true
    }
}

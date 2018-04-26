//
//  SideMenu.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 11/2/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class BounceSideMenu: UIView {
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonPublish:SideMenuButton! {
        didSet {
            buttonPublish.imageIconPath = "sm_btn_icon_publish"
            buttonPublish.imagePath = "sm_btn_text_publish"
        }
    }
    @IBOutlet weak var buttonSave:SideMenuButton! {
        didSet {
            buttonSave.imageIconPath = "sm_btn_icon_save"
            buttonSave.imagePath = "sm_btn_text_save"
        }
    }
    @IBOutlet weak var buttonClear:SideMenuButton! {
        didSet {
            buttonClear.imageIconPath = "sm_btn_icon_clear"
            buttonClear.imagePath = "sm_btn_text_clear"
        }
    }
    @IBOutlet weak var buttonExit:SideMenuButton! {
        didSet {
            buttonExit.imageIconPath = "sm_btn_icon_exit"
            buttonExit.imagePath = "sm_btn_text_exit"
        }
    }
    
    func setUp() {
        if buttonWidthConstraint != nil && buttonHeightConstraint != nil {
            var buttonSize = CGSize(width: 188.0, height: 50.0)
            if Device.isTablet {
                buttonSize = CGSize(width: buttonSize.width * 1.5, height: buttonSize.height * 1.5)
            }
            buttonWidthConstraint.constant = CGFloat(Int(buttonSize.width + 0.25))
            buttonHeightConstraint.constant = CGFloat(Int(buttonSize.height + 0.25))
            widthConstraint.constant = CGFloat(Int(buttonSize.width + 30.25))
            self.setNeedsUpdateConstraints()
        }
    }
    
    func update() {
        buttonPublish.update()
        buttonSave.update()
        buttonClear.update()
        buttonExit.update()
    }
    
    @IBAction func clickExit(sender: AnyObject) {
        if let engine = ApplicationController.shared.engine {
            let saveAction = { ToolActions.navigateHome() }
            if engine.shouldPromptForSave {
                if let askSave = ApplicationController.shared.getStoryboardVC("ask_save_scene") as? AskToSaveViewController {
                    askSave.completionAction = saveAction
                    ApplicationController.shared.root.pushDiaglog(withVC: askSave, completion: nil)
                }
            } else {
                saveAction()
            }
        }
    }
    
    @IBAction func clickPublish(sender: AnyObject) {
        
        
        if let engine = ApplicationController.shared.engine {
            if engine.canPublish() == false { return }
        }
        
        let publishSceneAction: (() -> Void) = {
            if let publishScene = ApplicationController.shared.getStoryboardVC("publish_scene") as? PublishSceneViewController {
                ApplicationController.shared.root.pushDiaglog(withVC: publishScene, completion: nil)
            }
        }
        
        if LoginManager.isSignedIn {
            publishSceneAction()
        } else {
            if let accountLogin = ApplicationController.shared.getStoryboardVC("account_login") as? AccountLoginViewController {
                accountLogin.signInAction = publishSceneAction
                ApplicationController.shared.root.pushDiaglog(withVC: accountLogin, completion: nil)
            }
        }
    }
    
    @IBAction func clickSave(sender: AnyObject) {
        ToolActions.save()
    }
    
    @IBAction func clickClear(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This will remove all blobs from the scene and restore all defaults.", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "Okay", style: .default) { (action: UIAlertAction) in
            DispatchQueue.main.async {
                //PurchaseManager.shared.startFreeSubscription()
                ToolActions.resetScene()
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(actionCancel)
        alert.addAction(actionOK)
        
        ApplicationController.shared.root.present(alert, animated: true, completion: nil)
        
        
    }
    
}

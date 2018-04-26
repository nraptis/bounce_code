//
//  GLView.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 10/27/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import GLKit
import OpenGLES

class BounceView: GLView {
    
    var defaultScaleFactor: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    deinit {
        
    }
    
    func setUp() {
        
        defaultScaleFactor = self.contentScaleFactor
        
        self.isOpaque = true
        self.contentScaleFactor = 1.0
        
        enableSetNeedsDisplay = true
        
    }
    
    override func display() {
        if let engine = ApplicationController.shared.engine, let bounce = ApplicationController.shared.bounce {
            if bounce.isUnfreezeEnqueued {
                bounce.unfreezeRealize()
            }
            if engine.stereoscopic {
                self.contentScaleFactor = 1.0
                engine.stereoscopicChannel = false
                engine.setStereoscopicBlendBackground(stereoscopicImage: self.snapshot)
                engine.stereoscopicChannel = true
                if bounce.isFreezeEnqueued {
                    let freezeImage = self.snapshot
                    bounce.freezeRealize(withImage: freezeImage)
                } else {
                    super.display()
                }
            } else {
                self.contentScaleFactor = defaultScaleFactor
                if bounce.isFreezeEnqueued {
                    let freezeImage = self.snapshot
                    bounce.freezeRealize(withImage: freezeImage)
                } else {
                    super.display()
                }
            }
            
            if engine.stereoscopic {
                engine.stereoscopicChannel = false
                self.contentScaleFactor = defaultScaleFactor
            }
        }
    }
    
    func exportStereoDisplay1() {
        if let engine = ApplicationController.shared.engine {
            self.contentScaleFactor = 1.0
            engine.stereoscopicChannel = false
            engine.setStereoscopicBlendBackground(stereoscopicImage: self.snapshot)
        }
    }
    
    func exportStereoDisplay2() {
        if let engine = ApplicationController.shared.engine {
            self.contentScaleFactor = 1.0
            engine.stereoscopicChannel = true
            super.display()
            self.contentScaleFactor = defaultScaleFactor
        }
    }
    
    
}

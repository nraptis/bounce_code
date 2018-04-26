//
//  BlobMotionController.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 3/30/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

class BlobMotionController: NSObject {
    
    var name: String = "Generic"
    
    //According to this motion controller, the
    //target offset should be (THIS)
    var center = CGPoint.zero
    
    //The blob's actual maximum mesh offset
    //that the end-user will see.
    var animationTargetOffset = CGPoint.zero
    var inflateScale: CGFloat = 1.0
    var twistRotation: CGFloat = 0.0
    
    internal var isAlt: Bool = false
    
    internal var blob: Blob?
    
    var isGrabbed: Bool {
        if let currentBlob = blob { return currentBlob.isGrabbed }
        return false
    }
    
    
    
    
    //These will mirror the falloff values of the blob (if it exists)
    //Or default to the control falloff values (for reference motion controller)
    var dragFalloffInputCap: CGFloat = 0.0
    var dragFalloffDampenInputMax: CGFloat = 0.0
    var dragFalloffDampenResultMax: CGFloat = 0.0
    var dragFalloffDampenStart: CGFloat = 0.0
    
    override init() {
        
        super.init()
        
    }
    
    func update() {
        
        //var isGrabbed = false
        
        guard let currentBlob = blob else { return }
        
        center = CGPoint(x: currentBlob.center.x, y: currentBlob.center.y)
        
        dragFalloffInputCap = currentBlob.dragFalloffInputCap
        dragFalloffDampenInputMax = currentBlob.dragFalloffDampenInputMax
        dragFalloffDampenResultMax = currentBlob.dragFalloffDampenResultMax
        dragFalloffDampenStart = currentBlob.dragFalloffDampenStart
        
        /*else {
            dragFalloffInputCap = ApplicationController.shared.dragFalloffInputCapMin
            
            dragFalloffDampenInputMax = dragFalloffInputCap
            
            let dragFalloffDampenResultMaxFactorMin = ApplicationController.shared.dragFalloffDampenResultMaxFactorMin
            let dragFalloffDampenResultMaxFactorMax = ApplicationController.shared.dragFalloffDampenResultMaxFactorMax
            let dragFalloffDampenResultMaxFactor: CGFloat = dragFalloffDampenResultMaxFactorMin + (dragFalloffDampenResultMaxFactorMax - dragFalloffDampenResultMaxFactorMin) * 0.5
            dragFalloffDampenResultMax = dragFalloffDampenInputMax * dragFalloffDampenResultMaxFactor
            
            let dragFalloffDampenStartFactorMin = ApplicationController.shared.dragFalloffDampenStartFactorMin
            let dragFalloffDampenStartFactorMax = ApplicationController.shared.dragFalloffDampenStartFactorMax
            let dragFalloffDampenStartFactor: CGFloat = dragFalloffDampenStartFactorMin + (dragFalloffDampenStartFactorMax - dragFalloffDampenStartFactorMin) * 0.5
            dragFalloffDampenStart = dragFalloffDampenResultMax * dragFalloffDampenStartFactor
        }
        */
        
        
        
        
    }
    
    
    
    func reset(alt: Bool) {
        
        isAlt = alt
        
        //if let bl = blob {
        //    print("[\(bl.name) Reset] \(name) Alt = \(alt)")
        //}
        
        animationTargetOffset = CGPoint(x: 0.0, y: 0.0)
        
        inflateScale = 1.0
        twistRotation = 0.0
    }
    
    
    
    func drawMarkers() {
        
        /*
         
         //Animation guide history..
         if true {
         
         ShaderProgramSimple.shared.use()
         
         ShaderProgramSimple.shared.colorSet(r: 0.0, g: 0.0, b: 0.0, a: 0.25)
         for i in 0..<animationGuideHistoryCount {
         let ap = animationGuideHistory[i]
         let p = CGPoint(x: ap.x + center.x, y: ap.y + center.y)
         ShaderProgramSimple.shared.pointDraw(point: p, size: 5.0)
         }
         
         ShaderProgramSimple.shared.colorSet(r: 0.10, g: 0.25, b: 1.0, a: 0.3)
         for i in 0..<animationGuideHistoryCount {
         let ap = animationGuideHistory[i]
         let p = CGPoint(x: ap.x + center.x, y: ap.y + center.y)
         ShaderProgramSimple.shared.pointDraw(point: p, size: 3.0)
         }
         
         ShaderProgramMesh.shared.use()
         }
         
         //Dampening bars...
         if true {
         ShaderProgramSimple.shared.use()
         
         let startPoint = center
         let endPointInputMax1 = CGPoint(x: center.x - dragFalloffDampenInputMax, y: startPoint.y)
         let endPointResultMax1 = CGPoint(x: center.x - dragFalloffDampenResultMax, y: startPoint.y)
         let endPointDampenStart1 = CGPoint(x: center.x - dragFalloffDampenStart, y: startPoint.y)
         
         ShaderProgramSimple.shared.colorSet(r: 1.0, g: 0.8, b: 0.05, a: 0.6)
         ShaderProgramSimple.shared.lineDraw(p1: startPoint, p2: endPointDampenStart1, thickness: 4.0)
         
         ShaderProgramSimple.shared.colorSet(r: 0.0, g: 0.4, b: 0.7, a: 0.6)
         ShaderProgramSimple.shared.lineDraw(p1: endPointDampenStart1, p2: endPointResultMax1, thickness: 2.0)
         
         ShaderProgramSimple.shared.colorSet(r: 0.45, g: 1.0, b: 0.6, a: 0.6)
         ShaderProgramSimple.shared.lineDraw(p1: endPointResultMax1, p2: endPointInputMax1, thickness: 4.0)
         
         let endPointInputMax2 = CGPoint(x: center.x + dragFalloffDampenInputMax, y: startPoint.y)
         let endPointResultMax2 = CGPoint(x: center.x + dragFalloffDampenResultMax, y: startPoint.y)
         let endPointDampenStart2 = CGPoint(x: center.x + dragFalloffDampenStart, y: startPoint.y)
         
         ShaderProgramSimple.shared.colorSet(r: 1.0 - 1.0, g: 1.0 - 0.8, b: 1.0 - 0.05, a: 0.6)
         ShaderProgramSimple.shared.lineDraw(p1: startPoint, p2: endPointDampenStart2, thickness: 4.0)
         
         ShaderProgramSimple.shared.colorSet(r: 1.0 - 0.0, g: 1.0 - 0.4, b: 1.0 - 0.7, a: 0.6)
         ShaderProgramSimple.shared.lineDraw(p1: endPointDampenStart2, p2: endPointResultMax2, thickness: 2.0)
         
         ShaderProgramSimple.shared.colorSet(r: 1.0 - 0.45, g: 1.0 - 1.0, b: 1.0 - 0.6, a: 0.6)
         ShaderProgramSimple.shared.lineDraw(p1: endPointResultMax2, p2: endPointInputMax2, thickness: 4.0)
         
         ShaderProgramMesh.shared.use()
         }
         
         
         //Animation guide (Gyro Driven)
         
         
         if true {
         ShaderProgramSimple.shared.use()
         
         let start = center
         let end = CGPoint(x: start.x + animationGuideOffset.x, y: start.y + animationGuideOffset.y)
         ShaderProgramSimple.shared.colorSet(r: 1.0, g: 1.0, b: 1.0, a: 1.0)
         ShaderProgramSimple.shared.lineDraw(p1: start, p2: end, thickness: 1.5)
         ShaderProgramSimple.shared.pointDraw(point: end, size: 18.0)
         
         ShaderProgramMesh.shared.use()
         }
         
         */
        
        //
    }
    
    
}





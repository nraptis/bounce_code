//
//  HistoryStateChangeShape.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 10/25/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class HistoryStateChangeShape : HistoryState
{
    override init() {
        super.init()
        type = .blobChangeShape
    }
    
    var startSplineData: [String: AnyObject]?
    var startCenter = CGPoint.zero
    var startBulgeOffset = CGPoint.zero
    //var startBulgeRotation: CGFloat = 0.0
    
    var endSplineData: [String: AnyObject]?
    var endCenter = CGPoint.zero
    var endBulgeOffset = CGPoint.zero
    //var endBulgeRotation: CGFloat = 0.0
    
    override func recordStart(withBlob recordBlob: Blob?) {
        if let blob = recordBlob {
            startSplineData = blob.spline.save()
            startSelectedControlPointIndex = blob.selectedControlPointIndex
            startCenter = blob.center
            startBulgeOffset = blob.bulgeWeightOffset
            //startBulgeRotation = blob.bulgeWeightRotation
            
            super.recordStart(withBlob: blob)
        }
    }
    
    override func recordEnd(withBlob recordBlob: Blob?) {
        if let blob = recordBlob {
            endSplineData = blob.spline.save()
            endSelectedControlPointIndex = blob.selectedControlPointIndex
            endCenter = blob.center
            endBulgeOffset = blob.bulgeWeightOffset
            //endBulgeRotation = blob.bulgeWeightRotation
            
            super.recordEnd(withBlob: blob)
        }
    }
    
    
}

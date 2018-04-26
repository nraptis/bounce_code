//
//  BlobMeshNode.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/9/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class BlobMeshNode : DrawNode
{
    var index:Int = 0
    
    var edgeDistance: CGFloat = 0.0
    var edgePercent: CGFloat = 0.0
    var edgePercentMin: CGFloat = 0.0
    var edgePercentMax: CGFloat = 0.0
    var edgeFactor: CGFloat = 0.0
    
    var weightDistance: CGFloat = 0.0
    
    
    var weightPercent: CGFloat = 0.0
    
    var weightPercentMin: CGFloat = 0.0
    var weightPercentMax: CGFloat = 0.0
    
    //var weightPercentMin: CGFloat = 0.0
    //var weightPercentMax: CGFloat = 0.0
    
    
    var weightFactor: CGFloat = 0.0
    
    var dampen: CGFloat = 0.0
    
    //Final factor in determining %
    //of actual movement...
    var factor: CGFloat = 0.0
    
    var animX: CGFloat = 0.0
    var animY: CGFloat = 0.0
    var animZ: CGFloat = 0.0
    
    func set(meshNode:BlobMeshNode) {
        set(drawNode: meshNode)
        index = meshNode.index
        edgeDistance = meshNode.edgeDistance
        edgePercent = meshNode.edgePercent
        edgePercentMin = meshNode.edgePercentMin
        edgePercentMax = meshNode.edgePercentMax
        edgeFactor = meshNode.edgeFactor
        weightDistance = meshNode.weightDistance
        //weightPercent = meshNode.weightPercent
        //weightPercentMin = meshNode.weightPercentMin
        //weightPercentMax = meshNode.weightPercentMax
        weightFactor = meshNode.weightFactor
        dampen = meshNode.dampen
        factor = meshNode.factor
    }
    
    
    func writeToTriangleListAnimated(_ t:inout [GLfloat], index:Int) {
        //let count = t.count
        t[index +  0] = GLfloat(animX)
        t[index +  1] = GLfloat(animY)
        t[index +  2] = GLfloat(animZ)
        t[index +  3] = GLfloat(u)
        t[index +  4] = GLfloat(v)
        t[index +  5] = GLfloat(w)
        t[index +  6] = GLfloat(r)
        t[index +  7] = GLfloat(g)
        t[index +  8] = GLfloat(b)
        t[index +  9] = GLfloat(a)
    }
    
}

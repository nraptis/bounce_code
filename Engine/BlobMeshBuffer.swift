//
//  BlobMeshBuffer.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/9/16.
//  Copyright © 2016 Darkswarm LLC. All rights reserved.
//

import UIKit

class BlobMeshBuffer {
    
    var count:Int { return _count }
    internal var _count:Int = 0
    
    var data = [BlobMeshNode]()
    
    func reset() {
        _count = 0
    }
    
    func ensureCapacity(_ capacity: Int) {
        if capacity >= data.count {
            let newCapacity = capacity + capacity / 2 + 1
            data.reserveCapacity(newCapacity)
            while data.count < newCapacity {
                data.append(BlobMeshNode())
            }
        }
    }
    
    func set(index:Int, node:BlobMeshNode) {
        guard index >= 0 else { return }
        ensureCapacity(index)
        if index >= _count { _count = index + 1 }
        data[index].set(meshNode:node)
    }
    
    func setXY(_ index:Int, x:CGFloat, y:CGFloat) {
        guard index >= 0 else { return }
        ensureCapacity(index)
        if index >= _count { _count = index + 1 }
        data[index].x = x
        data[index].y = y;
    }
    
    func setZ(_ index:Int, z:CGFloat) {
        guard index >= 0 else { return }
        ensureCapacity(index)
        if index >= _count { _count = index + 1 }
        data[index].z = z
    }
    
    func setEdgeDistance(_ index:Int, edgeDistance:CGFloat) {
        guard index >= 0 else { return }
        ensureCapacity(index)
        if index >= _count { _count = index + 1 }
        data[index].edgeDistance = edgeDistance
    }
    
    func printData() {
        print("DrawNodeBuffer [\(count)] Elements [\(data.count)] Size [\(data.capacity)] Capacity\n*** *** ***")
        for i in 0..<count {
            let d = data[i]
            print("Node[\(i)] xyz(\(d.x),\(d.y),\(d.z)")
        }
        print("*** *** ***")
    }
    
}



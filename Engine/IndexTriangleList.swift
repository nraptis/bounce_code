//
//  IndexTriangleList.swift
//
//  Created by Raptis, Nicholas on 9/2/16.
//

import Foundation

struct IndexTriangle {
    var i1:Int = 0
    var i2:Int = 0
    var i3:Int = 0
}

class IndexTriangleList {
    
    var data = [IndexTriangle]()
    var indeces = [IndexBufferType]()
    
    
    var count:Int {
        return _count
    }
    internal var _count:Int = 0
    
    func reset() {
        _count = 0
    }
    
    func add(i1:Int, i2:Int, i3:Int) {
        if _count >= data.count {
            var newCapacity = _count + _count / 2 + 1
            data.reserveCapacity(newCapacity)
            while data.count <= newCapacity {
                data.append(IndexTriangle())
            }
            
            newCapacity *= 3
            newCapacity += 3
            indeces.reserveCapacity(newCapacity)
            while indeces.count <= newCapacity {
                indeces.append(IndexBufferType(0))
            }
        }
        
        data[_count].i1 = i1
        data[_count].i2 = i2
        data[_count].i3 = i3
        
        let count3 = (_count + _count + _count)
        indeces[count3 + 0] = IndexBufferType(i1)
        indeces[count3 + 1] = IndexBufferType(i2)
        indeces[count3 + 2] = IndexBufferType(i3)
        _count += 1
    }
}


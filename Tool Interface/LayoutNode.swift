//
//  LayoutNode.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 9/7/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit

enum LayoutSide: Int { case left = -1, middle = 0, right = 1 }

class LayoutNode {
    
    weak var view: UIView!
    var name: String = ""
    
    ///////////////////////////////////////
    ///////////////////////////////////////
    ////
    ////     Must be pre-computed...
    ////
    var side: LayoutSide = .left
    var minimumWidth: Int = 36
    
    var preferredWidth: Int = 36
    var flexibleWidth: Bool = false
    
    var spacingLeft: Int = 6
    var spacingRight: Int = 6
    ////
    ////
    ///////////////////////////////////////
    ///////////////////////////////////////
    
    var fixedWidth: Bool {
        return preferredWidth == minimumWidth
    }
    
    
    var x: Int = 0
    var width: Int = 36
    
    func clone(fromNode: LayoutNode) {
        
        side = fromNode.side
        minimumWidth = fromNode.minimumWidth
        
        preferredWidth = fromNode.preferredWidth
        flexibleWidth = fromNode.flexibleWidth
        
        spacingLeft = fromNode.spacingLeft
        spacingRight = fromNode.spacingRight
        
        x = fromNode.x
        width = fromNode.width
    }
    
    func clone() -> LayoutNode {
        let result = LayoutNode()
        result.clone(fromNode: self)
        return result
    }
    
    class func layout(nodes: [LayoutNode], width: Int) {
        
        guard nodes.count > 0 else { return }
        
        for i in 0..<nodes.count {
            let node = nodes[i]
            node.width = node.minimumWidth
        }
        
        if getMinimumWidth(nodes) > width {
            
            print("*** NODES DO NOT FIT ***")
            
            printNodes(nodes)
            
            //layoutOverflowingMinimumWidth(nodes: nodes, width: width)
            
            return
        }
        
        var leftExists: Bool = false
        var middleExists: Bool = false
        var rightExists: Bool = false
        
        var leftFlex: Bool = false
        var middleFlex: Bool = false
        var rightFlex: Bool = false
        
        var leftCount: Int = 0
        var middleCount: Int = 0
        var rightCount: Int = 0
        
        //Factors in the spacing.
        var minimumWidthLeft: Int = 0
        var minimumWidthMiddle: Int = 0
        var minimumWidthRight: Int = 0
        
        //Factors in the spacing.
        var preferredWidthLeft: Int = 0
        var preferredWidthMiddle: Int = 0
        var preferredWidthRight: Int = 0
        
        var left = [LayoutNode]()
        var middle = [LayoutNode]()
        var right = [LayoutNode]()
        
        for i in 0..<nodes.count {
            let node = nodes[i]
            if node.side == .left {
                left.append(node)
                leftExists = true
                if node.flexibleWidth { leftFlex = true }
                leftCount += 1
            }
            if node.side == .middle {
                middle.append(node)
                middleExists = true
                if node.flexibleWidth { middleFlex = true }
                middleCount += 1
            }
            if node.side == .right {
                right.append(node)
                rightExists = true
                if node.flexibleWidth { rightFlex = true }
                rightCount += 1
            }
        }
        
        guard leftExists || middleExists || rightExists else {
            print("#### NO LEFT, MIDDLE, or RIGHT ####")
            return
        }
        
        minimumWidthLeft = getMinimumWidth(left)
        minimumWidthMiddle = getMinimumWidth(middle)
        minimumWidthRight = getMinimumWidth(right)
        
        preferredWidthLeft = getPreferredWidth(left)
        preferredWidthMiddle = getPreferredWidth(middle)
        preferredWidthRight = getPreferredWidth(right)
        
        //print("Min (L:\(minimumWidthLeft) M:\(minimumWidthMiddle) R: \(minimumWidthRight)) Total: \(minimumWidthLeft + minimumWidthMiddle + minimumWidthRight)")
        //print("Preferred (L:\(preferredWidthLeft) M:\(preferredWidthMiddle) R: \(preferredWidthRight)) Total: \(preferredWidthLeft + preferredWidthMiddle + preferredWidthRight)")
        
        var leftStartX: Int = 0
        var leftEndX: Int = minimumWidthLeft
        var leftWidth: Int = minimumWidthLeft
        
        var rightStartX: Int = width - minimumWidthRight
        var rightEndX: Int = width
        var rightWidth: Int = minimumWidthRight
        
        var middleStartX: Int = width / 2 - minimumWidthMiddle / 2
        var middleEndX: Int = middleStartX + minimumWidthMiddle
        var middleWidth: Int = minimumWidthMiddle
        
        var reloop: Bool = true
        
        /*
         //If only one section has items, handle the case...
         if leftExists && middleExists == false && rightExists == false {
         if leftFlex {
         leftWidth = width
         } else {
         leftWidth = preferredWidthLeft
         if leftWidth > width { leftWidth = width }
         if leftWidth < minimumWidthLeft { leftWidth = minimumWidthLeft }
         }
         leftStartX = 0
         leftEndX = leftStartX + leftWidth
         reloop = false
         }
         if leftExists == false && middleExists && rightExists == false {
         if middleFlex {
         middleWidth = width
         } else {
         middleWidth = preferredWidthMiddle
         if middleWidth > width { middleWidth = width }
         if middleWidth < minimumWidthMiddle { middleWidth = minimumWidthMiddle }
         }
         middleStartX = width / 2 - middleWidth / 2
         middleEndX = middleStartX + middleWidth
         reloop = false
         }
         if leftExists == false && middleExists == false && rightExists {
         if rightFlex {
         rightWidth = width
         } else {
         rightWidth = preferredWidthRight
         if rightWidth > width { rightWidth = width }
         if rightWidth < minimumWidthRight { rightWidth = minimumWidthRight }
         }
         rightEndX = width
         rightStartX = rightEndX - rightWidth
         reloop = false
         }
         */
        
        //If the middle section is overlapping one of the other sections, handle the case...
        var middleCentered: Bool = true
        
        
        //var middlePinnedRight: Bool = false
        //var middlePinnedLeft: Bool = true
        
        
        if middleExists {
            if leftExists {
                if leftEndX > middleStartX {
                    middleStartX = leftEndX
                    middleEndX = middleStartX + middleWidth
                    middleCentered = false
                    //middlePinnedLeft = true
                    
                }
            }
            if rightExists {
                if rightStartX < middleEndX {
                    middleEndX = rightStartX
                    middleStartX = middleEndX - middleWidth
                    middleCentered = false
                    //middlePinnedRight = true
                    
                }
            }
        }
        
        
        var middleExpansionCountRight: Int = 0
        var middleExpansionCountLeft: Int = 0
        
        while reloop {
            
            //In this loop we are guaranteed to have at least 2 non-empty sections
            //The sum of their minimum widths is < width.
            
            reloop = false
            
            if leftExists {
                var leftSpaceRemaining: Int = 0
                if middleExists {
                    leftSpaceRemaining = middleStartX - leftEndX
                } else if rightExists {
                    leftSpaceRemaining = rightStartX - leftEndX
                } else {
                    leftSpaceRemaining = width - leftEndX
                }
                
                let expandableNodes = countExpandableNodes(left)
                if (expandableNodes > 0) && (expandableNodes < leftSpaceRemaining) && (leftSpaceRemaining > 0) {
                    reloop = true
                    expandExpandableNodes(left)
                    leftWidth = getWidth(left)
                    leftStartX = 0
                    leftEndX = leftStartX + leftWidth
                }
            }
            
            if rightExists {
                var rightSpaceRemaining: Int = 0
                if middleExists {
                    rightSpaceRemaining = rightStartX - middleEndX
                } else if leftExists {
                    rightSpaceRemaining = rightStartX - leftEndX
                } else {
                    rightSpaceRemaining = rightStartX
                }
                let expandableNodes = countExpandableNodes(right)
                if (expandableNodes > 0) && (expandableNodes < rightSpaceRemaining) && (rightSpaceRemaining > 0) {
                    reloop = true
                    expandExpandableNodes(right)
                    rightWidth = getWidth(right)
                    rightEndX = width
                    rightStartX = rightEndX - rightWidth
                }
            }
            
            
            if middleExists {
                
                var middleSpaceRemainingLeft: Int = 0
                var middleSpaceRemainingRight: Int = 0
                
                if leftExists {
                    middleSpaceRemainingLeft = middleStartX - leftEndX
                } else {
                    middleSpaceRemainingLeft = middleStartX
                }
                
                if rightExists {
                    middleSpaceRemainingRight = rightStartX - middleEndX
                } else {
                    middleSpaceRemainingRight = width - middleEndX
                }
                
                if middleSpaceRemainingLeft < 0 {
                    print("[[[[?? 1 ??]]]]")
                    middleSpaceRemainingLeft = 0
                }
                if middleSpaceRemainingRight < 0 {
                    print("[[[[?? 2 ??]]]]")
                    middleSpaceRemainingRight = 0
                }
                
                
                let expandableNodes = countExpandableNodes(middle)
                if expandableNodes > 0 {
                    if middleFlex == true || middleCentered == false {
                        if expandableNodes <= (middleSpaceRemainingLeft + middleSpaceRemainingRight) {
                            reloop = true
                            expandExpandableNodes(middle)
                            for _ in 0..<expandableNodes {
                                if (middleExpansionCountRight < middleExpansionCountLeft && middleSpaceRemainingRight > 0) || (middleSpaceRemainingLeft <= 0) {
                                    middleEndX += 1
                                    middleExpansionCountRight += 1
                                    middleSpaceRemainingRight -= 1
                                } else { //if middleSpaceRemainingLeft always > 0...
                                    middleStartX -= 1
                                    middleExpansionCountLeft += 1
                                    middleSpaceRemainingLeft -= 1
                                    
                                }
                            }
                            
                            //let computedMiddleWidth = middleEndX - middleStartX
                            //middleWidth = getWidth(middle)
                            
                            middleWidth = middleEndX - middleStartX
                        }
                    } else {
                        
                        var requiredExpansionRight: Int = 0
                        var requiredExpansionLeft: Int = 0
                        
                        var rightSide: Bool = false
                        
                        if middleExpansionCountRight < middleExpansionCountLeft {
                            rightSide = true
                        }
                        
                        
                        for _ in 0..<expandableNodes {
                            if rightSide {
                                requiredExpansionRight += 1
                                rightSide = false
                            } else {
                                requiredExpansionLeft += 1
                                rightSide = true
                            }
                        }
                        
                        if (requiredExpansionRight < middleSpaceRemainingRight) && (requiredExpansionLeft < middleSpaceRemainingLeft) {
                            
                            reloop = true
                            expandExpandableNodes(middle)
                            
                            for _ in 0..<expandableNodes {
                                if middleExpansionCountRight < middleExpansionCountLeft {
                                    middleEndX += 1
                                    middleExpansionCountRight += 1
                                    middleSpaceRemainingRight -= 1
                                } else { //if middleSpaceRemainingLeft always > 0...
                                    middleStartX -= 1
                                    middleExpansionCountLeft += 1
                                    middleSpaceRemainingLeft -= 1
                                }
                            }
                            
                            //let computedMiddleWidth = middleEndX - middleStartX
                            //middleWidth = getWidth(middle)
                            middleWidth = middleEndX - middleStartX
                            //print("MW2 Comp(\(computedMiddleWidth)) Real(\(middleWidth))")
                            
                        }
                    }
                }
            }
        }
        
        
        
        
        
        
        if leftExists {
            var x = leftStartX + left[0].spacingLeft
            for i: Int in 0..<left.count {
                let node = left[i]
                node.x = x
                x += node.width
                x += node.spacingRight
            }
        }
        
        if middleExists {
            var x = middleStartX + middle[0].spacingLeft
            for i: Int in 0..<middle.count {
                let node = middle[i]
                node.x = x
                x += node.width
                x += node.spacingRight
            }
        }
        
        if rightExists {
            var x = rightStartX + right[0].spacingLeft
            for i: Int in 0..<right.count {
                let node = right[i]
                node.x = x
                x += node.width
                x += node.spacingRight
            }
        }
    }
    
    private class func getMinimumWidth(_ nodes: [LayoutNode]) -> Int {
        var result: Int = getTotalSpacing(nodeSequence: nodes)
        for node in nodes {
            result += node.minimumWidth
        }
        return result
    }
    
    private class func getPreferredWidth(_ nodes: [LayoutNode]) -> Int {
        var result: Int = getTotalSpacing(nodeSequence: nodes)
        for node in nodes {
            result += node.preferredWidth
        }
        return result
    }
    
    private class func getWidth(_ nodes: [LayoutNode]) -> Int {
        var result: Int = getTotalSpacing(nodeSequence: nodes)
        for node in nodes {
            result += node.width
        }
        return result
    }
    
    private class func getTotalSpacing(nodeSequence nodes: [LayoutNode]) -> Int {
        var result: Int = 0
        if nodes.count > 0 {
            result += nodes[0].spacingLeft
            result += nodes[nodes.count - 1].spacingRight
            if nodes.count > 1 {
                for i: Int in 0..<(nodes.count - 1) {
                    result += nodes[i].spacingRight
                }
            }
        }
        return result
    }
    
    
    private class func layoutOverflowingMinimumWidth(_ nodes: [LayoutNode], width: Int) {
        
        /*
         var didContractAnySpaces: Bool = false
         
         var newNodes = nodes.map { $0.clone() }
         
         repeat {
         
         for node in newNodes {
         
         if node.spacingLeft > 1 {
         node.spacingLeft -= 1
         didContractAnySpaces = true
         }
         
         if node.spacingRight > 1 {
         node.spacingRight -= 1
         didContractAnySpaces = true
         }
         }
         
         if didContractAnySpaces {
         if getMinimumWidth(newNodes) <= width {
         for i in 0..<nodes.count {
         let node = nodes[i]
         let newNode = newNodes[i]
         node.clone(fromNode: newNode)
         }
         print("*** CONTRACTED SPACING NODES DO FIT ***")
         
         layoutOverflowingMinimumWidth(nodes, width: width)
         return
         }
         }
         
         
         
         } while didContractAnySpaces == true
         
         
         print("*** UNABLE TO CONTRACT SPACES ***")
         
         
         //for node in nodes {
         //    let newNode = node.clone()
         //    newNodes.append(newNode)
         //}
         */
        
        
    }
    
    
    private class func countExpandableNodes(_ nodes: [LayoutNode]) -> Int {
        var result: Int = 0
        for node in nodes {
            if ((node.width < node.preferredWidth) || node.flexibleWidth) { result += 1 }
        }
        return result
    }
    
    
    private class func expandExpandableNodes(_ nodes: [LayoutNode]) {
        for node in nodes {
            if ((node.width < node.preferredWidth) || node.flexibleWidth) { node.width += 1 }
        }
    }
    
    
    
    class func printNodes(_ nodes: [LayoutNode]) {
        
        print("-=-=-=-=-=-=-=-=-=-=-=-")
        print("-=-=-=-=-=-=-=-")
        print("-=-=-=-=-=-=-=-=-=-=-=-")
        
        
        for i in 0..<nodes.count {
            
            let node = nodes[i]
            
            var ss: String = "L"
            if node.side == .middle { ss = "M" }
            if node.side == .right { ss = "R" }
            
            print("Node[\(i)] (\(node.name)) s: \(ss) mw: \(Int(node.minimumWidth)) pw: \(Int(node.preferredWidth)) sl:\(node.spacingLeft) sr:\(node.spacingRight) ")
        }
        
        print("-=-=-=-=-=-=-=-=-=-=-=-")
        print("-=-=-=-=-=-=-=-")
        print("-=-=-=-=-=-=-=-=-=-=-=-")
        
    }
}

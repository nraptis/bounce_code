//
//  Blob.swift
//
//  Created by Raptis, Nicholas on 8/22/16.
//

import UIKit
import OpenGLES

struct BlobGridNode {
    
    //Relative to (x=0, y=0).
    var pointBase:CGPoint = CGPoint.zero
    
    //Transformed to user's view.
    var point:CGPoint = CGPoint.zero
    
    //Index in the triangle list, we only store each data point once.
    var meshIndex:Int?
    
    var center = CGPoint.zero
    
    //Is it an edge?
    var edgeU:Bool = false
    var edgeR:Bool = false
    var edgeD:Bool = false
    var edgeL:Bool = false
    
    //Edge indeces in the triangle list, we only store each data point once.
    var meshIndexEdgeU:Int?
    var meshIndexEdgeR:Int?
    var meshIndexEdgeD:Int?
    var meshIndexEdgeL:Int?
    
    //Exact points where the adjacent edges are.
    var edgePointBaseU:CGPoint = CGPoint.zero
    var edgePointBaseR:CGPoint = CGPoint.zero
    var edgePointBaseD:CGPoint = CGPoint.zero
    var edgePointBaseL:CGPoint = CGPoint.zero
    
    
    var edgePointU:CGPoint = CGPoint.zero
    var edgePointR:CGPoint = CGPoint.zero
    var edgePointD:CGPoint = CGPoint.zero
    var edgePointL:CGPoint = CGPoint.zero
    
    //texture coordinates (u, v) of the transformed point on the background image.
    var texturePoint:CGPoint = CGPoint.zero
    
    //Is it inside the border outline?
    var inside:Bool = false
    
    var color:UIColor = UIColor.white
}

class Blob
{
    var isAltBlob: Bool = false
    //var name: String = "blob 0"
    
    var motionController: BlobMotionController!
    var orbitMotionController = BlobMotionControllerOrbiter()
    var bulgeBouncerMotionController = BlobMotionControllerBulgeBouncer()
    var twistMotionController = BlobMotionControllerTwister()
    var crazyMotionController = BlobMotionControllerCrazy()
    var motionControllers = [BlobMotionController]()
    
    internal var modeChangeResetMotionController: Bool = true
    
    internal var grid = [[BlobGridNode]]()
    
    internal var gridWidth: Int = 0
    internal var gridHeight: Int = 0
    
    internal let gridWidthMax: Int = 64
    internal let gridHeightMax: Int = 64
    
    internal var meshNodes = BlobMeshBuffer()
    internal var meshNodesBase = BlobMeshBuffer()
    
    fileprivate var centerMarkerRotation: CGFloat = 0.0
    
    weak var touch:UITouch?
    
    var spline = CubicSpline()
    
    var valid: Bool = false
    
    var simplePolygon: Bool = false
    
    var selected: Bool = false
    var selectedControlPointIndex: Int?
    
    var tri = IndexTriangleList()
    var vertexBuffer = [GLfloat]()
    
    var frozen: Bool = false  { didSet { setNeedsComputeWeight() } }
    
    var vertexBufferStereoLeft = [GLfloat]()
    var vertexBufferStereoRight = [GLfloat]()
    
    private var vertexBufferSlot:BufferIndex?
    private var indexBufferSlot:BufferIndex?
    
    var linesBase = LineSegmentBuffer()
    var linesInner = LineSegmentBuffer()
    var linesInnerSelected = LineSegmentBuffer()
    var linesInnerInvalid = LineSegmentBuffer()
    var linesOuter = LineSegmentBuffer()
    
    var linesMeshUnderlay = LineSegmentBuffer()
    var linesMesh = LineSegmentBuffer()
    
    var isGrabbed: Bool {
        if grabSelectionGesture { return true }
        if grabSelectionTouch !== nil { return true }
        return false
    }
    
    var isSelectable: Bool {
        if let engine = ApplicationController.shared.engine {
            if engine.sceneMode == .edit {
                if frozen { return false }
            }
        }
        return true
    }
    
    var grabSelectionGesture: Bool = false
    weak var grabSelectionTouch: UITouch?
    
    var grabAnimationTargetOffsetStart:CGPoint = CGPoint(x: 0.0, y: 0.0)
    var grabAnimationTargetOffsetTouchStart:CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    private var _previousBulgeWeightOffset = CGPoint.zero
    var bulgeWeightOffset = CGPoint.zero {
        willSet {
            _previousBulgeWeightOffset = bulgeWeightOffset
        }
        didSet {
            if bulgeWeightOffset.x != _previousBulgeWeightOffset.x || bulgeWeightOffset.y != _previousBulgeWeightOffset.y {
                setNeedsComputeWeight()
            }
        }
    }
    
    var drawBulgeCenterFactor: Bool = false
    fileprivate var _previousBulgeCenterFactor:CGFloat = 0.5
    var bulgeCenterFactor:CGFloat = 0.5 {
        willSet {
            _previousBulgeCenterFactor = bulgeCenterFactor
        }
        didSet {
            if _previousBulgeCenterFactor != bulgeCenterFactor {
                setNeedsComputeWeight()
            }
        }
    }
    
    var drawBulgeEdgeFactor: Bool = false
    private var _previousBulgeEdgeFactor: CGFloat = 0.85
    var bulgeEdgeFactor: CGFloat = 0.85 {
        willSet {
            _previousBulgeEdgeFactor = bulgeEdgeFactor
        }
        didSet {
            if _previousBulgeEdgeFactor != bulgeEdgeFactor {
                setNeedsComputeWeight()
            }
        }
    }
    
    var bulgeWeightCenter: CGPoint {
        set { bulgeWeightOffset = untransformPoint(point: newValue) }
        get { return transformPoint(point: bulgeWeightOffset) }
    }
    
    //Base = untransformed, no Base = transformed...
    private var borderBase = PointList()
    var border = PointList()
    
    var borderPerimeterBase: CGFloat = 0.0
    var borderPerimeter: CGFloat = 0.0
    
    var borderArea: CGFloat = 0.0
    
    //dragFalloffInputCap > dragFalloffDampenInputMax > dragFalloffDampenResultMax > dragFalloffDampenStart
    var dragFalloffInputCap: CGFloat = 0.0
    var dragFalloffDampenInputMax: CGFloat = 0.0
    var dragFalloffDampenResultMax: CGFloat = 0.0
    var dragFalloffDampenStart: CGFloat = 0.0
    
    
    var center:CGPoint = CGPoint(x: 256, y: 256) { didSet { setNeedsComputeAffine() } }
    var scale:CGFloat = 1.0 { didSet { setNeedsComputeAffine() } }
    var rotation:CGFloat = 0.0 { didSet { setNeedsComputeAffine() } }
    
    //Computer value - essentially the location of
    //the center-most node with a total weight of MAX...
    //
    var twistCenterBase = CGPoint.zero
    var twistCenter = CGPoint.zero
    
    var animationTarget = CGPoint.zero
    
    func setNeedsComputeShape() { needsComputeShape = true }
    internal var needsComputeShape: Bool = true
    func setNeedsComputeWeight() { needsComputeWeight = true }
    internal var needsComputeWeight: Bool = true
    func setNeedsComputeAffine() { needsComputeAffine = true }
    internal var needsComputeAffine: Bool = true
    internal var boundingBox: CGRect = CGRect.zero
    
    //var enabled: Bool {
    //    return true
    //}
    
    init() {
        
        bulgeBouncerMotionController.blob = self
        bulgeBouncerMotionController.name = "bulge"
        motionControllers.append(bulgeBouncerMotionController)
        
        twistMotionController.blob = self
        twistMotionController.name = "twist"
        motionControllers.append(twistMotionController)
        
        crazyMotionController.blob = self
        crazyMotionController.name = "crazy"
        motionControllers.append(crazyMotionController)
        
        orbitMotionController.blob = self
        orbitMotionController.name = "orbit"
        motionControllers.append(orbitMotionController)
        
        motionController = orbitMotionController
        
        vertexBufferSlot = Graphics.bufferGenerate()
        indexBufferSlot = Graphics.bufferGenerate()
        
        linesInner.color = Color(1.0, 1.0, 1.0, 1.0)
        linesInnerSelected.color = Color(1.0, 0.9825, 0.25, 1.0)
        linesInnerInvalid.color = Color(0.5, 0.0, 0.0, 1.0)
        linesOuter.color = Color(0.625, 0.625, 0.625, 1.0)
        linesMeshUnderlay.color = Color(0.625, 0.625, 0.625, 1.0)
        linesMesh.color = Color(1.0, 1.0, 1.0, 1.0)
        
        if Device.isTablet {
            linesMeshUnderlay.thickness = 0.8
            linesMesh.thickness = 0.55
        } else {
            linesMeshUnderlay.thickness = 0.6
            linesMesh.thickness = 0.4
        }
        
        
        
        grid = [[BlobGridNode]](repeating: [BlobGridNode](repeating: BlobGridNode(), count: gridHeightMax), count: gridWidthMax)
        
        var radius = min(ApplicationController.shared.width, ApplicationController.shared.height)
        var pointCount = 8
        
        if Device.isTablet {
            pointCount = 10
            radius = radius / 6
        } else {
            radius = radius / 6
        }
        
        for i in 0..<pointCount {
            let percent = CGFloat(i) / CGFloat(pointCount)
            let rads = percent * Math.PI2
            spline.add(sin(rads) * radius, y: -cos(rads) * radius)
        }
        spline.linear = false
        spline.closed = true
        computeShape()
    }
    
    deinit {
        Graphics.bufferDelete(bufferIndex: vertexBufferSlot)
        vertexBufferSlot = nil
        
        Graphics.bufferDelete(bufferIndex: indexBufferSlot)
        indexBufferSlot = nil
    }
    
    func update() {
        
        var isEditMode = false
        var isViewMode = false
        
        var isEditModeAffine = false
        var isEditModeShape = false
        
        if let engine = ApplicationController.shared.engine {
            if engine.sceneMode == .edit {
                isEditMode = true
                if engine.editMode == .affine { isEditModeAffine = true }
                if engine.editMode == .shape {
                    isEditModeShape = true
                }
            }
            if engine.sceneMode == .view {
                isViewMode = true
            }
        }
        
        motionController.update()
        
        if isViewMode {
            
            if isGrabbed == false {
                //for mc in motionControllers {
                //    if mc !== motionController {
                //        mc.reset(alt: isAltBlob)
                //    }
                //}
            }
        } else {
            
            if modeChangeResetMotionController {
                for mc in motionControllers {
                    mc.reset(alt: isAltBlob)
                }
                modeChangeResetMotionController = false
            }
        }
        
        if isViewMode == false {
            cancelGuideMotion()
        }
        
        centerMarkerRotation += Math.PI / 20
        if centerMarkerRotation >= Math.PI2 { centerMarkerRotation -= Math.PI2 }
        
    }
    
    func drawMesh() {
        guard valid else {
            return
        }
        
        guard let engine = ApplicationController.shared.engine else {
            valid = false
            return
        }
        
        let sprite = engine.background
        
        guard ApplicationController.shared.bounce != nil else {
            valid = false
            return
        }
        
        let stereo = ApplicationController.shared.engine!.stereoscopic
        let stereoChannel = ApplicationController.shared.engine!.stereoscopicChannel
        let stereoOffset: CGFloat = ApplicationController.shared.engine!.stereoscopicSpreadOffset
        let stereoBase: CGFloat = ApplicationController.shared.engine!.stereoscopicSpreadBase
        
        computeIfNeeded()
        
        let indexBufferCount = tri.count * 3
        let vertexBufferCount = meshNodes.count * 30
        if vertexBuffer.count < vertexBufferCount {
            vertexBuffer.reserveCapacity(vertexBufferCount)
            while(vertexBuffer.count < vertexBufferCount) {
                vertexBuffer.append(0.0)
                vertexBufferStereoLeft.append(0.0)
                vertexBufferStereoRight.append(0.0)
            }
        }
        
        ShaderProgramMesh.shared.colorSet()
        
        var r:CGFloat = 0.125
        var g:CGFloat = 0.65
        var b:CGFloat = 0.125
        var a:CGFloat = 0.35
        
        var vertexIndex:Int = 0
        if ApplicationController.shared.engine?.sceneMode == .edit {
            
            Graphics.textureDisable()
            //ShaderProgramMesh.shared.textureBlankBind()
            
            Graphics.blendEnable()
            Graphics.blendSetAlpha()
            
            if ApplicationController.shared.editMode == .distribution {
                
                var outerR:CGFloat = r
                var outerG:CGFloat = g
                var outerB:CGFloat = b
                var outerA:CGFloat = a
                
                var innerR:CGFloat = 1.0
                var innerG:CGFloat = 0.0
                var innerB:CGFloat = 0.0
                var innerA:CGFloat = 0.65
                
                if drawBulgeEdgeFactor {
                    innerR = 1.0
                    innerG = 0.075
                    innerB = 0.075
                    outerR = 0.075
                    outerG = 0.075
                    outerB = 1.0
                }
                
                if drawBulgeCenterFactor {
                    innerR = 1.0
                    innerG = 0.075
                    innerB = 0.075
                    outerR = 0.075
                    outerG = 0.075
                    outerB = 1.0
                }
                
                if selected {
                    outerA = 0.55
                    innerA = 0.85
                }
                
                if frozen {
                    innerR = 0.88
                    innerG = 0.88
                    innerB = 0.88
                    outerR = 0.88
                    outerG = 0.88
                    outerB = 0.88
                }
                
                for nodeIndex in 0..<meshNodes.count {
                    let node = meshNodes.data[nodeIndex]
                    var percent: CGFloat = 0.0
                    
                    if drawBulgeEdgeFactor {
                        percent = node.edgeFactor
                    } else if drawBulgeCenterFactor {
                        percent = node.weightFactor
                    } else {
                        percent = node.factor
                    }
                    
                    r = outerR + (innerR - outerR) * percent
                    g = outerG + (innerG - outerG) * percent
                    b = outerB + (innerB - outerB) * percent
                    a = outerA + (innerA - outerA) * percent
                    
                    node.r = r;node.g = g;node.b = b;node.a = a
                    node.writeToTriangleList(&vertexBuffer, index: vertexIndex)
                    
                    vertexIndex += 10
                }
            } else {
                if frozen {
                    r = 0.88; g = 0.88; b = 0.88; a = 0.25
                } else if selected {
                    r = 0.1; g = 1.0; b = 0.2; a = 0.525
                }
                
                for nodeIndex in 0..<meshNodes.count {
                    let node = meshNodes.data[nodeIndex]
                    node.r = r;node.g = g;node.b = b;node.a = a
                    node.writeToTriangleList(&vertexBuffer, index: vertexIndex)
                    vertexIndex += 10
                }
            }
        } else if ApplicationController.shared.engine?.sceneMode == .view {
            Graphics.textureEnable()
            Graphics.textureBind(texture: sprite.texture)
            Graphics.blendDisable()
            
            let animationTargetOffset = motionController.animationTargetOffset
            
            let animationCenter = bulgeWeightCenter
            animationTarget = CGPoint(x: animationCenter.x + animationTargetOffset.x, y: animationCenter.y + animationTargetOffset.y)
            
            r = 1.0;g = 1.0;b = 1.0;a = 1.0
            if stereo {
                if stereoChannel {
                    r = 0.0
                } else {
                    g = 0.0
                    b = 0.0
                }
            }
            
            for nodeIndex in 0..<meshNodes.count {
                let node = meshNodes.data[nodeIndex]
                
                var diffX: CGFloat = twistCenter.x - node.x
                var diffY: CGFloat = twistCenter.y - node.y
                var dist = diffX * diffX + diffY * diffY
                var rot: CGFloat = 0.0
                if dist > Math.epsilon {
                    dist = CGFloat(sqrtf(Float(dist)))
                    rot = Math.faceTarget(target: CGPoint(x: -diffX, y: -diffY))
                    diffX /= dist
                    diffY /= dist
                } else {
                    diffX = 0.0
                    diffY = 0.0
                }
                
                rot += motionController.twistRotation * node.factor * 0.3125
                
                let dirX: CGFloat = Math.sinr(radians: rot)
                let dirY: CGFloat = -Math.cosr(radians: rot)
                
                let scaleFactor:CGFloat = 1.0 + (motionController.inflateScale - 1.0) * node.factor * 1.125
                
                let nodeX = twistCenter.x + dirX * dist * scaleFactor
                let nodeY = twistCenter.y + dirY * dist * scaleFactor
                
                let animX = nodeX + animationTargetOffset.x * node.factor
                let animY = nodeY + animationTargetOffset.y * node.factor
                
                if stereo {
                    node.animX = animX + (stereoBase + stereoOffset * node.factor)
                } else {
                    node.animX = animX
                }
                
                node.animY = animY
                node.animZ = node.factor * 256.0
                
                node.r = r;node.g = g;node.b = b;node.a = a
                node.writeToTriangleListAnimated(&vertexBuffer, index: vertexIndex)
                
                vertexIndex += 10
            }
        }
        
        if vertexIndex > 0 && indexBufferCount > 0 {
            Graphics.bufferVertexSetData(bufferIndex: vertexBufferSlot, data: &vertexBuffer, size: vertexIndex)
            
            ShaderProgramMesh.shared.positionEnable()
            ShaderProgramMesh.shared.positionSetPointer(size: 3, offset: 0, stride: 10)
            ShaderProgramMesh.shared.texCoordEnable()
            ShaderProgramMesh.shared.textureCoordSetPointer(size: 3, offset: 3, stride: 10)
            ShaderProgramMesh.shared.colorArrayEnable()
            ShaderProgramMesh.shared.colorArraySetPointer(size: 4, offset: 6, stride: 10)
            Graphics.bufferIndexSetData(bufferIndex: indexBufferSlot, data: &tri.indeces, size: indexBufferCount)
            Graphics.drawElementsTriangle(count:indexBufferCount, offset: 0)
            
        }
        
        Graphics.blendEnable()
        Graphics.blendSetAlpha()
        
    }
    
    func drawMarkers() {
        
        computeIfNeeded()
        
        guard let screenScale = BounceViewController.shared?.screenScale else {
            return
        }
        
        var markerScale: CGFloat = 1.0
        if screenScale > 1.0 {
            markerScale = 1.0 / screenScale
        }
        
        if selected {
            if Device.isTablet {
                linesOuter.thickness = 2.5 * markerScale
                linesInner.thickness = 1.5 * markerScale
                linesInnerSelected.thickness = 1.5 * markerScale
                linesInnerInvalid.thickness = 1.5 * markerScale
            } else {
                linesOuter.thickness = 1.75 * markerScale
                linesInner.thickness = 1.0 * markerScale
                linesInnerSelected.thickness = 1.0 * markerScale
                linesInnerInvalid.thickness = 1.0 * markerScale
            }
        } else {
            if Device.isTablet {
                linesOuter.thickness = 2.0 * markerScale
                linesInner.thickness = 1.0 * markerScale
                linesInnerSelected.thickness = 1.0 * markerScale
                linesInnerInvalid.thickness = 1.0 * markerScale
            } else {
                linesOuter.thickness = 1.5 * markerScale
                linesInner.thickness = 0.75 * markerScale
                linesInnerSelected.thickness = 0.75 * markerScale
                linesInnerInvalid.thickness = 0.75 * markerScale
            }
        }
        
        var isEditMode = false
        var isViewMode = false
        
        var isEditModeAffine = false
        var isEditModeShape = false
        var isEditModeDistribution = false
        
        
        var shapeSelectionControlPointIndex:Int?
        
        if let engine = ApplicationController.shared.engine {
            if engine.sceneMode == .edit {
                isEditMode = true
                if engine.editMode == .affine { isEditModeAffine = true }
                if engine.editMode == .shape {
                    isEditModeShape = true
                    if selected {
                        shapeSelectionControlPointIndex = selectedControlPointIndex
                    }
                }
                if engine.editMode == .distribution { isEditModeDistribution = true }
            }
            if engine.sceneMode == .view {
                isViewMode = true
            }
        }
        
        if isEditMode {
            Graphics.blendEnable()
            Graphics.blendSetPremultiplied()
            if isEditModeShape {
                ShaderProgramSimple.shared.use()
                linesOuter.draw()
                ShaderProgramSimple.shared.colorSet()
                
                
                ShaderProgramSprite.shared.use()
                ShaderProgramSprite.shared.colorSet()
                
                if frozen == false {
                    for i in 0..<spline.controlPointCount {
                        let point = transformPoint(point: spline.getControlPoint(i))
                        if shapeSelectionControlPointIndex == i {
                            BounceViewController.shared?.controlPointSelectedUnderlay.drawCentered(pos: point, scale: markerScale)
                        } else {
                            BounceViewController.shared?.controlPointUnderlay.drawCentered(pos: point, scale: markerScale)
                        }
                    }
                }
                
                ShaderProgramSimple.shared.use()
                if valid {
                    
                    if selected {
                        linesInnerSelected.draw()
                    } else {
                        linesInner.draw()
                    }
                } else {
                    linesInnerInvalid.draw()
                }
                ShaderProgramSimple.shared.colorSet()
                
                ShaderProgramSprite.shared.use()
                ShaderProgramSprite.shared.colorSet()
                
                
                //controlPoint.load(path: "control_point")
                //controlPointActive.load(path: "control_point_active")
                //controlPointUnderlay.load(path: "control_point_underlay")
                
                //controlPointSelected.load(path: "control_point_selected")
                //controlPointActiveSelected.load(path: "control_point_active_selected")
                //controlPointSelectedUnderlay.load(path: "control_point_underlay_selected")
                
                
                if frozen == false {
                    for i in 0..<spline.controlPointCount {
                        let point = transformPoint(point: spline.getControlPoint(i))
                        if shapeSelectionControlPointIndex == i {
                            if selected {
                                BounceViewController.shared?.controlPointActiveSelected.drawCentered(pos: point, scale: markerScale)
                            } else {
                                BounceViewController.shared?.controlPointSelected.drawCentered(pos: point, scale: markerScale)
                            }
                        } else {
                            if selected {
                                BounceViewController.shared?.controlPointActive.drawCentered(pos: point, scale: markerScale)
                            } else {
                                BounceViewController.shared?.controlPoint.drawCentered(pos: point, scale: markerScale)
                            }
                        }
                    }
                }
                
                ShaderProgramMesh.shared.use()
                ShaderProgramMesh.shared.colorSet()
                
            } else {
                
                ShaderProgramSimple.shared.use()
                linesOuter.draw()
                if selected {
                    linesInnerSelected.draw()
                } else {
                    linesInner.draw()
                }
                ShaderProgramSimple.shared.colorSet()
            }
            
            if isEditModeDistribution {
                
                let bulgeCenterMarkerPos = bulgeWeightCenter
                
                ShaderProgramSprite.shared.use()
                ShaderProgramSprite.shared.colorSet()
                
                if selected {
                    
                    ApplicationController.shared.bounce!.bulgeMarkerCenterSelected.drawCentered(pos: bulgeCenterMarkerPos, scale: markerScale, rot: 0.0)
                    ApplicationController.shared.bounce!.bulgeMarkerSpinnerSelected.drawCentered(pos: bulgeCenterMarkerPos, scale: markerScale, rot: centerMarkerRotation)
                } else {
                    ApplicationController.shared.bounce!.bulgeMarkerCenter.drawCentered(pos: bulgeCenterMarkerPos, scale: markerScale, rot: 0.0)
                    ApplicationController.shared.bounce!.bulgeMarkerSpinner.drawCentered(pos: bulgeCenterMarkerPos, scale: markerScale, rot: centerMarkerRotation)
                }
                ApplicationController.shared.bounce!.bulgeMarkerOutline.drawCentered(pos: bulgeCenterMarkerPos, scale: markerScale, rot: 0.0)
            }
        }
        
        Graphics.blendEnable()
        Graphics.blendSetAlpha()
        
        ShaderProgramMesh.shared.use()
    }
    
    
    func drawOverlayMarkers() {
        
        computeIfNeeded()
        
        if Device.isTablet {
            linesOuter.thickness = 1.2
            linesInner.thickness = 0.8
        } else {
            linesOuter.thickness = 1.0
            linesInner.thickness = 0.6
        }
        
        Graphics.blendEnable()
        Graphics.blendSetPremultiplied()
        
        ShaderProgramSimple.shared.use()
        ShaderProgramSimple.shared.colorSet()
        
        var meshLineIndex: Int = 0
        
        linesMeshUnderlay.reset()
        linesMesh.reset()
        
        var prev = borderBase.data[borderBase.count - 1]
        for i in 0..<borderBase.count {
            let point = borderBase.data[i]
            linesBase.set(index: i, p1: prev, p2: point)
            borderPerimeterBase += Math.dist(p1: prev, p2: point)
            prev = point
        }
        
        var x: Int = 0
        var y: Int = 0
        
        let meshWidth: Int = grid.count
        if meshWidth > 0 {
            let meshHeight: Int = grid[0].count
            x = 1
            while x<meshWidth {
                y = 1
                while y<meshHeight {
                    if let index = grid[x][y].meshIndex {
                        let nodeX: CGFloat = meshNodes.data[index].animX
                        let nodeY: CGFloat = meshNodes.data[index].animY
                        var altX: CGFloat = nodeX
                        var altY: CGFloat = nodeY
                        
                        if let indexL = grid[x-1][y].meshIndex {
                            altX = meshNodes.data[indexL].animX
                            altY = meshNodes.data[indexL].animY
                            addRenderLine(meshLineIndex, nodeX, nodeY, altX, altY)
                            meshLineIndex += 1
                        }
                        
                        if let indexU = grid[x][y-1].meshIndex {
                            altX = meshNodes.data[indexU].animX
                            altY = meshNodes.data[indexU].animY
                            addRenderLine(meshLineIndex, nodeX, nodeY, altX, altY)
                            meshLineIndex += 1
                        }
                    }
                    y += 1
                }
                x += 1
            }
            
            x = 0
            while x<meshWidth {
                y = 0
                while y<meshHeight {
                    if let index = grid[x][y].meshIndex {
                        let nodeX: CGFloat = meshNodes.data[index].animX
                        let nodeY: CGFloat = meshNodes.data[index].animY
                        var altX: CGFloat = nodeX
                        var altY: CGFloat = nodeY
                        
                        if let indexU = grid[x][y].meshIndexEdgeU {
                            altX = meshNodes.data[indexU].animX
                            altY = meshNodes.data[indexU].animY
                            addRenderLine(meshLineIndex, nodeX, nodeY, altX, altY)
                            meshLineIndex += 1
                        }
                        
                        if let indexR = grid[x][y].meshIndexEdgeR {
                            altX = meshNodes.data[indexR].animX
                            altY = meshNodes.data[indexR].animY
                            addRenderLine(meshLineIndex, nodeX, nodeY, altX, altY)
                            meshLineIndex += 1
                        }
                        
                        if let indexD = grid[x][y].meshIndexEdgeD {
                            altX = meshNodes.data[indexD].animX
                            altY = meshNodes.data[indexD].animY
                            addRenderLine(meshLineIndex, nodeX, nodeY, altX, altY)
                            meshLineIndex += 1
                        }
                        
                        if let indexL = grid[x][y].meshIndexEdgeL {
                            altX = meshNodes.data[indexL].animX
                            altY = meshNodes.data[indexL].animY
                            addRenderLine(meshLineIndex, nodeX, nodeY, altX, altY)
                            meshLineIndex += 1
                        }
                    }
                    y += 1
                }
                x += 1
            }
        }
        
        linesOuter.draw()
        linesMeshUnderlay.draw()
        
        linesInner.draw()
        linesMesh.draw()
        
        ShaderProgramMesh.shared.use()
        ShaderProgramMesh.shared.colorSet()
        
        Graphics.blendEnable()
        Graphics.blendSetAlpha()
        
    }
    
    func addRenderLine(_ index: Int, _ p1_x: CGFloat, _ p1_y: CGFloat, _ p2_x: CGFloat, _ p2_y: CGFloat) {
        
        
        linesMeshUnderlay.add(p1: CGPoint(x: p1_x, y: p1_y), p2: CGPoint(x: p2_x, y: p2_y))
        linesMesh.add(p1: CGPoint(x: p1_x, y: p1_y), p2: CGPoint(x: p2_x, y: p2_y))
        
        //ShaderProgramSimple.shared.lineDraw(p1: CGPoint(x: p1_x, y: p1_y), p2: CGPoint(x: p2_x, y: p2_y), thickness: 1.0)
        
    }
    
    func resetAll() {
        handleAnimationEnabledChanged()
        handleAnimationBounceEnabledChanged()
        resetMotionControllers()
        modeChangeResetMotionController = true
        cancelGuideMotion()
    }
    
    func resetMotionControllers() {
        for mc in motionControllers {
            mc.reset(alt: isAltBlob)
        }
    }
    
    func useMotionControllerAutoLooper() {
        if motionController !== bulgeBouncerMotionController {
            motionController.reset(alt: isAltBlob)
            motionController = bulgeBouncerMotionController
        }
    }
    
    func useMotionControllerTwister() {
        if motionController !== twistMotionController {
            motionController.reset(alt: isAltBlob)
            motionController = twistMotionController
        }
    }
    
    func useMotionControllerCrazy() {
        if motionController !== crazyMotionController {
            motionController.reset(alt: isAltBlob)
            motionController = crazyMotionController
        }
    }
    
    func useMotionControllerOrbiter() {
        if motionController !== orbitMotionController {
            motionController.reset(alt: isAltBlob)
            motionController = orbitMotionController
        }
    }
    
    func dragAnimationTargetOffsetDampened(withNewOffset newOffset: CGPoint) -> Void {
        
        if motionController === orbitMotionController {
            orbitMotionController.drag(withGuideOffset: newOffset)
        }
        
        /*
         var offsetDir = newOffset
         var offSetLength: CGFloat = newOffset.x * newOffset.x + newOffset.y * newOffset.y
         if offSetLength > Math.epsilon {
         offSetLength = CGFloat(sqrtf(Float(offSetLength)))
         offsetDir = CGPoint(x: offsetDir.x / offSetLength, y: offsetDir.y / offSetLength)
         }
         offSetLength = BounceEngine.fallOffDampen(input: offSetLength, falloffStart: dragFalloffDampenStart, resultMax: dragFalloffDampenResultMax, inputMax: dragFalloffDampenInputMax)
         let adjustedOffset = CGPoint(x: offsetDir.x * offSetLength, y: offsetDir.y * offSetLength)
         
         motionController.animationTargetOffset = CGPoint(x: adjustedOffset.x, y: adjustedOffset.y)
         motionController.animationGuideOffset = CGPoint(x: newOffset.x, y: newOffset.y)
         motionController.didDrag = true
         motionController.dragLength = offSetLength
         */
    }
    
    /*
     func updateAnimationGuide(moving: Bool) {
     animationCycleDirection = calculateAnimationGuideDirection()
     
     
     let ellipseWidth = calculateAnimationGuideEllipseWidthPercent(moving: false)
     
     if animationCycleDirection < 1 {
     animationDesiredEllipseFactor = -ellipseWidth
     } else {
     animationDesiredEllipseFactor = ellipseWidth
     }
     
     if moving == true {
     animationDesiredEllipseFactor *= animationGuideRapidDecayFactor
     
     animationDesiredEllipseRadius = calculateAnimationGuideEllipseRadius()
     
     animationDesiredEllipseRadius = BounceEngine.fallOffDampen(input: animationDesiredEllipseRadius, falloffStart: dragFalloffDampenStart, resultMax: dragFalloffDampenResultMax, inputMax: dragFalloffDampenInputMax)
     }
     //animationGuideDesiredPeakSpeedFactor = calculateAnimationGuidePeakSpeedFactor()
     }
     */
    
    //Assumption: animationDesiredEllipseRadius is computed
    /*
     func calculateAnimationGuidePeakSpeedFactor() -> CGFloat {
     animationGuideHistorySpeedCount = 0
     if animationGuideHistoryCount < 6 {
     return animationGuideDesiredPeakSpeedFactor
     }
     
     var prev = animationGuideHistory[0]
     for i: Int in 1..<animationGuideHistoryCount {
     let point = animationGuideHistory[i]
     let diffX = point.x - prev.x
     let diffY = point.y - prev.y
     var dist = diffX * diffX + diffY * diffY
     if dist > Math.epsilon {
     dist = CGFloat(sqrtf(Float(dist)))
     }
     animationGuideHistorySpeed[animationGuideHistorySpeedCount] = dist
     animationGuideHistorySpeedCount += 1
     prev = CGPoint(x: point.x, y: point.y)
     }
     
     if animationGuideHistorySpeedCount < 4 {
     return animationGuideDesiredPeakSpeedFactor
     }
     
     for i: Int in 0..<animationGuideHistorySpeedCount {
     animationGuideHistorySpeedSorted[i] = animationGuideHistorySpeed[i]
     }
     
     var j: Int = 0
     var hold: CGFloat = 0.0
     for i: Int in 0..<animationGuideHistorySpeedCount {
     j = i
     while j > 0 && animationGuideHistorySpeedSorted[j] < animationGuideHistorySpeedSorted[j-1] {
     hold = animationGuideHistorySpeedSorted[j]
     animationGuideHistorySpeedSorted[j] = animationGuideHistorySpeedSorted[j-1]
     animationGuideHistorySpeedSorted[j-1] = hold
     j -= 1
     }
     }
     
     var count = 7
     if count > animationGuideHistorySpeedCount {
     count = animationGuideHistorySpeedCount
     }
     
     var speedSum: CGFloat = 0.0
     for i: Int in (animationGuideHistorySpeedCount - count)..<animationGuideHistorySpeedCount {
     speedSum += animationGuideHistorySpeedSorted[i]
     }
     speedSum /= CGFloat(count)
     
     var speedMax: CGFloat = 64.0
     if Device.isTablet == false {
     speedMax = 40.0
     }
     
     var result: CGFloat = (speedSum) / speedMax
     if result < 0.0 { result = 0.0 }
     if result > 1.0 { result = 1.0 }
     return result
     }
     */
    
    
    func captureFinalRelease(point: CGPoint) {
        if motionController === orbitMotionController {
            orbitMotionController.captureFinalRelease(point: point)
        }
    }
    
    func resetFinalRelease() {
        if motionController === orbitMotionController {
            orbitMotionController.resetFinalRelease()
        }
    }
    
    
    
    func releaseGrabFling() {
        if motionController === orbitMotionController {
            orbitMotionController.releaseGrabFling()
        }
        grabSelectionGesture = false
        grabSelectionTouch = nil
    }
    
    func computeWeight() {
        needsComputeWeight = false
        guard valid == true else { return }
        
        var minDist: CGFloat?
        var maxDist: CGFloat?
        
        for nodeIndex in 0..<meshNodesBase.count {
            let node = meshNodesBase.data[nodeIndex]
            let diffX = node.x - bulgeWeightOffset.x
            let diffY = node.y - bulgeWeightOffset.y
            var dist = diffX * diffX + diffY * diffY
            if dist > Math.epsilon {
                dist = CGFloat(sqrtf(Float(dist)))
            }
            if minDist != nil {
                if dist < minDist! { minDist = dist }
            } else { minDist = dist }
            
            if maxDist != nil {
                if dist > maxDist! { maxDist = dist }
            } else { maxDist = dist }
            node.weightDistance = dist
            node.weightPercent = 0.0
            node.weightPercentMin = 0.0
            node.weightPercentMax = 0.0
            node.factor = 0.0
            node.edgeFactor = node.edgePercentMin + (node.edgePercentMax - node.edgePercentMin) * bulgeEdgeFactor
        }
        
        
        //Prototype:
        //var maxCenterWeightDistance = dragFalloffDampenResultMax * 1.25
        //var minCenterWeightDistance = dragFalloffDampenStart * 0.75
        //var centerWeightDistance = minCenterWeightDistance + (maxCenterWeightDistance - minCenterWeightDistance) * bulgeCenterFactor
        
        
        if let minD = minDist, let maxD = maxDist { // && centerWeightDistance > Math.epsilon
            
            //var dragFalloffDampenResultMax: CGFloat = 0.0
            //var dragFalloffDampenStart: CGFloat = 0.0
            //linesOuter.color = Color(0.45, 0.45, 0.45, 1.0)
            
            //Note: This method doesn't produce enough variability in the way center motion and
            //edge clamping interact. We want the user to see some more notable effect...
            
            let spanD = maxD - minD
            //if spanD > Math.epsilon {
            if maxD > Math.epsilon && spanD > Math.epsilon {
                for nodeIndex in 0..<meshNodesBase.count {
                    let node = meshNodesBase.data[nodeIndex]
                    var percentFlattened = (node.weightDistance - minD) / spanD
                    var percent = (node.weightDistance) / (maxD * 0.5 + maxD * bulgeCenterFactor)
                    if percentFlattened > 1.0 {
                        percentFlattened = 1.0
                    }
                    if percentFlattened < 0.0 {
                        percentFlattened = 0.0
                    }
                    
                    percent = (1.0 - percent)
                    if percent >= 1.0 {
                        percent = 1.0
                        //node.weightPercentMin = 1.0
                        //node.weightPercentMax = 1.0
                    } else if percent <= 0.0 {
                        percent = 0.0
                        //node.weightPercentMin = 0.0
                        //node.weightPercentMax = 0.0
                    } else {
                        let percentInv:CGFloat = 1.0 - percent
                        
                        percent = (percentInv * percentInv)
                        percent = 1.0 - percent
                        
                        //var factorMin:CGFloat = percentInv * percentInv
                        //var factorMax:CGFloat = factorMin * percentInv * percentInv
                        
                        //factorMin = (1.0 - factorMin)
                        //factorMax = (1.0 - factorMax)
                        
                        //node.weightPercentMin = factorMin
                        //node.weightPercentMax = factorMax
                    }
                    
                    //node.weightPercent = percent
                    //node.weightFactor = node.weightPercentMin + (node.weightPercentMax - node.weightPercentMin) * bulgeCenterFactor
                    
                    node.weightFactor = percent * 0.65 + percentFlattened * 0.35 //node.weightPercentMax// * bulgeCenterFactor
                }
            }
        }
        
        
        
        
        
        
        
        for nodeIndex in 0..<meshNodesBase.count {
            let node = meshNodesBase.data[nodeIndex]
            node.factor = (node.weightFactor * node.edgeFactor)
        }
        
        var maxFactor: CGFloat = 0.0
        for nodeIndex in 0..<meshNodesBase.count {
            let node = meshNodesBase.data[nodeIndex]
            if node.factor > maxFactor {
                maxFactor = node.factor
                twistCenterBase = CGPoint(x: node.x, y: node.y)
            }
        }
        
        //Normalize node factors, [0..1]
        if maxFactor > Math.epsilon {
            for nodeIndex in 0..<meshNodesBase.count {
                let node = meshNodesBase.data[nodeIndex]
                node.factor = node.factor / maxFactor
                if node.factor < 0.0 { node.factor = 0.0 }
                if node.factor > 1.0 { node.factor = 1.0 }
            }
        }
        
        computeAffine()
        
    }
    
    func computeShape() {
        
        needsComputeShape = false
        valid = true
        
        computeBorder()
        
        guard borderBase.count > 4 && valid == true else {
            valid = false
            return
        }
        
        boundingBox = borderBase.getBoundingBox(padding: 5.0)
        
        guard boundingBox.size.width > 10.0 && boundingBox.size.height > 10.0 && valid == true else {
            valid = false
            return
        }
        
        computeGridPoints()
        
        guard gridWidth >= 3 else {
            valid = false
            return
        }
        guard gridHeight >= 3 && valid == true else {
            valid = false
            return
        }
        
        computeGridInside()
        computeGridEdges()
        computeMesh()
        computeMeshEdgeFactors()
        guard valid == true else { return }
        
        computeWeight()
    }
    
    internal func computeBorder() {
        borderBase.reset()
        
        var threshDist = CGFloat(3.0)
        if Device.isTablet { threshDist = 5.0 }
        
        threshDist = (threshDist * threshDist)
        
        let step = CGFloat(0.01)
        var prevPoint = spline.get(0.0)
        let lastPoint = spline.get(spline.maxPos)
        
        borderBase.add(x: prevPoint.x, y: prevPoint.y)
        for pos:CGFloat in stride(from: step, to: CGFloat(spline.maxPos), by: step) {
            let point = spline.get(pos)
            let diffX1 = point.x - prevPoint.x
            let diffY1 = point.y - prevPoint.y
            let diffX2 = point.x - lastPoint.x
            let diffY2 = point.y - lastPoint.y
            let dist1 = diffX1 * diffX1 + diffY1 * diffY1
            let dist2 = diffX2 * diffX2 + diffY2 * diffY2
            if dist1 > threshDist && dist2 > threshDist {
                borderBase.add(x: point.x, y: point.y)
                prevPoint = point
            }
        }
        
        simplePolygon = borderBase.isSimple()
        
        guard borderBase.count >= 1 else {
            valid = false
            return
        }
        
        borderPerimeterBase = 0.0
        
        linesBase.reset()
        var prev = borderBase.data[borderBase.count - 1]
        for i in 0..<borderBase.count {
            let point = borderBase.data[i]
            linesBase.set(index: i, p1: prev, p2: point)
            borderPerimeterBase += Math.dist(p1: prev, p2: point)
            prev = point
        }
        
    }
    
    func computeGridPoints() {
        let minSize = min(boundingBox.size.width, boundingBox.size.height)
        
        //TODO: Change this for release.. (22)
        //#if DEBUG
        let stepSize = minSize / 12.0
        //#else
        //let stepSize = minSize / 22.0
        //#endif
        
        gridWidth = 0
        gridHeight = 0
        
        let leftX = boundingBox.origin.x
        let rightX = leftX + boundingBox.size.width
        for _ in stride(from: leftX, to: rightX, by: stepSize) {
            gridWidth += 1
        }
        if gridWidth > gridWidthMax { gridWidth = gridWidthMax }
        
        let topY = boundingBox.origin.y
        let bottomY = topY + boundingBox.size.height
        for _ in stride(from: topY, to: bottomY, by: stepSize) {
            gridHeight += 1
        }
        if gridHeight > gridHeightMax { gridHeight = gridHeightMax }
        
        for i in 0..<gridWidth {
            let percentX = CGFloat(Double(i) / Double(gridWidth - 1))
            let x = leftX + (rightX - leftX) * percentX
            for n in 0..<gridHeight {
                let percentY = CGFloat(Double(n) / Double(gridHeight - 1))
                let y = topY + (bottomY - topY) * percentY
                let point = CGPoint(x: x, y: y)
                grid[i][n].pointBase = point
                grid[i][n].inside = borderBase.pointInside(point: point)
                if grid[i][n].inside {
                    grid[i][n].color = UIColor(red: 1.0 - percentX, green: 1.0, blue: 1.0 - percentY, alpha: 1.0)
                } else {
                    grid[i][n].color = UIColor(red: percentX, green: 0.0, blue: percentY, alpha: 1.0)
                }
            }
        }
    }
    
    //Find which grid points are inside our polygon.
    func computeGridInside() {
        guard gridWidth > 0 else { return }
        guard gridHeight > 0 else { return }
        for i in 0..<gridWidth {
            for n in 0..<gridHeight {
                grid[i][n].inside = borderBase.pointInside(point: grid[i][n].pointBase)
            }
        }
    }
    
    func computeGridEdges() {
        //Reset the border points.
        for i in 0..<gridWidth {
            for n in 1..<gridHeight {
                grid[i][n].edgeU = false
                grid[i][n].edgeR = false
                grid[i][n].edgeD = false
                grid[i][n].edgeL = false
            }
        }
        //Find all of the border points for the grid.
        for i in 1..<gridWidth {
            for n in 1..<gridHeight {
                let top = n - 1
                let left = i - 1
                let right = i
                let bottom = n
                if grid[left][bottom].inside == true && grid[left][top].inside == false {
                    grid[left][bottom].edgeU = true
                    grid[left][bottom].edgePointBaseU = closestBorderPointUp(point: grid[left][bottom].pointBase)
                }
                if grid[right][bottom].inside == true && grid[right][top].inside == false {
                    grid[right][bottom].edgeU = true
                    grid[right][bottom].edgePointBaseU = closestBorderPointUp(point: grid[right][bottom].pointBase)
                }
                if grid[left][bottom].inside == false && grid[left][top].inside == true {
                    grid[left][top].edgeD = true
                    grid[left][top].edgePointBaseD = closestBorderPointDown(point: grid[left][top].pointBase)
                }
                if grid[right][bottom].inside == false && grid[right][top].inside == true {
                    grid[right][top].edgeD = true
                    grid[right][top].edgePointBaseD = closestBorderPointDown(point: grid[right][top].pointBase)
                }
                if grid[left][top].inside == false && grid[right][top].inside == true {
                    grid[right][top].edgeL = true
                    grid[right][top].edgePointBaseL = closestBorderPointLeft(point: grid[right][top].pointBase)
                }
                if grid[left][bottom].inside == false && grid[right][bottom].inside == true {
                    grid[right][bottom].edgeL = true
                    grid[right][bottom].edgePointBaseL = closestBorderPointLeft(point: grid[right][bottom].pointBase)
                }
                if grid[left][top].inside == true && grid[right][top].inside == false {
                    grid[left][top].edgeR = true
                    grid[left][top].edgePointBaseR = closestBorderPointRight(point: grid[left][top].pointBase)
                }
                if grid[left][bottom].inside == true && grid[right][bottom].inside == false {
                    grid[left][bottom].edgeR = true
                    grid[left][bottom].edgePointBaseR = closestBorderPointRight(point: grid[left][bottom].pointBase)
                }
            }
        }
    }
    
    //For indexed triangle list, we will only use each grid edge point once.
    func meshIndexEdgeU(_ gridX: Int, _ gridY: Int) -> Int {
        if (grid[gridX][gridY].meshIndexEdgeU != nil) {
            return grid[gridX][gridY].meshIndexEdgeU!
        } else {
            let index = meshNodesBase.count
            grid[gridX][gridY].meshIndexEdgeU = meshNodesBase.count
            let point = grid[gridX][gridY].edgePointBaseU
            meshNodesBase.setXY(index, x: point.x, y: point.y)
            return index
        }
    }
    
    //For indexed triangle list, we will only use each grid edge point once.
    func meshIndexEdgeR(_ gridX: Int, _ gridY: Int) -> Int {
        if (grid[gridX][gridY].meshIndexEdgeR != nil) {
            return grid[gridX][gridY].meshIndexEdgeR!
        } else {
            let index = meshNodesBase.count
            grid[gridX][gridY].meshIndexEdgeR = meshNodesBase.count
            let point = grid[gridX][gridY].edgePointBaseR
            meshNodesBase.setXY(index, x: point.x, y: point.y)
            return index
        }
    }
    
    //For indexed triangle list, we will only use each grid edge point once.
    func meshIndexEdgeD(_ gridX: Int, _ gridY: Int) -> Int {
        if (grid[gridX][gridY].meshIndexEdgeD != nil) {
            return grid[gridX][gridY].meshIndexEdgeD!
        } else {
            let index = meshNodesBase.count
            grid[gridX][gridY].meshIndexEdgeD = meshNodesBase.count
            let point = grid[gridX][gridY].edgePointBaseD
            meshNodesBase.setXY(index, x: point.x, y: point.y)
            return index
        }
    }
    
    //For indexed triangle list, we will only use each grid edge point once.
    func meshIndexEdgeL(_ gridX: Int, _ gridY: Int) -> Int {
        if (grid[gridX][gridY].meshIndexEdgeL != nil) {
            return grid[gridX][gridY].meshIndexEdgeL!
        } else {
            let index = meshNodesBase.count
            grid[gridX][gridY].meshIndexEdgeL = meshNodesBase.count
            let point = grid[gridX][gridY].edgePointBaseL
            meshNodesBase.setXY(index, x: point.x, y: point.y)
            return index
        }
    }
    
    //For indexed triangle list, we will only use each grid point once.
    func meshIndex(_ gridX: Int, _ gridY: Int) -> Int {
        if (grid[gridX][gridY].meshIndex != nil) {
            return grid[gridX][gridY].meshIndex!
        } else {
            let index = meshNodesBase.count
            grid[gridX][gridY].meshIndex = meshNodesBase.count
            let point = grid[gridX][gridY].pointBase
            meshNodesBase.setXY(index, x: point.x, y: point.y)
            return index
        }
    }
    
    func addTriangle(x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int) {
        let i1 = meshIndex(x1, y1)
        let i2 = meshIndex(x2, y2)
        let i3 = meshIndex(x3, y3)
        tri.add(i1: i1, i2: i2, i3: i3)
    }
    
    func computeMesh() {
        guard valid else { return }
        
        //Reset the mesh indeces.
        for i in 0..<gridWidth {
            for n in 1..<gridHeight {
                grid[i][n].meshIndex = nil
                grid[i][n].meshIndexEdgeU = nil
                grid[i][n].meshIndexEdgeR = nil
                grid[i][n].meshIndexEdgeD = nil
                grid[i][n].meshIndexEdgeL = nil
            }
        }
        
        tri.reset()
        meshNodesBase.reset()
        
        //Build the mesh using level 6 magic.
        for i in 1..<gridWidth {
            for n in 1..<gridHeight {
                let top = n - 1
                let left = i - 1
                let right = i
                let bottom = n
                
                let U_L = grid[left][top]
                let D_L = grid[left][bottom]
                let U_R = grid[right][top]
                let D_R = grid[right][bottom]
                
                //All 4 tri's IN
                if (U_L.inside == true) && (U_R.inside == true) && (D_L.inside == true) && (D_R.inside == true) {
                    let t1_i1 = meshIndex(left, top)
                    let t1_i2 = meshIndex(left, bottom)
                    let t1_i3 = meshIndex(right, top)
                    tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                    
                    let t2_i1 = meshIndex(left, bottom)
                    let t2_i2 = meshIndex(right, top)
                    let t2_i3 = meshIndex(right, bottom)
                    tri.add(i1: t2_i1, i2: t2_i2, i3: t2_i3)
                }
                
                //Upper-Left in (Corner)
                if (U_L.inside == true) && (U_R.inside == false) && (D_L.inside == false) && (D_R.inside == false) {
                    if U_L.edgeR && U_L.edgeD {
                        let t1_i1 = meshIndex(left, top)
                        let t1_i2 = meshIndexEdgeD(left, top)
                        let t1_i3 = meshIndexEdgeR(left, top)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                    }
                }
                
                //Upper-Right in (Corner)
                if (U_L.inside == false) && (U_R.inside == true) && (D_L.inside == false) && (D_R.inside == false) {
                    if U_R.edgeL && U_R.edgeD {
                        let t1_i1 = meshIndexEdgeL(right, top)
                        let t1_i2 = meshIndexEdgeD(right, top)
                        let t1_i3 = meshIndex(right, top)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                    }
                }
                
                //Bottom-Left in (Corner)
                if (U_L.inside == false) && (U_R.inside == false) && (D_L.inside == true) && (D_R.inside == false) {
                    if D_L.edgeR && D_L.edgeU {
                        let t1_i1 = meshIndex(left, bottom)
                        let t1_i2 = meshIndexEdgeR(left, bottom)
                        let t1_i3 = meshIndexEdgeU(left, bottom)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                    }
                }
                
                //Bottom-Right in (Corner)
                if (U_L.inside == false) && (U_R.inside == false) && (D_L.inside == false) && (D_R.inside == true) {
                    if D_R.edgeL && D_R.edgeU {
                        let t1_i1 = meshIndexEdgeU(right, bottom)
                        let t1_i2 = meshIndexEdgeL(right, bottom)
                        let t1_i3 = meshIndex(right, bottom)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                    }
                }
                
                //Up in (Side)
                if (U_L.inside == true) && (U_R.inside == true) && (D_L.inside == false) && (D_R.inside == false) {
                    if U_L.edgeD && U_R.edgeD {
                        let t1_i1 = meshIndex(left, top)
                        let t1_i2 = meshIndexEdgeD(left, top)
                        let t1_i3 = meshIndexEdgeD(right, top)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                        
                        let t2_i1 = meshIndex(left, top)
                        let t2_i2 = meshIndex(right, top)
                        let t2_i3 = meshIndexEdgeD(right, top)
                        tri.add(i1: t2_i1, i2: t2_i2, i3: t2_i3)
                    }
                }
                
                //Right in (Side)
                if (U_L.inside == false) && (U_R.inside == true) && (D_L.inside == false) && (D_R.inside == true) {
                    if U_R.edgeL && D_R.edgeL {
                        let t1_i1 = meshIndexEdgeL(right, top)
                        let t1_i2 = meshIndexEdgeL(right, bottom)
                        let t1_i3 = meshIndex(right, top)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                        
                        let t2_i1 = meshIndexEdgeL(right, bottom)
                        let t2_i2 = meshIndex(right, top)
                        let t2_i3 = meshIndex(right, bottom)
                        tri.add(i1: t2_i1, i2: t2_i2, i3: t2_i3)
                    }
                }
                //Down in (Side)
                if (U_L.inside == false) && (U_R.inside == false) && (D_L.inside == true) && (D_R.inside == true) {
                    if D_L.edgeU && D_R.edgeU {
                        let t1_i1 = meshIndexEdgeU(left, bottom)
                        let t1_i2 = meshIndex(left, bottom)
                        let t1_i3 = meshIndexEdgeU(right, bottom)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                        
                        let t2_i1 = meshIndex(left, bottom)
                        let t2_i2 = meshIndexEdgeU(right, bottom)
                        let t2_i3 = meshIndex(right, bottom)
                        tri.add(i1: t2_i1, i2: t2_i2, i3: t2_i3)
                    }
                }
                
                //Left in (Side)
                if (U_L.inside == true) && (U_R.inside == false) && (D_L.inside == true) && (D_R.inside == false) {
                    if U_L.edgeR && D_L.edgeR {
                        let t1_i1 = meshIndex(left, top)
                        let t1_i2 = meshIndexEdgeR(left, top)
                        let t1_i3 = meshIndexEdgeR(left, bottom)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                        
                        let t2_i1 = meshIndexEdgeR(left, bottom)
                        let t2_i2 = meshIndex(left, top)
                        let t2_i3 = meshIndex(left, bottom)
                        tri.add(i1: t2_i1, i2: t2_i2, i3: t2_i3)
                    }
                }
                
                //Upper-Left out (Elbow)
                if (U_L.inside == false) && (U_R.inside == true) && (D_L.inside == true) && (D_R.inside == true) {
                    if U_R.edgeL && D_L.edgeU {
                        let t1_i1 = meshIndexEdgeU(left, bottom)
                        let t1_i2 = meshIndexEdgeL(right, top)
                        let t1_i3 = meshIndex(right, bottom)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                        
                        let t2_i1 = meshIndexEdgeU(left, bottom)
                        let t2_i2 = meshIndex(left, bottom)
                        let t2_i3 = meshIndex(right, bottom)
                        tri.add(i1: t2_i1, i2: t2_i2, i3: t2_i3)
                        
                        let t3_i1 = meshIndexEdgeL(right, top)
                        let t3_i2 = meshIndex(right, top)
                        let t3_i3 = meshIndex(right, bottom)
                        tri.add(i1: t3_i1, i2: t3_i2, i3: t3_i3)
                    }
                }
                
                //Upper-Right out (Elbow)
                if (U_L.inside == true) && (U_R.inside == false) && (D_L.inside == true) && (D_R.inside == true) {
                    if U_L.edgeR && D_R.edgeU {
                        let t1_i1 = meshIndex(left, bottom)
                        let t1_i2 = meshIndexEdgeR(left, top)
                        let t1_i3 = meshIndexEdgeU(right, bottom)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                        
                        let t2_i1 = meshIndex(left, top)
                        let t2_i2 = meshIndex(left, bottom)
                        let t2_i3 = meshIndexEdgeR(left, top)
                        tri.add(i1: t2_i1, i2: t2_i2, i3: t2_i3)
                        
                        let t3_i1 = meshIndex(left, bottom)
                        let t3_i2 = meshIndexEdgeU(right, bottom)
                        let t3_i3 = meshIndex(right, bottom)
                        tri.add(i1: t3_i1, i2: t3_i2, i3: t3_i3)
                    }
                }
                
                //Bottom-Left out (Elbow)
                if (U_L.inside == true) && (U_R.inside == true) && (D_L.inside == false) && (D_R.inside == true) {
                    if U_L.edgeD && D_R.edgeL {
                        let t1_i1 = meshIndexEdgeD(left, top)
                        let t1_i2 = meshIndex(right, top)
                        let t1_i3 = meshIndexEdgeL(right, bottom)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                        
                        let t2_i1 = meshIndex(left, top)
                        let t2_i2 = meshIndexEdgeD(left, top)
                        let t2_i3 = meshIndex(right, top)
                        tri.add(i1: t2_i1, i2: t2_i2, i3: t2_i3)
                        
                        let t3_i1 = meshIndexEdgeL(right, bottom)
                        let t3_i2 = meshIndex(right, top)
                        let t3_i3 = meshIndex(right, bottom)
                        tri.add(i1: t3_i1, i2: t3_i2, i3: t3_i3)
                    }
                }
                
                //Bottom-Right out (Elbow)
                if (U_L.inside == true) && (U_R.inside == true) && (D_L.inside == true) && (D_R.inside == false) {
                    if U_R.edgeD && D_L.edgeR {
                        let t1_i1 = meshIndex(left, top)
                        let t1_i2 = meshIndexEdgeD(right, top)
                        let t1_i3 = meshIndexEdgeR(left, bottom)
                        tri.add(i1: t1_i1, i2: t1_i2, i3: t1_i3)
                        
                        let t2_i1 = meshIndex(left, top)
                        let t2_i2 = meshIndex(left, bottom)
                        let t2_i3 = meshIndexEdgeR(left, bottom)
                        tri.add(i1: t2_i1, i2: t2_i2, i3: t2_i3)
                        
                        let t3_i1 = meshIndex(left, top)
                        let t3_i2 = meshIndex(right, top)
                        let t3_i3 = meshIndexEdgeD(right, top)
                        tri.add(i1: t3_i1, i2: t3_i2, i3: t3_i3)
                    }
                }
            }
        }
    }
    
    func closestBorderPointUp(point:CGPoint) -> CGPoint {
        var segment = LineSegment()
        segment.p1 = CGPoint(x: point.x, y: point.y)
        segment.p2 = CGPoint(x: point.x, y: point.y - 2048.0)
        return closestBorderPoint(segment: &segment)
    }
    
    func closestBorderPointRight(point:CGPoint) -> CGPoint {
        var segment = LineSegment()
        segment.p1 = CGPoint(x: point.x, y: point.y)
        segment.p2 = CGPoint(x: point.x + 2048.0, y: point.y)
        return closestBorderPoint(segment: &segment)
    }
    
    func closestBorderPointDown(point:CGPoint) -> CGPoint {
        var segment = LineSegment()
        segment.p1 = CGPoint(x: point.x, y: point.y)
        segment.p2 = CGPoint(x: point.x, y: point.y + 2048.0)
        return closestBorderPoint(segment: &segment)
    }
    
    func closestBorderPointLeft(point:CGPoint) -> CGPoint {
        var segment = LineSegment()
        segment.p1 = CGPoint(x: point.x, y: point.y)
        segment.p2 = CGPoint(x: point.x - 2048.0, y: point.y)
        return closestBorderPoint(segment: &segment)
    }
    
    func closestBorderPoint(segment: inout LineSegment) -> CGPoint {
        var result = CGPoint(x: segment.x1, y: segment.y1)
        var bestDist:CGFloat?
        let planeX = segment.x1
        let planeY = segment.y1
        let planeDir = segment.direction
        for i in 0..<linesBase.count {
            //let line = linesBase.data[i]
            if LineSegment.SegmentsIntersect(l1: &segment, l2: &(linesBase.data[i])) {
                let intersection = LineSegment.LinePlaneIntersection(line: &(linesBase.data[i]), planeX: planeX, planeY: planeY, planeDirX: planeDir.x, planeDirY: planeDir.y)
                if intersection.intersects {
                    if bestDist == nil {
                        bestDist = intersection.distance
                        result = intersection.point
                    } else if (intersection.distance < bestDist!) {
                        bestDist = intersection.distance
                        result = intersection.point
                    }
                }
            }
        }
        return result
    }
    
    func computeMeshEdgeFactors() {
        
        //Something went very wrong.
        guard linesBase.count > 1 && valid else {
            valid = false
            return
        }
        
        //The farthest total distance of any point to the border.
        var largestDist:CGFloat = 0.0
        
        //Find the closest distance from each point to anywhere on the border.
        for nodeIndex in 0..<meshNodesBase.count {
            let node = meshNodesBase.data[nodeIndex]
            let point = CGPoint(x: node.x, y: node.y)
            var closestDist:CGFloat = 100000000.0
            for segmentIndex in 0..<linesBase.count {
                let closestPoint = LineSegment.SegmentClosestPoint(line: &linesBase.data[segmentIndex], point: point)
                let diffX = closestPoint.x - point.x
                let diffY = closestPoint.y - point.y
                let dist = diffX * diffX + diffY * diffY
                if (dist < closestDist) {
                    closestDist = dist
                }
            }
            if closestDist > Math.epsilon { closestDist = CGFloat(sqrtf(Float(closestDist))) }
            if closestDist > largestDist { largestDist = closestDist }
            node.edgeDistance = closestDist
        }
        
        //Something went very wrong.
        guard largestDist > Math.epsilon else {
            valid = false
            return
        }
        
        //Normalize all of the distances for percent [0, 1]
        for nodeIndex in 0..<meshNodesBase.count {
            let node = meshNodesBase.data[nodeIndex]
            node.edgePercent = node.edgeDistance / largestDist
            if node.edgePercent >= 1.0 {
                node.edgePercent = 1.0
            } else if node.edgePercent <= 0.0 {
                node.edgePercent = 0.0
            }
        }
        
        //Compute damping based on percent.
        for nodeIndex in 0..<meshNodesBase.count {
            let node = meshNodesBase.data[nodeIndex]
            let percent = node.edgePercent
            if percent >= 1.0 {
                node.edgePercentMin = 1.0
                node.edgePercentMax = 1.0
            } else if percent <= 0.0 {
                node.edgePercentMin = 0.0
                node.edgePercentMax = 0.0
            } else {
                let percentInv:CGFloat = 1.0 - percent
                let percentInvSquared = percentInv * percentInv
                var factorMin:CGFloat = percentInvSquared * 0.5 + percentInv * 0.5
                var factorMax:CGFloat = percentInvSquared * percentInvSquared
                factorMin = 1.0 - factorMin
                factorMax = 1.0 - factorMax
                node.edgePercentMin = factorMin
                node.edgePercentMax = factorMax
            }
        }
    }
    
    func computeAffine() {
        needsComputeAffine = false
        
        guard valid == true else { return }
        
        border.reset()
        border.add(list: borderBase)
        border.transform(scale: scale, rotation: rotation)
        border.transform(translation: center)
        
        twistCenter = transformPoint(point: twistCenterBase)
        //twistCenterBase
        
        
        borderPerimeter = borderPerimeterBase * scale
        borderArea = border.area
        
        var powerPercent: CGFloat = 0.0
        var speedPercent: CGFloat = 0.0
        
        if let engine = ApplicationController.shared.engine {
            powerPercent = engine.animationPower
            speedPercent = engine.animationSpeed
        }
        
        let dragFalloffInputCapMin = ApplicationController.shared.dragFalloffInputCapMin
        let dragFalloffInputCapMax = ApplicationController.shared.dragFalloffInputCapMax
        
        dragFalloffInputCap = dragFalloffInputCapMin + (dragFalloffInputCapMax - dragFalloffInputCapMin) * powerPercent
        
        let dragFalloffDampenFactorMin = ApplicationController.shared.dragFalloffDampenFactorMin
        let dragFalloffDampenFactorMax = ApplicationController.shared.dragFalloffDampenFactorMax
        let dragFalloffDampenFactor: CGFloat = dragFalloffDampenFactorMin + (dragFalloffDampenFactorMax - dragFalloffDampenFactorMin) * powerPercent
        
        dragFalloffDampenInputMax = CGFloat(sqrt(Double(borderArea))) * dragFalloffDampenFactor
        if dragFalloffDampenInputMax > dragFalloffInputCap { dragFalloffDampenInputMax = dragFalloffInputCap }
        
        let dragFalloffDampenResultMaxFactorMin = ApplicationController.shared.dragFalloffDampenResultMaxFactorMin
        let dragFalloffDampenResultMaxFactorMax = ApplicationController.shared.dragFalloffDampenResultMaxFactorMax
        
        let dragFalloffDampenResultMaxFactor: CGFloat = dragFalloffDampenResultMaxFactorMin + (dragFalloffDampenResultMaxFactorMax - dragFalloffDampenResultMaxFactorMin) * powerPercent
        
        dragFalloffDampenResultMax = dragFalloffDampenInputMax * dragFalloffDampenResultMaxFactor
        
        let dragFalloffDampenStartFactorMin = ApplicationController.shared.dragFalloffDampenStartFactorMin
        let dragFalloffDampenStartFactorMax = ApplicationController.shared.dragFalloffDampenStartFactorMax
        let dragFalloffDampenStartFactor: CGFloat = dragFalloffDampenStartFactorMin + (dragFalloffDampenStartFactorMax - dragFalloffDampenStartFactorMin) * powerPercent
        dragFalloffDampenStart = dragFalloffDampenResultMax * dragFalloffDampenStartFactor
        
        for i in 0..<gridWidth {
            for n in 0..<gridHeight {
                grid[i][n].point = transformPoint(point: grid[i][n].pointBase)
            }
        }
        
        meshNodes.reset()
        for i in 0..<meshNodesBase.count {
            let node = meshNodesBase.data[i]
            meshNodes.set(index: i, node: node)
            let point = transformPoint(point: CGPoint(x: node.x, y: node.y))
            meshNodes.data[i].x = point.x
            meshNodes.data[i].y = point.y
        }
        
        
        
        //TODO:
        
        
        for i in 0..<gridWidth {
            for n in 1..<gridHeight {
                if grid[i][n].edgeU {
                    grid[i][n].edgePointU = transformPoint(point: grid[i][n].edgePointBaseU)
                }
                if grid[i][n].edgeR {
                    grid[i][n].edgePointR = transformPoint(point: grid[i][n].edgePointBaseR)
                }
                if grid[i][n].edgeD {
                    grid[i][n].edgePointD = transformPoint(point: grid[i][n].edgePointBaseD)
                }
                if grid[i][n].edgeL {
                    grid[i][n].edgePointL = transformPoint(point: grid[i][n].edgePointBaseL)
                }
            }
        }
        
        
        
        /*
         for i in 0..<meshNodesBase.count {
         let node = meshNodesBase.data[i]
         meshNodes.set(index: i, node: node)
         let point = transformPoint(point: CGPoint(x: node.x, y: node.y))
         meshNodes.data[i].x = point.x
         meshNodes.data[i].y = point.y
         }
         */
        
        
        
        
        
        /*
         var edgePointU:CGPoint = CGPoint.zero
         var edgePointR:CGPoint = CGPoint.zero
         var edgePointD:CGPoint = CGPoint.zero
         var edgePointL:CGPoint = CGPoint.zero
         */
        
        
        computeTextureCoords()
        
        guard border.count >= 1 else {
            valid = false
            return
        }
        
        linesInner.reset()
        linesInnerSelected.reset()
        linesInnerInvalid.reset()
        
        linesOuter.reset()
        var prev = border.data[border.count - 1]
        for i in 0..<border.count {
            let point = border.data[i]
            linesInner.set(index: i, p1: CGPoint(x: prev.x, y: prev.y), p2: CGPoint(x: point.x, y: point.y))
            linesInnerSelected.set(index: i, p1: CGPoint(x: prev.x, y: prev.y), p2: CGPoint(x: point.x, y: point.y))
            linesInnerInvalid.set(index: i, p1: CGPoint(x: prev.x, y: prev.y), p2: CGPoint(x: point.x, y: point.y))
            linesOuter.set(index: i, p1: CGPoint(x: prev.x, y: prev.y), p2: CGPoint(x: point.x, y: point.y))
            prev = point
        }
        
        if simplePolygon == false {
            valid = false
            return
        }
    }
    
    internal func computeTextureCoords() {
        guard let sceneRect = ApplicationController.shared.engine?.sceneRect else {
            valid = false
            return
        }
        
        guard let sprite = ApplicationController.shared.engine?.background else {
            valid = false
            return
        }
        
        let startU = Double(sprite.startU)
        let spanU = Double(sprite.endU) - startU
        let startV = Double(sprite.startV)
        let spanV = Double(sprite.endV) - startV
        
        let startX = Double(sceneRect.origin.x)
        let spanX = Double(sceneRect.size.width)
        
        let startY = Double(sceneRect.origin.y)
        let spanY = Double(sceneRect.size.height)
        
        guard spanX > 32.0 && spanY > 32.0 && spanU > 0.05 && spanV > 0.05 else {
            valid = false
            return
        }
        
        for i in 0..<meshNodes.count {
            let node = meshNodes.data[i]
            let x = Double(node.x)
            let y = Double(node.y)
            let percentX = (x - startX) / spanX
            let percentY = (y - startY) / spanY
            node.u = CGFloat(startU + spanU * percentX)
            node.v = CGFloat(startV + spanV * percentY)
        }
    }
    
    internal func computeIfNeeded() {
        if needsComputeShape { computeShape() }
        else if needsComputeWeight { computeWeight() }
        else if needsComputeAffine { computeAffine() }
    }
    
    func untransformPoint(point:CGPoint) -> CGPoint {
        return BounceEngine.untransformPoint(point: point, translation: center, scale: scale, rotation: rotation)
    }
    
    func transformPoint(point:CGPoint) -> CGPoint {
        return BounceEngine.transformPoint(point: point, translation: center, scale: scale, rotation: rotation)
    }
    
    func handleZoomEnabledChanged() {
        cancelGuideMotion()
    }
    
    func handleSceneModeChanged() {
        modeChangeResetMotionController = true
        cancelGuideMotion()
        resetMotionControllers()
    }
    
    func handleEditModeChanged() {
        modeChangeResetMotionController = true
        cancelGuideMotion()
    }
    
    func handleAnimationEnabledChanged() {
        handleAnimationModeChanged()
        modeChangeResetMotionController = true
        cancelGuideMotion()
    }
    
    func handleAnimationAlternationEnabledChanged() {
        resetMotionControllers()
    }
    
    func handleAnimationBounceEnabledChanged() {
        if let engine = ApplicationController.shared.engine {
            if engine.animationBulgeBouncerBounceEnabled {
                bulgeBouncerMotionController.enableBounce()
            } else {
                bulgeBouncerMotionController.disableBounce()
            }
        }
        resetMotionControllers()
    }
    
    func handleAnimationReverseEnabledChanged() {
        resetMotionControllers()
    }
    
    func handleAnimationTwistEnabledChanged() {
        resetMotionControllers()
    }
    
    func handleAnimationEllipseEnabledChanged() {
        resetMotionControllers()
    }
    
    func handleAnimationInflateEnabledChanged() {
        resetMotionControllers()
    }
    
    func handleAnimationHorizontalEnabledChanged() {
        resetMotionControllers()
    }
    
    
    //BounceEngine.postNotification(BounceNotification.)
    //BounceEngine.postNotification(BounceNotification.animation)
    //BounceEngine.postNotification(BounceNotification.animation)
    //BounceEngine.postNotification(BounceNotification.animation)
    //BounceEngine.postNotification(BounceNotification.animation)
    //BounceEngine.postNotification(BounceNotification.animation)
    //BounceEngine.postNotification(BounceNotification.animation)
    
    func handleAnimationModeChanged() {
        if let engine = ApplicationController.shared.engine {
            if engine.animationEnabled == true {
                if engine.animationMode == .bounce {
                    useMotionControllerAutoLooper()
                } else if engine.animationMode == .twist {
                    useMotionControllerTwister()
                } else {
                    useMotionControllerCrazy()
                }
            } else {
                useMotionControllerOrbiter()
            }
        }
        resetMotionControllers()
    }
    
    func didSelect() {
        
    }
    
    func didDeselect() {
        grabSelectionTouch = nil
    }
    
    func cancelGuideMotion() {
        grabSelectionTouch = nil
        grabSelectionGesture = false
        grabAnimationTargetOffsetStart  = CGPoint.zero
        grabAnimationTargetOffsetTouchStart = CGPoint.zero
        orbitMotionController.cancelAnimationGuideMotion()
    }
    
    func selectNextPoint() {
        if spline.controlPointCount <= 0 {
            selectedControlPointIndex = nil
            return
        }
        if selectedControlPointIndex == nil {
            selectedControlPointIndex = 0
            return
        }
        var index = selectedControlPointIndex!
        index += 1
        if index >= spline.controlPointCount {
            index = 0
        }
        selectedControlPointIndex = index
    }
    
    func selectPreviousPoint() {
        if spline.controlPointCount <= 0 {
            selectedControlPointIndex = nil
            return
        }
        if selectedControlPointIndex == nil {
            selectedControlPointIndex = spline.controlPointCount - 1
            return
        }
        var index = selectedControlPointIndex!
        index -= 1
        if index < 0 {
            index = spline.controlPointCount - 1
        }
        selectedControlPointIndex = index
    }
    
    func addPoint() {
        if selectedControlPointIndex == nil {
            selectedControlPointIndex = 0
        }
        
        if let index = selectedControlPointIndex {
            let pos: CGFloat = CGFloat(index) + 0.5
            let newPoint = spline.get(pos)
            let pointList = PointList()
            
            for i in 0..<(index + 1) {
                if i < spline.controlPointCount {
                    let point = spline.getControlPoint(i)
                    pointList.add(x: point.x, y: point.y)
                }
            }
            
            pointList.add(x: newPoint.x, y: newPoint.y)
            
            if (index + 1) < spline.controlPointCount {
                for i in (index + 1)..<spline.controlPointCount {
                    let point = spline.getControlPoint(i)
                    pointList.add(x: point.x, y: point.y)
                }
            }
            
            spline.reset()
            
            for i in 0..<pointList.count {
                spline.add(pointList.data[i].x, y: pointList.data[i].y)
            }
            
            selectedControlPointIndex = index + 2
            if selectedControlPointIndex! >= spline.controlPointCount {
                selectedControlPointIndex! -= spline.controlPointCount
            }
            
            if selectedControlPointIndex! < 0 {
                selectedControlPointIndex! += spline.controlPointCount
            }
            setNeedsComputeShape()
        }
    }
    
    func deletePoint() {
        
        if selectedControlPointIndex == nil {
            //If we don't have any point selected, we'll just select the first point...
            selectedControlPointIndex = 0
            return
        }
        
        if let index = selectedControlPointIndex {
            
            var deleteIndex: Int = index
            if deleteIndex < 0 { deleteIndex = 0 }
            if deleteIndex >= spline.controlPointCount { deleteIndex = spline.controlPointCount - 1 }
            
            let pointList = PointList()
            for i in 0..<index {
                let point = spline.getControlPoint(i)
                pointList.add(x: point.x, y: point.y)
            }
            for i in (index + 1)..<spline.controlPointCount {
                let point = spline.getControlPoint(i)
                pointList.add(x: point.x, y: point.y)
            }
            
            spline.reset()
            
            for i in 0..<pointList.count {
                spline.add(pointList.data[i].x, y: pointList.data[i].y)
            }
            
            if deleteIndex >= spline.controlPointCount {
                deleteIndex = 0
            }
            
            selectedControlPointIndex = deleteIndex
            setNeedsComputeShape()
        }
    }
    
    func flipH() {
        guard border.count > 2 else {
            return
        }
        
        let startList = PointList()
        var startCenterX: CGFloat = 0.0
        for i in 0..<border.count {
            startCenterX += border.data[i].x
        }
        startCenterX /= CGFloat(border.count)
        
        for i in 0..<spline.controlPointCount {
            let point = spline.getControlPoint(i)
            startList.add(x: point.x, y: point.y)
        }
        startList.transform(scaleX: 1.0, scaleY: 1.0, rotation: rotation)
        
        let newList = PointList()
        for i in 0..<startList.count {
            let point = startList.data[i]
            newList.add(x: -point.x, y: point.y)
        }
        newList.transform(scaleX: 1.0, scaleY: 1.0, rotation: -rotation)
        
        for i in 0..<newList.count {
            let point = newList.data[i]
            spline.set(i, x: point.x, y: point.y)
        }
        
        if (bulgeWeightOffset.x * bulgeWeightOffset.x + bulgeWeightOffset.y * bulgeWeightOffset.y) > Math.epsilon {
            bulgeWeightOffset = Math.rotatePoint(point: bulgeWeightOffset, radians: rotation)
            bulgeWeightOffset = CGPoint(x: -bulgeWeightOffset.x, y: bulgeWeightOffset.y)
            bulgeWeightOffset = Math.rotatePoint(point: bulgeWeightOffset, radians: -rotation)
        }
        
        computeShape()
        
        var newCenterX: CGFloat = 0.0
        for i in 0..<border.count {
            newCenterX += border.data[i].x
        }
        newCenterX /= CGFloat(border.count)
        center = CGPoint(x: center.x + (startCenterX - newCenterX), y: center.y)
        setNeedsComputeAffine()
    }
    
    func flipV() {
        guard border.count > 2 else {
            return
        }
        
        let startList = PointList()
        var startCenterY: CGFloat = 0.0
        for i in 0..<border.count {
            startCenterY += border.data[i].y
        }
        startCenterY /= CGFloat(border.count)
        
        for i in 0..<spline.controlPointCount {
            let point = spline.getControlPoint(i)
            startList.add(x: point.x, y: point.y)
        }
        startList.transform(scaleX: 1.0, scaleY: 1.0, rotation: rotation)
        
        let newList = PointList()
        for i in 0..<startList.count {
            let point = startList.data[i]
            newList.add(x: point.x, y: -point.y)
        }
        newList.transform(scaleX: 1.0, scaleY: 1.0, rotation: -rotation)
        
        for i in 0..<newList.count {
            let point = newList.data[i]
            spline.set(i, x: point.x, y: point.y)
        }
        
        if (bulgeWeightOffset.x * bulgeWeightOffset.x + bulgeWeightOffset.y * bulgeWeightOffset.y) > Math.epsilon {
            bulgeWeightOffset = Math.rotatePoint(point: bulgeWeightOffset, radians: rotation)
            bulgeWeightOffset = CGPoint(x: bulgeWeightOffset.x, y: -bulgeWeightOffset.y)
            bulgeWeightOffset = Math.rotatePoint(point: bulgeWeightOffset, radians: -rotation)
        }
        
        computeShape()
        
        var newCenterY: CGFloat = 0.0
        for i in 0..<border.count {
            newCenterY += border.data[i].y
        }
        newCenterY /= CGFloat(border.count)
        center = CGPoint(x: center.x, y: center.y + (startCenterY - newCenterY))
        setNeedsComputeAffine()
    }
    
    
    func save() -> [String:AnyObject] {
        var info = [String:AnyObject]()
        info["center_x"] = Float(center.x) as AnyObject?
        info["center_y"] = Float(center.y) as AnyObject?
        info["scale"] = Float(scale) as AnyObject?
        info["rotation"] = Float(rotation) as AnyObject?
        info["spline"] = spline.save() as AnyObject?
        
        info["bulge_weight_offset_x"] = Float(bulgeWeightOffset.x) as AnyObject?
        info["bulge_weight_offset_y"] = Float(bulgeWeightOffset.y) as AnyObject?
        
        info["bulge_weight_percent"] = Float(bulgeCenterFactor) as AnyObject?        
        info["bulge_weight_edges"] = Float(bulgeEdgeFactor) as AnyObject?
        
        return info
    }
    
    func load(info: inout [String:AnyObject]) {
        
        center.x = GoodParser.readFloat(&info, "center_x", center.x)
        center.y = GoodParser.readFloat(&info, "center_y", center.y)
        scale = GoodParser.readFloat(&info, "scale", scale)
        rotation = GoodParser.readFloat(&info, "rotation", rotation)
        
        
        //if var splineInfo = GoodParser.readInfo(&info, "spline") {
        
        if var splineInfo = GoodParser.readInfo(&info, "spline") {
            //print("Spline Info: \(splineInfo)")
            spline.load(info: &splineInfo)
        }
        
        //if var splineInfo = info["spline"] as? [String:AnyObject] { spline.load(info: &splineInfo) }
        
        
        bulgeWeightOffset.x = GoodParser.readFloat(&info, "bulge_weight_offset_x", bulgeWeightOffset.x)
        bulgeWeightOffset.y = GoodParser.readFloat(&info, "bulge_weight_offset_y", bulgeWeightOffset.y)
        bulgeCenterFactor = GoodParser.readFloat(&info, "bulge_weight_percent", bulgeCenterFactor)
        bulgeEdgeFactor = GoodParser.readFloat(&info, "bulge_weight_edges", bulgeEdgeFactor)
        
        setNeedsComputeShape()
    }
    
    func loadAdjust(loadScene: BounceScene, newScene: BounceScene) -> Void {
        
        let originalFrame = loadScene.imageFrame
        let newFrame = newScene.imageFrame
        
        if originalFrame.size.width > 64.0 && originalFrame.size.height > 64.0 {
            if newFrame.size.width > 64.0 && newFrame.size.height > 64.0 {
                
                let widthRatio: Double = Double(newFrame.size.width) / Double(originalFrame.size.width)
                let heightRatio: Double = Double(newFrame.size.height) / Double(originalFrame.size.height)
                let ratio = widthRatio * 0.5 + heightRatio * 0.5
                
                var newX: Double = Double(center.x)
                var newY: Double = Double(center.y)
                newX -= Double(originalFrame.origin.x)
                newY -= Double(originalFrame.origin.y)
                
                let percentX: Double = newX / Double(originalFrame.size.width)
                let percentY: Double = newY / Double(originalFrame.size.height)
                
                newX = percentX * Double(newFrame.size.width)
                newY = percentY * Double(newFrame.size.height)
                newX += Double(newFrame.origin.x)
                newY += Double(newFrame.origin.y)
                
                center = CGPoint(x: newX, y: newY)
                scale *= CGFloat(ratio)
                
                setNeedsComputeAffine()
            }
        }
    }
    
    //Save all the info necessary to make the screen look exactly like THIS again...
    func recordBlobState() -> RecordedBlobState {
        let state = RecordedBlobState()
        state.animationTargetOffset = motionController.animationTargetOffset
        state.inflateScale = motionController.inflateScale
        state.twistRotation = motionController.twistRotation
        return state
    }
    
    //Restore the engine to the recorded state. This is useful for playback.
    func readBlobState(_ state: RecordedBlobState) {
        motionController.animationTargetOffset = state.animationTargetOffset
        motionController.inflateScale = state.inflateScale
        motionController.twistRotation = state.twistRotation
    }
    
}


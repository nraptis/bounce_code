//
//  BounceEngine.swift
//
//  Created by Raptis, Nicholas on 8/24/16.
//

import UIKit
import Foundation

enum BounceNotification:String {
    
    case zoomEnabledChanged = "BounceNotification.zoomEnabledChanged"
    case zoomEnabledChangedForced = "BounceNotification.zoomEnabledChangedForced"
    case zoomScaleChanged = "BounceNotification.zoomScaleChanged"
    
    case showingMarkersChanged = "BounceNotification.showingMarkersChanged"
    
    case frozenStateChanged = "BounceNotification.frozenStateChanged"
    
    case pointCountChanged = "BounceNotification.pointCountChanged"
    
    case bulgeScaleChangedForced = "BounceNotification.bulgeScaleChangedForced"
    case bulgeEdgeFactorChangedForced = "BounceNotification.bulgeEdgeFactorChangedForced"
    
    case sceneModeChanged = "BounceNotification.sceneModeChanged"
    case editModeChanged = "BounceNotification.editModeChanged"
    case animationModeChanged = "BounceNotification.animationModeChanged"
    
    case animationAlternationEnabledChanged = "BounceNotification.animationAlternationEnabledChanged"
    case animationBounceEnabledChanged = "BounceNotification.animationBounceEnabledChanged"
    case animationReverseEnabledChanged = "BounceNotification.animationReverseEnabledChanged"
    case animationTwistEnabledChanged = "BounceNotification.animationTwistEnabledChanged"
    case animationEllipseEnabledChanged = "BounceNotification.animationEllipseEnabledChanged"
    case animationInflateEnabledChanged = "BounceNotification.animationInflateEnabledChanged"
    case animationHorizontalEnabledChanged = "BounceNotification.animationHorizontalEnabledChanged"
    
    
    case altMenuBulgeBouncerChanged = "BounceNotification.altMenuBulgeBouncerChanged"
    case altMenuTwisterChanged = "BounceNotification.altMenuTwisterChanged"
    case altMenuRandomChanged = "BounceNotification.altMenuRandomChanged"
    
    case animationEnabledChanged = "BounceNotification.animationEnabledChanged"
    
    case blobAdded = "BounceNotification.vlobAdded"
    case blobSelectionChanged = "BounceNotification.blobSelectionChanged"
    case historyChanged = "BounceNotification.historyStackChanged"
    
    case blobStackOrderChanged = "BounceNotification.blobStackOrderChanged"
    case blobCountChanged = "BounceNotification.blobCountChanged"
    
    
    case recordEnabledChanged = "BounceNotification.recordEnabledChanged"
    
    case timelineEnabledChanged = "BounceNotification.timelineEnabledChanged"
    case timelineFrameChanged = "BounceNotification.timelineFrameChanged"
    case timelineHandleChanged = "BounceNotification.timelineHandleChanged"
    
    
    case timelinePlaybackEnabledChanged = "BounceNotification.timelinePlaybackEnabledChanged"
    case timelinePlaybackRestart = "BounceNotification.timelinePlaybackRestart"
    
    
    case videoExportFrameChanged = "BounceNotification.videoExportFrameChanged"
    case videoExportBegin = "BounceNotification.videoExportBegin"
    case videoExportError = "BounceNotification.videoExportError"
    case videoExportComplete = "BounceNotification.videoExportComplete"
    
    
    
}

enum ActiveMenu: Int { case tools = 1, record = 2, timeline = 3, export = 4, exportComplete = 5 }
enum SceneMode: Int { case edit = 1, view = 2 }
enum EditMode: Int { case affine = 1, shape = 2, distribution = 3 }
enum AnimationMode: Int { case bounce = 1, twist = 2, random = 3 }

class BounceEngine {
    
    required init() {
        ApplicationController.shared.engine = self
    }
    
    deinit {
        ApplicationController.shared.engine = nil
    }
    
    class var shared:BounceEngine? {
        return ApplicationController.shared.engine
    }
    
    var shouldPromptForSave: Bool = false
    
    //When we load the scene,
    private var _loadName: String?
    var loadName: String? {
        if _loadName != nil {
            if _loadName!.count > 0 {
                return _loadName!
            }
        }
        return nil
    }
    
    private var _zoomEnabled:Bool = false
    var zoomEnabled:Bool {
        get {
            return _zoomEnabled
        }
        set {
            if newValue != _zoomEnabled {
                _zoomEnabled = newValue
                BounceEngine.postNotification(BounceNotification.zoomEnabledChanged)
            }
        }
    }
    
    var zoomEnabledForced:Bool {
        get {
            return _zoomEnabled
        }
        set {
            if newValue != _zoomEnabled {
                _zoomEnabled = newValue
                BounceEngine.postNotification(BounceNotification.zoomEnabledChangedForced)
            }
        }
    }
    
    var activeMenu: ActiveMenu = .tools
    //enum ActiveMenu: Int { case tools = 1, record = 2, animation = 3 }
    
    
    private var _animationEnabled:Bool = false
    var animationEnabled:Bool {
        get { return _animationEnabled }
        set {
            if newValue != _animationEnabled {
                _animationEnabled = newValue
                BounceEngine.postNotification(BounceNotification.animationEnabledChanged)
            }
        }
    }
    
    var animationMode:AnimationMode = .bounce {
        didSet {
            zoomEnabledForced = false
            handleModeChange()
            BounceEngine.postNotification(BounceNotification.animationModeChanged)
        }
    }
    
    private var historyStack = [HistoryState]()
    private var historyIndex: Int = 0
    private var historyLastActionUndo: Bool = false
    private var historyLastActionRedo: Bool = false
    
    var _stereoscopic: Bool = false
    var stereoscopic: Bool {
        get {
            if _stereoscopic && sceneMode == .view {
                if let bounce = ApplicationController.shared.bounce {
                    if fabs(bounce.screenTranslation.x) < 0.1 && fabs(bounce.screenTranslation.y) < 0.1 && fabs(bounce.screenScale - 1.0) < 0.05 {
                        return true
                    }
                }
            }
            return false
        }
        set {
            _stereoscopic = newValue
        }
    }
    
    var stereoscopicHD: Bool = false
    
    fileprivate var _globalCrazyMotionControllerAnimationProgress: CGFloat = 0.0
    var globalCrazyMotionControllerAnimationProgress: CGFloat {
        return _globalCrazyMotionControllerAnimationProgress
    }
    
    fileprivate var _globalCrazyMotionControllerAnimationLoopSpeed: CGFloat = 0.0
    var globalCrazyMotionControllerAnimationLoopSpeed: CGFloat {
        return _globalCrazyMotionControllerAnimationLoopSpeed
    }
    
    private var _gyro: Bool = true
    var gyro: Bool {
        get {
            return _gyro
        }
        set {
            _gyro = newValue
        }
    }
    
    var stereoscopicChannel: Bool = false
    
    //Good # = 16.0 - 18.0
    private var _stereoscopicSpreadOffset: CGFloat = 16.0
    var stereoscopicSpreadOffset: CGFloat {
        if stereoscopicChannel {
            return -_stereoscopicSpreadOffset
        } else {
            return _stereoscopicSpreadOffset
        }
    }
    
    //Good # = 1.6 - 2.0
    private var _stereoscopicSpreadBase:CGFloat = 2.0
    var stereoscopicSpreadBase: CGFloat {
        if stereoscopicChannel {
            return _stereoscopicSpreadBase
        } else {
            return -_stereoscopicSpreadBase
        }
    }
    
    var blobs = [Blob]()
    
    internal var _previousSelectedBlob:Blob?
    var selectedBlob:Blob? {
        willSet {
            _previousSelectedBlob = selectedBlob
            if let blob = _previousSelectedBlob {
                blob.selected = false
                blob.didDeselect()
            }
            
            bulgeWeightEdgeSliderBlob = nil
        }
        didSet {
            if _previousSelectedBlob !== selectedBlob {
                BounceEngine.postNotification(BounceNotification.blobSelectionChanged, object: selectedBlob)
            }
            if let blob = selectedBlob {
                blob.selected = true
                blob.didSelect()
            }
        }
    }
    
    func deleteAllBlobs() {
        var temp = [Blob]()
        for blob:Blob in blobs { temp.append(blob) }
        for blob:Blob in temp { deleteBlob(blob) }
    }
    
    func freeze() {
        stereoscopicBlendBackgroundData = nil
        stereoscopicBlendBackground.clear()
        stereoscopicBlendTexture.clear()
        cancelAllTouches()
        cancelAllGestures()
    }
    
    func unfreeze() {
        
    }
    
    var editShowEdgeFactor: Bool = false
    var editShowCenterWeight: Bool = true
    
    private var _altMenuBulgeBouncer: Int = 0
    var altMenuBulgeBouncer:Int {
        get {
            return _altMenuBulgeBouncer
        }
        set {
            if newValue != _altMenuBulgeBouncer {
                _altMenuBulgeBouncer = newValue
                BounceEngine.postNotification(BounceNotification.altMenuBulgeBouncerChanged)
            }
        }
    }
    
    private var _altMenuTwister: Int = 0
    var altMenuTwister:Int {
        get {
            return _altMenuTwister
        }
        set {
            if newValue != _altMenuTwister {
                _altMenuTwister = newValue
                BounceEngine.postNotification(BounceNotification.altMenuTwisterChanged)
            }
        }
    }
    
    private var _altMenuRandom: Int = 0
    var altMenuRandom:Int {
        get {
            return _altMenuRandom
        }
        set {
            if newValue != _altMenuRandom {
                _altMenuRandom = newValue
                BounceEngine.postNotification(BounceNotification.altMenuRandomChanged)
            }
        }
    }
    
    var animationPower: CGFloat = 0.33 { didSet { for blob in blobs { blob.setNeedsComputeAffine() } } }
    var animationSpeed: CGFloat = 0.75
    
    var animationBulgeBouncerPower: CGFloat = BlobMotionControllerBulgeBouncer.defaultAnimationPower { didSet { for blob in blobs { blob.setNeedsComputeAffine() } } }
    var animationBulgeBouncerSpeed: CGFloat = BlobMotionControllerBulgeBouncer.defaultAnimationSpeed
    var animationBulgeBouncerInflationStartFactor: CGFloat = BlobMotionControllerBulgeBouncer.defaultAnimationInflationStartFactor
    var animationBulgeBouncerEllipseFactor: CGFloat = BlobMotionControllerBulgeBouncer.defaultAnimationEllipseFactor
    var animationBulgeBouncerInflationFactor: CGFloat = BlobMotionControllerBulgeBouncer.defaultAnimationInflationFactor
    var animationBulgeBouncerBounceFactor: CGFloat = BlobMotionControllerBulgeBouncer.defaultAnimationBounceFactor
    
    private var _animationBulgeBouncerBounceEnabled:Bool = BlobMotionControllerBulgeBouncer.defaultAnimationBounceEnabled
    var animationBulgeBouncerBounceEnabled: Bool {
        get { return _animationBulgeBouncerBounceEnabled }
        set { if newValue != _animationBulgeBouncerBounceEnabled {_animationBulgeBouncerBounceEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationBounceEnabledChanged) } }
    }
    
    private var _animationBulgeBouncerReverseEnabled: Bool = BlobMotionControllerBulgeBouncer.defaultAnimationReverseEnabled
    var animationBulgeBouncerReverseEnabled: Bool {
        get { return _animationBulgeBouncerReverseEnabled }
        set { if newValue != _animationBulgeBouncerReverseEnabled {
            _animationBulgeBouncerReverseEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationReverseEnabledChanged) } }
    }
    
    private var _animationBulgeBouncerEllipseEnabled:Bool = BlobMotionControllerBulgeBouncer.defaultAnimationEllipseEnabled
    var animationBulgeBouncerEllipseEnabled:Bool {
        get { return _animationBulgeBouncerEllipseEnabled }
        set { if newValue != _animationBulgeBouncerEllipseEnabled { _animationBulgeBouncerEllipseEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationEllipseEnabledChanged) } }
    }
    
    private var _animationBulgeBouncerAlternateEnabled:Bool = BlobMotionControllerBulgeBouncer.defaultAnimationAlternateEnabled
    var animationBulgeBouncerAlternateEnabled:Bool {
        get { return _animationBulgeBouncerAlternateEnabled }
        set { if newValue != _animationBulgeBouncerAlternateEnabled { _animationBulgeBouncerAlternateEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationAlternationEnabledChanged) } }
    }
    
    private var _animationBulgeBouncerTwistEnabled:Bool = BlobMotionControllerBulgeBouncer.defaultAnimationTwistEnabled
    var animationBulgeBouncerTwistEnabled:Bool {
        get { return _animationBulgeBouncerTwistEnabled }
        set { if newValue != _animationBulgeBouncerTwistEnabled { _animationBulgeBouncerTwistEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationTwistEnabledChanged) } }
    }
    
    private var _animationBulgeBouncerInflateEnabled:Bool = BlobMotionControllerBulgeBouncer.defaultAnimationInflateEnabled
    var animationBulgeBouncerInflateEnabled:Bool {
        get { return _animationBulgeBouncerInflateEnabled }
        set { if newValue != _animationBulgeBouncerInflateEnabled { _animationBulgeBouncerInflateEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationInflateEnabledChanged) } }
    }
    
    private var _animationBulgeBouncerHorizontalEnabled:Bool = false
    var animationBulgeBouncerHorizontalEnabled:Bool {
        get { return _animationBulgeBouncerHorizontalEnabled }
        set { if newValue != _animationBulgeBouncerHorizontalEnabled { _animationBulgeBouncerHorizontalEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationHorizontalEnabledChanged) } }
    }
    
    var animationTwisterTwistPower: CGFloat = BlobMotionControllerTwister.defaultAnimationTwistPower  { didSet { for blob in blobs { blob.setNeedsComputeAffine() } } }
    var animationTwisterTwistSpeed: CGFloat = BlobMotionControllerTwister.defaultAnimationTwistSpeed
    var animationTwisterInflationFactor1: CGFloat = BlobMotionControllerTwister.defaultAnimationInflationFactor1
    var animationTwisterInflationFactor2: CGFloat = BlobMotionControllerTwister.defaultAnimationInflationFactor2
    
    private var _animationTwisterReverseEnabled:Bool = BlobMotionControllerTwister.defaultAnimationReverseEnabled
    var animationTwisterReverseEnabled:Bool {
        get { return _animationTwisterReverseEnabled }
        set { if newValue != _animationTwisterReverseEnabled { _animationTwisterReverseEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationReverseEnabledChanged) } }
    }
    
    private var _animationTwisterEllipseEnabled:Bool = BlobMotionControllerTwister.defaultAnimationEllipseEnabled
    var animationTwisterEllipseEnabled:Bool {
        get { return _animationTwisterEllipseEnabled }
        set { if newValue != _animationTwisterEllipseEnabled { _animationTwisterEllipseEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationEllipseEnabledChanged) } }
    }
    
    private var _animationTwisterAlternateEnabled:Bool = BlobMotionControllerTwister.defaultAnimationAlternateEnabled
    var animationTwisterAlternateEnabled:Bool {
        get { return _animationTwisterAlternateEnabled }
        set { if newValue != _animationTwisterAlternateEnabled { _animationTwisterAlternateEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationAlternationEnabledChanged) } }
    }
    
    private var _animationTwisterInflateEnabled:Bool = BlobMotionControllerTwister.defaultAnimationInflateEnabled
    var animationTwisterInflateEnabled:Bool {
        get { return _animationTwisterInflateEnabled }
        set { if newValue != _animationTwisterInflateEnabled { _animationTwisterInflateEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationTwistEnabledChanged) } }
    }
    
    var animationRandomPower: CGFloat = BlobMotionControllerCrazy.defaultAnimationPower { didSet { for blob in blobs { blob.setNeedsComputeAffine() } } }
    var animationRandomSpeed: CGFloat = BlobMotionControllerCrazy.defaultAnimationSpeed
    var animationRandomInflationFactor1: CGFloat = BlobMotionControllerCrazy.defaultAnimationInflationFactor1
    var animationRandomInflationFactor2: CGFloat = BlobMotionControllerCrazy.defaultAnimationInflationFactor2
    var animationRandomTwistFactor: CGFloat = BlobMotionControllerCrazy.defaultAnimationTwistFactor
    var animationRandomRandomnessFactor: CGFloat = BlobMotionControllerCrazy.defaultAnimationRandomnessFactor
    
    private var _animationRandomReverseEnabled:Bool = BlobMotionControllerCrazy.defaultAnimationReverseEnabled
    var animationRandomReverseEnabled:Bool {
        get { return _animationRandomReverseEnabled }
        set { if newValue != _animationRandomReverseEnabled { _animationRandomReverseEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationReverseEnabledChanged) } }
    }
    
    private var _animationRandomEllipseEnabled:Bool = BlobMotionControllerCrazy.defaultAnimationEllipseEnabled
    var animationRandomEllipseEnabled:Bool {
        get { return _animationRandomEllipseEnabled }
        set { if newValue != _animationRandomEllipseEnabled { _animationRandomEllipseEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationEllipseEnabledChanged) } }
    }
    
    private var _animationRandomAlternateEnabled:Bool = BlobMotionControllerCrazy.defaultAnimationAlternateEnabled
    var animationRandomAlternateEnabled:Bool {
        get { return _animationRandomAlternateEnabled }
        set { if newValue != _animationRandomAlternateEnabled { _animationRandomAlternateEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationAlternationEnabledChanged) } }
    }
    
    private var _animationRandomTwistEnabled:Bool = BlobMotionControllerCrazy.defaultAnimationTwistEnabled
    var animationRandomTwistEnabled:Bool {
        get { return _animationRandomTwistEnabled }
        set { if newValue != _animationRandomTwistEnabled { _animationRandomTwistEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationTwistEnabledChanged) } }
    }
    
    private var _animationRandomInflateEnabled:Bool = BlobMotionControllerCrazy.defaultAnimationInflateEnabled
    var animationRandomInflateEnabled:Bool {
        get { return _animationRandomInflateEnabled }
        set { if newValue != _animationRandomInflateEnabled { _animationRandomInflateEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationInflateEnabledChanged) } }
    }
    
    private var _animationRandomHorizontalEnabled:Bool = BlobMotionControllerBulgeBouncer.defaultAnimationHorizontalEnabled
    var animationRandomHorizontalEnabled:Bool {
        get { return _animationRandomHorizontalEnabled }
        set { if newValue != _animationRandomHorizontalEnabled { _animationRandomHorizontalEnabled = newValue; BounceEngine.postNotification(BounceNotification.animationHorizontalEnabledChanged) } }
    }
    
    private var _isShowingMarkers:Bool = false
    var isShowingMarkers:Bool {
        get {
            return _isShowingMarkers
        }
        set {
            if newValue != _isShowingMarkers {
                _isShowingMarkers = newValue
                BounceEngine.postNotification(BounceNotification.showingMarkersChanged)
            }
        }
    }
    
    
    
    
    //For grab selection via gesture..
    
    weak var _grabSelectionBlob:Blob?
    var grabSelectionBlob:Blob? {
        get {
            return _grabSelectionBlob
        }
        set {
            let blob = _grabSelectionBlob
            _grabSelectionBlob = newValue
            if blob !== newValue && blob !== nil && grabSelectionDidChange == true {
                grabSelectionDidChange = false
            }
        }
    }
    var grabSelectionDidChange: Bool = false
    var grabSelectionStartInflateScale: CGFloat = 1.0
    var grabSelectionStartTwistRotation: CGFloat = 0.0
    var grabSelectionStartAnimationTargetOffset = CGPoint.zero
    var grabSelectionPanning: Bool = false
    var grabSelectionPinching: Bool = false
    var grabSelectionRotating: Bool = false
    var grabSelectionPanStart = CGPoint.zero
    
    //For the affine transformations only..
    weak var _bulgeSelectionBlob:Blob?
    var bulgeSelectionBlob:Blob? {
        
        get {
            return _bulgeSelectionBlob
        }
        set {
            let blob = _bulgeSelectionBlob
            _bulgeSelectionBlob = newValue
            if blob !== newValue && blob !== nil && bulgeSelectionDidChange == true {
                bulgeSelectionDidChange = false
                let historyState = HistoryStateChangeBulgeCenter()
                historyState.recordStart(withBlob: blob)
                historyState.blobIndex = indexOf(blob: blob!)
                historyState.startOffset = bulgeHistoryStartOffset
                //historyState.startScale = bulgeHistoryStartScale
                //historyState.startRotation = bulgeHistoryStartRotation
                historyState.endOffset = blob!.bulgeWeightOffset
                //historyState.endScale = blob!.bulgeWeightScale
                //historyState.endRotation = blob!.bulgeWeightRotation
                
                historyState.recordEnd(withBlob: blob)
                historyAdd(withState: historyState)
            }
        }
    }
    weak var bulgeSelectionTouch:UITouch?
    var bulgeGestureCenter:CGPoint = CGPoint.zero
    var bulgeSelectionStartOffset:CGPoint = CGPoint.zero
    var bulgeSelectionStartCenter:CGPoint = CGPoint.zero
    
    var bulgeHistoryStartOffset:CGPoint = CGPoint.zero
    
    var bulgeSelectionDidChange: Bool = false
    
    var tweakStartBulgeEdgeFactor: CGFloat = 1.0
    var tweakStartBulgeCenterFactor: CGFloat = 1.0
    
    var tweakStartAnimationPower: CGFloat = 1.0
    var tweakStartAnimationSpeed: CGFloat = 1.0
    
    var tweakStartAnimationBulgeBouncerPower: CGFloat = 1.0
    var tweakStartAnimationBulgeBouncerSpeed: CGFloat = 1.0
    var tweakStartAnimationBulgeBouncerBounce: CGFloat = 1.0
    var tweakStartAnimationBulgeBouncerBounceStart: CGFloat = 1.0
    var tweakStartAnimationBulgeBouncerInflationFactor: CGFloat = 1.0
    var tweakStartAnimationBulgeBouncerEllipseFactor: CGFloat = 1.0
    
    var tweakStartAnimationTwisterTwistPower: CGFloat = 1.0
    var tweakStartAnimationTwisterTwistSpeed: CGFloat = 1.0
    var tweakStartAnimationTwisterInflationFactor1: CGFloat = 1.0
    var tweakStartAnimationTwisterInflationFactor2: CGFloat = 1.0
    
    var tweakStartAnimationRandomPower: CGFloat = 1.0
    var tweakStartAnimationRandomSpeed: CGFloat = 1.0
    var tweakStartAnimationRandomInflationFactor1: CGFloat = 1.0
    var tweakStartAnimationRandomInflationFactor2: CGFloat = 1.0
    var tweakStartAnimationRandomTwistFactor: CGFloat = 1.0
    var tweakStartAnimationRandomRandomnessFactor: CGFloat = 1.0
    
    //For the affine transformations only..
    weak var _affineSelectionBlob:Blob?
    var affineSelectionBlob:Blob? {
        get {
            return _affineSelectionBlob
        }
        set {
            let blob = _affineSelectionBlob
            _affineSelectionBlob = newValue
            if blob !== newValue && blob !== nil && affineSelectionDidChange == true {
                affineSelectionDidChange = false
                let historyState = HistoryStateChangeAffine()
                historyState.recordStart(withBlob: blob)
                historyState.blobIndex = indexOf(blob: blob!)
                historyState.startPos = affineHistoryStartCenter
                historyState.startScale = affineHistoryStartScale
                historyState.startRotation = affineHistoryStartRotation
                historyState.endPos = blob!.center
                historyState.endScale = blob!.scale
                historyState.endRotation = blob!.rotation
                historyState.recordEnd(withBlob: blob)
                historyAdd(withState: historyState)
            }
        }
    }
    
    weak var affineSelectionTouch:UITouch?
    var affineGestureStartCenter:CGPoint = CGPoint.zero
    var affineGestureCenter:CGPoint = CGPoint.zero
    var affineSelectionStartCenter:CGPoint = CGPoint.zero
    var affineSelectionStartScale:CGFloat = 1.0
    var affineSelectionStartRotation:CGFloat = 0.0
    
    var affineHistoryStartCenter:CGPoint = CGPoint.zero
    var affineHistoryStartScale:CGFloat = 1.0
    var affineHistoryStartRotation:CGFloat = 0.0
    
    var affineSelectionDidChange: Bool = false
    
    weak var _shapeSelectionBlob:Blob?
    var shapeSelectionBlob:Blob? {
        get {
            return _shapeSelectionBlob
        }
        
        set {
            let blob = _shapeSelectionBlob
            _shapeSelectionBlob = newValue
            
            if blob !== newValue && blob !== nil && shapeSelectionDidChange == true {
                shapeSelectionDidChange = false
                let historyState = HistoryStateChangeShape()
                historyState.recordStart(withBlob: blob)
                historyState.blobIndex = indexOf(blob: blob)
                historyState.startSplineData = shapeSelectionStartSpline.save()
                historyState.recordEnd(withBlob: blob)
                historyAdd(withState: historyState)
            }
        }
    }
    weak var shapeSelectionTouch:UITouch?
    var shapeSelectionOffset:CGPoint = CGPoint.zero
    var shapeSelectionStartSpline = CubicSpline()
    var shapeSelectionDidChange: Bool = false
    
    var scene = BounceScene()
    
    let background = SpriteColored()
    let backgroundTexture = Texture()
    
    func setStereoscopicBlendBackground(stereoscopicImage: UIImage?) {
        if let image = stereoscopicImage {
            var textureWidth:GLsizei = 0; var textureHeight:GLsizei = 0
            var scaledWidth:GLsizei = 0; var scaledHeight:GLsizei = 0
            if stereoscopicBlendTexture.bindIndex == nil || stereoscopicBlendBackgroundData == nil {
                stereoscopicBlendBackgroundData = Texture.load(image: image, textureWidth: &textureWidth, textureHeight: &textureHeight, scaledWidth: &scaledWidth, scaledHeight: &scaledHeight, atlasX: &stereoscopicBlendAtlasX, atlasY: &stereoscopicBlendAtlasY, atlasWidth: &stereoscopicBlendAtlasWidth, atlasHeight: &stereoscopicBlendAtlasHeight)
                stereoscopicBlendTexture.Load(data: &(stereoscopicBlendBackgroundData!), textureWidth: Int(textureWidth), textureHeight: Int(textureHeight), scaledWidth: Int(scaledWidth), scaledHeight: Int(scaledHeight), atlasX: stereoscopicBlendAtlasX, atlasY: stereoscopicBlendAtlasY, atlasWidth: stereoscopicBlendAtlasWidth, atlasHeight: stereoscopicBlendAtlasHeight)
                
                stereoscopicBlendBackground.load(texture: stereoscopicBlendTexture)
                stereoscopicBlendBackground.startX = 0.0
                stereoscopicBlendBackground.startY = 0.0
                stereoscopicBlendBackground.endX = ApplicationController.shared.bounce!.screenFrame.size.width
                stereoscopicBlendBackground.endY = ApplicationController.shared.bounce!.screenFrame.size.height
            } else {
                Texture.loadOver(image: image, data: &(stereoscopicBlendBackgroundData!), atlasX: stereoscopicBlendAtlasX, atlasY: stereoscopicBlendAtlasY, atlasWidth: stereoscopicBlendAtlasWidth, atlasHeight: stereoscopicBlendAtlasHeight, clear: true)
                stereoscopicBlendTexture.loadOver(imageData: &(stereoscopicBlendBackgroundData!))
            }
        }
    }
    
    var stereoscopicBlendBackgroundData:UnsafeMutableRawPointer?
    var stereoscopicBlendTexture = Texture()
    var stereoscopicBlendBackground = SpriteColored()
    
    var stereoscopicBlendAtlasX: Int = 0
    var stereoscopicBlendAtlasY: Int = 0
    var stereoscopicBlendAtlasWidth: Int = 0
    var stereoscopicBlendAtlasHeight: Int = 0
    
    var sceneRect:CGRect = CGRect.zero {
        didSet {
            background.startX = sceneRect.origin.x
            background.startY = sceneRect.origin.y
            background.endX = (sceneRect.origin.x + sceneRect.size.width)
            background.endY = (sceneRect.origin.y + sceneRect.size.height)
        }
    }
    
    var sceneMode:SceneMode = .edit {
        willSet {
            if sceneMode != newValue {
                if newValue == .edit {
                    ApplicationController.shared.bounce?.animateScreenTransformToEdit()
                } else if newValue == .view {
                    ApplicationController.shared.bounce?.animateScreenTransformToIdentity()
                }
            }
        }
        
        didSet {
            zoomEnabledForced = false
            handleModeChange()
            BounceEngine.postNotification(BounceNotification.sceneModeChanged)
        }
    }
    
    //internal var previousEditMode:EditMode = .affine
    var editMode:EditMode = .affine {
        didSet {
            handleModeChange()
            BounceEngine.postNotification(BounceNotification.editModeChanged)
        }
    }
    
    var deletedBlobs = [Blob]()
    func deleteBlob(_ blob:Blob?) {
        if let deleteBlob = blob {
            
            deletedBlobs.append(deleteBlob)
            
            if affineSelectionBlob === deleteBlob {
                affineSelectionBlob = nil
                affineSelectionTouch = nil
            }
            
            if bulgeSelectionBlob === deleteBlob {
                bulgeSelectionBlob = nil
                bulgeSelectionTouch = nil
            }
            
            if shapeSelectionBlob === deleteBlob {
                shapeSelectionBlob = nil
                shapeSelectionTouch = nil
            }
            
            if selectedBlob === deleteBlob {
                if blobs.count <= 1 {
                    deselectBlob()
                } else {
                    selectNextBlob()
                }
            }
            
            var deleteIndex:Int?
            for i in 0..<blobs.count {
                if blobs[i] === deleteBlob {
                    deleteIndex = i
                }
            }
            
            if let index = deleteIndex {
                blobs.remove(at: index)
            }
            
            blobCountDidChange()
        }
        
        refreshBlobAlternation()
    }
    
    func handleModeChange() {
        refreshBlobAlternation()
        cancelAllTouches()
        cancelAllGestures()
    }
    
    func setUp(scene: BounceScene) {//, appFrame:CGRect) {
        self.scene = scene
        let screenSize = scene.isLandscape ? CGSize(width: Device.landscapeWidth, height: Device.landscapeHeight) : CGSize(width: Device.portraitWidth, height: Device.portraitHeight)
        scene.screenSize = CGSize(width: screenSize.width, height: screenSize.height)
        scene.imageSize = CGSize(width: 0.0, height: 0.0)
        scene.imageFrame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        if let image = scene.image , image.size.width > 32 && image.size.height > 32 {
            scene.imageSize = CGSize(width: image.size.width, height: image.size.height)
            //If the image is too large for the device, shrink it down.
            let widthRatio = (Double(screenSize.width) * Double(Device.scale)) / Double(image.size.width)
            let heightRatio = (Double(screenSize.height) * Double(Device.scale)) / Double(image.size.height)
            let ratio = min(widthRatio, heightRatio)
            if ratio < 0.999 {
                //This basically means that we've imported an image from
                //a different device.
                
                let importWidth = CGFloat(Int(Double(image.size.width) * ratio + 0.5))
                let importHeight = CGFloat(Int(Double(image.size.height) * ratio + 0.5))
                scene.image = image.resize(CGSize(width: importWidth, height: importHeight))
            }
            
            backgroundTexture.load(image: scene.image)
            background.load(texture: backgroundTexture)
            
            //Center the image on the screen,
            if screenSize.width > 64 && screenSize.height > 64 && image.size.width > 64 && image.size.height > 64 {
                let widthRatio = Double(screenSize.width) / Double(image.size.width)
                let heightRatio = Double(screenSize.height) / Double(image.size.height)
                let ratio = min(widthRatio, heightRatio)
                let sceneWidth = CGFloat(Int(Double(image.size.width) * ratio))
                let sceneHeight = CGFloat(Int(Double(image.size.height) * ratio))
                let sceneX = CGFloat(Int(screenSize.width / 2.0 - sceneWidth / 2.0))
                let sceneY = CGFloat(Int(screenSize.height / 2.0 - sceneHeight / 2.0))
                self.sceneRect = CGRect(x: sceneX, y: sceneY, width: sceneWidth, height: sceneHeight)
                scene.imageFrame = CGRect(x: sceneX, y: sceneY, width: sceneWidth, height: sceneHeight)
            }
        }
        refreshBlobAlternation()
        blobCountDidChange()
    }
    
    //Called AFTER setup, for load it's called after loading is complete...
    func setUpComplete() {
        handleAnimationEnabledChanged()
    }
    
    func update() {
        
        let minAnimationLoopSpeed: CGFloat = 1.725
        let maxAnimationLoopSpeed: CGFloat = 4.65
        
        _globalCrazyMotionControllerAnimationLoopSpeed = minAnimationLoopSpeed + (maxAnimationLoopSpeed - minAnimationLoopSpeed) * animationRandomSpeed
        _globalCrazyMotionControllerAnimationProgress += globalCrazyMotionControllerAnimationLoopSpeed
        
        if _globalCrazyMotionControllerAnimationProgress > (BlobMotionControllerCrazy.globalLoopMax) {
            _globalCrazyMotionControllerAnimationProgress -= (BlobMotionControllerCrazy.globalLoopMax)
            //Re-compute the randomness.
            for blob in blobs {
                blob.crazyMotionController.resetLooping(alt: blob.isAltBlob)
                blob.crazyMotionController.recomputeSpline()
            }
        }
        
        for blob:Blob in blobs {
            blob.update()
        }
    }
    
    func draw() {
        
        if stereoscopic {
            
            let holdMat = ShaderProgramMesh.shared.matrixProjectionGet()
            let mat = Matrix(holdMat)
            mat.translate(stereoscopicSpreadBase, 0.0, 0.0)
            
            ShaderProgramSimple.shared.use()
            ShaderProgramSimple.shared.matrixProjectionSet(mat)
            
            ShaderProgramSprite.shared.use()
            ShaderProgramSprite.shared.matrixProjectionSet(mat)
            
            ShaderProgramMesh.shared.use()
            ShaderProgramMesh.shared.matrixProjectionSet(mat)
            
            if stereoscopicChannel {
                background.setColor(0.0, 1.0, 1.0, 1.0)
            } else {
                background.setColor(1.0, 0.0, 0.0, 1.0)
            }
            
            background.draw()
            
            ShaderProgramSimple.shared.use()
            ShaderProgramSimple.shared.matrixProjectionSet(holdMat)
            
            ShaderProgramSprite.shared.use()
            ShaderProgramSprite.shared.matrixProjectionSet(holdMat)
            
            ShaderProgramMesh.shared.use()
            ShaderProgramMesh.shared.matrixProjectionSet(holdMat)
            
        } else {
            background.setColor(1.0, 1.0, 1.0, 1.0)
            background.draw()
        }
        
        ShaderProgramSprite.shared.colorSet()
        ShaderProgramMesh.shared.colorSet()
        
        if sceneMode == .view {
            Graphics.depthEnable()
            Graphics.depthClear()
        }
        
        for blob:Blob in blobs {
            blob.drawBulgeEdgeFactor = (blob === bulgeWeightEdgeSliderBlob)
            blob.drawBulgeCenterFactor = (blob === bulgeWeightCenterSliderBlob)
            blob.drawMesh()
        }
        
        Graphics.depthClear()
        Graphics.depthDisable()
        
        if (sceneMode == .edit) {
            for blob:Blob in blobs { blob.drawMarkers() }
        }
        
        if (sceneMode == .view && _isShowingMarkers == true) {
            if stereoscopic == true {
                if stereoscopicChannel == false {
                    for blob:Blob in blobs { blob.drawOverlayMarkers() }
                }
            } else {
                for blob:Blob in blobs { blob.drawOverlayMarkers() }
            }
        }
        
        ShaderProgramMesh.shared.use()
        ShaderProgramMesh.shared.colorSet()
        
        
        if stereoscopic && stereoscopicChannel == true && stereoscopicBlendBackground.texture != nil {
            Graphics.blendEnable()
            Graphics.blendSetAdditive()
            stereoscopicBlendBackground.draw()
            Graphics.blendSetAlpha()
        }
        
        
        /*
         guard let screenRect = BounceViewController.shared?.screenFrame else { return }
         
         
         var safeInsetH: CGFloat = screenRect.size.width / 8.0
         var safeInsetV: CGFloat = screenRect.size.height / 8.0
         
         var safeRect = CGRect(x: screenRect.origin.x + safeInsetH, y: screenRect.origin.y + safeInsetV, width: screenRect.size.width - safeInsetH * 2.0, height: screenRect.size.height - safeInsetV * 2.0)
         
         //var screenFrame = CGRect(x: screenRect.origin.x + 50.0, y: screenRect.origin.y + 20.0, width: screenRect.size.width - 100.0, height: screenRect.size.height - 40.0)
         
         ShaderProgramSimple.shared.colorSet(r: 0.6, g: 0.2, b: 0.2, a: 0.5)
         ShaderProgramSimple.shared.rectDraw(safeRect)
         
         ShaderProgramSimple.shared.colorSet()
         
         var sceneCenterX = screenRect.midX + screenRect.size.width / 4.0
         var sceneCenterY = screenRect.midY
         
         //sceneCenterX = 150.0
         //sceneCenterY = 20.0
         
         sceneCenterX = blobs[0].center.x
         sceneCenterY = blobs[0].center.y
         
         ShaderProgramSimple.shared.colorSet(r: 1.0, g: 1.0, b: 1.0, a: 0.7)
         ShaderProgramSimple.shared.pointDraw(point: CGPoint(x: sceneCenterX, y: sceneCenterY), size: 24.0)
         
         pickNewBlobPositionOnScreen(point: CGPoint(x: sceneCenterX, y: sceneCenterY), withScreenFrame: screenRect)
         */
        
        
    }
    
    func uiActionAllowed() -> Bool {
        
        if affineSelectionBlob !== nil {
            print("AFFINE BLOB -> BLOCKING UI ACTION")
            return false
        }
        
        if bulgeSelectionBlob !== nil {
            print("BULGE BLOB -> BLOCKING UI ACTION")
            return false
        }
        
        if shapeSelectionBlob !== nil {
            print("SHAPE BLOB -> BLOCKING UI ACTION")
            return false
        }
        
        if affineSelectionTouch !== nil {
            print("AFFINE TOUCH -> BLOCKING UI ACTION")
            return false
        }
        
        if bulgeSelectionTouch !== nil {
            print("BULGE TOUCH -> BLOCKING UI ACTION")
            return false
        }
        
        if shapeSelectionTouch !== nil {
            print("SHAPE TOUCH -> BLOCKING UI ACTION")
            return false
        }
        
        return true
    }
    
    func touchesAllowed() -> Bool {
        
        if sceneMode == .view && _animationEnabled == true {
            return false
        }
        
        if _bulgeWeightEdgeSliderBlob !== nil {
            return false
        }
        return true
    }
    
    func touchDown(_ touch:inout UITouch, point:CGPoint) {
        
        if touchesAllowed() == false {
            cancelAllTouches()
            return
        }
        
        let touchBlob = selectBlobAtPoint(point)
        
        if sceneMode == .view {
            
            
            //OLD: Find better way to handle multi-touch overlapping blobs here.
            if let blob = touchBlob {
                
                if blob.grabSelectionTouch === nil {
                    blob.grabSelectionTouch = touch
                    
                    //Guide offset becomes the "undampened" version of the animation target
                    //This will keep position consistent as we release and re-grab, etc...
                    blob.orbitMotionController.animationGuideOffset = unwindAnimationTargetOffsetDamped(blob: blob)
                    
                    //At first this may be confising since we are "unwinding" the
                    //animation target offset dampening - however, we generally re-dampen
                    //the position that the target is being dragged to, so it makes sense
                    //for the limited scope of our current motion controllers.
                    blob.grabAnimationTargetOffsetStart = blob.orbitMotionController.animationGuideOffset
                    blob.grabAnimationTargetOffsetTouchStart = CGPoint(x: point.x, y: point.y)
                }
            }
        }
        
        if sceneMode == .edit && editMode == .affine {
            if affineSelectionTouch === nil {
                affineSelectionBlob = touchBlob
                if let checkAffineSelectedBlob = affineSelectionBlob {
                    affineSelectionDidChange = false
                    selectedBlob = checkAffineSelectedBlob
                    affineSelectionTouch = touch
                    affineSelectionStartCenter = checkAffineSelectedBlob.center
                    affineSelectionStartScale = checkAffineSelectedBlob.scale
                    affineSelectionStartRotation = checkAffineSelectedBlob.rotation
                    affineHistoryStartCenter = affineSelectionStartCenter
                    affineHistoryStartScale = affineSelectionStartScale
                    affineHistoryStartRotation = affineSelectionStartRotation
                } else {
                    // Touch outside all blobs = deselect
                    if affineSelectionTouch === nil && touchBlob === nil {
                        selectedBlob = nil
                    }
                    
                    affineSelectionDidChange = false
                    affineSelectionBlob = nil
                    affineSelectionTouch = nil
                }
            }
        }
        
        if sceneMode == .edit && editMode == .shape {
            var closest:(index:Int, distance:CGFloat)?
            var closestDistance: CGFloat = 1000.0
            var editBlob:Blob?
            var offset:CGPoint = CGPoint.zero
            for blob:Blob in blobs {
                if blob.isSelectable {
                    let pointInBlob = blob.untransformPoint(point: point)
                    if let c = blob.spline.getClosestControlPoint(point: pointInBlob) {
                        
                        //Normalize the distance comparisons to account for the scales of the blobs...
                        let scaledDistance: CGFloat = c.distance * blob.scale
                        var pick:Bool = false
                        if closest == nil {
                            pick = true
                        } else if scaledDistance < closestDistance {
                            pick = true
                        }
                        if pick {
                            closestDistance = scaledDistance
                            closest = c
                            editBlob = blob
                            
                            var controlPoint = blob.spline.getControlPoint(c.index)
                            controlPoint = blob.transformPoint(point: controlPoint)
                            offset.x = controlPoint.x - point.x
                            offset.y = controlPoint.y - point.y
                        }
                    }
                }
            }
            
            if let blob = editBlob , shapeSelectionTouch === nil {
                selectedBlob = blob
                if closest!.distance * blob.scale < ApplicationController.shared.pointSelectDist {
                    shapeSelectionDidChange = false
                    shapeSelectionBlob = blob
                    shapeSelectionStartSpline = blob.spline.clone()
                    shapeSelectionTouch = touch
                    blob.selectedControlPointIndex = closest!.index
                    shapeSelectionOffset = offset
                } else {
                    if shapeSelectionTouch === nil && touchBlob === nil {
                        selectedBlob = nil
                    }
                }
            }
        }
        
        if sceneMode == .edit && editMode == .distribution {
            var pickBlob: Blob?
            var bestDist: CGFloat?
            for i in stride(from: blobs.count - 1, to: -1, by: -1) {
                let blob = blobs[i]
                if blob.isSelectable {
                    let weightCenter = blob.bulgeWeightCenter
                    let diffX = weightCenter.x - point.x
                    let diffY = weightCenter.y - point.y
                    let dist = diffX * diffX + diffY * diffY
                    if bestDist == nil {
                        bestDist = dist
                        pickBlob = blob
                    } else {
                        if bestDist! > dist {
                            pickBlob = blob
                            bestDist = dist
                        }
                    }
                }
            }
            
            if bestDist != nil {
                if bestDist! > Math.epsilon {
                    bestDist = CGFloat(sqrtf(Float(bestDist!)))
                }
                if bestDist! > ApplicationController.shared.bulgeSelectDist {
                    pickBlob = nil
                }
            }
            
            if pickBlob === nil {
                pickBlob = touchBlob
            }
            
            if bulgeSelectionTouch === nil {
                bulgeSelectionBlob = pickBlob
                if let checkBulgeSelectedBlob = bulgeSelectionBlob {
                    bulgeSelectionDidChange = false
                    selectedBlob = checkBulgeSelectedBlob
                    bulgeSelectionTouch = touch
                    bulgeSelectionStartCenter = checkBulgeSelectedBlob.bulgeWeightCenter
                    bulgeSelectionStartOffset = checkBulgeSelectedBlob.bulgeWeightOffset
                    bulgeHistoryStartOffset = bulgeSelectionStartOffset
                } else {
                    
                    // Touch outside all blobs = deselect
                    if bulgeSelectionBlob === nil && pickBlob === nil {
                        selectedBlob = nil
                    }
                    
                    bulgeSelectionDidChange = false
                    bulgeSelectionBlob = nil
                    bulgeSelectionTouch = nil
                }
            }
        }
    }
    
    func touchMove(_ touch:inout UITouch, point:CGPoint) {
        
        if touchesAllowed() == false {
            cancelAllTouches()
            return
        }
        
        if sceneMode == .view {
            for blob in blobs {
                if blob.grabSelectionTouch === touch {
                    let diffX = point.x - blob.grabAnimationTargetOffsetTouchStart.x
                    let diffY = point.y - blob.grabAnimationTargetOffsetTouchStart.y
                    let guideX = blob.grabAnimationTargetOffsetStart.x + diffX
                    let guideY = blob.grabAnimationTargetOffsetStart.y + diffY
                    blob.dragAnimationTargetOffsetDampened(withNewOffset: CGPoint(x: guideX, y: guideY))
                }
            }
        }
        
        if sceneMode == .edit && editMode == .shape {
            if let blob = shapeSelectionBlob , touch === shapeSelectionTouch {
                if let index = blob.selectedControlPointIndex {
                    shapeSelectionDidChange = true
                    let pointInBlob = blob.untransformPoint(point: CGPoint(x: point.x + shapeSelectionOffset.x, y: point.y + shapeSelectionOffset.y))
                    blob.spline.set(index, x: pointInBlob.x, y: pointInBlob.y)
                    blob.setNeedsComputeShape()
                }
            }
        }
    }
    
    func touchUp(_ touch:inout UITouch, point:CGPoint) {
        if touchesAllowed() == false {
            cancelAllTouches()
            return
        }
        
        if sceneMode == .view {
            var index: Int = 0
            for blob in blobs {
                if blob.grabSelectionTouch === touch {
                    let diffX = point.x - blob.grabAnimationTargetOffsetTouchStart.x
                    let diffY = point.y - blob.grabAnimationTargetOffsetTouchStart.y
                    
                    let guideX = blob.grabAnimationTargetOffsetStart.x + diffX
                    let guideY = blob.grabAnimationTargetOffsetStart.y + diffY
                    
                    blob.captureFinalRelease(point: CGPoint(x: guideX, y: guideY))
                    blob.releaseGrabFling()
                }
                
                index += 1
            }
        }
        
        if touch === affineSelectionTouch {
            affineSelectionTouch = nil
            affineSelectionBlob = nil
        }
        
        if touch === bulgeSelectionTouch {
            bulgeSelectionTouch = nil
            bulgeSelectionBlob = nil
        }
        
        if touch === shapeSelectionTouch {
            shapeSelectionTouch = nil
            shapeSelectionBlob = nil
        }
    }
    
    func cancelAllTouches() {
        affineSelectionBlob = nil
        affineSelectionTouch = nil
        
        bulgeSelectionBlob = nil
        bulgeSelectionTouch = nil
        
        shapeSelectionTouch = nil
        shapeSelectionBlob = nil
        
        for blob in blobs { blob.grabSelectionTouch = nil }
        
        affineSelectionDidChange = false
        bulgeSelectionDidChange = false
        shapeSelectionDidChange = false
    }
    
    
    var isPanning:Bool = false
    var panStartPos:CGPoint = CGPoint.zero
    var panPos:CGPoint = CGPoint.zero
    
    func panBegin(pos:CGPoint) {
        
        if touchesAllowed() == false {
            cancelAllGestures()
            return
        }
        
        if isPanning {
            panEnd(pos: pos, velocity: CGPoint.zero, forced: true)
        }
        
        isPanning = true
        panStartPos = pos
        panPos = pos
        
        affineGestureCenter = pos
        bulgeGestureCenter = pos
        
        if grabSelectionBlob != nil && grabSelectionPanning == false {
            grabSelectionPanning = true
            grabSelectionPanStart = CGPoint(x: panPos.x, y: panPos.y)
        }
        
        
        if affineSelectionBlob != nil {
            affineSelectionDidChange = true
        }
        
        if bulgeSelectionBlob != nil {
            bulgeSelectionDidChange = true
        }
        
        if grabSelectionBlob != nil {
            grabSelectionDidChange = true
        }
        
        if sceneMode == .edit && editMode == .affine {
            if let blob = affineSelectionBlob {
                affineSelectionStartCenter = blob.center
                affineGestureStartCenter = blob.untransformPoint(point: pos)
            }
            gestureUpdateAffine()
        }
        
        if sceneMode == .edit && editMode == .distribution {
            if let blob = bulgeSelectionBlob {
                bulgeSelectionStartCenter = blob.bulgeWeightCenter
            }
            gestureUpdateBulge()
        }
    }
    
    func pan(pos:CGPoint) {
        
        if touchesAllowed() == false {
            cancelAllGestures()
            return
        }
        
        guard isPanning else { return }
        panPos = pos
        affineGestureCenter = pos
        bulgeGestureCenter = pos
        
        if grabSelectionBlob != nil && grabSelectionPanning == false {
            grabSelectionPanning = true
            grabSelectionPanStart = CGPoint(x: panPos.x, y: panPos.y)
        }
        if affineSelectionBlob != nil {
            affineSelectionDidChange = true
        }
        if bulgeSelectionBlob != nil {
            bulgeSelectionDidChange = true
        }
        if grabSelectionBlob != nil {
            grabSelectionDidChange = true
        }
        
        if sceneMode == .edit && editMode == .affine { gestureUpdateAffine() }
        if sceneMode == .edit && editMode == .distribution { gestureUpdateBulge() }
        
        updateSecondaryViewGrabGesture()
    }
    
    func panEnd(pos:CGPoint, velocity:CGPoint, forced: Bool) {
        
        if touchesAllowed() == false {
            cancelAllGestures()
            return
        }
        
        guard isPanning else { return }
        panPos = pos
        
        
        //We should only have one blob as our grab
        //selection via gesture. Release it with motion..
        if sceneMode == .view {
            for blob in blobs {
                if blob.grabSelectionGesture {
                    if grabSelectionPanning {
                        let guideX = grabSelectionStartAnimationTargetOffset.x + (panPos.x - grabSelectionPanStart.x)
                        let guideY = grabSelectionStartAnimationTargetOffset.y + (panPos.y - grabSelectionPanStart.y)
                        //print("PAN - blob.captureFinalRelease(\(guideX), \(guideY))")
                        blob.captureFinalRelease(point: CGPoint(x: guideX, y: guideY))
                    }
                    blob.releaseGrabFling()
                }
            }
        }
        
        grabSelectionPanning = false
        isPanning = false
        
        if forced == false {
            gestureEnd()
        }
    }
    
    var isPinching:Bool = false
    var pinchScale:CGFloat = 1.0
    var pinchStartPos:CGPoint = CGPoint.zero
    var pinchPos:CGPoint = CGPoint.zero
    
    func pinchBegin(pos:CGPoint, scale:CGFloat) {
        
        if touchesAllowed() == false {
            cancelAllGestures()
            return
        }
        
        if isPinching {
            pinchEnd(pos: pos, scale: pinchScale, forced: true)
            isPinching = false
        }
        
        isPinching = true
        pinchStartPos = pos
        pinchPos = pos
        affineGestureCenter = pos
        bulgeGestureCenter = pos
        
        pinchScale = scale
        
        if sceneMode == .view && _animationEnabled == false {
            attemptSecondaryViewGrabGesture(withPoint: pos)
        }
        
        if affineSelectionBlob != nil {
            affineSelectionDidChange = true
        }
        if bulgeSelectionBlob != nil {
            bulgeSelectionDidChange = true
        }
        if grabSelectionBlob != nil {
            grabSelectionDidChange = true
        }
        
        if sceneMode == .edit && editMode == .affine {
            if let blob = affineSelectionBlob {
                affineGestureStartCenter = blob.untransformPoint(point: pos)
            }
            gestureUpdateAffine()
        }
        
        if sceneMode == .edit && editMode == .distribution {
            gestureUpdateBulge()
        }
        
        if grabSelectionBlob != nil {
            grabSelectionPinching = true
        }
        
        updateSecondaryViewGrabGesture()
    }
    
    func pinch(pos:CGPoint, scale:CGFloat) {
        
        if touchesAllowed() == false {
            cancelAllGestures()
            return
        }
        
        guard isPinching else { return }
        pinchPos = pos
        pinchScale = scale
        affineGestureCenter = pos
        bulgeGestureCenter = pos
        if affineSelectionBlob != nil {
            affineSelectionDidChange = true
        }
        if bulgeSelectionBlob != nil {
            bulgeSelectionDidChange = true
        }
        if grabSelectionBlob != nil {
            grabSelectionDidChange = true
        }
        
        if sceneMode == .edit && editMode == .affine { gestureUpdateAffine() }
        if sceneMode == .edit && editMode == .distribution { gestureUpdateBulge() }
        
        updateSecondaryViewGrabGesture()
    }
    
    func pinchEnd(pos:CGPoint, scale:CGFloat, forced: Bool) {
        
        if touchesAllowed() == false {
            cancelAllGestures()
            return
        }
        
        guard isPinching else { return }
        pinchPos = pos
        pinchScale = scale
        isPinching = false
        
        if forced == false {
            gestureEnd()
        }
    }
    
    var isRotating:Bool = false
    var rotation:CGFloat = 0.0
    var rotationStartPos:CGPoint = CGPoint.zero
    var rotationPos:CGPoint = CGPoint.zero
    func rotateBegin(pos:CGPoint, radians:CGFloat) {
        
        if touchesAllowed() == false {
            cancelAllGestures()
            return
        }
        
        if isRotating {
            rotateEnd(pos: pos, radians: radians, forced: true)
            isRotating = false
        }
        isRotating = true
        rotationStartPos = pos
        rotationPos = pos
        rotation = radians
        affineGestureCenter = pos
        bulgeGestureCenter = pos
        
        if sceneMode == .view && animationEnabled == false {
            attemptSecondaryViewGrabGesture(withPoint: pos)
        }
        
        if affineSelectionBlob != nil {
            affineSelectionDidChange = true
        }
        if bulgeSelectionBlob != nil {
            bulgeSelectionDidChange = true
        }
        if grabSelectionBlob != nil {
            grabSelectionDidChange = true
        }
        
        if sceneMode == .edit && editMode == .affine {
            if let blob = affineSelectionBlob {
                affineGestureStartCenter = blob.untransformPoint(point: pos)
            }
            gestureUpdateAffine()
        }
        
        if sceneMode == .edit && editMode == .distribution {
            gestureUpdateBulge()
        }
        
        if grabSelectionBlob != nil {
            grabSelectionRotating = true
        }
        
        updateSecondaryViewGrabGesture()
        
    }
    
    func rotate(pos:CGPoint, radians:CGFloat) {
        
        if touchesAllowed() == false {
            cancelAllGestures()
            return
        }
        
        guard isRotating else { return }
        rotationPos = pos
        rotation = radians
        affineGestureCenter = pos
        bulgeGestureCenter = pos
        if affineSelectionBlob != nil {
            affineSelectionDidChange = true
        }
        if bulgeSelectionBlob != nil {
            bulgeSelectionDidChange = true
        }
        if grabSelectionBlob != nil {
            grabSelectionDidChange = true
        }
        
        if sceneMode == .edit && editMode == .affine { gestureUpdateAffine() }
        if sceneMode == .edit && editMode == .distribution { gestureUpdateBulge() }
        
        updateSecondaryViewGrabGesture()
    }
    
    func rotateEnd(pos:CGPoint, radians:CGFloat, forced: Bool) {
        
        if touchesAllowed() == false {
            cancelAllGestures()
            return
        }
        
        guard isRotating else { return }
        rotationPos = pos
        rotation = radians
        isRotating = false
        
        if forced == false {
            gestureEnd()
        }
    }
    
    func gestureEnd() {
        
        //It's possible that the gesure will cancel, but touch will remain
        //e.g. the user has clicked an interface element, therefore, we
        //must force the hand here to keep our history consistent.
        if isPanning == false && isPinching == false && isRotating == false {
            affineSelectionBlob = nil
            bulgeSelectionBlob = nil
            shapeSelectionBlob = nil
            grabSelectionBlob = nil
            
            affineSelectionTouch = nil
            bulgeSelectionTouch = nil
            shapeSelectionTouch = nil
        }
    }
    
    //affineSelectionBlob
    
    func cancelAllGestures() {
        isPanning = false
        isPinching = false
        isRotating = false
        affineSelectionBlob = nil
        bulgeSelectionBlob = nil
        affineSelectionTouch = nil
        affineSelectionDidChange = false
        bulgeSelectionDidChange = false
        
        cancelSecondaryViewGrabGesture()
    }
    
    func updateSecondaryViewGrabGesture() {
        if let blob = grabSelectionBlob {
            if grabSelectionPanning {
                let guideX = grabSelectionStartAnimationTargetOffset.x + (panPos.x - grabSelectionPanStart.x)
                let guideY = grabSelectionStartAnimationTargetOffset.y + (panPos.y - grabSelectionPanStart.y)
                blob.dragAnimationTargetOffsetDampened(withNewOffset: CGPoint(x: guideX, y: guideY))
            }
            if grabSelectionPinching {
                
                blob.orbitMotionController.inflateScale = grabSelectionStartInflateScale * pinchScale
                if blob.orbitMotionController.inflateScale < ApplicationController.shared.inflateScaleMin {
                    blob.orbitMotionController.inflateScale = ApplicationController.shared.inflateScaleMin
                }
                if blob.orbitMotionController.inflateScale > ApplicationController.shared.inflateScaleMax {
                    blob.orbitMotionController.inflateScale = ApplicationController.shared.inflateScaleMax
                }
            }
            if grabSelectionRotating {
                blob.orbitMotionController.twistRotation = grabSelectionStartTwistRotation + rotation
                if blob.orbitMotionController.twistRotation > Math.PI_2 { blob.orbitMotionController.twistRotation = Math.PI_2 }
                if blob.orbitMotionController.twistRotation < -(Math.PI_2) { blob.orbitMotionController.twistRotation = -(Math.PI_2) }
            }
        }
    }
    
    func attemptSecondaryViewGrabGesture(withPoint point: CGPoint) {
        
        if let touchBlob = selectBlobAtPoint(point) {
            
            var multipleBlobsSelected = false
            for blob in blobs {
                if blob !== touchBlob {
                    if blob.grabSelectionTouch !== nil {
                        //We have 2 blobs selected.. No dice!
                        multipleBlobsSelected = true
                    }
                }
            }
            
            if multipleBlobsSelected == false {
                grabSelectionBlob = touchBlob
                grabSelectionStartInflateScale = touchBlob.orbitMotionController.inflateScale
                grabSelectionStartTwistRotation = touchBlob.orbitMotionController.twistRotation
                
                grabSelectionStartAnimationTargetOffset = unwindAnimationTargetOffsetDamped(blob: touchBlob)
                
                touchBlob.grabSelectionGesture = true
                touchBlob.grabSelectionTouch = nil
                
                if isPanning {
                    grabSelectionPanning = true
                    grabSelectionPanStart = CGPoint(x: panPos.x, y: panPos.y)
                } else {
                    grabSelectionPanning = false
                }
            }
        }
    }
    
    func cancelSecondaryViewGrabGesture() -> Void {
        for blob in blobs {
            blob.grabSelectionGesture = false
        }
        if grabSelectionBlob != nil {
            grabSelectionBlob = nil
            grabSelectionRotating = false
            grabSelectionPinching = false
            grabSelectionPanning = false
        }
    }
    
    class func postNotification(_ notificationName: BounceNotification) {
        let notification = Notification(name: Notification.Name(notificationName.rawValue), object: nil, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    class func postNotification(_ notificationName: BounceNotification, object: AnyObject?) {
        let notification = Notification(name: Notification.Name(notificationName.rawValue), object: object, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    func handleZoomEnabledChanged() {
        for blob in blobs { blob.handleZoomEnabledChanged() }
    }
    
    func handleSceneModeChanged() {
        for blob in blobs { blob.handleSceneModeChanged() }
    }
    
    func handleEditModeChanged() {
        for blob in blobs { blob.handleEditModeChanged() }
    }
    
    func handleAnimationEnabledChanged() {
        _globalCrazyMotionControllerAnimationProgress = 0.0
        for blob in blobs { blob.handleAnimationEnabledChanged() }
    }
    
    func handleAnimationModeChanged() {
        _globalCrazyMotionControllerAnimationProgress = 0.0
        for blob in blobs { blob.handleAnimationModeChanged() }
    }
    
    func handleAnimationAlternationEnabledChanged() {
        _globalCrazyMotionControllerAnimationProgress = 0.0
        refreshBlobAlternation()
        for blob in blobs { blob.handleAnimationAlternationEnabledChanged() }
    }
    
    func handleAnimationBounceEnabledChanged() {
        _globalCrazyMotionControllerAnimationProgress = 0.0
        for blob in blobs { blob.handleAnimationBounceEnabledChanged() }
    }
    
    func handleAnimationReverseEnabledChanged() {
        _globalCrazyMotionControllerAnimationProgress = 0.0
        for blob in blobs { blob.handleAnimationReverseEnabledChanged() }
    }
    
    func handleAnimationTwistEnabledChanged() {
        _globalCrazyMotionControllerAnimationProgress = 0.0
        for blob in blobs { blob.handleAnimationTwistEnabledChanged() }
    }
    
    func handleAnimationEllipseEnabledChanged() {
        _globalCrazyMotionControllerAnimationProgress = 0.0
        for blob in blobs { blob.handleAnimationEllipseEnabledChanged() }
    }
    
    func handleAnimationInflateEnabledChanged() {
        _globalCrazyMotionControllerAnimationProgress = 0.0
        for blob in blobs { blob.handleAnimationInflateEnabledChanged() }
    }
    
    func handleAnimationHorizontalEnabledChanged() {
        _globalCrazyMotionControllerAnimationProgress = 0.0
        for blob in blobs { blob.handleAnimationHorizontalEnabledChanged() }
    }
    
    func handleHistoryChanged() {
        refreshBlobAlternation()
    }
    
    func handleStackOrderChanged() {
        //for blob in blobs { blob.handleStackOrderChanged() }
        refreshBlobAlternation()
    }
    
    func getSeparationDistance() -> CGFloat {
        guard let screenFrame = BounceViewController.shared?.screenFrame else { return 32.0 }
        return getSeparationDistance(screenFrame: screenFrame)
    }
    
    func getSeparationDistance(screenFrame: CGRect) -> CGFloat {
        var maxDimension: CGFloat = screenFrame.size.width
        if screenFrame.size.height > maxDimension { maxDimension = screenFrame.size.height }
        let separationDistance: CGFloat = (maxDimension / 2.0 + screenFrame.size.width / 4.0 + screenFrame.size.height / 4.0) / 16.0
        return separationDistance
    }
    
    func pickNewBlobPositionOnScreen(point: CGPoint, withScreenFrame screenFrame: CGRect) -> CGPoint {
        
        var result = CGPoint(x: point.x, y: point.y)
        
        let separationDistance = getSeparationDistance(screenFrame: screenFrame)
        
        if anyBlobOnPoint(point, separationDistance: separationDistance) == false {
            return result
        }
        
        let safeInsetH: CGFloat = screenFrame.size.width / 8.0
        let safeInsetV: CGFloat = screenFrame.size.height / 8.0
        
        let safeRect = CGRect(x: screenFrame.origin.x + safeInsetH, y: screenFrame.origin.y + safeInsetV, width: screenFrame.size.width - safeInsetH * 2.0, height: screenFrame.size.height - safeInsetV * 2.0)
        
        var candidatePoints = [CGPoint]()
        
        let screenFrameCenterX = screenFrame.midX
        let screenFrameCenterY = screenFrame.midY
        
        //1.) make a list of all candidate points.
        //2.) prune points which are outside of scene rectangle.        
        for ringIndex: Int in  1..<18 {
            
            //On ring 1, we are doing a 3x3 grid (8 nodes)
            var gridX: Int = -ringIndex
            var gridY: Int = -ringIndex
            
            var posX: CGFloat = point.x + CGFloat(gridX) * separationDistance
            var posY: CGFloat = point.y + CGFloat(gridY) * separationDistance
            while true {
                posX = point.x + CGFloat(gridX) * separationDistance
                let candidatePoint = CGPoint(x: posX, y: posY)
                if candidatePoint.x >= safeRect.origin.x &&
                    candidatePoint.x <= (safeRect.origin.x + safeRect.size.width) &&
                    candidatePoint.y >= safeRect.origin.y &&
                    candidatePoint.y <= (safeRect.origin.y + safeRect.size.height) {
                    candidatePoints.append(candidatePoint)
                }
                if gridX == ringIndex { break }
                gridX += 1
            }
            
            gridY += 1
            while true {
                posY = point.y + CGFloat(gridY) * separationDistance
                let candidatePoint = CGPoint(x: posX, y: posY)
                if candidatePoint.x >= safeRect.origin.x &&
                    candidatePoint.x <= (safeRect.origin.x + safeRect.size.width) &&
                    candidatePoint.y >= safeRect.origin.y &&
                    candidatePoint.y <= (safeRect.origin.y + safeRect.size.height) {
                    candidatePoints.append(candidatePoint)
                }
                if gridY == ringIndex { break }
                gridY += 1
            }
            
            gridX -= 1
            while true {
                posX = point.x + CGFloat(gridX) * separationDistance
                let candidatePoint = CGPoint(x: posX, y: posY)
                if candidatePoint.x >= safeRect.origin.x &&
                    candidatePoint.x <= (safeRect.origin.x + safeRect.size.width) &&
                    candidatePoint.y >= safeRect.origin.y &&
                    candidatePoint.y <= (safeRect.origin.y + safeRect.size.height) {
                    candidatePoints.append(candidatePoint)
                }
                if gridX == -ringIndex { break }
                gridX -= 1
            }
            
            gridY -= 1
            while true {
                posY = point.y + CGFloat(gridY) * separationDistance
                let candidatePoint = CGPoint(x: posX, y: posY)
                if candidatePoint.x >= safeRect.origin.x &&
                    candidatePoint.x <= (safeRect.origin.x + safeRect.size.width) &&
                    candidatePoint.y >= safeRect.origin.y &&
                    candidatePoint.y <= (safeRect.origin.y + safeRect.size.height) {
                    candidatePoints.append(candidatePoint)
                }
                if gridY == -(ringIndex-1) { break }
                gridY -= 1
            }
        }
        
        //3.) find a clever way to combine
        //    distance from point (higher priority)
        //    with  
        //    distance from scene rectangle center (lower priority)
        
        var distanceToPoint = [CGFloat](repeating: 0.0, count: candidatePoints.count)
        var maxDistanceToPoint: CGFloat = 1.0
        
        var distanceToScreenFrameCenter = [CGFloat](repeating: 0.0, count: candidatePoints.count)
        var maxDistanceToScreenFrameCenter: CGFloat = 1.0
        
        var sortFactor = [CGFloat](repeating: 0.0, count: candidatePoints.count)
        
        for i: Int in 0..<candidatePoints.count {
            let candidatePoint = candidatePoints[i]
            //var percent = CGFloat(i) / CGFloat(candidatePoints.count)
            
            var diffX: CGFloat = candidatePoint.x - point.x
            var diffY: CGFloat = candidatePoint.y - point.y
            var dist = diffX * diffX + diffY * diffY
            if dist > Math.epsilon { dist = CGFloat(sqrt(Double(dist))) }
            if dist > maxDistanceToPoint { maxDistanceToPoint = dist } 
            distanceToPoint[i] = dist
            diffX = candidatePoint.x - screenFrameCenterX
            diffY = candidatePoint.y - screenFrameCenterY
            dist = diffX * diffX + diffY * diffY
            if dist > Math.epsilon { dist = CGFloat(sqrt(Double(dist))) }
            if dist > maxDistanceToScreenFrameCenter { maxDistanceToScreenFrameCenter = dist } 
            distanceToScreenFrameCenter[i] = dist
        }
        
        for i: Int in 0..<candidatePoints.count {
            sortFactor[i] = (distanceToPoint[i] * 3.0) + (distanceToScreenFrameCenter[i] * 2.0)
        }
        
        //3.5) give extra priority to items which are directly horizontal or vertical
        //     to the original point..
        for i: Int in 0..<candidatePoints.count {
            let candidatePoint = candidatePoints[i]
            
            var dX: CGFloat = candidatePoint.x - point.x
            if dX < 0.0 { dX = -dX }
            
            var dY: CGFloat = candidatePoint.y - point.y
            if dY < 0.0 { dY = -dY }
            
            if dX < Math.epsilon || dY < Math.epsilon {
                sortFactor[i] = sortFactor[i] * 0.25
            }
        }
        
        //4.) sort list by this combined metric.
        var j: Int = 0
        var hold: CGFloat = 0.0
        var holdX: CGFloat = 0.0
        var holdY: CGFloat = 0.0
        for i: Int in 0..<sortFactor.count {
            j = i
            while j > 0 && sortFactor[j] < sortFactor[j-1] {
                hold = sortFactor[j]
                holdX = candidatePoints[j].x
                holdY = candidatePoints[j].y
                sortFactor[j] = sortFactor[j-1]
                candidatePoints[j].x = candidatePoints[j-1].x
                candidatePoints[j].y = candidatePoints[j-1].y                                
                sortFactor[j-1] = hold
                candidatePoints[j-1].x = holdX
                candidatePoints[j-1].y = holdY
                j -= 1
            }
        }
        
        //5.) iterate through list and pick first point which is not
        //    blocked by other blobs.
        var foundPoint: Bool = false
        var i: Int = 0
        while i < candidatePoints.count && foundPoint == false {
            let candidatePoint = candidatePoints[i]
            if anyBlobOnPoint(candidatePoint, separationDistance: separationDistance) == false {
                result = CGPoint(x: candidatePoint.x, y: candidatePoint.y)
                foundPoint = true
            }
            i += 1
        }
        
        //6.) if no position is available, default to "point" or list[0] (whichever is further from another blob)
        return result
    }
    
    func addBlob() {
        
        guard let screenFrame = BounceViewController.shared?.screenFrame else { return }
        
        var expectedWidth = Device.portraitWidth
        if scene.isLandscape {
            expectedWidth = Device.landscapeWidth
        }
        
        var blobScale = screenFrame.width / expectedWidth
        if blobScale > 1.0 { blobScale = 1.0 }
        
        if blobs.count >= ApplicationController.shared.maxBlobCount {
            return
        }
        
        let blob = Blob()
        
        let sceneCenterX = screenFrame.midX
        let sceneCenterY = screenFrame.midY
        
        let bestPos = pickNewBlobPositionOnScreen(point: CGPoint(x:sceneCenterX, y:sceneCenterY), withScreenFrame: screenFrame)
        blob.center.x = bestPos.x
        blob.center.y = bestPos.y
        blob.scale = blobScale
        
        //while anyBlobOnPoint(blob.center) {
        //blob.center.x += 30.0
        //}
        
        addBlob(blob)
    }
    
    func addBlob(_ blob: Blob) {
        blobs.append(blob)
        
        refreshBlobAlternation()
        
        let historyState = HistoryStateAddBlob()
        historyState.recordStart(withBlob: selectedBlob)
        selectedBlob = blob
        if let checkBlob = selectedBlob {
            historyState.blobIndex = indexOf(blob: checkBlob)
            historyState.blobData = checkBlob.save()
            historyState.recordEnd(withBlob: selectedBlob)
        }
        
        blob.resetAll()
        
        historyAdd(withState: historyState)
        refreshBlobAlternation()
        BounceEngine.postNotification(.blobAdded)
    }
    
    func cloneSelectedBlob() {
        guard let screenFrame = BounceViewController.shared?.screenFrame else { return }
        
        if blobs.count >= ApplicationController.shared.maxBlobCount {
            return
        }
        
        if selectedBlob != nil {
            let blob = Blob()
            
            var blobInfo = selectedBlob!.save()
            blob.load(info: &blobInfo)
            blob.center = pickNewBlobPositionOnScreen(point: blob.center, withScreenFrame: screenFrame)
            addBlob(blob)
        }
    }
    
    func deleteSelectedBlob() {
        if let blob = selectedBlob {
            let historyState = HistoryStateDeleteBlob()
            historyState.recordStart(withBlob: blob)
            historyState.blobIndex = indexOf(blob: blob)
            historyState.blobData = blob.save()
            historyState.recordEnd(withBlob: blob)
            historyAdd(withState: historyState)
            deleteBlob(blob)
        }
    }
    
    func flipHSelectedBlob() {
        if let blob = selectedBlob {
            let historyState = HistoryStateChangeShape()
            historyState.recordStart(withBlob: blob)
            historyState.blobIndex = indexOf(blob: blob)
            blob.flipH()
            historyState.recordEnd(withBlob: blob)
            historyAdd(withState: historyState)
        }
    }
    
    func flipVSelectedBlob() {
        if let blob = selectedBlob {
            let historyState = HistoryStateChangeShape()
            historyState.recordStart(withBlob: blob)
            historyState.blobIndex = indexOf(blob: blob)
            blob.flipV()
            historyState.recordEnd(withBlob: blob)
            historyAdd(withState: historyState)
        }
    }
    
    func addPointSelectedBlob() {
        if let blob = selectedBlob {
            if blob.spline.controlPointCount < ApplicationController.shared.maxPointCount {
                let historyState = HistoryStateChangeShape()
                historyState.recordStart(withBlob: blob)
                historyState.blobIndex = indexOf(blob: blob)
                blob.addPoint()
                historyState.recordEnd(withBlob: blob)
                historyAdd(withState: historyState)
                BounceEngine.postNotification(.pointCountChanged)
            }
        }
    }
    
    func deletePointSelectedBlob() {
        if let blob = selectedBlob {
            if blob.spline.controlPointCount > ApplicationController.shared.minPointCount {
                let historyState = HistoryStateChangeShape()
                historyState.recordStart(withBlob: blob)
                historyState.blobIndex = indexOf(blob: blob)
                blob.deletePoint()
                historyState.recordEnd(withBlob: blob)
                historyAdd(withState: historyState)
                BounceEngine.postNotification(.pointCountChanged)
            }
        }
    }
    
    func selectNextPointSelectedBlob() {
        if let blob = selectedBlob {
            blob.selectNextPoint()
        }
    }
    
    func selectPreviousPointSelectedBlob() {
        if let blob = selectedBlob {
            blob.selectPreviousPoint()
        }
    }
    
    func selectNextBlob() {
        if let baseIndex: Int = indexOf(blob: selectedBlob) {
            for i in 1..<blobs.count {
                var index: Int = baseIndex + i
                if index >= blobs.count { index -= blobs.count }
                let blob = blobs[index]
                if blob.isSelectable {
                    selectedBlob = blob
                    return
                }
            }
        }
        
        for i in 0..<blobs.count {
            let blob = blobs[i]
            if blob.isSelectable {
                selectedBlob = blob
                return
            }
        }
        
        //May also have frozen this blob. If we did, then we unfreeze it, bra.
        if selectedBlob !== nil {
            if selectedBlob!.isSelectable == false {
                selectedBlob = nil
            }
        }
        
    }
    
    func selectPreviousBlob() {
        if let baseIndex: Int = indexOf(blob: selectedBlob) {
            for i in 1..<blobs.count {
                var index: Int = baseIndex - i
                if index < 0 { index += blobs.count }
                let blob = blobs[index]
                if blob.isSelectable {
                    selectedBlob = blob
                    return
                }
            }
        } else {
            for i in 0..<blobs.count {
                let blob = blobs[(blobs.count - (i + 1))]
                if blob.isSelectable {
                    selectedBlob = blob
                    return
                }
            }
        }
    }
    
    func canSendBackward() -> Bool {
        guard let index = indexOf(blob: selectedBlob) else { return false }
        return index > 0
    }
    
    func sendBackward() {
        if let blob = selectedBlob, canSendBackward() {
            guard let index = indexOf(blob: blob) else { return }
            
            let hold = blobs[index]
            blobs[index] = blobs[index - 1]
            blobs[index - 1] = hold
            
            BounceEngine.postNotification(BounceNotification.blobStackOrderChanged, object: selectedBlob)
        }
    }
    
    func canSendBack() -> Bool {
        return canSendBackward()
    }
    
    func sendBack() {
        if let blob = selectedBlob, canSendBack() {
            var newBlobs = [Blob]()
            newBlobs.append(blob)
            for b in blobs {
                if b !== blob {
                    newBlobs.append(b)
                }
            }
            blobs.removeAll()
            blobs.append(contentsOf: newBlobs)
            BounceEngine.postNotification(BounceNotification.blobStackOrderChanged, object: selectedBlob)
        }
    }
    
    
    
    
    
    func canSendForward() -> Bool {
        guard let index = indexOf(blob: selectedBlob) else { return false }
        return index < (blobs.count - 1)
    }
    
    func sendForward() {
        if let blob = selectedBlob, canSendForward() {
            guard let index = indexOf(blob: blob) else { return }
            
            let hold = blobs[index]
            blobs[index] = blobs[index + 1]
            blobs[index + 1] = hold
            
            BounceEngine.postNotification(BounceNotification.blobStackOrderChanged, object: selectedBlob)
        }
    }
    
    func canSendFront() -> Bool {
        return canSendForward()
    }
    
    func sendFront() {
        if let blob = selectedBlob, canSendFront() {
            var newBlobs = [Blob]()
            for b in blobs {
                if b !== blob {
                    newBlobs.append(b)
                }
            }
            newBlobs.append(blob)
            blobs.removeAll()
            blobs.append(contentsOf: newBlobs)
            BounceEngine.postNotification(BounceNotification.blobStackOrderChanged, object: selectedBlob)
        }
    }
    
    func freezeSeleced() {
        if let blob = selectedBlob {
            let historyState = HistoryStateFreeze()
            historyState.recordStart(withBlob: selectedBlob)
            historyState.blobIndex = indexOf(blob: blob)
            blob.frozen = true
            selectNextBlob()
            historyState.recordEnd(withBlob: selectedBlob)
            historyAdd(withState: historyState)
            BounceEngine.postNotification(BounceNotification.frozenStateChanged)
        }
    }
    
    func unfreezeAll() {
        let historyState = HistoryStateUnfreezeAll()
        historyState.recordStart(withBlob: selectedBlob)
        var index: Int = 0
        for blob in blobs {
            if blob.frozen == true {
                historyState.frozenIndeces.append(index)
            }
            blob.frozen = false
            index += 1
        }
        historyState.recordEnd(withBlob: selectedBlob)
        historyAdd(withState: historyState)
        
        BounceEngine.postNotification(BounceNotification.frozenStateChanged)
    }
    
    func canPublish() -> Bool {
        
        if scene.isWebScene == true {
            let alert = UIAlertController(title: "Can't Publish", message: "We are currently not allowing re-publishing of content. Please create an original scene to publish!", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "Okay", style: .default) { (action: UIAlertAction) in }
            alert.addAction(actionOK)
            AppDelegate.root.present(alert, animated: true, completion: nil)
            return false
        }
        
        if blobs.count <= 0 {
            let alert = UIAlertController(title: "Can't Publish", message: "Your scene must have at least one blob to be published. Please make sure your scene is ready and try again!", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "Okay", style: .default) { (action: UIAlertAction) in }
            alert.addAction(actionOK)
            AppDelegate.root.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    var isAlternateAvailable: Bool {
        var result: Bool = false
        if blobs.count > 1 {
            result = true
        }
        return result
    }
    
    var isAnyBlobFrozen: Bool {
        var result: Bool = false
        for blob in blobs {
            if blob.frozen == true {
                result = true
            }
        }
        return result
    }
    
    func indexOf(blob: Blob?) -> Int? {
        if blob != nil {
            for i in 0..<blobs.count {
                if blobs[i] === blob {
                    return i
                }
            }
        }
        return nil
    }
    
    func blobAt(index: Int?) -> Blob? {
        if let blobIndex = index {
            if blobIndex >= 0 && blobIndex < blobs.count {
                return blobs[blobIndex]
            }
        }
        return nil
    }
    
    func anyBlobOnPoint(_ pos:CGPoint) -> Bool {
        let separationDistance = getSeparationDistance()
        return anyBlobOnPoint(pos, separationDistance: separationDistance)
    }
    
    func anyBlobOnPoint(_ pos:CGPoint, separationDistance: CGFloat) -> Bool {
        if blobs.count <= 0 {
            return false
        } else {
            if closestBlobCenterDistanceSquared(pos) <= separationDistance * separationDistance {
                return true
            }
        }
        return false
    }
    
    func closestBlobCenterDistanceSquared(_ pos:CGPoint) -> CGFloat {
        
        var hit:Bool = false
        var bestDist: CGFloat = 0.0
        
        for i in 0..<blobs.count {
            let blob = blobs[i]
            
            
            let dist = Math.distSquared(p1: blob.center, p2: pos)
            
            if hit == false {
                hit = true
                bestDist = dist
            } else {
                if dist < bestDist {
                    bestDist = dist
                }
            }
        }
        return bestDist
    }
    
    func deselectBlob() {
        if selectedBlob !== nil {
            selectedBlob = nil
        }
        
    }
    
    func selectBlobAtPoint(_ pos:CGPoint) -> Blob? {
        var result:Blob?
        
        for i in stride(from: blobs.count - 1, to: -1, by: -1) {
            let blob = blobs[i]
            if blob.isSelectable, blob.border.pointInside(point: pos) {
                result = blob
                break
            }
        }
        
        //If we weren't exactly inside of the blob, let's try to pick one that's near.
        if(result === nil) {
            var bestDist:CGFloat = (45.0 * 45.0)
            for i in 0..<blobs.count {
                let blob = blobs[i]
                if blob.isSelectable {
                    if let c = blob.border.closestPointSquared(point: pos) {
                        if c.distanceSquared < bestDist {
                            bestDist = c.distanceSquared
                            result = blob
                        }
                    }
                }
            }
        }
        return result
    }
    
    func gestureUpdateAffine() {
        if let blob = affineSelectionBlob , sceneMode == .edit && editMode == .affine {
            if isPanning {
                let x = affineSelectionStartCenter.x + (panPos.x - panStartPos.x)
                let y = affineSelectionStartCenter.y + (panPos.y - panStartPos.y)
                blob.center = CGPoint(x: x, y: y)
            }
            if isPinching {
                blob.scale = affineSelectionStartScale * pinchScale
            }
            if isRotating {
                var newRotation = affineSelectionStartRotation + rotation
                while newRotation > Math.PI2 { newRotation -= Math.PI2 }
                while newRotation < 0.0 { newRotation += Math.PI2 }
                blob.rotation = newRotation
            }
            
            //Correction to the center of blob. "Pivot" effect..
            let startCenter = blob.transformPoint(point: affineGestureStartCenter)
            blob.center = CGPoint(x: blob.center.x + (affineGestureCenter.x - startCenter.x),
                                  y: blob.center.y + (affineGestureCenter.y - startCenter.y))
        }
    }
    
    func gestureUpdateBulge() {
        if let blob = bulgeSelectionBlob , sceneMode == .edit && editMode == .distribution {
            if isPanning {
                let x = bulgeSelectionStartCenter.x + (panPos.x - panStartPos.x)
                let y = bulgeSelectionStartCenter.y + (panPos.y - panStartPos.y)
                blob.bulgeWeightCenter = CGPoint(x: x, y: y)
            }
            
            /*if isPinching {
             
             var newScale = bulgeSelectionStartScale * pinchScale
             if newScale < ApplicationController.shared.bulgeScaleMin {
             newScale = ApplicationController.shared.bulgeScaleMin
             }
             if newScale > ApplicationController.shared.bulgeScaleMax {
             newScale = ApplicationController.shared.bulgeScaleMax
             }
             
             blob.bulgeWeightScale = newScale
             
             }
             if isRotating {
             var newRotation = bulgeSelectionStartRotation + rotation
             while newRotation > Math.PI { newRotation -= Math.PI2 }
             while newRotation < -Math.PI { newRotation += Math.PI2 }
             blob.bulgeWeightRotation = newRotation
             }
             */
            
        }
    }
    
    class func transformPoint(point:CGPoint, scale: CGFloat, rotation:CGFloat) -> CGPoint {
        var x = point.x
        var y = point.y
        if scale != 1.0 {
            x *= scale
            y *= scale
        }
        if rotation != 0 {
            var dist = x * x + y * y
            if dist > Math.epsilon {
                dist = CGFloat(sqrtf(Float(dist)))
                x /= dist
                y /= dist
            }
            let pivotRotation = rotation - CGFloat(atan2f(Float(-x), Float(-y)))
            x = CGFloat(sinf(Float(pivotRotation))) * dist
            y = CGFloat(-cosf(Float(pivotRotation))) * dist
        }
        return CGPoint(x: x, y: y)
    }
    
    class func transformPoint(point:CGPoint, translation:CGPoint, scale: CGFloat, rotation:CGFloat) -> CGPoint {
        var result = transformPoint(point: point, scale: scale, rotation: rotation)
        result = CGPoint(x: result.x + translation.x, y: result.y + translation.y)
        return result
    }
    
    class func untransformPoint(point:CGPoint, scale: CGFloat, rotation:CGFloat) -> CGPoint {
        return transformPoint(point: point, scale: 1.0 / scale, rotation: -rotation)
    }
    
    class func untransformPoint(point:CGPoint, translation:CGPoint, scale: CGFloat, rotation:CGFloat) -> CGPoint {
        var result = CGPoint(x: point.x - translation.x, y: point.y - translation.y)
        result = untransformPoint(point: result, scale: scale, rotation: rotation)
        return result
    }
    
    /*
     func toggleAnimationBounceRecordHistory() {
     let historyState = HistoryStateAnimationBounceEnabled()
     historyState.recordStart(withBlob: selectedBlob)
     historyState.blobIndex = indexOf(blob: selectedBlob)
     historyState.startEnabled = !isAnimationBounceEnabled
     historyState.recordEnd(withBlob: selectedBlob)
     historyState.endEnabled = isAnimationBounceEnabled
     historyAdd(withState: historyState)
     }
     */
    
    func toggleAnimationBulgeBouncerBounceEnabledRecordHistory() {
        let historyState = HistoryStateAnimationBulgeBouncerBounceEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationBulgeBouncerBounceEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationBulgeBouncerBounceEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationBulgeBouncerReverseEnabledRecordHistory() {
        let historyState = HistoryStateAnimationBulgeBouncerReverseEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationBulgeBouncerReverseEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationBulgeBouncerReverseEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationBulgeBouncerEllipseEnabledRecordHistory() {
        let historyState = HistoryStateAnimationBulgeBouncerEllipseEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationBulgeBouncerEllipseEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationBulgeBouncerEllipseEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationBulgeBouncerAlternateEnabledRecordHistory() {
        let historyState = HistoryStateAnimationBulgeBouncerAlternateEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationBulgeBouncerAlternateEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationBulgeBouncerAlternateEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationBulgeBouncerTwistEnabledRecordHistory() {
        let historyState = HistoryStateAnimationBulgeBouncerTwistEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationBulgeBouncerTwistEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationBulgeBouncerTwistEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationBulgeBouncerInflateEnabledRecordHistory() {
        let historyState = HistoryStateAnimationBulgeBouncerInflateEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationBulgeBouncerInflateEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationBulgeBouncerInflateEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationBulgeBouncerHorizontalEnabledRecordHistory() {
        let historyState = HistoryStateAnimationBulgeBouncerHorizontalEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationBulgeBouncerHorizontalEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationBulgeBouncerHorizontalEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationTwisterReverseEnabledRecordHistory() {
        let historyState = HistoryStateAnimationTwisterReverseEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationTwisterReverseEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationTwisterReverseEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationTwisterEllipseEnabledRecordHistory() {
        let historyState = HistoryStateAnimationTwisterEllipseEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationTwisterEllipseEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationTwisterEllipseEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationTwisterAlternateEnabledRecordHistory() {
        let historyState = HistoryStateAnimationTwisterAlternateEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationTwisterAlternateEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationTwisterAlternateEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationTwisterInflateEnabledRecordHistory() {
        let historyState = HistoryStateAnimationTwisterInflateEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationTwisterInflateEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationTwisterInflateEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationRandomReverseEnabledRecordHistory() {
        let historyState = HistoryStateAnimationRandomReverseEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationRandomReverseEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationRandomReverseEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationRandomEllipseEnabledRecordHistory() {
        let historyState = HistoryStateAnimationRandomEllipseEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationRandomEllipseEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationRandomEllipseEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationRandomAlternateEnabledRecordHistory() {
        let historyState = HistoryStateAnimationRandomAlternateEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationRandomAlternateEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationRandomAlternateEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationRandomTwistEnabledRecordHistory() {
        let historyState = HistoryStateAnimationRandomTwistEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationRandomTwistEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationRandomTwistEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationRandomInflateEnabledRecordHistory() {
        let historyState = HistoryStateAnimationRandomInflateEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationRandomInflateEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationRandomInflateEnabled
        historyAdd(withState: historyState)
    }
    
    func toggleAnimationRandomHorizontalEnabledRecordHistory() {
        let historyState = HistoryStateAnimationRandomHorizontalEnabled()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startEnabled = !animationRandomHorizontalEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endEnabled = animationRandomHorizontalEnabled
        historyAdd(withState: historyState)
    }
    
    
    
    //    func toggleAnimationRandomHorizontalEnabledRecordHistory() {
    //        let historyState = HistoryStateAnimationRandomHorizontalEnabled()
    //        historyState.recordStart(withBlob: selectedBlob)
    //        historyState.blobIndex = indexOf(blob: selectedBlob)
    //        historyState.startEnabled = !animationRandomHorizontalEnabled
    //        historyState.recordEnd(withBlob: selectedBlob)
    //        historyState.endEnabled = animationRandomHorizontalEnabled
    //        historyAdd(withState: historyState)
    //    }
    
    /*
     var tweakStartAnimationBulgeBouncerPower: CGFloat = 1.0
     var tweakStartAnimationBulgeBouncerSpeed: CGFloat = 1.0
     var tweakStartAnimationBulgeBouncerBounce: CGFloat = 1.0
     var tweakStartAnimationBulgeBouncerBounceStart: CGFloat = 1.0
     var tweakStartAnimationBulgeBouncerInflationFactor: CGFloat = 1.0
     var tweakStartAnimationBulgeBouncerEllipseFactor: CGFloat = 1.0
     
     var tweakStartAnimationBounceEnabled: Bool = false
     var tweakStartAnimationReverseEnabled: Bool = false
     var tweakStartAnimationEllipseEnabled:Bool = false
     var tweakStartAnimationAlternateEnabled:Bool = false
     var tweakStartAnimationTwistEnabled:Bool = false
     var tweakStartAnimationInflateEnabled:Bool = false
     var tweakStartAnimationHorizontalEnabled:Bool = false
     */
    
    
    
    var _bulgeWeightCenterSliderBlob: Blob?
    var bulgeWeightCenterSliderBlob: Blob? {
        set {
            if _bulgeWeightCenterSliderBlob !== nil && _bulgeWeightCenterSliderBlob !== newValue {
                bulgeWeightCenterSliderRecordHistory()
            }
            _bulgeWeightCenterSliderBlob = newValue
        }
        get {
            return _bulgeWeightCenterSliderBlob
        }
    }
    
    func bulgeWeightCenterSliderStart() {
        sliderStart()
        if let blob = selectedBlob {
            _bulgeWeightCenterSliderBlob = blob
            tweakStartBulgeCenterFactor = blob.bulgeCenterFactor
        }
    }
    
    func bulgeWeightCenterSliderEnd() {
        sliderEnd()
        bulgeWeightCenterSliderRecordHistory()
        _bulgeWeightCenterSliderBlob = nil
    }
    
    func bulgeWeightCenterSliderRecordHistory() {
        if let blob = _bulgeWeightCenterSliderBlob {
            let historyState = HistoryStateChangeBulgeCenterFactor()
            historyState.recordStart(withBlob: _bulgeWeightCenterSliderBlob)
            historyState.blobIndex = indexOf(blob: blob)
            historyState.startCenterFactor = tweakStartBulgeCenterFactor
            historyState.recordEnd(withBlob: _bulgeWeightCenterSliderBlob)
            historyState.endCenterFactor = blob.bulgeCenterFactor
            historyAdd(withState: historyState)
        }
    }
    
    var _bulgeWeightEdgeSliderBlob: Blob?
    var bulgeWeightEdgeSliderBlob: Blob? {
        set {
            if _bulgeWeightEdgeSliderBlob !== nil && _bulgeWeightEdgeSliderBlob !== newValue {
                bulgeWeightEdgeSliderRecordHistory()
            }
            _bulgeWeightEdgeSliderBlob = newValue
        }
        get {
            return _bulgeWeightEdgeSliderBlob
        }
    }
    
    
    func bulgeWeightEdgeSliderStart() {
        sliderStart()
        if let blob = selectedBlob {
            _bulgeWeightEdgeSliderBlob = blob
            tweakStartBulgeEdgeFactor = blob.bulgeEdgeFactor
        }
    }
    
    func bulgeWeightEdgeSliderEnd() {
        sliderEnd()
        bulgeWeightEdgeSliderRecordHistory()
        _bulgeWeightEdgeSliderBlob = nil
    }
    
    func bulgeWeightEdgeSliderRecordHistory() {
        if let blob = _bulgeWeightEdgeSliderBlob {
            let historyState = HistoryStateChangeBulgeEdgeFactor()
            historyState.recordStart(withBlob: _bulgeWeightEdgeSliderBlob)
            historyState.blobIndex = indexOf(blob: blob)
            historyState.startEdgeFactor = tweakStartBulgeEdgeFactor
            historyState.recordEnd(withBlob: _bulgeWeightEdgeSliderBlob)
            historyState.endEdgeFactor = blob.bulgeEdgeFactor
            historyAdd(withState: historyState)
        }
    }
    
    
    
    
    func animationSpeedSliderStart() {
        sliderStart()
        tweakStartAnimationSpeed = animationSpeed
    }
    
    func animationSpeedSliderEnd() {
        let historyState = HistoryStateAnimationSpeed()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startAnimationSpeed = tweakStartAnimationSpeed
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endAnimationSpeed = animationSpeed
        historyAdd(withState: historyState)        
    }
    
    func animationPowerSliderStart() {
        sliderStart()
        tweakStartAnimationPower = animationPower
    }
    
    func animationPowerSliderEnd() {
        let historyState = HistoryStateAnimationPower()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startAnimationPower = tweakStartAnimationPower
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endAnimationPower = animationPower
        historyAdd(withState: historyState)
    }
    
    func animationBulgeBouncerPowerSliderStart() {
        sliderStart()
        tweakStartAnimationBulgeBouncerPower = animationBulgeBouncerPower
    }
    
    func animationBulgeBouncerPowerSliderEnd() {
        let historyState = HistoryStateAnimationBulgeBouncerPower()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationBulgeBouncerPower
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationBulgeBouncerPower
        historyAdd(withState: historyState)        
    }
    
    
    
    func animationBulgeBouncerSpeedSliderStart() {
        sliderStart()
        tweakStartAnimationBulgeBouncerSpeed = animationBulgeBouncerSpeed
    }
    
    func animationBulgeBouncerSpeedSliderEnd() {
        let historyState = HistoryStateAnimationBulgeBouncerSpeed()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationBulgeBouncerSpeed
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationBulgeBouncerSpeed
        historyAdd(withState: historyState)        
    }
    
    func animationBulgeBouncerInflationFactorSliderStart() {
        sliderStart()
        tweakStartAnimationBulgeBouncerInflationFactor = animationBulgeBouncerInflationFactor
    }
    
    func animationBulgeBouncerInflationFactorSliderEnd() {
        let historyState = HistoryStateAnimationBulgeBouncerInflationFactor()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationBulgeBouncerInflationFactor
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationBulgeBouncerInflationFactor
        historyAdd(withState: historyState)        
    }
    
    func animationBulgeBouncerBounceStartSliderStart() {
        sliderStart()
        tweakStartAnimationBulgeBouncerBounceStart = animationBulgeBouncerInflationStartFactor
    }
    
    func animationBulgeBouncerBounceStartSliderEnd() {
        let historyState = HistoryStateanimationBulgeBouncerInflationStartFactor()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationBulgeBouncerBounceStart
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationBulgeBouncerInflationStartFactor
        historyAdd(withState: historyState)        
    }
    
    func animationBulgeBouncerBounceSliderStart() {
        sliderStart()
        tweakStartAnimationBulgeBouncerBounce = animationBulgeBouncerBounceFactor
    }
    
    func animationBulgeBouncerBounceSliderEnd() {
        let historyState = HistoryStateAnimationBulgeBouncerBounceFactor()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationBulgeBouncerBounce
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationBulgeBouncerBounceFactor
        historyAdd(withState: historyState)        
    }
    
    
    func animationBulgeBouncerEllipseFactorSliderStart() {
        sliderStart()
        tweakStartAnimationBulgeBouncerEllipseFactor = animationBulgeBouncerEllipseFactor
    }
    
    func animationBulgeBouncerEllipseFactorSliderEnd() {
        let historyState = HistoryStateAnimationBulgeBouncerEllipseFactor()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationBulgeBouncerEllipseFactor
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationBulgeBouncerEllipseFactor
        historyAdd(withState: historyState)        
    }
    
    
    func animationTwisterTwistPowerSliderStart() {
        sliderStart()
        tweakStartAnimationTwisterTwistPower = animationTwisterTwistPower
    }
    
    func animationTwisterTwistPowerSliderEnd() {
        let historyState = HistoryStateAnimationTwisterPower()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationTwisterTwistPower
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationTwisterTwistPower
        historyAdd(withState: historyState)
    }
    
    func animationTwisterTwistSpeedSliderStart() {
        sliderStart()
        tweakStartAnimationTwisterTwistSpeed = animationTwisterTwistSpeed
    }
    
    func animationTwisterTwistSpeedSliderEnd() {
        let historyState = HistoryStateAnimationTwisterSpeed()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationTwisterTwistSpeed
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationTwisterTwistSpeed
        historyAdd(withState: historyState)        
    }
    
    func animationTwisterInflationFactor1SliderStart() {
        sliderStart()
        tweakStartAnimationTwisterInflationFactor1 = animationTwisterInflationFactor1
    }
    
    func animationTwisterInflationFactor1SliderEnd() {
        let historyState = HistoryStateAnimationTwisterInflationFactor1()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationTwisterInflationFactor1
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationTwisterInflationFactor1
        historyAdd(withState: historyState)        
    }
    
    func animationTwisterInflationFactor2SliderStart() {
        sliderStart()
        tweakStartAnimationTwisterInflationFactor2 = animationTwisterInflationFactor2
    }
    
    func animationTwisterInflationFactor2SliderEnd() {
        let historyState = HistoryStateAnimationTwisterInflationFactor2()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationTwisterInflationFactor2
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationTwisterInflationFactor2
        historyAdd(withState: historyState)        
    }
    
    
    
    
    
    ///////////////
    ///////////////
    ///////////////
    ///////////////
    
    func animationRandomPowerSliderStart() {
        sliderStart()
        tweakStartAnimationRandomPower = animationRandomPower
    }
    
    func animationRandomPowerSliderEnd() {
        let historyState = HistoryStateAnimationRandomPower()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationRandomPower
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationRandomPower
        historyAdd(withState: historyState)
    }
    
    func animationRandomSpeedSliderStart() {
        sliderStart()
        tweakStartAnimationRandomSpeed = animationRandomSpeed
    }
    
    func animationRandomSpeedSliderEnd() {
        let historyState = HistoryStateAnimationRandomSpeed()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationRandomSpeed
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationRandomSpeed
        historyAdd(withState: historyState)        
    }
    
    func animationRandomRandomnessFactorSliderStart() {
        sliderStart()
        tweakStartAnimationRandomRandomnessFactor = animationRandomRandomnessFactor
    }
    
    func animationRandomRandomnessFactorSliderEnd() {
        let historyState = HistoryStateAnimationRandomRandomnessFactor()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationRandomRandomnessFactor
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationRandomRandomnessFactor
        historyAdd(withState: historyState)        
    }
    
    func animationRandomTwistFactorSliderStart() {
        sliderStart()
        tweakStartAnimationRandomTwistFactor = animationRandomTwistFactor
    }
    
    func animationRandomTwistFactorSliderEnd() {
        let historyState = HistoryStateAnimationRandomTwistFactor()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationRandomTwistFactor
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationRandomTwistFactor
        historyAdd(withState: historyState)        
    }
    
    func animationRandomInflationFactor1SliderStart() {
        sliderStart()
        tweakStartAnimationRandomInflationFactor1 = animationRandomInflationFactor1
    }
    
    func animationRandomInflationFactor1SliderEnd() {
        let historyState = HistoryStateAnimationRandomInflationFactor1()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationRandomInflationFactor1
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationRandomInflationFactor1
        historyAdd(withState: historyState)        
    }
    
    func animationRandomInflationFactor2SliderStart() {
        sliderStart()
        tweakStartAnimationRandomInflationFactor2 = animationRandomInflationFactor2
    }
    
    func animationRandomInflationFactor2SliderEnd() {
        let historyState = HistoryStateAnimationRandomInflationFactor2()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        historyState.startValue = tweakStartAnimationRandomInflationFactor2
        historyState.recordEnd(withBlob: selectedBlob)
        historyState.endValue = animationRandomInflationFactor2
        historyAdd(withState: historyState)        
    }
    
    ///////////////
    ///////////////
    ///////////////
    ///////////////
    
    
    
    //var animationTwisterTwistPower: CGFloat = BlobMotionControllerTwister.defaultAnimationTwistPower  { didSet { for blob in blobs { blob.setNeedsComputeAffine() } } }
    //var animationTwisterTwistSpeed: CGFloat = BlobMotionControllerTwister.defaultAnimationTwistSpeed
    //var animationTwisterInflationFactor1: CGFloat = BlobMotionControllerTwister.defaultAnimationInflationFactor1
    //var animationTwisterInflationFactor2: CGFloat = BlobMotionControllerTwister.defaultAnimationInflationFactor2
    
    //var animationTwisterReverseEnabled: Bool = BlobMotionControllerTwister.defaultAnimationReverseEnabled
    //var animationTwisterEllipseEnabled: Bool = BlobMotionControllerTwister.defaultAnimationEllipseEnabled
    //var animationTwisterAlternateEnabled: Bool = BlobMotionControllerTwister.defaultAnimationAlternateEnabled
    //var animationTwisterInflateEnabled: Bool = BlobMotionControllerTwister.defaultAnimationInflateEnabled
    
    
    var isAnimationBulgeBouncerAtDefaultValues: Bool {
        if fabsf(Float(animationBulgeBouncerSpeed - BlobMotionControllerBulgeBouncer.defaultAnimationSpeed)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationBulgeBouncerInflationStartFactor - BlobMotionControllerBulgeBouncer.defaultAnimationInflationStartFactor)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationBulgeBouncerEllipseFactor - BlobMotionControllerBulgeBouncer.defaultAnimationEllipseFactor)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationBulgeBouncerInflationFactor - BlobMotionControllerBulgeBouncer.defaultAnimationInflationFactor)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationBulgeBouncerBounceFactor - BlobMotionControllerBulgeBouncer.defaultAnimationBounceFactor)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationBulgeBouncerPower - BlobMotionControllerBulgeBouncer.defaultAnimationPower)) > Float(Math.epsilon) { return false }
        
        if animationBulgeBouncerBounceEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationBounceEnabled { return false }
        if animationBulgeBouncerReverseEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationReverseEnabled { return false }
        if animationBulgeBouncerEllipseEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationEllipseEnabled { return false }
        if animationBulgeBouncerAlternateEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationAlternateEnabled { return false }
        if animationBulgeBouncerTwistEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationTwistEnabled { return false }
        if animationBulgeBouncerInflateEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationInflateEnabled { return false }
        if animationBulgeBouncerHorizontalEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationHorizontalEnabled { return false }
        
        return true
    }
    
    var isAnimationTwisterAtDefaultValues: Bool {
        if fabsf(Float(animationTwisterTwistPower - BlobMotionControllerTwister.defaultAnimationTwistPower)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationTwisterTwistSpeed - BlobMotionControllerTwister.defaultAnimationTwistSpeed)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationTwisterInflationFactor1 - BlobMotionControllerTwister.defaultAnimationInflationFactor1)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationTwisterInflationFactor2 - BlobMotionControllerTwister.defaultAnimationInflationFactor2)) > Float(Math.epsilon) { return false }
        
        if animationTwisterReverseEnabled != BlobMotionControllerTwister.defaultAnimationReverseEnabled { return false }
        if animationTwisterEllipseEnabled != BlobMotionControllerTwister.defaultAnimationEllipseEnabled { return false }
        if animationTwisterAlternateEnabled != BlobMotionControllerTwister.defaultAnimationAlternateEnabled { return false }
        if animationTwisterInflateEnabled != BlobMotionControllerTwister.defaultAnimationInflateEnabled { return false }
        
        return true
    }
    
    var isAnimationRandomAtDefaultValues: Bool {
        
        if fabsf(Float(animationRandomSpeed - BlobMotionControllerCrazy.defaultAnimationSpeed)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationRandomInflationFactor1 - BlobMotionControllerCrazy.defaultAnimationInflationFactor1)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationRandomInflationFactor2 - BlobMotionControllerCrazy.defaultAnimationInflationFactor2)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationRandomTwistFactor - BlobMotionControllerCrazy.defaultAnimationTwistFactor)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationRandomRandomnessFactor - BlobMotionControllerCrazy.defaultAnimationRandomnessFactor)) > Float(Math.epsilon) { return false }
        if fabsf(Float(animationRandomPower - BlobMotionControllerCrazy.defaultAnimationPower)) > Float(Math.epsilon) { return false }
        
        if animationRandomReverseEnabled != BlobMotionControllerCrazy.defaultAnimationReverseEnabled { return false }
        if animationRandomEllipseEnabled != BlobMotionControllerCrazy.defaultAnimationEllipseEnabled { return false }
        if animationRandomAlternateEnabled != BlobMotionControllerCrazy.defaultAnimationAlternateEnabled { return false }
        if animationRandomTwistEnabled != BlobMotionControllerCrazy.defaultAnimationTwistEnabled { return false }
        if animationRandomInflateEnabled != BlobMotionControllerCrazy.defaultAnimationInflateEnabled { return false }
        if animationRandomHorizontalEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationHorizontalEnabled { return false }
        
        return true
    }
    
    private func resetDefaultAnimationBulgeBouncerInternal() {
        animationBulgeBouncerBounceEnabled = BlobMotionControllerBulgeBouncer.defaultAnimationBounceEnabled
        animationBulgeBouncerReverseEnabled = BlobMotionControllerBulgeBouncer.defaultAnimationReverseEnabled
        animationBulgeBouncerEllipseEnabled = BlobMotionControllerBulgeBouncer.defaultAnimationEllipseEnabled
        animationBulgeBouncerAlternateEnabled = BlobMotionControllerBulgeBouncer.defaultAnimationAlternateEnabled
        animationBulgeBouncerTwistEnabled = BlobMotionControllerBulgeBouncer.defaultAnimationTwistEnabled
        animationBulgeBouncerInflateEnabled = BlobMotionControllerBulgeBouncer.defaultAnimationInflateEnabled
        animationBulgeBouncerHorizontalEnabled = BlobMotionControllerBulgeBouncer.defaultAnimationHorizontalEnabled
        animationBulgeBouncerSpeed = BlobMotionControllerBulgeBouncer.defaultAnimationSpeed
        animationBulgeBouncerInflationStartFactor = BlobMotionControllerBulgeBouncer.defaultAnimationInflationStartFactor
        animationBulgeBouncerEllipseFactor = BlobMotionControllerBulgeBouncer.defaultAnimationEllipseFactor
        animationBulgeBouncerInflationFactor = BlobMotionControllerBulgeBouncer.defaultAnimationInflationFactor
        animationBulgeBouncerBounceFactor = BlobMotionControllerBulgeBouncer.defaultAnimationBounceFactor
        animationBulgeBouncerPower = BlobMotionControllerBulgeBouncer.defaultAnimationPower
    }
    
    func resetDefaultAnimationBulgeBouncer() {
        
        let historyState = HistoryStateAnimationBulgeBouncerResetDefault()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        
        //Store the initial values in history state
        historyState.startPower = animationBulgeBouncerPower
        historyState.startSpeed = animationBulgeBouncerSpeed
        historyState.startBounceStartFactor = animationBulgeBouncerInflationStartFactor
        historyState.startEllipseFactor = animationBulgeBouncerEllipseFactor
        historyState.startInflationFactor = animationBulgeBouncerInflationFactor
        historyState.startBounceFactor = animationBulgeBouncerBounceFactor
        historyState.startBounceEnabled = animationBulgeBouncerBounceEnabled
        historyState.startReverseEnabled = animationBulgeBouncerReverseEnabled
        historyState.startEllipseEnabled = animationBulgeBouncerEllipseEnabled
        historyState.startAlternateEnabled = animationBulgeBouncerAlternateEnabled
        historyState.startTwistEnabled = animationBulgeBouncerTwistEnabled
        historyState.startInflateEnabled = animationBulgeBouncerInflateEnabled
        historyState.startHorizontalEnabled = animationBulgeBouncerHorizontalEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        
        //Reset the actual values to default
        resetDefaultAnimationBulgeBouncerInternal()
        
        
        //Store the final values in history state
        historyState.endPower = animationBulgeBouncerPower
        historyState.endSpeed = animationBulgeBouncerSpeed
        historyState.endBounceStartFactor = animationBulgeBouncerInflationStartFactor
        historyState.endEllipseFactor = animationBulgeBouncerEllipseFactor
        historyState.endInflationFactor = animationBulgeBouncerInflationFactor
        historyState.endBounceFactor = animationBulgeBouncerBounceFactor
        historyState.endBounceEnabled = animationBulgeBouncerBounceEnabled
        historyState.endReverseEnabled = animationBulgeBouncerReverseEnabled
        historyState.endEllipseEnabled = animationBulgeBouncerEllipseEnabled
        historyState.endAlternateEnabled = animationBulgeBouncerAlternateEnabled
        historyState.endTwistEnabled = animationBulgeBouncerTwistEnabled
        historyState.endInflateEnabled = animationBulgeBouncerInflateEnabled
        historyState.endHorizontalEnabled = animationBulgeBouncerHorizontalEnabled
        
        historyAdd(withState: historyState)
    }
    
    private func resetDefaultAnimationTwisterInternal() {
        animationTwisterReverseEnabled = BlobMotionControllerTwister.defaultAnimationReverseEnabled
        animationTwisterEllipseEnabled = BlobMotionControllerTwister.defaultAnimationEllipseEnabled
        animationTwisterAlternateEnabled = BlobMotionControllerTwister.defaultAnimationAlternateEnabled
        animationTwisterInflateEnabled = BlobMotionControllerTwister.defaultAnimationInflateEnabled
        animationTwisterTwistSpeed = BlobMotionControllerTwister.defaultAnimationTwistSpeed
        animationTwisterInflationFactor1 = BlobMotionControllerTwister.defaultAnimationInflationFactor1
        animationTwisterInflationFactor2 = BlobMotionControllerTwister.defaultAnimationInflationFactor2
        animationTwisterTwistPower = BlobMotionControllerTwister.defaultAnimationTwistPower
    }
    
    func resetDefaultAnimationTwister() {
        
        let historyState = HistoryStateAnimationTwisterResetDefault()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        
        historyState.startTwistPower = animationTwisterTwistPower
        historyState.startTwistSpeed = animationTwisterTwistSpeed   
        historyState.startInflationFactor1 = animationTwisterInflationFactor1
        historyState.startInflationFactor2 = animationTwisterInflationFactor2
        historyState.startReverseEnabled = animationTwisterReverseEnabled
        historyState.startEllipseEnabled = animationTwisterEllipseEnabled
        historyState.startAlternateEnabled = animationTwisterAlternateEnabled
        historyState.startInflateEnabled = animationTwisterInflateEnabled
        
        historyState.recordEnd(withBlob: selectedBlob)
        
        resetDefaultAnimationTwisterInternal()
        
        historyState.endTwistPower = animationTwisterTwistPower
        historyState.endTwistSpeed = animationTwisterTwistSpeed
        historyState.endInflationFactor1 = animationTwisterInflationFactor1
        historyState.endInflationFactor2 = animationTwisterInflationFactor2
        historyState.endReverseEnabled = animationTwisterReverseEnabled
        historyState.endEllipseEnabled = animationTwisterEllipseEnabled
        historyState.endAlternateEnabled = animationTwisterAlternateEnabled
        historyState.endInflateEnabled = animationTwisterInflateEnabled
        
        historyAdd(withState: historyState)
    }
    
    private func resetDefaultAnimationRandomInternal() {
        animationRandomReverseEnabled = BlobMotionControllerCrazy.defaultAnimationReverseEnabled
        animationRandomEllipseEnabled = BlobMotionControllerCrazy.defaultAnimationEllipseEnabled
        animationRandomAlternateEnabled = BlobMotionControllerCrazy.defaultAnimationAlternateEnabled
        animationRandomTwistEnabled = BlobMotionControllerCrazy.defaultAnimationTwistEnabled
        animationRandomInflateEnabled = BlobMotionControllerCrazy.defaultAnimationInflateEnabled
        animationRandomHorizontalEnabled = BlobMotionControllerBulgeBouncer.defaultAnimationHorizontalEnabled
        animationRandomSpeed = BlobMotionControllerCrazy.defaultAnimationSpeed
        animationRandomInflationFactor1 = BlobMotionControllerCrazy.defaultAnimationInflationFactor1
        animationRandomInflationFactor2 = BlobMotionControllerCrazy.defaultAnimationInflationFactor2
        animationRandomTwistFactor = BlobMotionControllerCrazy.defaultAnimationTwistFactor
        animationRandomRandomnessFactor = BlobMotionControllerCrazy.defaultAnimationRandomnessFactor
        animationRandomPower = BlobMotionControllerCrazy.defaultAnimationPower
    }
    
    func resetDefaultAnimationRandom() {
        let historyState = HistoryStateAnimationRandomResetDefault()
        historyState.recordStart(withBlob: selectedBlob)
        historyState.blobIndex = indexOf(blob: selectedBlob)
        
        historyState.startPower = animationRandomPower
        historyState.startSpeed = animationRandomSpeed
        historyState.startInflationFactor1 = animationRandomInflationFactor1
        historyState.startInflationFactor2 = animationRandomInflationFactor2
        historyState.startTwistFactor = animationRandomTwistFactor
        historyState.startRandomnessFactor = animationRandomRandomnessFactor
        historyState.startReverseEnabled = animationRandomReverseEnabled
        historyState.startEllipseEnabled = animationRandomEllipseEnabled
        historyState.startAlternateEnabled = animationRandomAlternateEnabled
        historyState.startTwistEnabled = animationRandomTwistEnabled
        historyState.startInflateEnabled = animationRandomInflateEnabled
        historyState.startHorizontalEnabled = animationRandomHorizontalEnabled
        historyState.recordEnd(withBlob: selectedBlob)
        
        resetDefaultAnimationRandomInternal()
        
        historyState.endPower = animationRandomPower
        historyState.endSpeed = animationRandomSpeed
        historyState.endInflationFactor1 = animationRandomInflationFactor1
        historyState.endInflationFactor2 = animationRandomInflationFactor2
        historyState.endTwistFactor = animationRandomTwistFactor
        historyState.endRandomnessFactor = animationRandomRandomnessFactor
        historyState.endReverseEnabled = animationRandomReverseEnabled
        historyState.endEllipseEnabled = animationRandomEllipseEnabled
        historyState.endAlternateEnabled = animationRandomAlternateEnabled
        historyState.endTwistEnabled = animationRandomTwistEnabled
        historyState.endInflateEnabled = animationRandomInflateEnabled
        historyState.endHorizontalEnabled = animationRandomHorizontalEnabled
        
        historyAdd(withState: historyState)
    }
    
    func sliderStart() {
        cancelAllTouches()
        cancelAllGestures()
    }
    
    func sliderEnd() {
        
    }
    
    func unwindAnimationTargetOffsetDamped(blob: Blob) -> CGPoint {
        var offsetDir = blob.motionController.animationTargetOffset
        var offSetLength: CGFloat = offsetDir.x * offsetDir.x + offsetDir.y * offsetDir.y
        if offSetLength > Math.epsilon {
            offSetLength = CGFloat(sqrtf(Float(offSetLength)))
            offsetDir = CGPoint(x: offsetDir.x / offSetLength, y: offsetDir.y / offSetLength)
        }
        offSetLength = BounceEngine.fallOffDampenInverse(input: offSetLength, falloffStart: blob.dragFalloffDampenStart, resultMax: blob.dragFalloffDampenResultMax, inputMax: blob.dragFalloffDampenInputMax)
        return CGPoint(x: offsetDir.x * offSetLength, y: offsetDir.y * offSetLength)
    }
    
    // 0.0 < falloffStart < resultMax < inputMax
    class func fallOffDampen(input:CGFloat, falloffStart:CGFloat, resultMax: CGFloat, inputMax:CGFloat) -> CGFloat {
        var result: CGFloat = input
        if result > falloffStart {
            result = resultMax
            if input < inputMax {
                //We are constrained between [falloffStart .. inputMax]
                let span = (inputMax - falloffStart)
                if span > Math.epsilon {
                    var percentLinear = (input - falloffStart) / span
                    if percentLinear < 0.0 { percentLinear = 0.0 }
                    if percentLinear > 1.0 { percentLinear = 1.0 }
                    //sin [0..1] => [0..pi/2]
                    let factor = CGFloat(sin(Float(percentLinear * Math.PI_2)))
                    result = falloffStart + factor * (resultMax - falloffStart)
                }
            }
        }
        return result
    }
    
    // 0.0 < falloffStart < resultMax < inputMax
    class func fallOffDampenInverse(input:CGFloat, falloffStart:CGFloat, resultMax: CGFloat, inputMax:CGFloat) -> CGFloat {
        var result: CGFloat = input
        if input > falloffStart {
            result = inputMax
            if input < resultMax {
                //We are constrained between [falloffStart .. resultMax]
                let span = (resultMax - falloffStart)
                if span > Math.epsilon {
                    var percentLinear = (input - falloffStart) / span
                    if percentLinear < 0.0 { percentLinear = 0.0 }
                    if percentLinear > 1.0 { percentLinear = 1.0 }
                    //asin [0..1] => [0..pi/2]
                    let factor = CGFloat(asinf(Float(percentLinear))) / Math.PI_2
                    result = falloffStart + factor * (inputMax - falloffStart)
                }
            }
        }
        return result
    }
    
    func blobCountDidChange() {
        BounceEngine.postNotification(BounceNotification.blobCountChanged)
    }
    
    func refreshBlobAlternation() {
        var index: Int = 1
        for blob:Blob in blobs {
            //blob.name = "Blob #\(index)"
            index += 1
        }
        
        
        var isAlt: Bool = false
        
        if animationMode == .bounce {
            isAlt = animationBulgeBouncerAlternateEnabled
        }
        if animationMode == .twist {
            isAlt = animationTwisterAlternateEnabled
        }
        if animationMode == .random {
            isAlt = animationRandomAlternateEnabled
        }
        
        if isAlt {
            var isAltBlob: Bool = false
            for blob:Blob in blobs {
                blob.isAltBlob = isAltBlob
                if isAltBlob {
                    isAltBlob = false
                } else {
                    isAltBlob = true
                }
            }
        } else {
            for blob:Blob in blobs {
                blob.isAltBlob = false
            }
        }
    }
    
    func historyPrint() {
        
        print("___HISTORY STACK [\(historyStack.count) items] Ind[\(historyIndex)]")
        
        for i in 0..<historyStack.count {
            
            let state = historyStack[i]
            
            var typeString = "Unknown"
            
            if state.type == .blobAdd {
                typeString = "Add Blob"
            }
            if state.type == .blobDelete {
                typeString = "Delete Blob"
            }
            if state.type == .blobChangeAffine {
                typeString = "Blob Change Affine"
            }
            if state.type == .blobChangeShape {
                typeString = "Blob Change Shape"
            }
            
            //print("Hist [\(i) -> \(typeString) Ind(\(state.blobIndex))")
            
        }
        
        print("___END HISTORY STACK")
    }
    
    func historyClear() {
        historyStack.removeAll()
        historyIndex = 0
    }
    
    func historyAdd(withState state: HistoryState) -> Void {
        
        shouldPromptForSave = true
        
        //if let bounce = ApplicationController.shared.bounce {
        
        //Don't record history when animting or recording.
        
        //User may twiddle animation settings during...
        
        //Actually, no, the user can't touch these menus.
        
        //if bounce.isRecording { return }
        //if bounce.timelineEnabled { return }
        //}
        
        
        //state.selectedBlobIndex = indexOf(blob: selectedBlob)
        
        //var selectedBlobIndex: Int?
        
        //var sceneMode: SceneMode = .edit
        //var editMode: EditMode = .affine
        //var viewMode: ViewMode = .grab
        
        //print("PRE____")
        //historyPrint()
        
        //Case 0:
        //History stack has 0 items, we are at item nil.
        //[] index = nil
        //...
        //[NEW] index = 0
        
        //Case 1:
        //History stack has 4 items, we are at item 1.
        //[H0, H1, H2, H3] index = 1
        //...
        //[H0, H1, NEW] index = 2
        
        //Case 2:
        //History stack has 1 items, we are at item 0.
        //[H0] index = 0
        //...
        //[H0, NEW] index = 1
        
        var newHistoryStack = [HistoryState]()
        var index = historyIndex
        if historyLastActionUndo == false { index += 1 }
        if index > 0 {
            if index > historyStack.count { index = historyStack.count }
            for i in 0..<(index) {
                newHistoryStack.append(historyStack[i])
            }
        }
        
        newHistoryStack.append(state)
        historyIndex = newHistoryStack.count
        historyStack = newHistoryStack
        historyLastActionUndo = false
        historyLastActionRedo = false
        BounceEngine.postNotification(BounceNotification.historyChanged)
    }
    
    func canUndo() -> Bool {
        if zoomEnabled { return false }
        if historyStack.count > 0 {
            if historyLastActionRedo {
                return (historyIndex >= 0 && historyIndex < historyStack.count)
            } else {
                return (historyIndex > 0 && historyIndex <= historyStack.count)
            }
        }
        return false
    }
    
    func canRedo() -> Bool {
        if zoomEnabled { return false }
        if historyStack.count > 0 {
            if historyLastActionUndo {
                return (historyIndex >= 0 && historyIndex < historyStack.count)
            } else {
                return (historyIndex >= 0 && historyIndex < (historyStack.count - 1))
            }
        }
        return false
    }
    
    
    func undo() {
        print("Undo! Allow[\(canUndo())] -> Index = \(historyIndex)")
        if canUndo() {
            let index = historyLastActionRedo ? historyIndex : (historyIndex - 1)
            let state = historyStack[index]
            historyApplyUndo(withState: state)
            historyIndex = index
            historyLastActionUndo = true
            historyLastActionRedo = false
            BounceEngine.postNotification(BounceNotification.historyChanged)
        }
        print("Post Undo! Index = \(historyIndex)")
    }
    
    func redo() {
        if canRedo() {
            let index = historyLastActionUndo ? historyIndex : (historyIndex + 1)
            let state = historyStack[index]
            historyApplyRedo(withState: state)
            historyIndex = index
            historyLastActionUndo = false
            historyLastActionRedo = true
            BounceEngine.postNotification(BounceNotification.historyChanged)
        }
    }
    
    func historyApplyUndo(withState historyState: HistoryState) {
        shouldPromptForSave = true
        if historyState.type == .blobAdd {
            if let state = historyState as? HistoryStateAddBlob {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    deleteBlob(blobs[index])
                }
            }
        } else if historyState.type == .blobChangeAffine {
            if let state = historyState as? HistoryStateChangeAffine {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    let blob = blobs[index]
                    blob.center = state.startPos
                    blob.scale = state.startScale
                    blob.rotation = state.startRotation
                }
            }
        } else if historyState.type == .blobChangeBulgeCenter {
            if let state = historyState as? HistoryStateChangeBulgeCenter {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    let blob = blobs[index]
                    blob.bulgeWeightOffset = state.startOffset
                    //blob.bulgeWeightScale = state.startScale
                    //blob.bulgeWeightRotation = state.startRotation
                }
            }
        } else if historyState.type == .blobChangeBulgeEdgeFactor {
            if let state = historyState as? HistoryStateChangeBulgeEdgeFactor {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    let blob = blobs[index]
                    blob.bulgeEdgeFactor = state.startEdgeFactor
                    //BounceEngine.postNotification(BounceNotification.bulgeEdgeFactorChangedForced)
                    
                }
            }
        } else if historyState.type == .blobChangeBulgeCenterFactor {
            if let state = historyState as? HistoryStateChangeBulgeCenterFactor {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    let blob = blobs[index]
                    blob.bulgeCenterFactor = state.startCenterFactor
                    //BounceEngine.postNotification(BounceNotification.bulgeCe)
                    
                }
            }
        } else if historyState.type == .animationSpeed {
            if let state = historyState as? HistoryStateAnimationSpeed {
                animationSpeed = state.startAnimationSpeed
            }
        } else if historyState.type == .animationPower {
            if let state = historyState as? HistoryStateAnimationPower {
                animationPower = state.startAnimationPower
            }
        } else if historyState.type == .animationBulgeBouncerPower {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerPower {
                animationBulgeBouncerPower = state.startValue
            }
        } else if historyState.type == .animationBulgeBouncerSpeed {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerSpeed {
                animationBulgeBouncerSpeed = state.startValue
            }
        }  else if historyState.type == .animationBulgeBouncerInflationFactor {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerInflationFactor {
                animationBulgeBouncerInflationFactor = state.startValue
            }
        } else if historyState.type == .animationBulgeBouncerEllipseFactor {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerEllipseFactor {
                animationBulgeBouncerEllipseFactor = state.startValue
            }
        } else if historyState.type == .animationBulgeBouncerBounceFactor {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerBounceFactor {
                animationBulgeBouncerBounceFactor = state.startValue
            }
        } else if historyState.type == .animationBulgeBouncerInflationStartFactor {
            if let state = historyState as? HistoryStateanimationBulgeBouncerInflationStartFactor {
                animationBulgeBouncerInflationStartFactor = state.startValue
            }
        } else if historyState.type == .animationTwisterInflationFactor1 {
            if let state = historyState as? HistoryStateAnimationTwisterInflationFactor1 {
                animationTwisterInflationFactor1 = state.startValue
            }
        } else if historyState.type == .animationTwisterInflationFactor2 {
            if let state = historyState as? HistoryStateAnimationTwisterInflationFactor2 {
                animationTwisterInflationFactor2 = state.startValue
            }
        } else if historyState.type == .animationTwisterPower {
            if let state = historyState as? HistoryStateAnimationTwisterPower {
                animationTwisterTwistPower = state.startValue
            }
        } else if historyState.type == .animationTwisterSpeed {
            if let state = historyState as? HistoryStateAnimationTwisterSpeed {
                animationTwisterTwistSpeed = state.startValue
            }
        } else if historyState.type == .animationRandomRandomnessFactor {
            if let state = historyState as? HistoryStateAnimationRandomRandomnessFactor {
                animationRandomRandomnessFactor = state.startValue
            }
        } else if historyState.type == .animationRandomTwistFactor {
            if let state = historyState as? HistoryStateAnimationRandomTwistFactor {
                animationRandomTwistFactor = state.startValue
            }
        } else if historyState.type == .animationRandomPower {
            if let state = historyState as? HistoryStateAnimationRandomPower {
                animationRandomPower = state.startValue
            }
        } else if historyState.type == .animationRandomSpeed {
            if let state = historyState as? HistoryStateAnimationRandomSpeed {
                animationRandomSpeed = state.startValue
            }
        } else if historyState.type == .animationRandomInflationFactor1 {
            if let state = historyState as? HistoryStateAnimationRandomInflationFactor1 {
                animationRandomInflationFactor1 = state.startValue
            }
        } else if historyState.type == .animationRandomInflationFactor2 {
            if let state = historyState as? HistoryStateAnimationRandomInflationFactor2 {
                animationRandomInflationFactor2 = state.startValue
            }
        } else if historyState.type == .blobChangeShape {
            if let state = historyState as? HistoryStateChangeShape {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    if var data = state.startSplineData {
                        let blob = blobs[index]
                        blob.spline.load(info: &data)
                        blob.bulgeWeightOffset = state.startBulgeOffset
                        blob.center = state.startCenter
                        blob.computeShape()
                    }
                }
            }
        } else if historyState.type == .blobDelete {
            if let state = historyState as? HistoryStateDeleteBlob {
                if let index = state.blobIndex, var data = state.blobData {
                    let blob = Blob()
                    blob.load(info: &data)
                    if index >= 0 && index < blobs.count {
                        blobs.insert(blob, at: index)
                    } else {
                        blobs.append(blob)
                        blobCountDidChange()
                    }
                }
            }
        } else if historyState.type == .blobFreeze {
            if let state = historyState as? HistoryStateFreeze {
                if let index = state.blobIndex {
                    let blob = blobs[index]
                    blob.frozen = false
                    BounceEngine.postNotification(BounceNotification.frozenStateChanged)
                }
            }
        }
        else if historyState.type == .unfreezeAll {
            if let state = historyState as? HistoryStateUnfreezeAll {
                for blob in blobs {
                    blob.frozen = false
                }
                for index in state.frozenIndeces {
                    if let blob = blobAt(index: index) {
                        blob.frozen = true
                    }
                }
                BounceEngine.postNotification(BounceNotification.frozenStateChanged)
            }
        } else if historyState.type == .animationBulgeBouncerHorizontalEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerHorizontalEnabled {
                //ToolActions.setAnimationBulgeBouncerHorizontalEnabled(state.startEnabled)
                animationBulgeBouncerHorizontalEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerInflateEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerInflateEnabled {
                animationBulgeBouncerInflateEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerTwistEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerTwistEnabled {
                animationBulgeBouncerTwistEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerAlternateEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerAlternateEnabled {
                animationBulgeBouncerAlternateEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerEllipseEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerEllipseEnabled {
                animationBulgeBouncerEllipseEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerReverseEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerReverseEnabled {
                animationBulgeBouncerReverseEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerBounceEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerBounceEnabled {
                animationBulgeBouncerBounceEnabled = state.startEnabled
            }
        } else if historyState.type == .animationTwisterReverseEnabled {
            if let state = historyState as? HistoryStateAnimationTwisterReverseEnabled {
                animationTwisterReverseEnabled = state.startEnabled
            }
        } else if historyState.type == .animationBulgeBouncerResetDefault {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerResetDefault {
                animationBulgeBouncerPower = state.startPower
                animationBulgeBouncerSpeed = state.startSpeed
                animationBulgeBouncerInflationStartFactor = state.startBounceStartFactor
                animationBulgeBouncerEllipseFactor = state.startEllipseFactor
                animationBulgeBouncerInflationFactor = state.startInflationFactor
                animationBulgeBouncerBounceFactor = state.startBounceFactor
                animationBulgeBouncerBounceEnabled = state.startBounceEnabled
                animationBulgeBouncerReverseEnabled = state.startReverseEnabled
                animationBulgeBouncerEllipseEnabled = state.startEllipseEnabled
                animationBulgeBouncerAlternateEnabled = state.startAlternateEnabled
                animationBulgeBouncerTwistEnabled = state.startTwistEnabled
                animationBulgeBouncerInflateEnabled = state.startInflateEnabled
                animationBulgeBouncerHorizontalEnabled = state.startHorizontalEnabled
            }
        } else if historyState.type == .animationTwisterResetDefault {
            if let state = historyState as? HistoryStateAnimationTwisterResetDefault {
                animationTwisterTwistSpeed = state.startTwistSpeed
                animationTwisterInflationFactor1 = state.startInflationFactor1
                animationTwisterInflationFactor2 = state.startInflationFactor2
                animationTwisterTwistPower = state.startTwistPower
                animationTwisterReverseEnabled = state.startReverseEnabled
                animationTwisterEllipseEnabled = state.startEllipseEnabled
                animationTwisterAlternateEnabled = state.startAlternateEnabled
                animationTwisterInflateEnabled = state.startReverseEnabled
            }
        } else if historyState.type == .animationRandomResetDefault {
            if let state = historyState as? HistoryStateAnimationRandomResetDefault {
                animationRandomPower = state.startPower
                animationRandomSpeed = state.startSpeed
                animationRandomInflationFactor1 = state.startInflationFactor1
                animationRandomInflationFactor2 = state.startInflationFactor2
                animationRandomTwistFactor = state.startTwistFactor
                animationRandomRandomnessFactor = state.startRandomnessFactor
                animationRandomReverseEnabled = state.startReverseEnabled
                animationRandomEllipseEnabled = state.startEllipseEnabled
                animationRandomAlternateEnabled = state.startAlternateEnabled
                animationRandomTwistEnabled = state.startTwistEnabled
                animationRandomInflateEnabled = state.startInflateEnabled
                animationRandomHorizontalEnabled = state.startHorizontalEnabled
            }
        } else if historyState.type == .animationTwisterEllipseEnabled {
            if let state = historyState as? HistoryStateAnimationTwisterEllipseEnabled {
                animationTwisterEllipseEnabled = state.startEnabled
            }
        } else if historyState.type == .animationTwisterAlternateEnabled {
            if let state = historyState as? HistoryStateAnimationTwisterAlternateEnabled {
                animationTwisterAlternateEnabled = state.startEnabled
            }
        } else if historyState.type == .animationTwisterInflateEnabled {
            if let state = historyState as? HistoryStateAnimationTwisterInflateEnabled {
                animationTwisterInflateEnabled = state.startEnabled
            }
        } else if historyState.type == .animationRandomReverseEnabled {
            if let state = historyState as? HistoryStateAnimationRandomReverseEnabled {
                animationRandomReverseEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationRandomEllipseEnabled {
            if let state = historyState as? HistoryStateAnimationRandomEllipseEnabled {
                animationRandomEllipseEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationRandomAlternateEnabled {
            if let state = historyState as? HistoryStateAnimationRandomAlternateEnabled {
                animationRandomAlternateEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationRandomTwistEnabled {
            if let state = historyState as? HistoryStateAnimationRandomTwistEnabled {
                animationRandomTwistEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationRandomInflateEnabled {
            if let state = historyState as? HistoryStateAnimationRandomInflateEnabled {
                animationRandomInflateEnabled = state.startEnabled
            }
        }  else if historyState.type == .animationRandomHorizontalEnabled {
            if let state = historyState as? HistoryStateAnimationRandomHorizontalEnabled {
                animationRandomHorizontalEnabled = state.startEnabled
            }
        }
        
        sceneMode = historyState.startSceneMode
        editMode = historyState.startEditMode
        animationEnabled = historyState.startAnimationEnabled
        animationMode = historyState.startAnimationMode
        altMenuBulgeBouncer = historyState.startAltMenuBulgeBouncer
        altMenuTwister = historyState.startAltMenuTwister
        altMenuRandom = historyState.startAltMenuRandom
        
        selectedBlob = blobAt(index: historyState.startSelectedBlobIndex)
        if selectedBlob !== nil {
            selectedBlob!.selectedControlPointIndex = historyState.startSelectedControlPointIndex
        }
    }
    
    func historyApplyRedo(withState historyState: HistoryState) {
        shouldPromptForSave = true
        if historyState.type == .blobAdd {
            if let state = historyState as? HistoryStateAddBlob {
                if let index = state.blobIndex, var data = state.blobData {
                    let blob = Blob()
                    blob.load(info: &data)
                    if index >= 0 && index < blobs.count {
                        blobs.insert(blob, at: index)
                    } else {
                        blobs.append(blob)
                        blobCountDidChange()
                    }
                }
            }
        } else if historyState.type == .blobChangeAffine {
            if let state = historyState as? HistoryStateChangeAffine {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    let blob = blobs[index]
                    blob.center = state.endPos
                    blob.scale = state.endScale
                    blob.rotation = state.endRotation
                }
            }
        } else if historyState.type == .blobChangeBulgeCenter {
            if let state = historyState as? HistoryStateChangeBulgeCenter {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    let blob = blobs[index]
                    blob.bulgeWeightOffset = state.endOffset
                }
            }
        } else if historyState.type == .blobChangeBulgeEdgeFactor {
            if let state = historyState as? HistoryStateChangeBulgeEdgeFactor {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    let blob = blobs[index]
                    blob.bulgeEdgeFactor = state.endEdgeFactor
                }
            }
        } else if historyState.type == .blobChangeBulgeCenterFactor {
            if let state = historyState as? HistoryStateChangeBulgeCenterFactor {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    let blob = blobs[index]
                    blob.bulgeCenterFactor = state.endCenterFactor
                }
            }
        } else if historyState.type == .animationSpeed {
            if let state = historyState as? HistoryStateAnimationSpeed {
                animationSpeed = state.endAnimationSpeed
            }
        } else if historyState.type == .animationPower {
            if let state = historyState as? HistoryStateAnimationPower {
                animationPower = state.endAnimationPower
            }
        } else if historyState.type == .animationBulgeBouncerPower {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerPower {
                animationBulgeBouncerPower = state.endValue
            }
        } else if historyState.type == .animationBulgeBouncerSpeed {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerSpeed {
                animationBulgeBouncerSpeed = state.endValue
            }
        } else if historyState.type == .animationBulgeBouncerInflationFactor {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerInflationFactor {
                animationBulgeBouncerInflationFactor = state.endValue
            }
        } else if historyState.type == .animationBulgeBouncerEllipseFactor {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerEllipseFactor {
                animationBulgeBouncerEllipseFactor = state.endValue
            }
        } else if historyState.type == .animationBulgeBouncerBounceFactor {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerBounceFactor {
                animationBulgeBouncerBounceFactor = state.endValue
            }
        } else if historyState.type == .animationBulgeBouncerInflationStartFactor {
            if let state = historyState as? HistoryStateanimationBulgeBouncerInflationStartFactor {
                animationBulgeBouncerInflationStartFactor = state.endValue
            }
        } else if historyState.type == .animationTwisterInflationFactor1 {
            if let state = historyState as? HistoryStateAnimationTwisterInflationFactor1 {
                animationTwisterInflationFactor1 = state.endValue
            }
        } else if historyState.type == .animationTwisterInflationFactor2 {
            if let state = historyState as? HistoryStateAnimationTwisterInflationFactor2 {
                animationTwisterInflationFactor2 = state.endValue
            }
        } else if historyState.type == .animationTwisterPower {
            if let state = historyState as? HistoryStateAnimationTwisterPower {
                animationTwisterTwistPower = state.endValue
            }
        } else if historyState.type == .animationTwisterSpeed {
            if let state = historyState as? HistoryStateAnimationTwisterSpeed {
                animationTwisterTwistSpeed = state.endValue
            }
        } else if historyState.type == .animationRandomRandomnessFactor {
            if let state = historyState as? HistoryStateAnimationRandomRandomnessFactor {
                animationRandomRandomnessFactor = state.endValue
            }
        } else if historyState.type == .animationRandomTwistFactor {
            if let state = historyState as? HistoryStateAnimationRandomTwistFactor {
                animationRandomTwistFactor = state.endValue
            }
        }  else if historyState.type == .animationRandomPower {
            if let state = historyState as? HistoryStateAnimationRandomPower {
                animationRandomPower = state.endValue
            }
        } else if historyState.type == .animationRandomSpeed {
            if let state = historyState as? HistoryStateAnimationRandomSpeed {
                animationRandomSpeed = state.endValue
            }
        } else if historyState.type == .animationRandomInflationFactor1 {
            if let state = historyState as? HistoryStateAnimationRandomInflationFactor1 {
                animationRandomInflationFactor1 = state.endValue
            }
        } else if historyState.type == .animationRandomInflationFactor2 {
            if let state = historyState as? HistoryStateAnimationRandomInflationFactor2 {
                animationRandomInflationFactor2 = state.endValue
            }
        } else if historyState.type == .blobChangeShape {
            if let state = historyState as? HistoryStateChangeShape {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    if var data = state.endSplineData {
                        let blob = blobs[index]
                        blob.spline.load(info: &data)
                        blob.bulgeWeightOffset = state.endBulgeOffset
                        blob.center = state.endCenter
                        blob.computeShape()
                    }
                }
            }
        } else if historyState.type == .blobDelete {
            if let state = historyState as? HistoryStateDeleteBlob {
                if let index = state.blobIndex, index >= 0 && index < blobs.count {
                    deleteBlob(blobs[index])
                }
            }
        } else if historyState.type == .blobFreeze {
            if let state = historyState as? HistoryStateFreeze {
                if let index = state.blobIndex {
                    let blob = blobs[index]
                    blob.frozen = true
                    BounceEngine.postNotification(BounceNotification.frozenStateChanged)
                }
            }
        } else if historyState.type == .unfreezeAll {
            for blob in blobs {
                blob.frozen = false
            }
            BounceEngine.postNotification(BounceNotification.frozenStateChanged)
        } else if historyState.type == .animationBulgeBouncerHorizontalEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerHorizontalEnabled {
                animationBulgeBouncerHorizontalEnabled = state.endEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerInflateEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerInflateEnabled {
                animationBulgeBouncerInflateEnabled = state.endEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerTwistEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerTwistEnabled {
                animationBulgeBouncerTwistEnabled = state.endEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerAlternateEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerAlternateEnabled {
                animationBulgeBouncerAlternateEnabled = state.endEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerEllipseEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerEllipseEnabled {
                animationBulgeBouncerEllipseEnabled = state.endEnabled
            }
        }  else if historyState.type == .animationBulgeBouncerReverseEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerReverseEnabled {
                animationBulgeBouncerReverseEnabled = state.endEnabled
            }
        } else if historyState.type == .animationBulgeBouncerResetDefault {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerResetDefault {
                animationBulgeBouncerPower = state.endPower
                animationBulgeBouncerSpeed = state.endSpeed
                animationBulgeBouncerInflationStartFactor = state.endBounceStartFactor
                animationBulgeBouncerEllipseFactor = state.endEllipseFactor
                animationBulgeBouncerInflationFactor = state.endInflationFactor
                animationBulgeBouncerBounceFactor = state.endBounceFactor
                animationBulgeBouncerBounceEnabled = state.endBounceEnabled
                animationBulgeBouncerReverseEnabled = state.endReverseEnabled
                animationBulgeBouncerEllipseEnabled = state.endEllipseEnabled
                animationBulgeBouncerAlternateEnabled = state.endAlternateEnabled
                animationBulgeBouncerTwistEnabled = state.endTwistEnabled
                animationBulgeBouncerInflateEnabled = state.endInflateEnabled
                animationBulgeBouncerHorizontalEnabled = state.endHorizontalEnabled
            }
        } else if historyState.type == .animationTwisterResetDefault {
            if let state = historyState as? HistoryStateAnimationTwisterResetDefault {
                animationTwisterTwistPower = state.endTwistPower
                animationTwisterTwistSpeed = state.endTwistSpeed
                animationTwisterInflationFactor1 = state.endInflationFactor1
                animationTwisterInflationFactor2 = state.endInflationFactor2
                animationTwisterReverseEnabled = state.endReverseEnabled
                animationTwisterEllipseEnabled = state.endEllipseEnabled
                animationTwisterAlternateEnabled = state.endAlternateEnabled
                animationTwisterInflateEnabled = state.endReverseEnabled
            }
        } else if historyState.type == .animationRandomResetDefault {
            if let state = historyState as? HistoryStateAnimationRandomResetDefault {
                animationRandomPower = state.endPower
                animationRandomSpeed = state.endSpeed
                animationRandomInflationFactor1 = state.endInflationFactor1
                animationRandomInflationFactor2 = state.endInflationFactor2
                animationRandomTwistFactor = state.endTwistFactor
                animationRandomRandomnessFactor = state.endRandomnessFactor
                animationRandomReverseEnabled = state.endReverseEnabled
                animationRandomEllipseEnabled = state.endEllipseEnabled
                animationRandomAlternateEnabled = state.endAlternateEnabled
                animationRandomTwistEnabled = state.endTwistEnabled
                animationRandomInflateEnabled = state.endInflateEnabled
                animationRandomHorizontalEnabled = state.endHorizontalEnabled
            }
        } else if historyState.type == .animationBulgeBouncerBounceEnabled {
            if let state = historyState as? HistoryStateAnimationBulgeBouncerBounceEnabled {
                animationBulgeBouncerBounceEnabled = state.endEnabled
            }
        } else if historyState.type == .animationTwisterReverseEnabled {
            if let state = historyState as? HistoryStateAnimationTwisterReverseEnabled {
                animationTwisterReverseEnabled = state.endEnabled
            }
        } else if historyState.type == .animationTwisterEllipseEnabled {
            if let state = historyState as? HistoryStateAnimationTwisterEllipseEnabled {
                animationTwisterEllipseEnabled = state.endEnabled
            }
        } else if historyState.type == .animationTwisterAlternateEnabled {
            if let state = historyState as? HistoryStateAnimationTwisterAlternateEnabled {
                animationTwisterAlternateEnabled = state.endEnabled
            }
        } else if historyState.type == .animationTwisterInflateEnabled {
            if let state = historyState as? HistoryStateAnimationTwisterInflateEnabled {
                animationTwisterInflateEnabled = state.endEnabled
            }
        } else if historyState.type == .animationRandomReverseEnabled {
            if let state = historyState as? HistoryStateAnimationRandomReverseEnabled {
                animationRandomReverseEnabled = state.endEnabled
            }
        }  else if historyState.type == .animationRandomEllipseEnabled {
            if let state = historyState as? HistoryStateAnimationRandomEllipseEnabled {
                animationRandomEllipseEnabled = state.endEnabled
            }
        }  else if historyState.type == .animationRandomAlternateEnabled {
            if let state = historyState as? HistoryStateAnimationRandomAlternateEnabled {
                animationRandomAlternateEnabled = state.endEnabled
            }
        }  else if historyState.type == .animationRandomTwistEnabled {
            if let state = historyState as? HistoryStateAnimationRandomTwistEnabled {
                animationRandomTwistEnabled = state.endEnabled
            }
        }  else if historyState.type == .animationRandomInflateEnabled {
            if let state = historyState as? HistoryStateAnimationRandomInflateEnabled {
                animationRandomInflateEnabled = state.endEnabled
            }
        }  else if historyState.type == .animationRandomHorizontalEnabled {
            if let state = historyState as? HistoryStateAnimationRandomHorizontalEnabled {
                animationRandomHorizontalEnabled = state.endEnabled
            }
        }
        
        sceneMode = historyState.endSceneMode
        editMode = historyState.endEditMode
        animationEnabled = historyState.endAnimationEnabled
        animationMode = historyState.endAnimationMode
        altMenuBulgeBouncer = historyState.endAltMenuBulgeBouncer
        altMenuTwister = historyState.endAltMenuTwister
        altMenuRandom = historyState.endAltMenuRandom
        
        selectedBlob = blobAt(index: historyState.endSelectedBlobIndex)
        if selectedBlob !== nil {
            selectedBlob!.selectedControlPointIndex = historyState.endSelectedControlPointIndex
        }
    }
    
    //Save all the info necessary to make the screen look exactly like THIS again...
    func recordEngineState() -> RecordedEngineState {
        let state = RecordedEngineState()
        if blobs.count > 0 {
            state.blobStates.reserveCapacity(blobs.count)
            for blob in blobs {
                let blobState = blob.recordBlobState()
                state.blobStates.append(blobState)
            }
        }
        return state
    }
    
    //Restore the engine to the recorded state. This is useful for playback.
    func readEngineState(_ state: RecordedEngineState) {
        for i in 0..<state.blobStates.count {
            if let blob = blobAt(index: i) {
                blob.readBlobState(state.blobStates[i])
            }
        }
    }
    
    func save() -> [String:AnyObject] {
        
        var info = [String:AnyObject]()
        var blobData = [[String:AnyObject]]()
        for blob in blobs {
            blobData.append(blob.save())
        }
        
        info["blobs"] = blobData as AnyObject?
        info["animation_enabled"] = _animationEnabled as AnyObject?
        info["animation_power"] = Float(animationPower) as AnyObject?
        info["animation_speed"] = Float(animationSpeed) as AnyObject?
        
        var animationModeIndex: Int = 0
        if animationMode == .twist { animationModeIndex = 1 }
        if animationMode == .random { animationModeIndex = 2 }
        
        info["animation_mode"] = animationModeIndex as AnyObject?
        
        if animationBulgeBouncerPower != BlobMotionControllerBulgeBouncer.defaultAnimationPower {
            info["a_bb_power"] = animationBulgeBouncerPower as AnyObject?
        }
        if animationBulgeBouncerSpeed != BlobMotionControllerBulgeBouncer.defaultAnimationSpeed {
            info["a_bb_speed"] = animationBulgeBouncerSpeed as AnyObject?
        }
        if animationBulgeBouncerInflationStartFactor != BlobMotionControllerBulgeBouncer.defaultAnimationInflationStartFactor {
            info["a_bb_inflation_start_factor"] = animationBulgeBouncerInflationStartFactor as AnyObject?
        }
        if animationBulgeBouncerEllipseFactor != BlobMotionControllerBulgeBouncer.defaultAnimationEllipseFactor {
            info["a_bb_ellipse_factor"] = animationBulgeBouncerEllipseFactor as AnyObject?
        }
        if animationBulgeBouncerInflationFactor != BlobMotionControllerBulgeBouncer.defaultAnimationInflationFactor {
            info["a_bb_inflation_factor"] = animationBulgeBouncerInflationFactor as AnyObject?
        }
        if animationBulgeBouncerBounceFactor != BlobMotionControllerBulgeBouncer.defaultAnimationBounceFactor {
            info["a_bb_bounce_factor"] = animationBulgeBouncerBounceFactor as AnyObject?
        }
        if animationBulgeBouncerBounceEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationBounceEnabled {
            info["a_bb_bounce_enabled"] = animationBulgeBouncerBounceEnabled as AnyObject?
        }
        if animationBulgeBouncerReverseEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationReverseEnabled {
            info["a_bb_reverse_enabled"] = animationBulgeBouncerReverseEnabled as AnyObject?
        }
        if animationBulgeBouncerEllipseEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationEllipseEnabled {
            info["a_bb_ellipse_enabled"] = animationBulgeBouncerEllipseEnabled as AnyObject?
        }
        if animationBulgeBouncerAlternateEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationAlternateEnabled {
            info["a_bb_alternate_enabled"] = animationBulgeBouncerAlternateEnabled as AnyObject?
        }
        if animationBulgeBouncerTwistEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationTwistEnabled {
            info["a_bb_twist_enabled"] = animationBulgeBouncerTwistEnabled as AnyObject?
        }
        if animationBulgeBouncerInflateEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationInflateEnabled {
            info["a_bb_inflate_enabled"] = animationBulgeBouncerInflateEnabled as AnyObject?
        }
        if animationBulgeBouncerHorizontalEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationHorizontalEnabled {
            info["a_bb_horizontal_enabled"] = animationBulgeBouncerHorizontalEnabled as AnyObject?
        }
        if animationTwisterTwistSpeed != BlobMotionControllerTwister.defaultAnimationTwistSpeed {
            info["animation_twister_twist_speed"] = animationTwisterTwistSpeed as AnyObject?
        }
        if animationTwisterInflationFactor1 != BlobMotionControllerTwister.defaultAnimationInflationFactor1 {
            info["animation_twister_inflation_factor_1"] = animationTwisterInflationFactor1 as AnyObject?
        }
        if animationTwisterInflationFactor2 != BlobMotionControllerTwister.defaultAnimationInflationFactor2 {
            info["animation_twister_inflation_factor_2"] = animationTwisterInflationFactor2 as AnyObject?
        }
        if animationTwisterTwistPower != BlobMotionControllerTwister.defaultAnimationTwistPower {
            info["animation_twister_twist_power"] = animationTwisterTwistPower as AnyObject?
        }
        if animationTwisterReverseEnabled != BlobMotionControllerTwister.defaultAnimationReverseEnabled {
            info["animation_twister_reverse_enabled"] = animationTwisterReverseEnabled as AnyObject?
        }
        if animationTwisterEllipseEnabled != BlobMotionControllerTwister.defaultAnimationEllipseEnabled {
            info["animation_twister_ellipse_enabled"] = animationTwisterEllipseEnabled as AnyObject?
        }
        if animationTwisterAlternateEnabled != BlobMotionControllerTwister.defaultAnimationAlternateEnabled {
            info["animation_twister_alternate_enabled"] = animationTwisterAlternateEnabled as AnyObject?
        }
        if animationTwisterInflateEnabled != BlobMotionControllerTwister.defaultAnimationInflateEnabled {
            info["animation_twister_inflate_enabled"] = animationTwisterInflateEnabled as AnyObject?
        }
        if animationRandomPower != BlobMotionControllerCrazy.defaultAnimationPower {
            info["animation_random_power"] = animationRandomPower as AnyObject?
        }
        if animationRandomSpeed != BlobMotionControllerCrazy.defaultAnimationSpeed {
            info["animation_random_speed"] = animationRandomSpeed as AnyObject?
        }
        if animationRandomInflationFactor1 != BlobMotionControllerCrazy.defaultAnimationInflationFactor1 {
            info["animation_random_inflation_factor_1"] = animationRandomInflationFactor1 as AnyObject?
        }
        if animationRandomInflationFactor2 != BlobMotionControllerCrazy.defaultAnimationInflationFactor2 {
            info["animation_random_inflation_factor_2"] = animationRandomInflationFactor2 as AnyObject?
        }
        if animationRandomTwistFactor != BlobMotionControllerCrazy.defaultAnimationTwistFactor {
            info["animation_random_twist_factor"] = animationRandomTwistFactor as AnyObject?
        }
        if animationRandomRandomnessFactor != BlobMotionControllerCrazy.defaultAnimationRandomnessFactor {
            info["animation_random_randomness_factor"] = animationRandomRandomnessFactor as AnyObject?
        }
        if animationRandomReverseEnabled != BlobMotionControllerCrazy.defaultAnimationReverseEnabled {
            info["animation_random_reverse_enabled"] = animationRandomReverseEnabled as AnyObject?
        }
        if animationRandomEllipseEnabled != BlobMotionControllerCrazy.defaultAnimationEllipseEnabled {
            info["animation_random_ellipse_enabled"] = animationRandomEllipseEnabled as AnyObject?
        }
        if animationRandomAlternateEnabled != BlobMotionControllerCrazy.defaultAnimationAlternateEnabled {
            info["animation_random_alternate_enabled"] = animationRandomAlternateEnabled as AnyObject?
        }
        if animationRandomTwistEnabled != BlobMotionControllerCrazy.defaultAnimationTwistEnabled {
            info["animation_random_twist_enabled"] = animationRandomTwistEnabled as AnyObject?
        }
        if animationRandomInflateEnabled != BlobMotionControllerCrazy.defaultAnimationInflateEnabled {
            info["animation_random_inflate_enabled"] = animationRandomInflateEnabled as AnyObject?
        }
        if animationRandomHorizontalEnabled != BlobMotionControllerBulgeBouncer.defaultAnimationHorizontalEnabled {
            info["animation_random_horizontal_enabled"] = animationRandomHorizontalEnabled as AnyObject?
        }
        
        return info
    }
    
    func load(info: inout [String:AnyObject]) {
        
        deleteAllBlobs()
        
        if var blobData = info["blobs"] as? [[String:AnyObject]] {
            for i in 0..<blobData.count {
                let blob = Blob()
                blob.load(info: &(blobData[i]))
                blobs.append(blob)
            }
        }
        
        _animationEnabled = GoodParser.readBool(&info, "animation_enabled", _animationEnabled)
        
        animationPower = GoodParser.readFloat(&info, "animation_power", animationPower)
        
        rotation = GoodParser.readFloat(&info, "rotation", rotation)
        
        animationSpeed = GoodParser.readFloat(&info, "animation_speed", animationSpeed)
        
        let readAnimationModeIndex = GoodParser.readInt(&info, "animation_mode", 0)
            
            //info["animation_mode"] as? Int {
            
            if readAnimationModeIndex == 0 {
                animationMode = .bounce
            } else if readAnimationModeIndex == 1 {
                animationMode = .twist
            } else {
                animationMode = .random
            }
        //}
        
        
        animationBulgeBouncerPower = GoodParser.readFloat(&info, "a_bb_power", animationBulgeBouncerPower)
        animationBulgeBouncerSpeed = GoodParser.readFloat(&info, "a_bb_speed", animationBulgeBouncerSpeed)
        animationBulgeBouncerInflationStartFactor = GoodParser.readFloat(&info, "a_bb_inflation_start_factor", animationBulgeBouncerInflationStartFactor)
        animationBulgeBouncerEllipseFactor = GoodParser.readFloat(&info, "a_bb_ellipse_factor", animationBulgeBouncerEllipseFactor)
        
        
        animationBulgeBouncerInflationFactor = GoodParser.readFloat(&info, "a_bb_inflation_factor", animationBulgeBouncerInflationFactor)
        
        
        animationBulgeBouncerBounceFactor = GoodParser.readFloat(&info, "a_bb_bounce_factor", animationBulgeBouncerBounceFactor)
        
        
        animationBulgeBouncerBounceEnabled = GoodParser.readBool(&info, "a_bb_bounce_enabled", animationBulgeBouncerBounceEnabled)
        
        
        animationBulgeBouncerReverseEnabled = GoodParser.readBool(&info, "a_bb_reverse_enabled", animationBulgeBouncerReverseEnabled)
        
        
        animationBulgeBouncerEllipseEnabled = GoodParser.readBool(&info, "a_bb_ellipse_enabled", animationBulgeBouncerEllipseEnabled)
        
        animationBulgeBouncerAlternateEnabled = GoodParser.readBool(&info, "a_bb_alternate_enabled", animationBulgeBouncerAlternateEnabled)
        
        animationBulgeBouncerTwistEnabled = GoodParser.readBool(&info, "a_bb_twist_enabled", animationBulgeBouncerTwistEnabled)
        
        animationBulgeBouncerInflateEnabled = GoodParser.readBool(&info, "a_bb_inflate_enabled", animationBulgeBouncerInflateEnabled)
        
        
        animationBulgeBouncerHorizontalEnabled = GoodParser.readBool(&info, "a_bb_horizontal_enabled", animationBulgeBouncerHorizontalEnabled)
        
        animationTwisterTwistSpeed = GoodParser.readFloat(&info, "animation_twister_twist_speed", animationTwisterTwistSpeed)
        
        animationTwisterInflationFactor1 = GoodParser.readFloat(&info, "animation_twister_inflation_factor_1", animationTwisterInflationFactor1)
        
        animationTwisterInflationFactor2 = GoodParser.readFloat(&info, "animation_twister_inflation_factor_2", animationTwisterInflationFactor2)
        
        
        animationTwisterTwistPower = GoodParser.readFloat(&info, "animation_twister_twist_power", animationTwisterTwistPower)
        
        
        animationTwisterReverseEnabled = GoodParser.readBool(&info, "animation_twister_reverse_enabled", animationTwisterReverseEnabled)
        
        animationTwisterEllipseEnabled = GoodParser.readBool(&info, "animation_twister_ellipse_enabled", animationTwisterEllipseEnabled)
        
        animationTwisterAlternateEnabled = GoodParser.readBool(&info, "animation_twister_alternate_enabled", animationTwisterAlternateEnabled)
        
        animationTwisterInflateEnabled = GoodParser.readBool(&info, "animation_twister_inflate_enabled", animationTwisterInflateEnabled)
        
        animationRandomPower = GoodParser.readFloat(&info, "animation_random_power", animationRandomPower)
        
        animationRandomSpeed = GoodParser.readFloat(&info, "animation_random_speed", animationRandomSpeed)
        
        animationRandomInflationFactor1 = GoodParser.readFloat(&info, "animation_random_inflation_factor_1", animationRandomInflationFactor1)
        
        animationRandomInflationFactor2 = GoodParser.readFloat(&info, "animation_random_inflation_factor_2", animationRandomInflationFactor2)
        
        animationRandomTwistFactor = GoodParser.readFloat(&info, "animation_random_twist_factor", animationRandomTwistFactor)
        
        animationRandomRandomnessFactor = GoodParser.readFloat(&info, "animation_random_randomness_factor", animationRandomRandomnessFactor)
        
        animationRandomReverseEnabled = GoodParser.readBool(&info, "animation_random_reverse_enabled", animationRandomReverseEnabled)
        
        animationRandomEllipseEnabled = GoodParser.readBool(&info, "animation_random_ellipse_enabled", animationRandomEllipseEnabled)
        
        animationRandomAlternateEnabled = GoodParser.readBool(&info, "animation_random_alternate_enabled", animationRandomAlternateEnabled)
        
        animationRandomTwistEnabled = GoodParser.readBool(&info, "animation_random_twist_enabled", animationRandomTwistEnabled)
        
        animationRandomInflateEnabled = GoodParser.readBool(&info, "animation_random_inflate_enabled", animationRandomInflateEnabled)
        
        animationRandomHorizontalEnabled = GoodParser.readBool(&info, "animation_random_horizontal_enabled", animationRandomHorizontalEnabled)
        
        
        
    }
    
    func loadAdjust(loadScene: BounceScene, newScene: BounceScene) -> Void {
        
        //print("OriginalScreenSize=\(loadScene.screenSize.width)x\(loadScene.screenSize.height)")
        //print("OriginalImageSize=\(loadScene.imageSize.width)x\(loadScene.imageSize.height)")
        //print("OriginalImageFrame=[\(loadScene.imageFrame.origin.x),\(loadScene.imageFrame.origin.y)](\(loadScene.imageFrame.size.width)x\(loadScene.imageFrame.size.height))\n\n")
        
        //print("NewScreenSize=\(newScene.screenSize.width)x\(newScene.screenSize.height)")
        //print("NewImageSize=\(newScene.imageSize.width)x\(newScene.imageSize.height)")
        //print("NewImageFrame=[\(newScene.imageFrame.origin.x),\(newScene.imageFrame.origin.y)](\(newScene.imageFrame.size.width)x\(newScene.imageFrame.size.height))\n\n")
        
        for blob in blobs {
            blob.loadAdjust(loadScene: loadScene, newScene: newScene)
        }
    }
    
    
    func resetAll() {
        
        deleteAllBlobs()
        
        resetDefaultAnimationBulgeBouncerInternal()
        resetDefaultAnimationRandomInternal()
        resetDefaultAnimationTwisterInternal()
        
        _zoomEnabled = false
        activeMenu = .tools
        _animationEnabled = false
        animationMode = .bounce
        historyStack.removeAll()
        historyIndex = 0
        historyLastActionUndo = false
        historyLastActionRedo = false
        _stereoscopic = false
        stereoscopicHD = false
        _globalCrazyMotionControllerAnimationProgress = 0.0
        _globalCrazyMotionControllerAnimationLoopSpeed = 0.0
        _gyro = true
        _previousSelectedBlob = nil
        editShowEdgeFactor = false
        editShowCenterWeight = true
        _altMenuBulgeBouncer = 0
        _altMenuTwister = 0
        _altMenuRandom = 0
        
        animationPower = 0.33
        animationSpeed = 0.75
        
        editMode = .affine
        sceneMode = .edit
    }
}


//
//  BounceViewController.swift
//
//  Created by Nicholas Raptis on 8/7/16.
//

import UIKit
import GLKit
import OpenGLES

class BounceViewController : GLViewController, UIGestureRecognizerDelegate//, URLSessionDelegate
{
    @IBOutlet weak var bounceView: BounceView!
    
    @IBOutlet weak var buttonShowHideAll:RRButton!
    
    //If we loaded from the web, we have a web scene model..
    private var sceneModel: WebSceneModel?
    
    
    var videoRecorder: VideoRecorder?
    var audioRecorder: AudioRecorder?
    
    var recordedEngineStates = [RecordedEngineState]()
    
    var exportFinished: Bool = false
    
    private var exportFrame: Int = 0
    
    var exportReadyForPhotoLibrary: Bool = false
    
    private var _isExporting:Bool = false
    var isExporting:Bool {
        get {
            return _isExporting
        }
        set {
            if newValue != _isExporting {
                _isExporting = newValue
            }
        }
    }
    
    var exportError: Bool = false
    
    private var _isRecording:Bool = false
    var isRecording:Bool {
        get {
            return _isRecording
        }
        set {
            if newValue != _isRecording {
                _isRecording = newValue
                //BounceEngine.postNotification(BounceNotification.recordEnabledChanged)
            }
        }
    }
    
    private var _timelineEnabled:Bool = false
    var timelineEnabled:Bool {
        get {
            return _timelineEnabled
        }
        set {
            if newValue != _timelineEnabled {
                _timelineEnabled = newValue
                BounceEngine.postNotification(BounceNotification.timelineEnabledChanged)
            }
        }
    }
    
    //The actual timeline position. This is in
    //"ticks" e.g. 1 frame per increment, exactly.
    var timelineFrame: Int = 0
    
    //timelineFrame will always be between these two values.
    var timelineHandleStartFrame: Int = 0
    var timelineHandleEndFrame: Int = ApplicationController.shared.minTimelineFrameSpan
    
    //Mutual Exclusion: Timeline dragging and timeline playing.
    //var : Bool = true
    private var _timelinePlaying:Bool = false
    var timelinePlaying:Bool {
        get {
            return _timelinePlaying
        }
        set {
            if newValue != _timelinePlaying {
                _timelinePlaying = newValue
                BounceEngine.postNotification(BounceNotification.timelinePlaybackEnabledChanged)
            }
        }
    }
    
    var timelineDraggingHandle: Bool = false
    var timelineDraggingLeftHandle: Bool = true
    
    var timelineDraggingThumb: Bool = false
    
    var timelineShouldResumeAfterDrag: Bool = true
    
    var expandToolbarButtonTop: ExpandToolbarButton!
    var expandToolbarButtonBottom: ExpandToolbarButton!
    
    
    var bottomMenu: BottomMenu!
    var topMenu: TopMenu!
    
    var bottomMenuRecord: RecordBottomMenu!
    
    var bottomMenuTimeline: TimelineBottomMenu!
    var topMenuTimeline: TimelineTopMenu!
    
    var bottomMenuExport: ExportBottomMenu!
    
    @IBOutlet weak var mainContainer:UIView! {
        didSet {
            mainContainer.isMultipleTouchEnabled = true
        }
    }
    @IBOutlet weak var mainContainerLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuContainer:BounceSideMenuContainer!
    
    let engine = BounceEngine()
    
    @IBOutlet weak var sideMenu: BounceSideMenu!
    
    var isShowingSideMenu: Bool = false
    var isAnimatingSideMenu: Bool = false
    
    func showSideMenu() {
        if isShowingSideMenu == false {
            isAnimatingSideMenu = true
            isShowingSideMenu = true
            freeze()
        }
    }
    
    func hideSideMenu(completion:(() -> Swift.Void)?) {
        if isShowingSideMenu == true {
            
            isAnimatingSideMenu = true
            
            var safeAreaLeft = Device.safeAreaInsetLeftPortrait
            if ApplicationController.shared.isSceneLandscape {
                safeAreaLeft = Device.safeAreaInsetLeftLandscape
            }
            
            let sideWidth = sideMenu.widthConstraint.constant
            
            sideMenu.leftConstraint.constant = -(sideWidth + safeAreaLeft)
            sideMenuContainer.setNeedsUpdateConstraints()
            
            ApplicationController.shared.addActionBlocker(name: "hide_side_menu")
            
            var sideMenuTransform = CATransform3DIdentity
            sideMenuTransform = CATransform3DScale(sideMenuTransform, 0.666, 0.666, 0.666)
            
            UIView.animate(withDuration: 0.52, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations:
                {
                    self.sideMenuContainer.layer.transform = sideMenuTransform
                    let transform = CATransform3DIdentity
                    self.mainContainer.layer.transform = transform
                    self.view.layoutIfNeeded()
            }, completion:
                { (finished:Bool) in
                    self.unfreeze()
                    self.isShowingSideMenu = false
                    self.isAnimatingSideMenu = false
                    self.sideMenuContainer.isHidden = true
                    ApplicationController.shared.removeActionBlocker(name: "hide_side_menu")
                    
                    DispatchQueue.main.async {
                        completion?()
                    }
            })
        }
    }
    
    
    var isFreezeEnqueued = false
    var isUnfreezeEnqueued = false
    var isFrozen = false
    var freezeOverlayImageView:UIImageView?
    
    //Freeze happens on the next draw, screen is converted into an image...
    func freeze() {
        if isFrozen == false {
            isFreezeEnqueued = true
        }
    }
    
    func freezeRealize(withImage freezeImage: UIImage) {
        
        cancelAllGesturesAndTouches()
        
        isFreezeEnqueued = false
        isFrozen = true
        
        if freezeOverlayImageView == nil {
            
            freezeOverlayImageView = UIImageView(frame: CGRect.zero)
            freezeOverlayImageView!.isOpaque = true
            
            mainContainer.insertSubview(freezeOverlayImageView!, at: 0)
            
            //view.addSubview(freezeOverlayImageView!)
            
            freezeOverlayImageView!.translatesAutoresizingMaskIntoConstraints = false
            let constraintLeft = NSLayoutConstraint(item: freezeOverlayImageView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
            let constraintRight = NSLayoutConstraint(item: freezeOverlayImageView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            let constraintTop = NSLayoutConstraint(item: freezeOverlayImageView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
            let constraintBottom = NSLayoutConstraint(item: freezeOverlayImageView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            
            view.addConstraints([constraintLeft, constraintRight, constraintTop, constraintBottom])
            view.setNeedsUpdateConstraints()
        }
        freezeOverlayImageView!.image = freezeImage
        
        mainContainer.setNeedsLayout()
        mainContainer.layoutIfNeeded()
        
        
        //Is this for the side menu?
        if true {
            sideMenuContainer.isHidden = false
            
            var safeAreaLeft = Device.safeAreaInsetLeftPortrait
            if ApplicationController.shared.isSceneLandscape {
                safeAreaLeft = Device.safeAreaInsetLeftLandscape
            }
            
            let sideWidth = sideMenu.widthConstraint.constant
            
            sideMenu.leftConstraint.constant = -(sideWidth + safeAreaLeft)// * (1 / 0.72)
            sideMenuContainer.setNeedsUpdateConstraints()
            sideMenuContainer.layoutIfNeeded()
            
            ApplicationController.shared.addActionBlocker(name: "screen_freeze")
            sideMenu.leftConstraint.constant = safeAreaLeft
            sideMenuContainer.setNeedsUpdateConstraints()
            
            var sideMenuTransform = CATransform3DIdentity
            sideMenuTransform = CATransform3DScale(sideMenuTransform, 0.72, 0.72, 0.72)
            sideMenuContainer.layer.transform = sideMenuTransform
            
            UIView.animate(withDuration: 0.52, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations:
                {
                    self.sideMenuContainer.layer.transform = CATransform3DIdentity
                    self.sideMenuContainer.layoutIfNeeded()
                    
                    var transform = CATransform3DIdentity
                    transform = CATransform3DScale(transform, 0.835, 0.835, 0.835)
                    transform = CATransform3DTranslate(transform, sideWidth + safeAreaLeft, 0.0, 0.0)
                    self.mainContainer.layer.transform = transform
                    
            }, completion:
                { (finished:Bool) in
                    self.isAnimatingSideMenu = false
                    ApplicationController.shared.removeActionBlocker(name: "screen_freeze")
                    self.saveRecentScene()
            })
        }
    }
    
    func unfreeze() {
        isPaused = false
        if isFrozen == true {
            isFrozen = false
            isUnfreezeEnqueued = true
        }
    }
    
    func unfreezeRealize() {
        isUnfreezeEnqueued = false
        if freezeOverlayImageView != nil {
            freezeOverlayImageView!.removeFromSuperview()
            freezeOverlayImageView!.image = nil
            freezeOverlayImageView = nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //Make sure global reference is ready for setup.
        ApplicationController.shared.bounce = self
    }
    
    deinit {
        ApplicationController.shared.bounce = nil
        print("Deinit: BounceViewController")
        
    }
    
    class var shared: BounceViewController? {
        return ApplicationController.shared.bounce
    }
    
    var isAnyGestureRecognizerActive: Bool = false
    
    var panRecognizer:UIPanGestureRecognizer!
    var pinchRecognizer:UIPinchGestureRecognizer!
    var rotRecognizer:UIRotationGestureRecognizer!
    var doubleTapRecognizer:UITapGestureRecognizer!
    
    var controlPoint = Sprite()
    var controlPointActive = Sprite()
    var controlPointUnderlay = Sprite()
    
    
    var controlPointSelected = Sprite()
    var controlPointActiveSelected = Sprite()
    var controlPointSelectedUnderlay = Sprite()
    
    //var centerMarker = Sprite()
    //var centerMarkerSelected = Sprite()
    
    
    var bulgeMarkerCenter = Sprite()
    var bulgeMarkerCenterSelected = Sprite()
    
    var bulgeMarkerSpinner = Sprite()
    var bulgeMarkerSpinnerSelected = Sprite()
    
    var bulgeMarkerOutline = Sprite()
    
    var panRecognizerTouchCount:Int = 0
    var pinchRecognizerTouchCount:Int = 0
    var rotRecognizerTouchCount:Int = 0
    
    var zoomGestureCancelTimer:Int = 0
    
    var gestureTouchCenter:CGPoint = CGPoint.zero
    var gestureTouchCenterPrevious:CGPoint = CGPoint.zero
    
    var touchCancelTimer:Int = 0
    
    private var previousScreenTranslation:CGPoint = CGPoint.zero
    var screenTranslation:CGPoint = CGPoint.zero {
        willSet {
            previousScreenTranslation = screenTranslation
        }
        didSet {
            if previousScreenTranslation.x != screenTranslation.x || screenTranslation.y != screenTranslation.y {
                BounceEngine.postNotification(BounceNotification.zoomScaleChanged)
            }
        }
    }
    
    private var previousScreenScale:CGFloat = 1.0
    var screenScale:CGFloat = 1.0 {
        willSet {
            previousScreenScale = screenScale
        }
        didSet {
            if previousScreenScale != screenScale {
                BounceEngine.postNotification(BounceNotification.zoomScaleChanged)
            }
        }
    }
    
    var screenEditTranslation:CGPoint = CGPoint(x:0.0, y:0.0)
    var screenEditScale:CGFloat = 1.0
    
    var screenAnimStartTranslation:CGPoint = CGPoint(x:0.0, y:0.0)
    var screenAnimStartScale:CGFloat = 1.0
    
    var screenAnimEndTranslation:CGPoint = CGPoint(x:0.0, y:0.0)
    var screenAnimEndScale:CGFloat = 1.0
    
    var screenAnim:Bool = false
    var screenAnimTick:Int = 0
    var screenAnimTime:Int = 34
    
    var gestureStartTranslate:CGPoint = CGPoint.zero
    var gestureStartScale:CGFloat = 1.0
    
    var gestureStartScreenTouch:CGPoint = CGPoint.zero
    var gestureStartImageTouch:CGPoint = CGPoint.zero
    
    var appFrame:CGRect {
        if ApplicationController.shared.isSceneLandscape {
            return CGRect(x: 0.0, y: 0.0, width: Device.landscapeWidth, height: Device.landscapeHeight)
        } else {
            return CGRect(x: 0.0, y: 0.0, width: Device.portraitWidth, height: Device.portraitHeight)
        }
    }
    
    var screenCenter: CGPoint {
        let fr = appFrame
        let center = CGPoint(x: fr.size.width / 2.0, y: fr.size.height / 2.0)
        return untransformPoint(center)
    }
    
    var screenFrame:CGRect {
        let sc = screenCenter
        let fr = appFrame
        let width = fr.size.width / screenScale
        let height = fr.size.height / screenScale
        return CGRect(x: sc.x - width / 2.0, y: sc.y - height / 2.0, width: width, height: height)
    }
    
    
    
    func setUpNew(image:UIImage, sceneRect:CGRect, portraitOrientation:Bool) {
        
        
        print("Set Up New Scene Port: \(portraitOrientation) [\(sceneRect.origin.x), \(sceneRect.origin.y) [\(sceneRect.size.width) x \(sceneRect.size.height)]]")
        
        let scene = BounceScene()
        
        let thumb = ApplicationController.shared.getThumb(image: image)
        
        //OLD: Instead, copy this image over on
        _ = FileUtils.saveImagePNG(image: image, filePath: ApplicationController.shared.recentImagePath)
        _ = FileUtils.saveImagePNG(image: thumb, filePath: ApplicationController.shared.recentThumbPath)
        
        //We delete this file...
        FileUtils.deleteFile(ApplicationController.shared.recentScenePath)
        
        scene.image = image
        //scene.size = sceneRect.size
        scene.isLandscape = !portraitOrientation
        
        print("scene.isLandscape = \(scene.isLandscape)")
        
        setUp(scene: scene, appFrame: appFrame)
        engine.setUpComplete()
        
        //New scene prompts for saving.
        engine.shouldPromptForSave = true
        
        engine.addBlob()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.saveRecentScene()
        }
        
    }
    
    func setUpTestScene(image:UIImage) {
        let thumb = ApplicationController.shared.getThumb(image: image)
        _ = FileUtils.saveImagePNG(image: image, filePath: ApplicationController.shared.recentImagePath)
        _ = FileUtils.saveImagePNG(image: thumb, filePath: ApplicationController.shared.recentThumbPath)
    }
    
    internal func setUp(scene:BounceScene, appFrame:CGRect) {
        
        
        if Thread.isMainThread == false {
            DispatchQueue.main.sync {
                self.setUp(scene: scene, appFrame: appFrame)
            }
            return
        }
        
        Config.shared.recordDidPerformFirstInterstitialAction()
        
        engine.scene.isLandscape = scene.isLandscape
        
        var safeAreaTop = Device.safeAreaInsetTopPortrait
        var safeAreaRight = Device.safeAreaInsetRightPortrait
        var safeAreaBottom = Device.safeAreaInsetBottomPortrait
        var safeAreaLeft = Device.safeAreaInsetLeftPortrait
        if scene.isLandscape {
            safeAreaTop = Device.safeAreaInsetTopLandscape
            safeAreaRight = Device.safeAreaInsetRightLandscape
            safeAreaBottom = Device.safeAreaInsetBottomLandscape
            safeAreaLeft = Device.safeAreaInsetLeftLandscape
        }
        
        
        autoreleasepool {
            engine.setUp(scene: scene)
            scene.image = nil
        }
        
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            if scene.isLandscape == false {
                Device.orientation = .portrait
            }
        } else {
            if scene.isLandscape {
                Device.orientation = .landscapeLeft
            }
        }
        
        
        //bottomMenu.setUp()
        //topMenu.setUp()
        
        //videoMenu.setUp()
        //videoMenu.isHidden = true
        
        //timelineMenu.setUp()
        //timelineMenu.isHidden = true
        
        sideMenuContainer.setUp()
        sideMenuContainer.isHidden = true
        
        //view.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        
        
        var expandButtonInset: CGFloat = 4.0
        if Device.isTablet { expandButtonInset = 6.0 }
        
        var expandButtonWidth: CGFloat = 84.0
        var expandButtonHeight: CGFloat = 64.0
        
        if Device.isTablet {
            expandButtonWidth = 96.0
            expandButtonHeight = 74.0
        }
        
        let buttonDragMinX: CGFloat = expandButtonInset + safeAreaLeft
        let buttonDragMaxX: CGFloat = appFrame.size.width - (safeAreaRight + expandButtonWidth + expandButtonInset)
        
        var expandButtonBuffer: CGFloat = -4.0
        if Device.isTablet { expandButtonBuffer = -6.0 }
        
        expandToolbarButtonTop = ExpandToolbarButton(frame: CGRect(x: buttonDragMaxX, y: safeAreaTop, width: expandButtonWidth, height: expandButtonHeight))
        mainContainer.addSubview(expandToolbarButtonTop)
        expandToolbarButtonTop.setUp(top: true)
        expandToolbarButtonTop.addTarget(self, action: #selector(clickExpandTop(button:)), for: .touchUpInside)
        expandToolbarButtonTop.isHidden = true
        expandToolbarButtonTop.alpha = 0.0
        expandToolbarButtonTop.dragMinX = buttonDragMinX
        expandToolbarButtonTop.dragMaxX = buttonDragMaxX
        expandToolbarButtonTop.isAtTopOfScreen = true
        
        expandToolbarButtonBottom = ExpandToolbarButton(frame: CGRect(x: buttonDragMaxX, y: appFrame.height - (safeAreaBottom + expandButtonHeight), width: expandButtonWidth, height: expandButtonHeight))
        mainContainer.addSubview(expandToolbarButtonBottom)
        expandToolbarButtonBottom.setUp(top: false)
        expandToolbarButtonBottom.addTarget(self, action: #selector(clickExpandBottom(button:)), for: .touchUpInside)
        expandToolbarButtonBottom.isHidden = true
        expandToolbarButtonBottom.alpha = 0.0
        expandToolbarButtonBottom.dragMinX = buttonDragMinX
        expandToolbarButtonBottom.dragMaxX = buttonDragMaxX
        expandToolbarButtonBottom.isAtTopOfScreen = false
        
        bottomMenu = BottomMenu(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 40.0))
        topMenu = TopMenu(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 40.0))
        
        bottomMenuTimeline = TimelineBottomMenu(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 40.0))
        topMenuTimeline = TimelineTopMenu(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 40.0))
        
        bottomMenuRecord = RecordBottomMenu(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 40.0))
        bottomMenuExport = ExportBottomMenu(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 40.0))
        
        mainContainer.addSubview(bottomMenu)
        mainContainer.addSubview(topMenu)
        
        mainContainer.addSubview(bottomMenuTimeline)
        mainContainer.addSubview(topMenuTimeline)
        
        mainContainer.addSubview(bottomMenuRecord)
        
        mainContainer.addSubview(bottomMenuExport)
        
        
        
        if engine.scene.isLandscape {
            
            bottomMenu.setUp(parentFrame: appFrame, top: false, rowCount: 2, landscape: scene.isLandscape)
            topMenu.setUp(parentFrame: appFrame, top: true, rowCount: 2, landscape: scene.isLandscape)
            
            bottomMenuRecord.setUp(parentFrame: appFrame, top: false, rowCount: 1, landscape: scene.isLandscape)
            
            bottomMenuTimeline.setUp(parentFrame: appFrame, top: false, rowCount: 1, landscape: scene.isLandscape)
            topMenuTimeline.setUp(parentFrame: appFrame, top: true, rowCount: 1, landscape: scene.isLandscape)
            
        } else {
            
            bottomMenu.setUp(parentFrame: appFrame, top: false, rowCount: 3, landscape: scene.isLandscape)
            topMenu.setUp(parentFrame: appFrame, top: true, rowCount: 3, landscape: scene.isLandscape)
            
            bottomMenuRecord.setUp(parentFrame: appFrame, top: false, rowCount: 1, landscape: scene.isLandscape)
            
            bottomMenuTimeline.setUp(parentFrame: appFrame, top: false, rowCount: 1, landscape: scene.isLandscape)
            topMenuTimeline.setUp(parentFrame: appFrame, top: true, rowCount: 2, landscape: scene.isLandscape)
            
        }
        
        bottomMenuExport.setUp(parentFrame: appFrame, top: false, rowCount: 1, landscape: scene.isLandscape)
        
        bottomMenuRecord.hide()
        bottomMenuTimeline.hide()
        topMenuTimeline.hide()
        bottomMenuExport.hide()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleZoomEnabledChanged),
                       name: NSNotification.Name(BounceNotification.zoomEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleSceneModeChanged),
                       name: NSNotification.Name(BounceNotification.sceneModeChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleEditModeChanged),
                       name: NSNotification.Name(BounceNotification.editModeChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationEnabledChanged),
                       name: NSNotification.Name(BounceNotification.animationEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationModeChanged),
                       name: NSNotification.Name(BounceNotification.animationModeChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationAlternationEnabledChanged),
                       name: NSNotification.Name(BounceNotification.animationAlternationEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationBounceEnabledChanged),
                       name: NSNotification.Name(BounceNotification.animationBounceEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationReverseEnabledChanged),
                       name: NSNotification.Name(BounceNotification.animationReverseEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationEllipseEnabledChanged),
                       name: NSNotification.Name(BounceNotification.animationEllipseEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationInflateEnabledChanged),
                       name: NSNotification.Name(BounceNotification.animationInflateEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationHorizontalEnabledChanged),
                       name: NSNotification.Name(BounceNotification.animationHorizontalEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleAnimationTwistEnabledChanged),
                       name: NSNotification.Name(BounceNotification.animationTwistEnabledChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleBlobSelectionChanged),
                       name: NSNotification.Name(BounceNotification.blobSelectionChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleBlobCountChanged),
                       name: NSNotification.Name(BounceNotification.blobCountChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleBlobAdded),
                       name: NSNotification.Name(BounceNotification.blobAdded.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleHistoryChanged),
                       name: NSNotification.Name(BounceNotification.historyChanged.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(handleStackOrderChanged),
                       name: NSNotification.Name(BounceNotification.blobStackOrderChanged.rawValue), object: nil)
        
        
        nc.addObserver(self, selector: #selector(handleExportError),
                       name: NSNotification.Name(BounceNotification.videoExportError.rawValue), object: nil)
        
        nc.addObserver(self, selector: #selector(handleExportComplete),
                       name: NSNotification.Name(BounceNotification.videoExportComplete.rawValue), object: nil)
        
        nc.addObserver(self, selector: #selector(handleTimelinePlaybackEnabledChanged),
                       name: NSNotification.Name(BounceNotification.timelinePlaybackEnabledChanged.rawValue), object: nil)
        
        nc.addObserver(self, selector: #selector(handleTimelinePlaybackRestart),
                       name: NSNotification.Name(BounceNotification.timelinePlaybackRestart.rawValue), object: nil)
        
        nc.addObserver(self, selector: #selector(handleSceneUploadComplete),
                       name: NSNotification.Name(UploadSceneNotification.uploadComplete.rawValue), object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if engine.scene.isLandscape {
            return [.landscapeRight, .landscapeLeft]
        } else {
            return [.portrait, .portraitUpsideDown]
        }
    }
    
    /*
     override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
     if engine.scene.isLandscape {
     return UIInterfaceOrientation.landscapeLeft
     } else {
     return UIInterfaceOrientation.portrait
     }
     }
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
        //    BounceEngine.postNotification(BounceNotification.sceneReady)
        //}
        
        
        view.bringSubview(toFront: sideMenuContainer)
        sideMenuContainer.layer.zPosition = -512.0
        sideMenuContainer.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        saveRecentScene()
        AppDelegate.root.removeUpdateObject(sideMenuContainer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.root.addUpdateObject(sideMenuContainer)
        Device.setStatusBarLight()
    }
    
    override func load() {
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        panRecognizer.delegate = self
        panRecognizer.maximumNumberOfTouches = 2
        panRecognizer.cancelsTouchesInView = false
        panRecognizer.delaysTouchesEnded = false
        mainContainer.addGestureRecognizer(panRecognizer)
        
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        pinchRecognizer.delegate = self
        pinchRecognizer.cancelsTouchesInView = false
        pinchRecognizer.delaysTouchesEnded = false
        mainContainer.addGestureRecognizer(pinchRecognizer)
        
        rotRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        rotRecognizer.delegate = self
        rotRecognizer.cancelsTouchesInView = false
        rotRecognizer.delaysTouchesEnded = false
        mainContainer.addGestureRecognizer(rotRecognizer)
        
        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
        doubleTapRecognizer.delegate = self
        doubleTapRecognizer.cancelsTouchesInView = false
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesEnded = false
        mainContainer.addGestureRecognizer(doubleTapRecognizer)
        
        controlPoint.load(path: "control_point")
        controlPointActive.load(path: "control_point_active")
        controlPointUnderlay.load(path: "control_point_underlay")
        
        controlPointSelected.load(path: "control_point_selected")
        controlPointActiveSelected.load(path: "control_point_active_selected")
        controlPointSelectedUnderlay.load(path: "control_point_underlay_selected")
        
        
        
        //centerMarker.load(path: "center_marker")
        //centerMarkerSelected.load(path: "center_marker_selected")
        
        bulgeMarkerCenter.load(path: "bulge_marker_center")
        bulgeMarkerCenterSelected.load(path: "bulge_marker_center_selected")
        
        bulgeMarkerSpinner.load(path: "bulge_marker_spinner")
        bulgeMarkerSpinnerSelected.load(path: "bulge_marker_spinner_selected")
        
        bulgeMarkerOutline.load(path: "bulge_marker_outline")
        
        
        
        
        
        
        
        
        
        
        
        
        
        //centerMarker.load(path: "AppIcon")
        //centerMarkerSelected.load(path: "AppIcon")
        
    }
    
    override func update() {
        
        if touchCancelTimer > 0 {
            touchCancelTimer -= 1
            if touchCancelTimer <= 0 {
                touchCancelTimer = 0
            }
        }
        
        if zoomGestureCancelTimer > 0 {
            zoomGestureCancelTimer = zoomGestureCancelTimer - 1
            if zoomGestureCancelTimer <= 0 {
                panRecognizer.isEnabled = true
                pinchRecognizer.isEnabled = true
                rotRecognizer.isEnabled = true
            }
        }
        
        if isFrozen || isFreezeEnqueued || isAnimatingSideMenu || isShowingSideMenu {
            cancelAllGesturesAndTouches()
            return
        }
        
        //recordedEngineStates
        
        if isRecording {
            let state = engine.recordEngineState()
            recordedEngineStates.append(state)
            engine.update()
        } else if isExporting {
            
            //
            
            if exportFrame >= 0 && exportFrame < recordedEngineStates.count {
                let state = recordedEngineStates[exportFrame]
                engine.readEngineState(state)
            }
            
        } else if timelineEnabled {
            if timelinePlaying {
                timelineFrame += 1
                if timelineFrame > timelineHandleEndFrame {
                    timelineFrame = timelineHandleStartFrame
                    BounceEngine.postNotification(BounceNotification.timelinePlaybackRestart)
                }
                BounceEngine.postNotification(BounceNotification.timelineFrameChanged)
            }
            
            var displayFrame = timelineFrame
            
            if timelineDraggingHandle {
                if timelineDraggingLeftHandle == true {
                    displayFrame = timelineHandleStartFrame
                } else {
                    displayFrame = timelineHandleEndFrame
                    //timelineHandleStartFrame
                }
            }
            
            if displayFrame >= 0 && displayFrame < recordedEngineStates.count {
                let state = recordedEngineStates[displayFrame]
                engine.readEngineState(state)
            }
            
            //Do cool stuff.
            
        } else {
            engine.update()
        }
        
        expandToolbarButtonTop.update()
        expandToolbarButtonBottom.update()
        
        if screenAnim {
            screenAnimTick += 1
            if screenAnimTick >= screenAnimTime {
                screenTranslation = CGPoint(x: screenAnimEndTranslation.x, y: screenAnimEndTranslation.y)
                screenScale = screenAnimEndScale
                screenAnim = false
                ApplicationController.shared.removeActionBlocker(name: "side_menu_main_screen_animation")
            } else {
                var percent = CGFloat(screenAnimTick) / CGFloat(screenAnimTime)
                percent = sin(percent * Math.PI_2)
                
                let newX: CGFloat = screenAnimStartTranslation.x + (screenAnimEndTranslation.x - screenAnimStartTranslation.x) * percent
                
                let newY: CGFloat = screenAnimStartTranslation.y + (screenAnimEndTranslation.y - screenAnimStartTranslation.y) * percent
                
                
                screenTranslation = CGPoint(x: newX, y: newY)
                
                //screenTranslation.x = screenAnimStartTranslation.x + (screenAnimEndTranslation.x - screenAnimStartTranslation.x) * percent
                //screenTranslation.y =
                screenScale = screenAnimStartScale + (screenAnimEndScale - screenAnimStartScale) * percent
            }
        }
        
        if sideMenuContainer.isHidden == false {
            sideMenu.update()
        }
        
        if engine.activeMenu == .tools {
            bottomMenu.update()
            topMenu.update()
        } else if engine.activeMenu == .record {
            bottomMenuRecord.update()
        } else if engine.activeMenu == .timeline {
            bottomMenuTimeline.update()
            topMenuTimeline.update()
        } else if engine.activeMenu == .export {
            bottomMenuExport.update()
        }
        
    }
    
    override func draw() {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        let screenMat = Matrix.createOrtho(left: 0.0, right: Float(width), bottom: Float(height), top: 0.0, nearZ: -2048, farZ: 2048)
        Graphics.viewport(CGRect(x: 0.0, y: 0.0, width: appFrame.size.width * view.contentScaleFactor, height: appFrame.size.height * view.contentScaleFactor))
        Graphics.clip(clipRect: CGRect(x: 0.0, y: 0.0, width: appFrame.size.width * view.contentScaleFactor, height: appFrame.size.height * view.contentScaleFactor))
        
        ShaderProgramMesh.shared.use()
        ShaderProgramMesh.shared.matrixProjectionSet(screenMat)
        
        ShaderProgramSimple.shared.use()
        ShaderProgramSimple.shared.matrixProjectionSet(screenMat)
        
        ShaderProgramSprite.shared.use()
        ShaderProgramSprite.shared.matrixProjectionSet(screenMat)
        
        Graphics.clear(r: 0.09, g: 0.09, b: 0.11)
        
        if isFrozen == false {
            
            let viewMat = screenMat.clone()
            viewMat.translate(GLfloat(screenTranslation.x), GLfloat(screenTranslation.y), 0.0)
            viewMat.scale(Float(screenScale))
            
            ShaderProgramSimple.shared.use()
            ShaderProgramSimple.shared.matrixProjectionSet(viewMat)
            
            ShaderProgramSprite.shared.use()
            ShaderProgramSprite.shared.matrixProjectionSet(viewMat)
            
            ShaderProgramMesh.shared.use()
            ShaderProgramMesh.shared.matrixProjectionSet(viewMat)
            
            
            ShaderProgramMesh.shared.colorSet(r: 1.0, g: 1.0, b: 1.0, a: 1.0)
            Graphics.textureEnable()
            engine.draw()
        }
        
        if isFrozen {
            isPaused = true
        }
    }
    
    @objc func handleZoomEnabledChanged() {
        engine.handleZoomEnabledChanged()
        cancelAllGesturesAndTouches()
    }
    
    @objc func handleSceneModeChanged() {
        engine.handleSceneModeChanged()
        cancelAllGesturesAndTouches()
        saveRecentScene()
    }
    
    @objc func handleEditModeChanged() {
        engine.handleEditModeChanged()
        cancelAllGesturesAndTouches()
        saveRecentScene()
    }
    
    @objc func handleAnimationEnabledChanged() {
        engine.handleAnimationEnabledChanged()
        cancelAllGesturesAndTouches()
        saveRecentScene()
    }
    
    @objc func handleAnimationModeChanged() {
        engine.handleAnimationModeChanged()
        cancelAllGesturesAndTouches()
        saveRecentScene()
    }
    
    @objc func handleAnimationAlternationEnabledChanged() {
        engine.handleAnimationAlternationEnabledChanged()
        cancelAllGesturesAndTouches()
    }
    
    @objc func handleAnimationBounceEnabledChanged() {
        engine.handleAnimationBounceEnabledChanged()
        cancelAllGesturesAndTouches()
    }
    
    @objc func handleAnimationReverseEnabledChanged() {
        engine.handleAnimationReverseEnabledChanged()
        cancelAllGesturesAndTouches()
    }
    
    @objc func handleAnimationTwistEnabledChanged() {
        engine.handleAnimationTwistEnabledChanged()
        cancelAllGesturesAndTouches()
    }
    
    @objc func handleAnimationEllipseEnabledChanged() {
        engine.handleAnimationEllipseEnabledChanged()
        cancelAllGesturesAndTouches()
    }
    
    @objc func handleAnimationInflateEnabledChanged() {
        engine.handleAnimationInflateEnabledChanged()
        cancelAllGesturesAndTouches()
    }
    
    @objc func handleAnimationHorizontalEnabledChanged() {
        engine.handleAnimationHorizontalEnabledChanged()
        cancelAllGesturesAndTouches()
    }
    
    /*
     @objc func handleAnimationAlternationChanged() {
     engine.handleAnimationAlternationChanged()
     cancelAllGesturesAndTouches()
     }
     
     @objc func handleAnimationBounceChanged() {
     engine.handleAnimationBounceChanged()
     cancelAllGesturesAndTouches()
     }
     
     @objc func handleAnimationReverseChanged() {
     engine.handleAnimationReverseChanged()
     cancelAllGesturesAndTouches()
     }
     
     */
    
    @objc func handleBlobAdded() {
        cancelAllGesturesAndTouches()
    }
    
    @objc func handleBlobSelectionChanged() {
        
    }
    
    @objc func handleBlobCountChanged() {
        
    }
    
    @objc func handleHistoryChanged() {
        engine.handleHistoryChanged()
        cancelAllGesturesAndTouches()
        saveRecentScene()
    }
    
    @objc func handleStackOrderChanged() {
        engine.handleStackOrderChanged()
        cancelAllGesturesAndTouches()
        saveRecentScene()
    }
    
    @objc func handleExportError() {
        exportCancel()
    }
    
    @objc func handleExportComplete() {
        
        print("handleExportComplete()")
        
        timelineStop()
        recordClear()
        
        exportReadyForPhotoLibrary = false
        isExporting = false
        exportFrame = 0
        
        //ToolActions.setActiveMenusTools()
        
        let alert = UIAlertController(title: "Success!", message: "Your movie file has been saved to your photo library!", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "Okay", style: .default) { (action: UIAlertAction) in }
        alert.addAction(actionOK)
        ApplicationController.shared.root.present(alert, animated: true, completion: nil)
    }
    
    
    
    @objc func handleTimelinePlaybackEnabledChanged() {
        
        print("handleTimelinePlaybackEnabledChanged()")
        
        if timelinePlaying {
            audioRecorder?.playStart()
        } else {
            audioRecorder?.playPause()
        }
    }
    
    @objc func handleTimelinePlaybackRestart() {
        print("handleTimelinePlaybackRestart()")
        audioRecorder?.playStart()
    }
    
    @objc func handleSceneUploadComplete() {
        print("handleSceneUploadComplete()")
        engine.scene.isWebScene = true
        saveRecentScene()
    }
    
    func cancelAllGesturesAndTouches() {
        touchCancelTimer = 3
        cancelAllGestureRecognizers()
        engine.cancelAllTouches()
        engine.cancelAllGestures()
    }
    
    func untransformPoint(_ point:CGPoint) -> CGPoint {
        return BounceEngine.untransformPoint(point: point, translation: screenTranslation, scale: screenScale, rotation: 0.0)
        //return CGPoint(x: (point.x - screenTranslation.x) / screenScale, y: (point.y - screenTranslation.y) / screenScale)
    }
    
    func transformPoint(_ point:CGPoint) -> CGPoint {
        return BounceEngine.transformPoint(point: point, translation: screenTranslation, scale: screenScale, rotation: 0.0)
        //return CGPoint(x: point.x * screenScale + screenTranslation.x, y: point.y * screenScale + screenTranslation.y)
    }
    
    //MARK: Gesture stuff, pan, pinch, etc
    private var _allowZoomGestures:Bool {
        if zoomGestureCancelTimer > 0 {
            return false
        }
        return true
    }
    
    func animateScreenTransform(scale: CGFloat, translate: CGPoint) {
        
        if scale == screenScale && translate.equalTo(screenTranslation) {
            //Don't do anything
        } else {
            ApplicationController.shared.addActionBlocker(name: "side_menu_main_screen_animation")
            
            screenAnim = true
            screenAnimTick = 0
            
            screenAnimStartScale = screenScale
            screenAnimStartTranslation = CGPoint(x: screenTranslation.x, y: screenTranslation.y)
            
            screenAnimEndScale = scale
            screenAnimEndTranslation = CGPoint(x: translate.x, y: translate.y)
        }
    }
    
    func animateScreenTransformToEdit() {
        animateScreenTransform(scale: screenEditScale, translate: screenEditTranslation)
    }
    
    func animateScreenTransformToIdentity() {
        animateScreenTransform(scale: 1.0, translate: CGPoint(x: 0.0, y: 0.0))
    }
    
    var allowTouch: Bool {
        if ApplicationController.shared.allowTouch() == false {
            return false
        }
        if isFrozen || isFreezeEnqueued || isAnimatingSideMenu || isShowingSideMenu {
            return false
        }
        if touchCancelTimer > 0 {
            return false
        }
        if zoomGestureCancelTimer > 0 {
            return false
        }
        return true
    }
    
    func setZoom(_ zoomScale: CGFloat) {
        //
        //Keep the screen centered as we zoom in...
        //
        let c = CGPoint(x: view.bounds.width / 2.0, y: view.bounds.height / 2.0)
        let prevCenter = untransformPoint(c)
        screenScale = zoomScale
        let newCenter = transformPoint(prevCenter)
        let newX: CGFloat = screenTranslation.x - (newCenter.x - c.x)
        let newY: CGFloat = screenTranslation.y - (newCenter.y - c.y)
        screenTranslation = CGPoint(x: newX, y: newY)
    }
    
    func updateTransform() {
        
        
        if screenScale < ApplicationController.shared.zoomMin {
            screenScale = ApplicationController.shared.zoomMin
        } else if screenScale > ApplicationController.shared.zoomMax {
            screenScale = ApplicationController.shared.zoomMax
        }
        
        //
        //Keep the screen centered as we zoom/pan...
        //
        
        screenTranslation = CGPoint.zero
        let gestureStart = transformPoint(gestureStartImageTouch)
        let newX: CGFloat = (gestureTouchCenter.x - gestureStart.x)
        let newY: CGFloat = (gestureTouchCenter.y - gestureStart.y)
        screenTranslation = CGPoint(x: newX, y: newY)
        
        screenEditScale = screenScale
        screenEditTranslation.x = screenTranslation.x
        screenEditTranslation.y = screenTranslation.y
    }
    
    func gestureBegan(_ pos:CGPoint) {
        gestureStartScreenTouch = pos
        gestureStartImageTouch = untransformPoint(pos)
        pinchRecognizer.scale = 1.0
        panRecognizer.setTranslation(CGPoint.zero, in: view)
        gestureStartTranslate = CGPoint(x: screenTranslation.x, y: screenTranslation.y)
        gestureStartScale = screenScale
        rotRecognizer.rotation = 0.0
    }
    
    @objc func didPanMainThread(_ gr:UIPanGestureRecognizer) -> Void {
        
        gestureTouchCenterPrevious = CGPoint(x: gestureTouchCenter.x, y: gestureTouchCenter.y)
        gestureTouchCenter = gr.location(in: self.view)
        
        var panVelocity = gr.velocity(in: self.view)
        panVelocity = CGPoint(x: panVelocity.x / screenScale, y: panVelocity.y / screenScale)
        
        var panVelocityDirX: CGFloat = panVelocity.x
        var panVelocityDirY: CGFloat = panVelocity.y
        
        var dist = panVelocityDirX * panVelocityDirX + panVelocityDirY * panVelocityDirY
        if dist > Math.epsilon {
            dist = CGFloat(sqrtf(Float(dist)))
            panVelocityDirX /= dist
            panVelocityDirY /= dist
            dist /= 24.0
            if Device.isTablet {
                if dist > 40 {
                    dist = 40.0
                }
            } else {
                if dist > 28.0 {
                    dist = 28.0
                }
            }
        }
        panVelocity = CGPoint(x: panVelocityDirX * dist, y: panVelocityDirY * dist)
        
        if allowTouch == false {
            cancelAllGesturesAndTouches()
            return
        }
        
        if engine.zoomEnabled {
            if _allowZoomGestures == false {
                cancelAllGestureRecognizers()
                return
            }
            switch gr.state {
            case .began:
                isAnyGestureRecognizerActive = true
                gestureBegan(gestureTouchCenter)
                panRecognizerTouchCount = gr.numberOfTouches
                break
            case .changed:
                if panRecognizerTouchCount != gr.numberOfTouches {
                    if gr.numberOfTouches > panRecognizerTouchCount {
                        panRecognizerTouchCount = gr.numberOfTouches
                        gestureBegan(gestureTouchCenter)
                    }
                    else {
                        cancelAllGestureRecognizers()
                    }
                }
                break
            default:
                cancelAllGestureRecognizers()
                break
            }
            if _allowZoomGestures {
                updateTransform()
            }
        } else {
            let panPos = untransformPoint(gestureTouchCenter)
            
            switch gr.state {
            case .began:
                panRecognizerTouchCount = gr.numberOfTouches
                engine.panBegin(pos: panPos)
                break
            case .changed:
                if panRecognizerTouchCount != gr.numberOfTouches {
                    if gr.numberOfTouches > panRecognizerTouchCount {
                        panRecognizerTouchCount = gr.numberOfTouches
                        engine.panBegin(pos: panPos)
                        engine.pan(pos: panPos)
                    }
                    else {
                        
                        let panCenter: CGPoint = CGPoint(x: gestureTouchCenterPrevious.x + panVelocity.x, y: gestureTouchCenterPrevious.y + panVelocity.y)
                        engine.panEnd(pos: panCenter, velocity: CGPoint.zero, forced: false)
                        engine.cancelAllGestures()
                    }
                } else {
                    engine.pan(pos: panPos)
                }
                break
            default:
                
                let panCenter: CGPoint = CGPoint(x: gestureTouchCenterPrevious.x + panVelocity.x, y: gestureTouchCenterPrevious.y + panVelocity.y)
                engine.panEnd(pos: panCenter, velocity: CGPoint.zero, forced: false)
                engine.cancelAllGestures()
                break
            }
        }
    }
    
    @objc func didPinchMainThread(_ gr:UIPinchGestureRecognizer) -> Void {
        
        gestureTouchCenter = gr.location(in: self.view)
        
        if allowTouch == false {
            cancelAllGesturesAndTouches()
            return
        }
        
        if engine.zoomEnabled {
            if _allowZoomGestures == false {
                cancelAllGestureRecognizers()
                return
            }
            switch gr.state {
            case .began:
                isAnyGestureRecognizerActive = true
                gestureBegan(gestureTouchCenter)
                gestureStartScale = screenScale
                pinchRecognizerTouchCount = gr.numberOfTouches
                break
            case .changed:
                if pinchRecognizerTouchCount != gr.numberOfTouches {
                    if gr.numberOfTouches > pinchRecognizerTouchCount {
                        pinchRecognizerTouchCount = gr.numberOfTouches
                        gestureBegan(gestureTouchCenter)
                    }
                    else {
                        cancelAllGestureRecognizers()
                    }
                }
                break
            default:
                cancelAllGestureRecognizers()
                break
            }
            if _allowZoomGestures {
                screenScale = gestureStartScale * gr.scale
                updateTransform()
            }
        } else {
            let pinchPos = untransformPoint(gestureTouchCenter)
            let pinchScale = gr.scale
            switch gr.state {
            case .began:
                pinchRecognizerTouchCount = gr.numberOfTouches
                engine.pinchBegin(pos: pinchPos, scale: pinchScale)
                break
            case .changed:
                if pinchRecognizerTouchCount != gr.numberOfTouches {
                    if gr.numberOfTouches > pinchRecognizerTouchCount {
                        pinchRecognizerTouchCount = gr.numberOfTouches
                        gr.scale = 1.0
                        engine.pinchBegin(pos: pinchPos, scale: 1.0)
                    }
                    else {
                        engine.pinchEnd(pos: pinchPos, scale: pinchScale, forced: false)
                        engine.cancelAllGestures()
                        break
                    }
                } else {
                    engine.pinch(pos: pinchPos, scale: pinchScale)
                }
                break
            default:
                engine.pinchEnd(pos: pinchPos, scale: pinchScale, forced: false)
                engine.cancelAllGestures()
                break
            }
        }
    }
    
    @objc func didRotateMainThread(_ gr:UIRotationGestureRecognizer) -> Void {
        
        gestureTouchCenter = gr.location(in: self.view)
        
        if allowTouch == false {
            cancelAllGesturesAndTouches()
            return
        }
        
        if engine.zoomEnabled {
            if _allowZoomGestures == false {
                cancelAllGestureRecognizers()
                return
            }
            switch gr.state {
            case .began:
                gestureBegan(gestureTouchCenter)
                isAnyGestureRecognizerActive = true
                rotRecognizerTouchCount = gr.numberOfTouches
                break
            case .changed:
                if rotRecognizerTouchCount != gr.numberOfTouches {
                    if gr.numberOfTouches > rotRecognizerTouchCount {
                        rotRecognizerTouchCount = gr.numberOfTouches
                        gestureBegan(gestureTouchCenter)
                    }
                    else {
                        cancelAllGestureRecognizers()
                    }
                }
                break
            default:
                cancelAllGestureRecognizers()
                break
            }
            if _allowZoomGestures {
                updateTransform()
            }
        } else {
            let rotPos = untransformPoint(gestureTouchCenter)
            let rot = gr.rotation
            switch gr.state {
            case .began:
                rotRecognizerTouchCount = gr.numberOfTouches
                engine.rotateBegin(pos: rotPos, radians: rot)
                break
            case .changed:
                if rotRecognizerTouchCount != gr.numberOfTouches {
                    if gr.numberOfTouches > rotRecognizerTouchCount {
                        rotRecognizerTouchCount = gr.numberOfTouches
                        gr.rotation = 0.0
                        engine.rotateBegin(pos: rotPos, radians: 0.0)
                    }
                    else {
                        engine.rotateEnd(pos: rotPos, radians: rot, forced: false)
                        engine.cancelAllGestures()
                        break
                    }
                } else {
                    engine.rotate(pos: rotPos, radians: rot)
                }
                break
            default:
                engine.rotateEnd(pos: rotPos, radians: rot, forced: false)
                engine.cancelAllGestures()
                gr.rotation = 0.0
                break
            }
        }
    }
    
    @objc func didDoubleTapMainThread(_ gr:UITapGestureRecognizer) -> Void {
        
        print("DID DOUBLE-TAP??")
        
        if allowTouch == false {
            cancelAllGesturesAndTouches()
            return
        }
        
        if isAnyGestureRecognizerActive {
            return
        }
        
        
        if ToolActions.allow() {
            ToolActions.menusToggleShowing()
        }
        
    }
    
    func cancelAllGestureRecognizers() {
        zoomGestureCancelTimer = 3
        panRecognizer.isEnabled = false
        pinchRecognizer.isEnabled = false
        rotRecognizer.isEnabled = false
        isAnyGestureRecognizerActive = false
    }
    
    @objc func didPan(_ gr:UIPanGestureRecognizer) -> Void {
        self.performSelector(onMainThread: #selector(didPanMainThread(_:)), with: gr, waitUntilDone: true, modes: [RunLoopMode.commonModes.rawValue])
    }
    
    @objc func didPinch(_ gr:UIPinchGestureRecognizer) -> Void {
        self.performSelector(onMainThread: #selector(didPinchMainThread(_:)), with: gr, waitUntilDone: true, modes: [RunLoopMode.commonModes.rawValue])
    }
    
    @objc func didRotate(_ gr:UIRotationGestureRecognizer) -> Void {
        self.performSelector(onMainThread: #selector(didRotateMainThread(_:)), with: gr, waitUntilDone: true, modes: [RunLoopMode.commonModes.rawValue])
    }
    
    @objc func didDoubleTap(_ gr:UITapGestureRecognizer) -> Void {
        self.performSelector(onMainThread: #selector(didDoubleTapMainThread(_:)), with: gr, waitUntilDone: true, modes: [RunLoopMode.commonModes.rawValue])
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pos = gestureRecognizer.location(in: view)
        if topMenu.frame.contains(pos) { return false }
        if bottomMenu.frame.contains(pos) { return false }
        if allowTouch == false { return false }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if allowTouch == false {
            cancelAllGesturesAndTouches()
            return
        }
        if engine.zoomEnabled == false {
            for var touch:UITouch in touches {
                if touch.phase == .began {
                    let location = touch.location(in: view)
                    if topMenu.frame.contains(location) == false && bottomMenu.frame.contains(location) == false {
                        engine.touchDown(&touch, point: untransformPoint(location))
                    }
                }
            }
        } else {
            engine.cancelAllTouches()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if allowTouch == false {
            cancelAllGesturesAndTouches()
            return
        }
        if engine.zoomEnabled == false {
            for var touch:UITouch in touches {
                if touch.phase == .moved {
                    let location = touch.location(in: view)
                    engine.touchMove(&touch, point: untransformPoint(location))
                }
            }
        } else {
            engine.cancelAllTouches()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if allowTouch == false {
            cancelAllGesturesAndTouches()
            return
        }
        
        if engine.zoomEnabled == false {
            for var touch:UITouch in touches {
                if touch.phase == .ended || touch.phase == .cancelled {
                    let location = touch.location(in: view)
                    engine.touchUp(&touch, point: untransformPoint(location))
                }
            }
        } else {
            engine.cancelAllTouches()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //embed_bottom_menu
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /*
         if segue.identifier == "embed_bottom_menu" {
         if let bm = segue.destination as? BottomMenu {
         bottomMenu = bm
         }
         }
         */
        
    }
    
    func saveScene(sceneTitle: String?) {
        saveScene(sceneTitle: sceneTitle, scene: engine.scene, isRecent: false)
    }
    
    @objc func clickExpandTop(button: AnyObject) {
        ToolActions.showTopMenu()
    }
    
    @objc func clickExpandBottom(button: AnyObject) {
        ToolActions.showBottomMenu()
    }
    
    @IBAction func clickShowHideAll(_ sender: RRButton) {
        
        //ToolActions.menusToggleShowing()
        
    }
    
    func saveRecentScene() {
        let scene = engine.scene.clone()
        scene.image = nil
        scene.imageName = "recent"
        saveScene(sceneTitle: scene.title, scene:scene, isRecent: true)
    }
    
    func saveScene(sceneTitle: String?, scene: BounceScene, isRecent: Bool) {
        if let title = sceneTitle, title.count > 0 {
            
            print("Save Scene[\(title)]")
            
            var info = [String:AnyObject]()
            var filePath:String = ""
            scene.title = title
            
            if isRecent {
                scene.isRecent = true
                scene.imageName  = ApplicationController.shared.recentImageName
            }
            else { scene.isRecent = false }
            
            var savedFilePath: String = ""
            
            if isRecent == false {
                let isSaveOver: Bool = ApplicationController.shared.savedFiles.titleExists(sceneTitle: title)
                if isSaveOver == false {
                    //Generate a new unique name...
                    scene.imageName = Config.shared.uniqueString
                } else {
                    let oldFilePath = ApplicationController.shared.savedFiles.getFilePath(sceneTitle: title)
                    ApplicationController.shared.deleteScene(filePath: oldFilePath)
                }
                
                filePath = String(scene.imageName) + ".json"
                savedFilePath = "\(filePath)"
                
                let imagePath = String(scene.imageName) + ".png"
                let thumbPath = String(scene.imageName) + "_thumb.png"
                
                //if isSaveOver == false {
                ApplicationController.shared.savedFiles.updateFile(sceneTitle: title, filePath: filePath, imagePath: imagePath, thumbPath: thumbPath, webScene: scene.isWebScene)
                filePath = FileUtils.getDocsPath(filePath)
                FileUtils.copyFile(from: ApplicationController.shared.recentThumbPath, to: FileUtils.getDocsPath(thumbPath))
                FileUtils.copyFile(from: ApplicationController.shared.recentImagePath, to: FileUtils.getDocsPath(imagePath))
            } else {
                filePath = ApplicationController.shared.recentScenePath
            }
            
            info["scene"] = scene.save() as AnyObject?
            info["engine"] = engine.save() as AnyObject?
            
            do {
                var fileData:Data?
                try fileData = JSONSerialization.data(withJSONObject: info, options: .prettyPrinted)
                if fileData != nil {
                    let imagePath = String(scene.imageName) + ".png"
                    let thumbPath = String(scene.imageName) + "_thumb.png"
                    _ = FileUtils.saveData(data: &fileData, filePath: filePath)
                    if isRecent == false {
                        ApplicationController.shared.savedFiles.updateFile(sceneTitle: scene.title, filePath: savedFilePath, imagePath: imagePath, thumbPath: thumbPath, webScene: scene.isWebScene)
                    }
                }
            } catch {
                print("Unable to save Data [\(filePath)]")
            }
        }
    }
    
    func loadRecentScene() {
        loadScene(filePath: ApplicationController.shared.recentScenePath, isRecent: true, isWeb: false)
    }
    
    func loadWebScene(sceneModel model: WebSceneModel) {
        sceneModel = model
        loadScene(filePath: ApplicationController.shared.webScenePath, isRecent: false, isWeb: true)
        engine.scene.sceneModel = model.clone()
    }
    
    
    func loadScene(filePath:String?, isRecent: Bool, isWeb: Bool) {
        
        if isWeb && isRecent {
            
            print("***** ***** ***** *****")
            print("***** ***** ***** *****")
            print("***** ***** ***** *****")
            print("***** FATAL ERROR *****")
            print("***** SCENE IS RECENT *****")
            print("***** SCENE IS ALSO WEB *****")
            print("***** ***** ***** *****")
            print("***** ***** ***** *****")
            print("***** ***** ***** *****")
            return
        }
        
        var _fileData = FileUtils.loadFileData(filePath)
        if isRecent {
            _fileData = FileUtils.loadFileData(ApplicationController.shared.recentScenePath)
        }
        if isWeb {
            _fileData = FileUtils.loadFileData(ApplicationController.shared.webScenePath)
        }
        
        if let fileData = _fileData {
            var parsedInfo:[String:AnyObject]?
            do {
                var jsonData:Any?
                jsonData = try JSONSerialization.jsonObject(with: fileData, options:.mutableLeaves)
                parsedInfo = jsonData as? [String:AnyObject]
            }
            catch {
                print("Unable to parse data [\(filePath!)]")
            }
            
            if var info = parsedInfo {
                let scene = BounceScene()
                var loadScene = BounceScene()
                
                if var sceneInfo = GoodParser.readInfo(&info, "scene") {
                    scene.load(info: &sceneInfo)
                    //scene.webSceneID
                    //sceneModel
                    
                    //Okay, so if we are a freshly pulled web scene, we must flag ourselves as a web scene...
                    if isWeb {
                        scene.isWebScene = true
                        scene.imageName = Config.shared.uniqueString
                        //scene.imagePath = ApplicationController.shared.recentImagePath
                        //scene.thumbPath = ApplicationController.shared.recentThumbPath
                        
                    }
                    
                    loadScene = scene.clone()
                    
                    scene.isLoaded = true
                    if isRecent {
                        scene.image = UIImage(contentsOfFile: ApplicationController.shared.recentImagePath)
                    } else {
                        
                        var imagePath = String(scene.imageName) + ".png"
                        imagePath = FileUtils.findAbsolutePath(imagePath)
                        
                        if isWeb { imagePath = "\(ApplicationController.shared.webImagePath)" }
                        if let image = UIImage(contentsOfFile: imagePath) {
                            let thumb = ApplicationController.shared.getThumb(image: image)
                            scene.image = image
                            _ = FileUtils.saveImagePNG(image: image, filePath: ApplicationController.shared.recentImagePath)
                            _ = FileUtils.saveImagePNG(image: thumb, filePath: ApplicationController.shared.recentThumbPath)
                        }
                    }
                }
                
                if scene.isLandscape {
                    setUp(scene: scene, appFrame: CGRect(x: 0.0, y: 0.0, width: Device.landscapeWidth, height: Device.landscapeHeight))
                } else {
                    setUp(scene: scene, appFrame: CGRect(x: 0.0, y: 0.0, width: Device.portraitWidth, height: Device.portraitHeight))
                }
                
                if var engineInfo = info["engine"] as? [String:AnyObject] {
                    engine.load(info: &engineInfo)
                    //If we saved a scene model...
                    if let model = engine.scene.sceneModel {
                        sceneModel = model
                    }
                    engine.loadAdjust(loadScene: loadScene, newScene: scene)
                }
                
                if isRecent == false {
                    saveRecentScene()
                }
                
                engine.setUpComplete()
            }
        }
    }
    
    func recordStart() {
        audioRecorder?.clear()
        audioRecorder = AudioRecorder()
        audioRecorder!.recordBegin() { (allowed: Bool) in
            DispatchQueue.main.async {
                self.isRecording = true
                BounceEngine.postNotification(BounceNotification.recordEnabledChanged)
            }
        }
    }
    
    func recordStop() {
        isRecording = false
        audioRecorder?.recordEnd()
        BounceEngine.postNotification(BounceNotification.recordEnabledChanged)
    }
    
    func recordClear() {
        recordedEngineStates.removeAll()
        isRecording = false
        timelineEnabled = false
        timelinePlaying = false
        timelineFrame = 0
        timelineDraggingHandle = false
        timelineDraggingThumb = false
        timelineShouldResumeAfterDrag = false
        timelineHandleStartFrame = 0
        timelineHandleEndFrame = 0
        audioRecorder?.clear()
        videoRecorder?.clear()
    }
    
    func timelineCanStart() -> Bool {
        if recordedEngineStates.count >= ApplicationController.shared.minRecordStates {
            return true
        } else {
            return false
        }
    }
    
    func timelineStart() {
        timelineEnabled = true
        timelinePlaying = true
        timelineFrame = 0
        timelineDraggingHandle = false
        timelineDraggingThumb = false
        
        timelineShouldResumeAfterDrag = false
        
        timelineHandleStartFrame = 0
        timelineHandleEndFrame = (recordedEngineStates.count - 1)
        if timelineHandleEndFrame < 0 {
            timelineHandleEndFrame = 0
        }
        
        BounceEngine.postNotification(BounceNotification.timelineEnabledChanged)
    }
    
    func timelineStop() {
        
        recordClear()
        
        timelineEnabled = false
        timelinePlaying = false
        timelineFrame = timelineHandleStartFrame
        
        timelineDraggingHandle = false
        timelineDraggingThumb = false
        
        timelineShouldResumeAfterDrag = false
        
        BounceEngine.postNotification(BounceNotification.timelineEnabledChanged)
        
    }
    
    func timelinePause() {
        timelinePlaying = false
        
    }
    
    func timelineResume() {
        timelinePlaying = true
    }
    
    var timelineFrameCount: Int {
        return (timelineHandleEndFrame - timelineHandleStartFrame) + 1
    }
    
    func exportPrepare() {
        exportFinished = false
        exportError = false
        timelineEnabled = false
        timelinePlaying = false
        timelineDraggingHandle = false
        timelineDraggingThumb = false
        timelineShouldResumeAfterDrag = false
        exportFrame = timelineHandleStartFrame
        isExporting = true
        exportReadyForPhotoLibrary = false
    }
    
    func exportStart() {
        
        exportPrepare()
        
        if let recorder = videoRecorder {
            recorder.clear()
            videoRecorder = nil
        }
        
        
        
        videoRecorder = VideoRecorder()
        
        var exportWidth: CGFloat = Device.portraitWidth
        var exportHeight: CGFloat = Device.portraitHeight
        if engine.scene.isLandscape {
            exportWidth = Device.landscapeWidth
            exportHeight = Device.landscapeHeight
        }
        
        if videoRecorder!.videoRecordBegin(size: CGSize(width: exportWidth, height: exportHeight), frameCount: timelineFrameCount) {
            BounceEngine.postNotification(BounceNotification.videoExportBegin)
        } else {
            exportCancel()
            exportError = true
            ToolActions.setActiveMenusTimeline()
            BounceEngine.postNotification(BounceNotification.videoExportError)
            ToolActions.showExportErrorAlert(withSettingsLink: true)
        }
    }
    
    //videoRecorder is non-null...
    func exportIncrement() {
        exportFrame += 1
        BounceEngine.postNotification(BounceNotification.videoExportFrameChanged)
        if exportFrame > timelineHandleEndFrame && exportFinished == false {
            if exportError == false {
                exportFinished = true
            }
        }
    }
    
    func exportFlagReadyForPhotoLibrary() {
        exportReadyForPhotoLibrary = true
    }
    //
    
    
    func exportCancel() {
        
        videoRecorder?.clear()
        
        exportReadyForPhotoLibrary = false
        isExporting = false
        exportFinished = false
        exportFrame = 0
        
        if (timelineHandleEndFrame - timelineHandleStartFrame) > 0 {
            timelineFrame = timelineHandleStartFrame
            timelineEnabled = true
            timelineDraggingHandle = false
            timelineDraggingThumb = false
            timelineShouldResumeAfterDrag = false
            timelinePlaying = true
        }
    }
    
    //func exportDone() {
    
    //}
    
    //The actual timeline position. This is in
    //"ticks" e.g. 1 frame per increment, exactly.
    //var timelineFrame: Int = 0
    
    //timelineFrame will always be between these two values.
    //var handleStartFrame: Int = 0
    //var handleEndFrame: Int = ApplicationController.shared.minTimelineFrameSpan
    
    func timelineStopDraggingHandle() {
        timelineDraggingHandle = false
        if timelineShouldResumeAfterDrag == true {
            if timelineDraggingThumb == false {
                timelinePlaying = true
                timelineShouldResumeAfterDrag = false
            }
        }
    }
    
    func timelineStopDraggingThumb() {
        timelineDraggingThumb = false
        if timelineShouldResumeAfterDrag == true {
            if timelineDraggingHandle == false {
                timelinePlaying = true
                timelineShouldResumeAfterDrag = false
            }
        }
    }
    
    //timelineDraggingThumb = false
    
    func timelineStartDraggingLeftHandle() {
        
        timelineShouldResumeAfterDrag = timelinePlaying || (timelineShouldResumeAfterDrag && timelineDraggingThumb)
        timelinePlaying = false
        
        timelineDraggingHandle = true
        timelineDraggingLeftHandle = true
        timelineDraggingThumb = false
    }
    
    func timelineStartDraggingRightHandle() {
        timelineShouldResumeAfterDrag = timelinePlaying || (timelineShouldResumeAfterDrag && timelineDraggingThumb)
        timelinePlaying = false
        
        timelineDraggingHandle = true
        timelineDraggingLeftHandle = false
        timelineDraggingThumb = false
    }
    
    func timelineStartDraggingThumb() {
        timelineShouldResumeAfterDrag = timelinePlaying || (timelineShouldResumeAfterDrag && timelineDraggingHandle)
        timelinePlaying = false
        timelineDraggingThumb = true
        timelineDraggingHandle = false
    }
    
    func getTimelineLeftHandlePercent() -> CGFloat {
        let maxFrame: Int = recordedEngineStates.count - 1
        if maxFrame > 0 {
            return CGFloat(timelineHandleStartFrame) / CGFloat(maxFrame)
        }
        return 0.5
    }
    
    func getTimelineRightHandlePercent() -> CGFloat {
        let maxFrame: Int = recordedEngineStates.count - 1
        if maxFrame > 0 {
            return CGFloat(timelineHandleEndFrame) / CGFloat(maxFrame)
        }
        return 0.5
    }
    
    func getTimelineThumbPercent() -> CGFloat {
        let handleSpan = CGFloat(timelineHandleEndFrame - timelineHandleStartFrame)
        if handleSpan > 1.0 {
            return CGFloat(timelineFrame - timelineHandleStartFrame) / CGFloat(handleSpan)
        }
        return 0.5
    }
    
    func getTimelineMinTimelineFrameSpanPercent() -> CGFloat {
        let maxFrame: Int = recordedEngineStates.count - 1
        if maxFrame > 0 {
            return CGFloat(ApplicationController.shared.minTimelineFrameSpan) / CGFloat(maxFrame)
        }
        return 0.5
    }
    
    func timelinePlayPause() {
        if timelinePlaying {
            timelinePlaying = false
        } else {
            timelinePlaying = true
        }
    }
    
    func timelineNextFrame() {
        timelinePlaying = false
        if timelineFrame < timelineHandleEndFrame {
            timelineFrame += 1
            BounceEngine.postNotification(BounceNotification.timelineFrameChanged)
        }
    }
    
    func timelinePreviousFrame() {
        timelinePlaying = false
        if timelineFrame > timelineHandleStartFrame {
            timelineFrame -= 1
            BounceEngine.postNotification(BounceNotification.timelineFrameChanged)
        }
    }
    
    
    func timelinePlaceTicker(_ percent: CGFloat) {
        let handleSpan = CGFloat(timelineHandleEndFrame - timelineHandleStartFrame)
        
        var newTick = Int(CGFloat(timelineHandleStartFrame) + CGFloat(handleSpan) * percent + 0.5)
        
        if newTick < timelineHandleStartFrame { 
            newTick = timelineHandleStartFrame
        }
        if newTick > timelineHandleEndFrame { 
            newTick = timelineHandleEndFrame
        }
        timelineFrame = newTick
        timelineShouldResumeAfterDrag = false
        timelinePlaying = false
    }
    
    //Assumption - the drag is coming from a legal position and already constrained..
    //Hence, we only need to clip the lower extremes.
    func timelinePlaceLeftHandle(_ percent: CGFloat) {
        let minFrame: Int = 0
        let maxFrame: Int = (recordedEngineStates.count - 1)
        
        timelineHandleStartFrame = Int(CGFloat(maxFrame) * percent + 0.5)
        
        if timelineHandleStartFrame < minFrame {
            timelineHandleStartFrame = minFrame
        }
        
        //if handleStartFrame > (maxFrame - ApplicationController.shared.minTimelineFrameSpan) {
        //    handleStartFrame = (maxFrame - ApplicationController.shared.minTimelineFrameSpan)
        //}
        
        //In-case we nudged the index (also, shouldn't happen)
        if timelineFrame < timelineHandleStartFrame {
            print("FATAL UNACCOUNTED FOR ERROR: INDEX BEFORE START FRAME...")
            timelineFrame = timelineHandleStartFrame
            BounceEngine.postNotification(BounceNotification.timelineFrameChanged)
        }
    }
    
    
    //Assumption - the drag is coming from a legal position and already constrained..
    //Hence, we only need to clip the lower extremes.
    func timelinePlaceRightHandle(_ percent: CGFloat) {
        //let minFrame: Int = 0
        let maxFrame: Int = (recordedEngineStates.count - 1) 
        
        timelineHandleEndFrame = Int(CGFloat(maxFrame) * percent + 0.5)
        
        if timelineHandleEndFrame > maxFrame {
            timelineHandleEndFrame = maxFrame
        }
        
        //if handleStartFrame > (maxFrame - ApplicationController.shared.minTimelineFrameSpan) {
        //    handleStartFrame = (maxFrame - ApplicationController.shared.minTimelineFrameSpan)
        //}
        
        //In-case we nudged the index (also, shouldn't happen)
        if timelineFrame > timelineHandleEndFrame {
            print("FATAL UNACCOUNTED FOR ERROR: INDEX AFTER END FRAME...")
            timelineFrame = timelineHandleEndFrame
            BounceEngine.postNotification(BounceNotification.timelineFrameChanged)
        }
    }
    
    func didBecomeActive() {
        
    }
    
    func didBecomeInactive() {
        
        
        print("*** ROOT DID BECOME INACTIVE!!! ***")
        print("*** isExporting=\(isExporting) exportReadyForPhotoLibrary=\(exportReadyForPhotoLibrary) ***")
        
        
        
        
        if isRecording {
            
            //OLD: Re-explore keeping the recording alive when backgrounding...
            
            recordClear()
            BounceEngine.postNotification(BounceNotification.recordEnabledChanged)
            //ToolActions.setActiveMenusTools()
            
            //Show alert box to notify of recording clear...
            
            let alert = UIAlertController(title: "Recording Problem", message: "Your recording was interrupted, please try again!", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "Okay", style: .default) { (action: UIAlertAction) in }
            alert.addAction(actionOK)
            ApplicationController.shared.root.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if isExporting == true && exportReadyForPhotoLibrary == false {
            exportCancel()
            exportError = true
            ToolActions.setActiveMenusTimeline()
            BounceEngine.postNotification(BounceNotification.videoExportError)
            ToolActions.showExportErrorAlert(withSettingsLink: false)
        }
    }
    
    func resetAll() {
        screenEditScale = 1.0
        screenEditTranslation = CGPoint.zero
        animateScreenTransformToIdentity()
        engine.resetAll()
    }
    
}










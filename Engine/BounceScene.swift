//
//  BounceScene.swift
//
//  Created by Nicholas Raptis on 8/25/16.
//

import UIKit

class BounceScene
{
    var image:UIImage?
    
    var title:String? = "Scene 01"
    
    //So, it's a "RECENT" scene... / the one instance of recent scene that we hang onto...
    var isRecent: Bool = false
    
    var isWebScene: Bool = false
    
    //var webSceneID: Int?
    
    var sceneModel: WebSceneModel?
    
    //If it's from a loaded scene...
    var isLoaded: Bool = false
    
    var imageName:String = "AUTOSAVE"
    
    //var orientation:UIInterfaceOrientation = .Portrait
    var isLandscape:Bool = true
    
    //var size:CGSize = CGSize(width: 320.0, height: 320.0)
    var screenSize:CGSize = CGSize(width: 320.0, height: 320.0)
    var imageSize:CGSize = CGSize(width: 320.0, height: 320.0)
    var imageFrame:CGRect = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 320.0)
    
    func clone() -> BounceScene {
        let scene = BounceScene()
        scene.title = title
        scene.isLandscape = isLandscape
        scene.isRecent = isRecent
        scene.isWebScene = isWebScene
        
        if let model = sceneModel {
            scene.sceneModel = model.clone()
        }
        
        scene.screenSize = CGSize(width: screenSize.width, height: screenSize.height)
        scene.imageSize = CGSize(width: imageSize.width, height: imageSize.height)
        scene.imageFrame = CGRect(x: imageFrame.origin.x, y: imageFrame.origin.y, width: imageFrame.size.width, height: imageFrame.size.height)
        
        return scene
    }
    
    func save() -> [String:AnyObject] {
        var info = [String:AnyObject]()
        info["image_name"] = imageName as AnyObject?
        info["landscape"] = isLandscape as AnyObject?
        info["screen_size_width"] = Float(screenSize.width) as AnyObject?
        info["screen_size_height"] = Float(screenSize.height) as AnyObject?
        info["image_size_width"] = Float(imageSize.width) as AnyObject?
        info["image_size_height"] = Float(imageSize.height) as AnyObject?
        info["image_frame_x"] = Float(imageFrame.origin.x) as AnyObject?
        info["image_frame_y"] = Float(imageFrame.origin.y) as AnyObject?
        info["image_frame_width"] = Float(imageFrame.size.width) as AnyObject?
        info["image_frame_height"] = Float(imageFrame.size.height) as AnyObject?
        info["is_recent"] = Bool(isRecent) as AnyObject?
        info["is_web_scene"] = Bool(isWebScene) as AnyObject?
        
        if let model = sceneModel {
            info["web_scene"] = model.save() as AnyObject?
        }
        
        return info
    }
    
    func load(info: inout [String:AnyObject]) {
        
        //if let _imageName = info["image_name"] as? String { imageName = _imageName }
        imageName = GoodParser.readString(&info, "image_name", imageName)
        
        //if let _isLandscape = info["landscape"] as? Bool { isLandscape = _isLandscape }
        isLandscape = GoodParser.readBool(&info, "landscape", isLandscape)
        
        //if let _screenSizeWidth = info["screen_size_width"] as? Float { screenSize.width = CGFloat(_screenSizeWidth) }
        screenSize.width = GoodParser.readFloat(&info, "screen_size_width", screenSize.width)
        //if let _screenSizeHeight = info["screen_size_height"] as? Float { screenSize.height = CGFloat(_screenSizeHeight) }
        screenSize.height = GoodParser.readFloat(&info, "screen_size_height", screenSize.height)
        //if let _imageSizeWidth = info["image_size_width"] as? Float { imageSize.width = CGFloat(_imageSizeWidth) }
        imageSize.width = GoodParser.readFloat(&info, "image_size_width", imageSize.width)
        //if let _imageSizeHeight = info["image_size_height"] as? Float { imageSize.height = CGFloat(_imageSizeHeight) }
        imageSize.height = GoodParser.readFloat(&info, "image_size_height", imageSize.height)
        //if let _imageFrameX = info["image_frame_x"] as? Float { imageFrame.origin.x = CGFloat(_imageFrameX) }
        imageFrame.origin.x = GoodParser.readFloat(&info, "image_frame_x", imageFrame.origin.x)
        //if let _imageFrameY = info["image_frame_y"] as? Float { imageFrame.origin.y = CGFloat(_imageFrameY) }
        imageFrame.origin.y = GoodParser.readFloat(&info, "image_frame_y", imageFrame.origin.y)
        //if let _imageFrameWidth = info["image_frame_width"] as? Float { imageFrame.size.width = CGFloat(_imageFrameWidth) }
        imageFrame.size.width = GoodParser.readFloat(&info, "image_frame_width", imageFrame.size.width)
        //if let _imageFrameHeight = info["image_frame_height"] as? Float { imageFrame.size.height = CGFloat(_imageFrameHeight) }
        imageFrame.size.height = GoodParser.readFloat(&info, "image_frame_height", imageFrame.size.height)
        
        //if let _isRecent = info["is_recent"] as? Bool { isRecent = _isRecent }
        isRecent = GoodParser.readBool(&info, "is_recent", isRecent)
        
        //if let _isWebScene = info["is_web_scene"] as? Bool { isWebScene = _isWebScene }
        isWebScene = GoodParser.readBool(&info, "is_web_scene", isWebScene)
        
        if var modelInfo = GoodParser.readInfo(&info, "web_scene") {
            print("Loaded Model info: \(modelInfo)")
            let model = WebSceneModel()
            if model.load(info: &modelInfo) {
                sceneModel = model
            }
        }
        
    }
}

//
//  VideoRecorder.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 12/21/17.
//  Copyright © 2017 Darkswarm LLC. All rights reserved.
//

import UIKit
import AVFoundation
//import AssetsLibrary


class VideoRecorder: NSObject {
    
    var videoSize = CGSize(width: 256.0, height: 256.0)
    
    static var tempVideoPath = FileUtils.getDocsPath("temp_video.mp4")
    static var finalVideoPath = FileUtils.getDocsPath("video.mp4")
    
    var assetWriter: AVAssetWriter!
    
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    var pixelBuffer: CVPixelBuffer?
    var videoWriterInput: AVAssetWriterInput!
    
    var fps: Int = 30
    var frame: Int = 0
    var frameCount: Int = 0
    
    func clear() {
        
        frame = 0
        
        /*
        if FileUtils.fileExists(VideoRecorder.tempVideoPath) {
            FileUtils.deleteFile(VideoRecorder.tempVideoPath)
        }
        
        if FileUtils.fileExists(VideoRecorder.finalVideoPath) {
            FileUtils.deleteFile(VideoRecorder.finalVideoPath)
        }
        */
        
        assetWriter = nil
        pixelBufferAdaptor = nil
        pixelBuffer = nil
        videoWriterInput = nil
        
        frameCount = 0
        
        //We always resume the update loop after export finishes..
        if let bounce = ApplicationController.shared.bounce {
            if AppDelegate.sharedDelegate.isAppActive {
                bounce.isPaused = false
            }
        }
    }
    
    func videoRecordBegin(size: CGSize, frameCount fc: Int) -> Bool {
        
        videoSize = CGSize(width: size.width, height: size.height)
        
        clear()
        
        //KLUDGE: We may want to test a flow which intentionally fails..
        //return false
        
        if FileUtils.fileExists(VideoRecorder.tempVideoPath) {
            FileUtils.deleteFile(VideoRecorder.tempVideoPath)
        }
        
        frameCount = fc
        
        let url = URL(fileURLWithPath: VideoRecorder.tempVideoPath)
        
        assetWriter = try? AVAssetWriter(url: url, fileType: .mp4)
        
        if assetWriter === nil {
            print("FAIL AT Having Asset Writer")
            clear()
            return false
        }
        
        let widthNumber = NSNumber(value: Float(size.width))
        let heightNumber = NSNumber(value: Float(size.height))
        let outputSettings = [AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : widthNumber, AVVideoHeightKey : heightNumber] as [String : Any]
        
        guard assetWriter.canApply(outputSettings: outputSettings, forMediaType: .video) else {
            
            print("This code is being run on an unexpected or broken device.")
            
            print("FAIL AT VIDEO SETTINGZZZLLLOOOOLLLL@@@@ T_T T_T >_< WHYYYYYY")
            clear()
            return false
        }
        
        //let videoWriterInput
        
        videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        
        let sourcePixelBufferAttributesDictionary = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32ARGB), kCVPixelBufferWidthKey as String: widthNumber, kCVPixelBufferHeightKey as String: heightNumber]
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        
        if assetWriter.canAdd(videoWriterInput) {
            assetWriter.add(videoWriterInput)
        } else {
            print("FAIL AT VIDEO ADDING INPUT LOOOOOL NO")
            clear()
            return false
        }
        
        videoWriterInput.expectsMediaDataInRealTime = true
        
        var didSavePreview: Bool = false
        if assetWriter.startWriting() {
            assetWriter.startSession(atSourceTime: kCMTimeZero)
            
            if pixelBufferAdaptor.pixelBufferPool == nil {
                print("User is using an iPhone that isn't an iPhone.")
                print("pixelBufferPool is nil...")
                return false
            }
            
            let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferAdaptor.pixelBufferPool!, &pixelBuffer)
            
            let bounce = ApplicationController.shared.bounce!
            let engine = BounceEngine.shared!
            
            //let videoExportQueue = DispatchQueue(label: "video_export_queue")
            let videoExportQueue = DispatchQueue.global(qos: .utility)
            //videoExportQueue.
            
            bounce.isPaused = true
            
            var didEnterBackground: Bool = false
            
            
            videoWriterInput.requestMediaDataWhenReady(on: videoExportQueue, using: {
                
                let renderBlock = {
                    
                    if didEnterBackground == true { return }
                    
                    if AppDelegate.sharedDelegate.isAppActive == false {
                        print("$$$$$$ INTERRUPT EXPORT $$$$$$")
                        didEnterBackground = true
                        VideoRecorder.exportError()
                        return
                    }
                    
                    bounce.update()
                    
                    if engine.stereoscopic {
                        bounce.bounceView.exportStereoDisplay1()
                        bounce.bounceView.exportStereoDisplay2()
                    } else {
                        bounce.bounceView.display()
                    }
                    
                    var exportImage = bounce.bounceView.snapshot
                    
                    //We make a little preview image of our video.
                    
                    //This is used to add flavor to our export dialogs.
                    
                    if didSavePreview == false {
                        didSavePreview = true
                        
                        _ = FileUtils.saveImagePNG(image: exportImage, filePath: ApplicationController.shared.videoExportPreviewPath)
                        
                        
                        //OLD: Image Verification.
                        //if let image = UIImage(contentsOfFile: ApplicationController.shared.videoExportPreviewPath) {
                        //    print("EXPORT PREVIEW IMAGE: \(image.size.width) x \(image.size.height)")
                        //}
                    }
                    
                    if self.videoRecordAppendFrame(image: &exportImage) {
                        
                    } else {
                        VideoRecorder.exportError()
                    }
                    
                    if bounce.exportFinished == false {
                        bounce.exportIncrement()
                    } else {
                        self.videoRecordFinish()
                    }
                }
                
                if Thread.isMainThread == false {
                    DispatchQueue.main.sync {
                        renderBlock()
                    }
                } else {
                    renderBlock()
                }
            })
        } else {
            clear()
            return false
        }
        
        return true
    }
    
    func videoRecordAppendFrame(image: inout UIImage) -> Bool {
        
        guard let adaptor = pixelBufferAdaptor else {
            return false
        }
        
        guard let bufferPool = adaptor.pixelBufferPool else {
            return false
        }
        
        var pixelBuffer: CVPixelBuffer? = nil
        
        let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, bufferPool, &pixelBuffer)
        
        if pixelBuffer !== nil && status == 0 {
            
            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
            let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            
            if let context =  CGContext(data: data, width: Int(videoSize.width), height: Int(videoSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) {
                
                context.clear(CGRect(x: 0.0, y: 0.0, width: videoSize.width, height: videoSize.height))
                context.draw(image.cgImage!, in: CGRect(x: 0.0, y: 0.0, width: videoSize.width, height: videoSize.height))
                
                CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
                
                if adaptor.append(pixelBuffer!, withPresentationTime: CMTimeMake(Int64(frame), Int32(fps))) {
                    frame += 1
                    return true
                } else {
                    print("Failed to append frame...")
                    return false
                }
            } else {
                print("Failed to generate CONTEXT...")
                return false
            }
        } else {
            print("Failed to allocate pixel buffer")
            return false
        }
    }
    
    func videoRecordFinish() {
        
        videoWriterInput.markAsFinished()
        assetWriter.finishWriting { () -> Void in
            
            let mixComposition = AVMutableComposition()
            let audioFileExists = FileUtils.fileExists(AudioRecorder.audioPath)
            
            let audioFileURL = URL(fileURLWithPath: AudioRecorder.audioPath)
            let videoFileURL = URL(fileURLWithPath: VideoRecorder.tempVideoPath)
            
            let audioAsset = AVURLAsset(url: audioFileURL)
            let videoAsset = AVURLAsset(url: videoFileURL)
            
            let video_timeRange = CMTimeRange(start: kCMTimeZero, duration: videoAsset.duration)
            
            let audioDuration = Int(audioAsset.duration.value)
            let videoDuration = Int(videoAsset.duration.value)
            
            if videoDuration <= 0 {
                VideoRecorder.exportError()
                return
            }
            
            if audioFileExists == true && audioDuration > 0 && Config.shared.exportAudio {
                if let audioCompositeTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
                    let bounce = ApplicationController.shared.bounce!
                    let maxFrame: Int = bounce.recordedEngineStates.count - 1
                    let frame = bounce.timelineHandleStartFrame
                    let percent: CGFloat = CGFloat(frame) / CGFloat(maxFrame)
                    let startFrame: Int = Int(percent * CGFloat(maxFrame) + 0.5)
                    let startTime: CMTime = CMTimeMake(Int64(startFrame), 30)
                    if let track = audioAsset.tracks(withMediaType: .audio).first {
                        do {
                            let audio_timeRange = CMTimeRange(start: startTime, duration: video_timeRange.duration)
                            try audioCompositeTrack.insertTimeRange(audio_timeRange, of: track, at: kCMTimeZero)
                        } catch let error as NSError {
                            print("b: insertTimeRange error: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            if let videoCompositeTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) {
                if let track = videoAsset.tracks(withMediaType: .video).first {
                    do {
                        try videoCompositeTrack.insertTimeRange(video_timeRange, of: track, at: kCMTimeZero)
                    } catch let error as NSError {
                        print("a: insertTimeRange error: \(error.localizedDescription)")
                    }
                }
            }
            
            if let _assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                
                if FileUtils.fileExists(VideoRecorder.finalVideoPath) {
                    FileUtils.deleteFile(VideoRecorder.finalVideoPath)
                }
                
                
                Thread.sleep(forTimeInterval: 0.05)
                
                _assetExport.outputFileType = .mp4 // "com.apple.quicktime-movie"
                _assetExport.outputURL =  URL(fileURLWithPath: VideoRecorder.finalVideoPath)
                _assetExport.exportAsynchronously(completionHandler: {
                    
                    self.exportVideoToCameraRoll()
                    
                   // UISaveVideoAtPathToSavedPhotosAlbum(VideoRecorder.finalVideoPath, self, #selector(VideoRecorder.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                    
                    
                })
            } else {
                VideoRecorder.exportError()
            }
        }
    }
    
    private func exportVideoToCameraRoll() {
        
        ToolActions.flagExportReadyForPhotoLibrary()
        
        UISaveVideoAtPathToSavedPhotosAlbum(VideoRecorder.finalVideoPath, self, #selector(VideoRecorder.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
        
        
        
        /*
        let assetLibrary = ALAssetsLibrary()
        let videoURL = URL(string: VideoRecorder.finalVideoPath)
        assetLibrary.writeVideoAtPath(toSavedPhotosAlbum: videoURL) { (url: URL?, error: Error?) in
            print("Asset URL: \(url)")
            print("Asset Error: \(error)")
            
            DispatchQueue.main.async {
                self.handleExportToCameraRollComplete(error: error, withURL: url)
            }
        }
        */
    }
    
    @objc func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        DispatchQueue.main.async {
            self.handleExportToCameraRollComplete(error: error, withURL: nil)
        }
    }
    
    func handleExportToCameraRollComplete(error: Error?, withURL url: URL?) {
        
        if let assetURL = url {
            print("AssetURL: \(assetURL)")
            Config.shared.recentExportVideoURL = assetURL.absoluteString
            Config.shared.save()
        }
        
        if error != nil {
            
            print("Error,Video failed to save")
            print(error!.localizedDescription)
            
            if FileUtils.fileExists(VideoRecorder.finalVideoPath) {
                VideoRecorder.exportComplete()
                ToolActions.showExportErrorAlert(withSettingsLink: true)
            } else {
                DispatchQueue.main.async {
                    VideoRecorder.exportError()
                    if let bounce = ApplicationController.shared.bounce {
                        if AppDelegate.sharedDelegate.isAppActive {
                            bounce.isPaused = false
                        }
                    }
                }
            }
            
            
            
            //_assetExport.outputFileType = .mp4 // "com.apple.quicktime-movie"
            //_assetExport.outputURL =  URL(fileURLWithPath: VideoRecorder.finalVideoPath)
            //_assetExport.exportAsynchronously(completionHandler: {
            //    UISaveVideoAtPathToSavedPhotosAlbum(VideoRecorder.finalVideoPath, self, #selector(VideoRecorder.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
            //})
            
            
            
            
            //
            
            
            
            
        } else {
            print("Successfully, Video was saved")
            VideoRecorder.exportComplete()
        }
        self.clear()
    }
    
    class func exportError() {
        /*
        if let bounce = ApplicationController.shared.bounce {
            bounce.isExporting = false
            bounce.exportError = true
        }
        BounceEngine.postNotification(BounceNotification.videoExportError)
        */
        
        
        if let bounce = ApplicationController.shared.bounce {
            bounce.exportCancel()
            bounce.exportError = true
            bounce.isExporting = false
            
            ToolActions.setActiveMenusTimeline()
            BounceEngine.postNotification(BounceNotification.videoExportError)
            ToolActions.showExportErrorAlert(withSettingsLink: false)
        }
        
    }
    
    class func exportComplete() {
        DispatchQueue.main.async {
            if let bounce = ApplicationController.shared.bounce {
                bounce.isExporting = false
                bounce.exportError = false
                bounce.exportFinished = true
            }
            BounceEngine.postNotification(BounceNotification.videoExportComplete)
        }
    }
    
}

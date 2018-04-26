//
//  AudioRecorder.swift
//  Bounce
//
//  Created by Raptis, Nicholas on 1/2/18.
//  Copyright © 2018 Darkswarm LLC. All rights reserved.
//

import UIKit
import AVFoundation

var recordButton: UIButton!
var recordingSession: AVAudioSession!
var audioRecorder: AVAudioRecorder!

class AudioRecorder: NSObject {
    
    var audioPlayer: AVAudioPlayer?
    
    static var audioPath = FileUtils.getDocsPath("export_sound.caf")
    
    func clear() {
        
        if let player = audioPlayer {
            player.delegate = nil
            player.stop()
            audioPlayer = nil
        }
        
        if audioRecorder !== nil {
            audioRecorder.deleteRecording()
            audioRecorder = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch let error as NSError {
            print("audioSession Active error: \(error.localizedDescription)")
        }
        
        if FileUtils.fileExists(AudioRecorder.audioPath) {
            FileUtils.deleteFile(AudioRecorder.audioPath)
        }
    }
    
    func recordBegin(completion: @escaping (Bool) -> Void) {
        clear()
        let url = URL(fileURLWithPath: AudioRecorder.audioPath)
        let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue, AVEncoderBitRateKey: 16, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0] as [String : AnyObject]
        do {
            try audioRecorder = AVAudioRecorder(url: url, settings: recordSettings)
            if audioRecorder !== nil {
                audioRecorder.isMeteringEnabled = true
                audioRecorder.delegate = self
                audioRecorder.prepareToRecord()
            } else {
                print("audio Recorder cannot be created!")
                completion(false)
                return
            }
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        //audioSession.outputVolume = 1.0
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("audioSession Category error: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        audioSession.requestRecordPermission { (allowed: Bool) in
            
            
            do {
                try audioSession.setActive(true)
            } catch let error as NSError {
                print("audioSession Active error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            
            
            print("AUDIO PERMISSION GRANTED: \(allowed)")
            if allowed {
                if audioRecorder.record() {
                    print("audio Recorder SUCCEEDED to Record!")
                    completion(true)
                } else {
                    print("audio Recorder Failed to Record!")
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        /*
         audioSession.requestRecordPermission { (allowed: Bool) in
         
         print("AUDIO PERMISSION GRANTED: \(allowed)")
         
         if allowed {
         
         
         
         
         do {
         try audioRecorder = AVAudioRecorder(url: url, settings: recordSettings)
         if audioRecorder !== nil {
         audioRecorder.isMeteringEnabled = true
         audioRecorder.delegate = self
         audioRecorder.prepareToRecord()
         if audioRecorder.record() {
         print("audio Recorder SUCCEEDED to Record!")
         completion(true)
         } else {
         print("audio Recorder Failed to Record!")
         completion(false)
         }
         } else {
         print("audio Recorder cannot be created!")
         completion(false)
         }
         } catch let error as NSError {
         print("audioSession error: \(error.localizedDescription)")
         completion(false)
         }
         } else {
         completion(false)
         }
         }
         */
        
        
        //audioRecorder = new AV
        
        
        
    }
    
    func recordEnd() {
        if audioRecorder !== nil {
            if audioRecorder.isRecording {
                audioRecorder.stop()
            }
        }
    }
    
    func playStart() {
        
        if audioPlayer === nil {
         
            let url = URL(fileURLWithPath: AudioRecorder.audioPath)
            
       
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: url)
            } catch let error as NSError {
                print("Audio Player Error: \(error.localizedDescription)")
            }
        }
        
        if let player = audioPlayer, let bounce = ApplicationController.shared.bounce {
            
            
            let maxFrame: Int = bounce.recordedEngineStates.count - 1
            if maxFrame > 0 && player.duration > 2.0 {
                
                
                let frame = bounce.timelineFrame
                
                let percent: CGFloat = CGFloat(frame) / CGFloat(maxFrame)
                
                let time: TimeInterval = TimeInterval(percent) * player.duration
                
                
                player.volume = 1.0
                player.currentTime = time
                
                if player.isPlaying == false {
                    player.play()
                }
                
                
            }
            
            
            
            //open var currentTime: TimeInterval
            
            
                
            
        }
        
    }
    
    func playPause() {
        
        if let player = audioPlayer {
            
            if player.isPlaying {
                player.pause()
            }
        }
    }
    
    
    //audioPlayer
    
    
    //audioRecorder
    
    
}


extension AudioRecorder: AVAudioRecorderDelegate {
    
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio Recorder Did Finish Recording... Successfully... \(flag)")
    }
    
    
    /* if an error occurs while encoding it will be reported to the delegate. */
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if error != nil {
            print("Audio Recorder Encode Error: \(error!.localizedDescription)")
        } else {
            print("Audio Recorder Encode Error: (NULL)")
        }
    }
}

extension AudioRecorder: AVAudioPlayerDelegate {
    
    /* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio Player Did Finish Playing... Successfully... \(flag)")
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if error != nil {
            print("Audio Player Decode Error: \(error!.localizedDescription)")
        } else {
            print("Audio Player Decode Error: (NULL)")
        }
    }
    
    public func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        print("Audio Player Begin Interruption")
    }
    
    public func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        print("Audio Player End Interruption")
    }
    
}

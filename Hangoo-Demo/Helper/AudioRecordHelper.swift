//
//  AudioRecordHelper.swift
//  Hangoo-Demo
//
//  Created by Adis Mulabdic on 01.09.2021..
//

import Foundation
import AVFoundation

class AudioRecordHelper: NSObject {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    weak var audioRecorderDelegate: AudioRecordDelegate?
    
    var sendBirdHelper: SendBirdHelper!
    
    func setupAndRequestPermission() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        audioRecorderDelegate?.permissionGranted()
                    } else {
                        audioRecorderDelegate?.permissionDenied()
                    }
                }
            }
        } catch {
            audioRecorderDelegate?.audioFailed()
        }
    }
    
    func startRecord() {
        let audioFilename = getFileURL()
        
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
        
        let settings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatAppleLossless,
                    AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                    AVEncoderBitRateKey: 32000,
                    AVNumberOfChannelsKey: 2,
                    AVSampleRateKey: 44100.0
                ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            audioRecorderDelegate?.recordStart()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            audioRecorderDelegate?.recordFinished()
        } else {
            audioRecorderDelegate?.recordFailed()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getAudioURL(_ stringUrl: String) -> URL? {
        return URL(string: stringUrl)
    }
    
    func getFileURL() -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        return path as URL
    }
    
    func preparPlay(_ urlSendBird: String) {
        guard let url = URL(string: urlSendBird) else {return}
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }

        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 10.0
            audioPlayer.play()
        }
    }
    
//    func preparPlay(_ urlSendBird: String) {
//        guard let url = URL(string: urlSendBird) else {return}
//        let dataTest = try! Data(contentsOf: url)
//        var error: NSError?
//        do {
//            audioPlayer = try AVAudioPlayer(data: dataTest)
//        } catch let error1 as NSError {
//            error = error1
//            audioPlayer = nil
//        }
//
//        if let err = error {
//            print("AVAudioPlayer error: \(err.localizedDescription)")
//        } else {
//            audioPlayer.delegate = self
//            audioPlayer.prepareToPlay()
//            audioPlayer.volume = 10.0
//            audioPlayer.play()
//        }
//    }
 
    
    func stop() {
        audioPlayer.pause()
        audioPlayer = nil
    }
    
    func uploadAudioMessage() {
        let url = getFileURL()
        do {
            let data = try Data(contentsOf: url)
            sendBirdHelper.sendVoiceMessage(data)
        } catch (let err) {
            print(err.localizedDescription)
        }
        
    }
}

extension AudioRecordHelper: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
}

extension AudioRecordHelper: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
}


protocol AudioRecordDelegate: AnyObject {
    func permissionGranted()
    func permissionDenied()
    func audioFailed()
    func recordStart()
    func recordStop()
    func recordFinished()
    func recordFailed()
    
}

//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Created by Viktor Lund on 21.10.20.
//  Copyright © 2020 Viktor Lund. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - PlaySoundsViewController: AVAudioPlayerDelegate
extension PlaySoundsViewController: AVAudioPlayerDelegate {
    
    // MARK: - Alerts
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // MARK: - PlayingState
    
    enum PlayingState { case playing, notPlaying }
    
    // MARK: - Audio Functions
     func setupAudio() {
         do {
             audioFile = try AVAudioFile(forReading: recordedAudioURL!)
         } catch {
             showAlert(Alerts.AudioFileError, message: String(describing: error))
         }
     }
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        audioEngine = AVAudioEngine()
        
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let changRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changRatePitchNode.pitch = pitch
        }
        
        if let rate = rate {
            changRatePitchNode.rate = rate
        }
        audioEngine.attach(changRatePitchNode)
        
        
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        let nodes = [audioPlayerNode, changRatePitchNode, echo ? echoNode : nil, reverb ? reverbNode : nil, audioEngine.outputNode].compactMap { $0 }
        
        connectAudioNodes(nodes)
        
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: .default)
        }

        
        do {
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        audioPlayerNode.play()
    }
    
    func connectAudioNodes(_ nodes: [AVAudioNode]) {
        for x in 0..<nodes.count - 1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    @objc func stopAudio() {
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.notPlaying)
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    func configureUI(_ playState: PlayingState) {
        switch playState {
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
        }
    }
    
    func setPlayButtonsEnabled(_ enabled: Bool) {
        slowButton.isEnabled = enabled
        fastButton.isEnabled = enabled
        lowPitchButton.isEnabled = enabled
        highPitchButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
        stopButton.isEnabled = enabled
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
     
}

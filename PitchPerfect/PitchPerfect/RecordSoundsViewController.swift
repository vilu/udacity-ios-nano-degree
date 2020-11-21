//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Viktor Lund on 04.10.20.
//  Copyright © 2020 Viktor Lund. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordButton: UIButton!
    
    private let stopRecordingSegueId = "stopRecording"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(isRecording: false)
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord)
            try audioRecorder = AVAudioRecorder(url: makeFilePath()!, settings: [:])
        } catch {
            recordingLabel.text = "Oops, something went wrong!"
            return
        }
        
        setupUI(isRecording: true)
        
        
        audioRecorder.isMeteringEnabled = true
        audioRecorder.delegate = self
        audioRecorder.prepareToRecord()
        audioRecorder.record() 
    }
    
    private func setupUI(isRecording: Bool) {
        stopRecordButton.isEnabled = isRecording
        recordButton.isEnabled = !isRecording
        recordingLabel.text = !isRecording ? "Tap to Record" : "Recording in Progress"
    }
    
    private func makeFilePath() -> URL? {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let recordingName = "recordedVoice.wav"
        return URL(string: [dirPath, recordingName].joined(separator: "/"))
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        setupUI(isRecording: false)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: stopRecordingSegueId, sender: audioRecorder.url)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == stopRecordingSegueId {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
}


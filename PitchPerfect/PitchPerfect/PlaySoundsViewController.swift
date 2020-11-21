//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Viktor Lund on 10.10.20.
//  Copyright © 2020 Viktor Lund. All rights reserved.
//

import UIKit
import AVKit


class PlaySoundsViewController: UIViewController {
    
    @IBOutlet var slowButton: UIButton!
    @IBOutlet var fastButton: UIButton!
    @IBOutlet var lowPitchButton: UIButton!
    @IBOutlet var highPitchButton: UIButton!
    @IBOutlet var echoButton: UIButton!
    @IBOutlet var reverbButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
    var recordedAudioURL:URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    
    @IBAction func playSoundForButton(_ sender: UIButton) {
        switch ButtonType(rawValue: sender.tag)! {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 1.5)
        case .chipmunk:
            playSound(pitch: 1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }
        
        configureUI(.playing)
    }
    
    @IBAction func stopButton(_ sender: AnyObject) {
        stopAudio()
    }
    
    override func viewDidLoad() {
        setupAudio()
        setupUI()
    }
    
    private func setupUI() {
        slowButton.imageView?.contentMode = .scaleAspectFit
        fastButton.imageView?.contentMode = .scaleAspectFit
        lowPitchButton.imageView?.contentMode = .scaleAspectFit
        highPitchButton.imageView?.contentMode = .scaleAspectFit
        echoButton.imageView?.contentMode = .scaleAspectFit
        reverbButton.imageView?.contentMode = .scaleAspectFit
        stopButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopAudio()
    }
    
}

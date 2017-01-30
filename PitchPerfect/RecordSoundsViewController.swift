//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by 사규진 on 2017. 1. 2..
//  Copyright © 2017년 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    
    var timer : Timer!
    
    var soundFileURL:URL!
    
    //재녹음 이용
    var recordingResume = false
    var recordingFirst = false
    
    //MARK: 아울렛 선언
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusLabel.text = String(format: "%02d:%02d")
        //재실행 판단자
        recordingResume = false
        recordingFirst = false
    }
    
    
    //타이머
    func updateAudioMeter(_ timer:Timer) {
        
        if audioRecorder.isRecording {
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let s = String(format: "%02d:%02d", min, sec)
            statusLabel.text = s
            audioRecorder.updateMeters()
        }
    }
    
    //오디오 녹음버튼 작동 액션
    @IBAction func recordAudio(_ sender: AnyObject) {
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(RecordSoundsViewController.updateAudioMeter), userInfo: nil, repeats: true)
        
        
        recordingLabel.text = "Recording in progress"
        stopRecordingButton.isEnabled = true //녹음 버튼 눌렀을시 정지버튼 활성화
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
       
        //재녹음
        if recordingFirst == true{
            //녹음 일시정지
            recordingLabel.text = "Paused"
            audioRecorder.pause()
            recordingResume = true
            recordingFirst = false
        } else if recordingFirst == false && recordingResume == false {
            //녹음 시작
            recordingFirst = true
            try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } else if recordingResume == true {
            //재녹음
            recordingFirst = true
            audioRecorder.record()
        }
       
       
    }
    
    //녹음 정지 버튼 액션
    @IBAction func stopRecording(_ sender: AnyObject) {
        recordButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        recordingLabel.text = "Tap to Record"
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        timer.invalidate()
    }
    
    //녹음이 끝난 뒤 작동
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successful")
        }

    }
    
    //녹음이 끝난 뒤 세그웨이 화면 전환
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
}


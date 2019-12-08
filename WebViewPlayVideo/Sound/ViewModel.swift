//
//  ViewModel.swift
//  SoundWave
//
//  Created by Bastien Falcou on 12/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

struct SoundRecord {
    var audioFilePathLocal: URL?
    var meteringLevels: [Float]?
}

final class ViewModel {
    var audioVisualizationTimeInterval: TimeInterval = 0.05 // Time interval between each metering bar representation

    var currentAudioRecord: SoundRecord?
    private var isPlaying = false

    var audioMeteringLevelUpdate: ((Float) -> ())?
    var audioDidFinish: (() -> ())?

    init() {
        // notifications update metering levels
        NotificationCenter.default.addObserver(self, selector: #selector(ViewModel.didReceiveMeteringLevelUpdate),
                                               name: .audioRecorderManagerMeteringLevelDidUpdateNotification, object: nil)

        // notifications audio finished
        NotificationCenter.default.addObserver(self, selector: #selector(ViewModel.didFinishRecordOrPlayAudio),
                                               name: .audioRecorderManagerMeteringLevelDidFinishNotification, object: nil)
    }

    // MARK: - Recording

    func askAudioRecordingPermission(completion: ((Bool) -> Void)? = nil) {
        return AudioRecorderManager.shared.askPermission(completion: completion)
    }

    func startRecording(completion: @escaping (SoundRecord?, Error?) -> Void) {
        AudioRecorderManager.shared.startRecording(with: self.audioVisualizationTimeInterval, completion: { [weak self] url, error in
            guard let url = url else {
                completion(nil, error!)
                return
            }

            self?.currentAudioRecord = SoundRecord(audioFilePathLocal: url, meteringLevels: [])
            print("sound record created at url \(url.absoluteString))")
            completion(self?.currentAudioRecord, nil)
        })
    }


    func resetRecording() throws {
        try AudioRecorderManager.shared.reset()
        self.isPlaying = false
        self.currentAudioRecord = nil
    }

   
    // MARK: - Notifications Handling

    @objc private func didReceiveMeteringLevelUpdate(_ notification: Notification) {
        let percentage = notification.userInfo![audioPercentageUserInfoKey] as! Float
        self.audioMeteringLevelUpdate?(percentage)
    }

    @objc private func didFinishRecordOrPlayAudio(_ notification: Notification) {
        self.audioDidFinish?()
    }
}

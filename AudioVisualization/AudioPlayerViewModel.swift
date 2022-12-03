//
//  AudioPlayerViewModel.swift
//  AudioVisualization
//
//  Created by Karen Mirakyan on 04.12.22.
//

import Foundation
import AVKit
import SwiftUI
import AVFoundation
import Combine

class AudioPlayViewModel: ObservableObject {
    
    private var timer: Timer?
    
    @Published var isPlaying: Bool = false
    
    @Published public var soundSamples = [AudioPreviewModel]()
    let sample_count: Int
    var index = 0
    let url: URL
    
    var dataManager: ServiceProtocol
    
    @Published var player: AVPlayer!
    @Published var session: AVAudioSession!
    
    init(url: URL, sampels_count: Int, dataManager: ServiceProtocol = Service.shared) {
        self.url = url
        self.sample_count = sampels_count
        self.dataManager = dataManager
        
        visualizeAudio()
        
        
        do {
            session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord)

            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            
        } catch {
            print(error.localizedDescription)
        }
        
        player = AVPlayer(url: self.url)
    }

    func startTimer() {
        
        count_duration { duration in
            let time_interval = duration / Double(self.sample_count)

            self.timer = Timer.scheduledTimer(withTimeInterval: time_interval, repeats: true, block: { (timer) in
                if self.index < self.soundSamples.count {
                    withAnimation(Animation.linear) {
                        self.soundSamples[self.index].color = Color.black
                    }
                    self.index += 1
                }
            })
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.player.pause()
        self.player.seek(to: .zero)
        self.timer?.invalidate()
        self.isPlaying = false
        self.index = 0
        self.soundSamples = self.soundSamples.map { tmp -> AudioPreviewModel in
            var cur = tmp
            cur.color = Color.gray
            return cur
        }
    }
    
    func playAudio() {
        
        if isPlaying {
            pauseAudio()
        } else {
            
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)

            isPlaying.toggle()
            player.play()
            
            startTimer()
            count_duration { _ in }
        }
    }
    
    func pauseAudio() {
        player.pause()
        timer?.invalidate()
        self.isPlaying = false
    }

    
    func count_duration(completion: @escaping(Float64) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            if let duration = self.player.currentItem?.asset.duration {
                let seconds = CMTimeGetSeconds(duration)
                DispatchQueue.main.async {
                    completion(seconds)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(1)
            }
        }

    }
    
    func visualizeAudio() {
        dataManager.buffer(url: url, samplesCount: sample_count) { results in
            self.soundSamples = results
        }
    }
    
    func removeAudio() {
        do {
            try FileManager.default.removeItem(at: url)            
        } catch {
            print(error)
        }
    }

}

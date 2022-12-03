//
//  ContentView.swift
//  AudioVisualization
//
//  Created by Karen Mirakyan on 04.12.22.
//

import SwiftUI
import AVFoundation
import AVKit

struct ContentView: View {
    @StateObject private var audioVM: AudioPlayViewModel
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 70) / 2 // between 0.1 and 35
        
        return CGFloat(level * (40/35))
    }
    
    init(audio: String) {
        _audioVM = StateObject(wrappedValue: AudioPlayViewModel(url: URL(string: audio)!, sampels_count: Int(UIScreen.main.bounds.width * 0.6 / 4)))
    }
    
    var body: some View {
        VStack( alignment: .leading ) {
            
            LazyHStack(alignment: .center, spacing: 10) {
                
                Button {
                    if audioVM.isPlaying {
                        audioVM.pauseAudio()
                    } else {
                        audioVM.playAudio()
                    }
                } label: {
                    Image(systemName: !(audioVM.isPlaying) ? "play.fill" : "pause.fill" )
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)

                }
                
                HStack(alignment: .center, spacing: 2) {
                    if audioVM.soundSamples.isEmpty {
                        ProgressView()
                    } else {
                        ForEach(audioVM.soundSamples, id: \.self) { model in
                            BarView(value: self.normalizeSoundLevel(level: model.magnitude), color: model.color)
                        }
                    }
                }.frame(width: UIScreen.main.bounds.width * 0.6)
            }
            
            
        }.padding(.vertical, 8)
            .padding(.horizontal)
            .frame(minHeight: 0, maxHeight: 50)
            .background(Color.gray.opacity(0.3).cornerRadius(10))
    }
}

struct BarView: View {
    let value: CGFloat
    var color: Color = Color.gray
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .cornerRadius(10)
                .frame(width: 2, height: value)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audio: "audio.mp3")
    }
}

//
//  AudioVisualizationApp.swift
//  AudioVisualization
//
//  Created by Karen Mirakyan on 04.12.22.
//

import SwiftUI

@main
struct AudioVisualizationApp: App {
    let audio = "your url here"
    var body: some Scene {
        WindowGroup {
            ContentView(audio: audio)
        }
    }
}

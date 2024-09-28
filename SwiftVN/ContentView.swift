//
//  ContentView.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import SwiftUI
// import SwiftData

struct ContentView: View {
    @State private var isPlaying = false;
    
    let audioManager = AudioManager()
    let scriptManager = ScriptManager()
    
    var body: some View {
        VStack {
            Button(isPlaying ? "Pause" : "Play")
            {
                audioManager.loadMusic(path: "sample.ogg")
                audioManager.playMusic()
                
                isPlaying.toggle()
            }
        }
    }
}

#Preview {
    ContentView()
}

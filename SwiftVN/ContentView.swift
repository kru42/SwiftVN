//
//  ContentView.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import SwiftUI
// import SwiftData

struct ContentView: View {
    @State private var isPlaying = false
    
    let vn = SwiftVN()
    let audioManager = AudioManager()
    let scriptManager = ScriptManager()
    
    var body: some View {
        VStack {
            Button("Load") {
                vn.emitLoadEvent()
            }
            
            Button(isPlaying ? "Pause" : "Play") {
                if (!isPlaying) {
                    audioManager.loadMusic(title: "s02.mp3")
                    audioManager.playMusic()
                } else {
                    audioManager.clearMusic()
                }
                
                isPlaying.toggle()
                
//                let str = scriptManager.find(fileName: "s01.scr")
//                if (str != nil) {
//                    print("ok")
//                } else {
//                    print("lmao")
//                }
            }
        }
    }
}

#Preview {
    ContentView()
}

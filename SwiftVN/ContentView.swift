//
//  ContentView.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import SwiftUI

// SwiftUI View
struct ContentView: View {
    @StateObject private var viewModel = ImageViewModel.shared
    
    private let vn: SwiftVN = SwiftVN()
    
    init() {
        vn.prepareAssets()
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5, anchor: .center)
            } else {
                // Draw the background with alpha
                if let bgImage = viewModel.backgroundImage {
                    bgImage
                        .resizable()
                        .scaledToFill()
                        .opacity(viewModel.alpha)
                }
                
                // Draw the foreground images
                ForEach(viewModel.images) { imageModel in
                    imageModel.image
                        .resizable()
                        .position(x: imageModel.x, y: imageModel.y)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if ImageViewModel.hasLoaded {
                    // Load background and images
                    viewModel.loadBackground(path: "ba05no1.jpg", withAnimationFrames: 60)
                    viewModel.setForegroundImage(fileName: "kouji12.png", x: 100, y: 100)
                }
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

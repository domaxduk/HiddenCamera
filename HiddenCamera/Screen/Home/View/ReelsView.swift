//
//  ReelsView.swift
//  HiddenCamera
//
//  Created by Tra Le on 12/2/25.
//

import SwiftUI
import SakuraExtension
import VideoPlayer
import AVKit
import GoogleMobileAds
import Lottie

struct ReelsView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    @ViewBuilder
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 1)
                    
                    if viewModel.reels.isEmpty {
                        ProgressView().circleprogressColor(.black)
                    } else {
                        ForEach(viewModel.reels.indices, id: \.self) { index in
                            let reel = viewModel.reels[index]
                            ReelItemView(duration: viewModel.downloadedReels.first(where: { $0.filename == reel.filename})?.duration,
                                         reel: reel)
                            .onTapGesture {
                                viewModel.input.selectReel.onNext(reel)
                            }
                            .padding(.top, 16)
                            
                            if (index + 1) % 3 == 0 && !viewModel.isPremium {
                                NativeContentView(padding: .init(top: 16))
                            }
                        }
                    }
                }
                .padding(.init(top: 0, leading: 20, bottom: 20, trailing: 20))
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - ReelScrollView
struct ReelScrollView: View {
    @State private var offset: CGFloat = 0
    @ObservedObject var viewModel: HomeViewModel  // Assume viewModel contains reels
    @State var currentTime: CMTime = .zero
    
    @ViewBuilder
    var body: some View {
        if let currentReel = viewModel.currentReel {
            ZStack {
                let previousReel = viewModel.findPreviousReel(from: currentReel)
                let nextReel = viewModel.findNextReel(from: currentReel)
                
                // Previous Reel (Above)
                ReelDetailView(viewModel: viewModel, 
                               currentReel: $viewModel.currentReel,
                               reel: previousReel,
                               currentTime: $currentTime)
                    .offset(y: offset - UIScreen.main.bounds.height)
                
                // Current Reel
                ReelDetailView(viewModel: viewModel, 
                               currentReel: $viewModel.currentReel, 
                               reel: currentReel,
                               currentTime: $currentTime)
                    .offset(y: offset)
                
                // Next Reel (Below)
                ReelDetailView(viewModel: viewModel, 
                               currentReel: $viewModel.currentReel, 
                               reel: nextReel,
                               currentTime: $currentTime)
                    .offset(y: offset + UIScreen.main.bounds.height)
                
                VStack {
                    HStack {
                        Image("ic_back")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24)
                            .padding(5)
                            .foreColor(.white)
                            .onTapGesture {
                                viewModel.input.selectReel.onNext(nil)
                            }
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                
                if viewModel.isTheFirstSwipe {
                    ZStack {
                        Color.black.opacity(0.5).ignoresSafeArea()
                        LottieView(animation: .named("nextvideo"))
                            .playing(loopMode: .loop)
                    }
                    .onTapGesture {
                        withAnimation {
                            viewModel.isTheFirstSwipe = false
                        }
                    }
                }
            }
            .background(Color.black.ignoresSafeArea())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if viewModel.isTheFirstSwipe {
                            viewModel.isTheFirstSwipe = false
                        }
                        
                        offset = value.translation.height
                    }
                    .onEnded { value in
                        let threshold = UIScreen.main.bounds.height / 3
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if offset > threshold {
                                // Move to Previous Reel
                                previousReel(reel: currentReel)
                            } else if offset < -threshold {
                                // Move to Next Reel
                                nextReel(reel: currentReel)
                            } else {
                                // Stay on current reel (return to center)
                                offset = 0
                            }
                        }
                    }
            )
        }
    }
    
    private func nextReel(reel: Reel) {
        let newReel = viewModel.findNextReel(from: reel)

        withAnimation(.easeInOut(duration: 0.3)) {
            offset = -UIScreen.main.bounds.height
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.input.swipeReel.onNext(newReel)
            self.offset = .zero
        }
    }
    
    private func previousReel(reel: Reel) {
        let newReel = viewModel.findPreviousReel(from: reel)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            offset = UIScreen.main.bounds.height
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentTime = .zero
            viewModel.input.swipeReel.onNext(newReel)
            self.offset = .zero
        }
    }
}


// MARK: - ReelDetailView
fileprivate struct ReelDetailView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var currentReel: Reel?
    let reel: Reel
    
    @Binding var currentTime: CMTime
    @State var isPlaying: Bool = false
    
    @State var percent: CGFloat = 0 {
        didSet {
            let timeScale = CMTimeScale(NSEC_PER_SEC)
            let second = CGFloat(percent) * reel.duration
            let time = CMTime(seconds: second, preferredTimescale: timeScale)
            self.currentTime = time
        }
    }
    
    var isDownloaded: Bool {
        return viewModel.downloadedReels.contains(where: { $0.id == reel.id })
    }
    
    var body: some View {
        ZStack {
            if isDownloaded{
                VideoPlayer(url: reel.localURL, play: $isPlaying,
                            time: $currentTime)
                    .contentMode(.scaleAspectFit)
                    .autoReplay(true)
            } else {
                ProgressView()
                    .circleprogressColor(.white)
            }
            
                        
            VStack(spacing: 0) {
                Color.clear
                
                HStack {
                    Text(reel.title)
                        .font(Poppins.semibold.font(size: 18))
                        .textColor(.app(.light01))
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
               
                
                if isDownloaded {
                    seekBar.padding(.top, 12)
                    
                    controlView
                        .padding(.top, 12)
                        .padding(.bottom, 10)
                    
                    if !viewModel.isPremium {
                        BannerContentView(isCollapse: false, needToReload: nil)
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .onAppear(perform: {
            self.isPlaying = currentReel == reel
        })
    }
    
    var seekBar: some View {
        HStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * CGFloat(currentTime.seconds / reel.duration))
                    
                    Spacer()
                }
                .cornerRadius(3)
                .overlay(
                    HStack(spacing: 0) {
                        if geometry.size.width * CGFloat(currentTime.seconds / reel.duration) - 16 >= 0 {
                            Color.clear.frame(width: geometry.size.width * CGFloat(currentTime.seconds / reel.duration) - 16)
                        }
                        
                        Circle()
                            .fill(Color.app(.main))
                            .frame(height: 16)
                        
                        Spacer(minLength: 0)
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        let process = min(max(0, CGFloat(value.location.x / geometry.size.width)), 1)
                        self.percent = process
                    })
                    .onEnded({ value in
                        let process = min(max(0, CGFloat(value.location.x / geometry.size.width)), 1)
                        self.percent = process
                    })
                )
            }.frame(height: 6)
        }
        .padding(.horizontal, 20)
        .frame(width: UIScreen.main.bounds.width)
    }
    
    var controlView: some View {
        HStack(spacing: 40) {
            Image("ic_backward")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
                .onTapGesture {
                    let timeScale = CMTimeScale(NSEC_PER_SEC)
                    let second = max(currentTime.seconds - 10, 0)
                    let time = CMTime(seconds: second, preferredTimescale: timeScale)
                    self.currentTime = time
                }
                .foreColor(.white)
            
            Circle()
                .fill(Color.white)
                .frame(width: 60)
                .overlay(
                    Image("ic_\(isPlaying ? "pause" : "play")")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28)
                        .foreColor(.black)
                )
                .onTapGesture {
                    isPlaying.toggle()
                }
            
            Image("ic_forward")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
                .onTapGesture {
                    let timeScale = CMTimeScale(NSEC_PER_SEC)
                    let second = min(currentTime.seconds + 10, reel.duration)
                    let time = CMTime(seconds: second, preferredTimescale: timeScale)
                    self.currentTime = time
                }
                .foreColor(.white)
        }
        .frame(height: 60)
        
    }
}

// MARK: - ReelItemView
fileprivate struct ReelItemView: View {
    var duration: Double?
    var reel: Reel
    
    var body: some View {
        HStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.app(.light05))
                .frame(width: 44, height: 44)
                .overlay(
                    Image("ic_reel")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                )
            VStack(alignment: .leading, spacing: 0) {
                Text(reel.title)
                    .textColor(.app(.light12))
                    .font(Poppins.semibold.font(size: 14))
                
                Text(durationDescription)
                    .textColor(.app(.light09))
                    .font(Poppins.regular.font(size: 12))
                    .padding(.top, 4)
            }
            .padding(.leading, 16)
            
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(minHeight: 84)
        .background(Color.app(.light01))
        .cornerRadius(16, corners: .allCorners)
    }
    
    var durationDescription: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(duration ?? 0)) ?? "00:00"
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

//
//  CameraResultViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import UIKit
import RxSwift
import AVFoundation
import SwiftUI
import SakuraExtension

struct CameraResultViewModelInput: InputOutputViewModel {
    var didTapPlay = PublishSubject<()>()
    var mask =  PublishSubject<CameraResultTag>()
    var didTapBack = PublishSubject<()>()
}

struct CameraResultViewModelOutput: InputOutputViewModel {

}

struct CameraResultViewModelRouting: RoutingOutput {
    var back = PublishSubject<()>()
}

final class CameraResultViewModel: BaseViewModel<CameraResultViewModelInput, CameraResultViewModelOutput, CameraResultViewModelRouting> {
    @Published var player: SakuraVideoPlayer
    @Published var percent: CGFloat = 0
    @Published var isPlaying: Bool = false
    @Published var isSeeking: Bool = false
    var asset: AVAsset!
    @Published var item: CameraResultItem
    
    private let dao = CameraResultDAO()
    
    init(item: CameraResultItem) {
        self.item = item
        let url = FileManager.documentURL().appendingPathComponent(item.fileName)
        self.asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = SakuraVideoPlayer(playerItem: playerItem)
        super.init()
        configPlayer()
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapPlay.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.isPlaying.toggle()
            
            if isPlaying {
                playVideo()
            } else {
                pauseVideo()
            }
        }).disposed(by: self.disposeBag)
        
        input.mask.subscribe(onNext: { [weak self] tag in
            guard let self else { return }
            self.item.tag = tag
            
            withAnimation {
                self.objectWillChange.send()
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapBack.subscribe(onNext: { [weak self] tag in
            guard let self else { return }
            self.player.removePlayerObserver()
            self.dao.addObject(item: item)
            self.routing.back.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    private func configPlayer() {
        player.config()
        player.delegate = self
        player.addPlayerObserver()
    }
    
    // MARK: - PlayVideo
    func playVideo() {
        if player.currentTime() == duration() {
            seek(.zero)
        }
        
        player.play()
    }
    
    func pauseVideo() {
        player.pause()
    }
    
    func seek(_ time: CMTime) {
        player.seek(to: time)
    }
    
    func seek(process: CGFloat) {
        let second = CGFloat(process * asset.duration.seconds)
        let time = CMTime(seconds: second, preferredTimescale: 3600)
        self.player.seek(to: time)
        self.percent = process
    }
}

// MARK: - SakuraVideoPlayerDelegate
extension CameraResultViewModel: SakuraVideoPlayerDelegate {
    func videoPlayerDidPlaying(_ player: SakuraVideoPlayer, _ progress: Double) {
        if !isSeeking {
            self.percent = progress
        }
    }
    
    func videoPlayerUpdatePlayingState(_ player: SakuraVideoPlayer, isPlaying: Bool) {
        self.isPlaying = isPlaying
    }
}

// MARK: - Get
extension CameraResultViewModel {
    var title: String {
        switch item.type {
        case .aiDetector:
            "AI Camera Scanner Result"
        case .infrared:
            "IR Vision Camera Result"
        }
    }
    
    var tag: CameraResultTag? {
        return item.tag
    }
    
    func duration() -> CMTime {
        return player.duration
    }
    
    func currentTime() -> String {
        let duration = self.player.duration.seconds
        if !duration.isNormal {
            return "00:00"
        }
        
        var timeDescription = ""
        
        let seconds = Int(duration * percent)
        let hour = seconds / 3600
        let minute = (seconds - hour * 3600) / 60
        let second = seconds - hour * 3600 - minute * 60
        
        if hour > 0 {
            timeDescription += String(format: "%02d:", hour)
        }
        
        timeDescription += String(format: "%02d:%02d", minute, second)
        
        
        return timeDescription
    }
}

#Preview {
    CameraResultView(viewModel: CameraResultViewModel(item: .init(id: "", fileName: "test", type: .infrared)))
}


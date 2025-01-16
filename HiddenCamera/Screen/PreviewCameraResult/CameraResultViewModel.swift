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
    var didTapNext = PublishSubject<()>()
    var changeOffsetTime = PublishSubject<Double>()
}

struct CameraResultViewModelOutput: InputOutputViewModel {

}

struct CameraResultViewModelRouting: RoutingOutput {
    var back = PublishSubject<()>()
    var nextTool = PublishSubject<()>()
}

final class CameraResultViewModel: BaseViewModel<CameraResultViewModelInput, CameraResultViewModelOutput, CameraResultViewModelRouting> {
    @Published var player: SakuraVideoPlayer
    @Published var percent: CGFloat = 0
    @Published var isPlaying: Bool = false
    @Published var isSeeking: Bool = false
    @Published var item: CameraResultItem
    @Published var tag: CameraResultTag?
    
    var asset: AVAsset!

    private let dao = CameraResultDAO()
    let scanOption: ScanOptionItem?
    
    init(item: CameraResultItem, scanOption: ScanOptionItem?) {
        self.item = item
        self.scanOption = scanOption
        
        if scanOption == nil {
            self.tag = item.tag
        } else {
            self.tag = nil
        }
        
        self.player = SakuraVideoPlayer()
        super.init()
        configPlayer()
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapNext.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.routing.nextTool.onNext(())
        }).disposed(by: self.disposeBag)
        
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
            self.tag = tag
            self.item.tag = tag
            self.dao.addObject(item: item)
            
            if item.type == .aiDetector {
                self.scanOption?.suspiciousResult[.cameraDetector] = tag == .risk ? 1 : 0
            } else {
                self.scanOption?.suspiciousResult[.infraredCamera] = tag == .risk ? 1 : 0
            }
                        
            withAnimation {
                self.objectWillChange.send()
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapBack.subscribe(onNext: { [weak self] tag in
            guard let self else { return }
            self.player.removePlayerObserver()
            self.routing.back.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.changeOffsetTime.subscribe(onNext: { [weak self] value in
            guard let self else { return }
            let currentTime = self.player.currentTime() + value.convertToTime()
            self.seek(time: currentTime)
        }).disposed(by: self.disposeBag)
    }
    
    private func configPlayer() {
         let url = FileManager.documentURL().appendingPathComponent(item.fileName)
         self.asset = AVAsset(url: url)
         let playerItem = AVPlayerItem(asset: asset)
        player.replacePlayerItem(playerItem)
        player.config()
        player.delegate = self
        player.addPlayerObserver()
    }
    
    // MARK: - PlayVideo
    func playVideo() {
        if player.currentTime() == asset.duration {
            self.seek(time: .zero)
        }
        
        player.play()
    }
    
    func pauseVideo() {
        player.pause()
    }
    
    func seek(time: CMTime) {
        player.seekTo(time)
    }
    
    func seek(process: CGFloat) {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let second = CGFloat(process) * asset.duration.seconds
        let time = CMTime(seconds: second, preferredTimescale: timeScale)
        self.seek(time: time)
        self.percent = process
    }
}

extension Double {
    func convertToTime() -> CMTime {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        return CMTime(seconds: self, preferredTimescale: timeScale)
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
        if !isSeeking {
            self.isPlaying = isPlaying
        }
    }
    
    func videoPlayerPlayToEnd(_ player: SakuraVideoPlayer) {
        print("videoPlayerPlayToEnd")
        player.seekTo(.zero)
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


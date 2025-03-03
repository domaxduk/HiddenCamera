//
//  CCTVViewModel.swift
//  HiddenCamera
//
//  Created by Tra Le on 11/2/25.
//

import UIKit
import RxSwift
import AVKit
import SwiftUI

struct CCTVViewModelInput: InputOutputViewModel {
    var back = PublishSubject<()>()
    var didTapZoom = PublishSubject<()>()
}

struct CCTVViewModelOutput: InputOutputViewModel {

}

struct CCTVViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
}

final class CCTVViewModel: BaseViewModel<CCTVViewModelInput, CCTVViewModelOutput, CCTVViewModelRouting> {
    @Published var didAppear: Bool = false
    @Published var isMuted: Bool = false
    @Published var isZoom: Bool = false
    @Published var info: CCTVInfoFetcher.Result? {
        didSet {
            print("[URL STREAM] \(info?.link)")
        }
    }
    
    private var timer: Timer?
    let cctv: CCTV
    
    init(cctv: CCTV) {
        self.cctv = cctv
        
        super.init()
        
        getInfo()
    }
    
    override func configInput() {
        super.configInput()
        
        input.back.subscribe(onNext: { [weak self] in
            self?.timer?.invalidate()
            self?.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didTapZoom.subscribe(onNext: { [weak self] in
            guard let self else { return }
            if isPremium {
                withAnimation {
                    self.isZoom.toggle()
                }
            } else {
                SubscriptionViewController.open { }
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.init(timeInterval: 3600, repeats: false, block: { [weak self] _ in
            self?.getInfo()
        })
    }
    
    private func getInfo() {
        let task = CCTVInfoFetcher.getM3u8Link(from: cctv.path, completion: { [weak self] result, error in
            guard let self else { return }
            if let result {
                DispatchQueue.main.async {
                    self.info = result
                    self.startTimer()
                }
            }
            
            if let error {
                print("[GET INFO CCTV] \(error)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    self?.getInfo()
                }
            }
        })
        
        task?.resume()
    }
}

// MARK: - CCTVViewModel
extension CCTVViewModel {
    var title: String {
        return cctv.name
    }
    
    var location: String {
        return cctv.location
    }
    
    var views: String? {
        return info?.views
    }
    
    var link: URL? {
        let path = info?.link ?? ""
        return URL(string: path)
    }
}

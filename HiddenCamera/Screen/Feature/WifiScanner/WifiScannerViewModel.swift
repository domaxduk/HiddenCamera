//
//  WifiScannerViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import UIKit
import RxSwift
import SwiftUI
import FirebaseAnalytics

enum ScannerState {
    case ready
    case isScanning
    case done
}

struct WifiScannerViewModelInput: InputOutputViewModel {
    var didTapScan = PublishSubject<()>()
    var viewResult = PublishSubject<()>()
    var didTapBack = PublishSubject<()>()
    var didTapNext = PublishSubject<()>()
    
    var didTapRemoveAd = PublishSubject<()>()
    var didTapContinueAds = PublishSubject<()>()
}

struct WifiScannerViewModelOutput: InputOutputViewModel {

}

struct WifiScannerViewModelRouting: RoutingOutput {
    var routeToResult =  PublishSubject<[Device]>()
    var showErrorMessage = PublishSubject<String>()
    var stop = PublishSubject<()>()
    var nextTool = PublishSubject<()>()
}

final class WifiScannerViewModel: BaseViewModel<WifiScannerViewModelInput, WifiScannerViewModelOutput, WifiScannerViewModelRouting> {
    @Published var state: ScannerState = .ready
    @Published var percent: Double = 0
    @Published var seconds: Double = 0
    @Published var devices = [LANDevice]()
    @Published var showingDevice = [LANDevice]()
    
    @Published var isLoading: Bool = false
    @Published var isShowingLocationDialog: Bool = false
    @Published var isShowingLocalNetworkDialog: Bool = false
    @Published var isShowingRemoveAdDialog: Bool = false
    
    @Published var networkName = NetworkUtils.getWifiName()
    @Published var ip = NetworkUtils.currentIPAddress()

    private var index: Int = 0
    private var timer: Timer?
    let scanOption: ScanOptionItem?
    
    init(scanOption: ScanOptionItem?) {
        self.scanOption = scanOption
        super.init()
        
        if let scanOption {
            switch scanOption.type {
            case .option:
                Analytics.logEvent("feature_option_wifi", parameters: nil)
            case .full:
                if scanOption.isThreadAfterIntro {
                    Analytics.logEvent("first_wifi", parameters: nil)
                }
            default: break
            }
        }
        
        LocalNetworkDetector.shared.delegate = self
    }
    
    override func config() {
        super.config()
        configNotificationCenter()
    }
    
    private func configNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateNetworkInfo), name: .didChangeNetworkStatus, object: nil)
    }
    
    @objc private func updateNetworkInfo() {
        self.networkName = NetworkUtils.getWifiName()
        self.ip = NetworkUtils.currentIPAddress()
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapScan.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            // Chặn scan again đối với free user
            if state == .done && !UserSetting.isPremiumUser {
                SubscriptionViewController.open { }
                return
            }
            
            // Nếu là scan option
            if let scanOption {
                if scanOption.suspiciousResult.contains(where: { $0.key == .wifiScanner }) && !UserSetting.isPremiumUser {
                    SubscriptionViewController.open { }
                } else {
                    prepareToScan()
                }
                
                return
            }
            
            // Nếu là scan thường
            if UserSetting.canUsingFeature(.wifi) {
                prepareToScan()
                UserSetting.increaseUsedFeature(.wifi)
            } else {
                SubscriptionViewController.open { }
            }
        }).disposed(by: self.disposeBag)
        
        input.viewResult.subscribe(onNext: { [weak self] _ in
            guard let self else {return}
            self.routing.routeToResult.onNext(devices)
            self.state = .ready
        }).disposed(by: self.disposeBag)
        
        input.didTapBack.subscribe(onNext: { [weak self] _ in
            guard let self else{ return }
            
            if state == .done && !UserSetting.isPremiumUser {
                withAnimation {
                    self.isShowingRemoveAdDialog = true
                }
            } else {
                self.routing.stop.onNext(())
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapNext.subscribe(onNext: { [weak self] _ in
            self?.routing.nextTool.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didTapRemoveAd.subscribe(onNext: { [unowned self] in
            SubscriptionViewController.open { [weak self] in
                guard let self else { return }
                if UserSetting.isPremiumUser {
                    DispatchQueue.main.async {
                        self.isShowingRemoveAdDialog = false
                    }
                }
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapContinueAds.subscribe(onNext: { [unowned self] in
            self.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    private func prepareToScan() {
        if LocationManager.shared.status == .restricted || LocationManager.shared.status == .denied {
            withAnimation {
                self.isShowingLocationDialog = true
            }
            
            return
        }
        
        if let path = NetworkManager.shared.path, !(path.status == .satisfied && !path.isExpensive) {
            self.routing.showErrorMessage.onNext("Please connect to wifi")
            return
        }
                
        self.isLoading = true
        Task {
            let granted = try await requestLocalNetworkAuthorization()
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if granted {
                    self.resetData()
                    self.startTimer()
                    self.startScan()
                } else {
                    withAnimation {
                        self.isShowingLocalNetworkDialog = true
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            seconds = ((seconds + 0.1) * 10).rounded() / 10
            self.percent = seconds / AppConfig.wifiDuration * 100
            
            if Double(Int(seconds)) == seconds {
                if devices.count > index {
                    self.showingDevice.append(self.devices[self.index])
                    
                    index += 1
                }
            }
                        
            if seconds >= AppConfig.wifiDuration {
                timer?.invalidate()
                self.scanOption?.suspiciousResult[.wifiScanner] = suspiciousDevices().count
                
                withAnimation {
                    self.state = .done
                }
            }
        })
    }
    
    private func startScan() {
        print("startScan")
        if state == .isScanning {
             return
        }
        
        self.state = .isScanning
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            LocalNetworkDetector.shared.start()
            LocalNetworkDetector.shared.delegate = self
        }
    }
    
    private func resetData() {
        LocalNetworkDetector.shared.stopScan()
        self.devices.removeAll()
        self.showingDevice.removeAll()
        self.index = 0
        self.seconds = 0
        self.percent = 0
    }
    
    func scanningText() -> String {
        var text = "Scanning"
        let numberOfDot = Int(seconds) % 4
        
        for _ in 0..<numberOfDot {
            text += "."
        }
        
        return text
    }
    
    func suspiciousDevices() -> [LANDevice] {
        return devices.filter({ !$0.isSafe() })
    }
    
    func showBackButton() -> Bool {
        if let scanOption, scanOption.isThreadAfterIntro {
            return scanOption.isEnd && state != .isScanning
        }
        
        return state != .isScanning
    }
}

// MARK: - LocalNetworkDetectorDelegate
extension WifiScannerViewModel: LocalNetworkDetectorDelegate {
    func localNetworkDetector(_ detector: LocalNetworkDetector, updateListDevice devices: [LANDevice]) {
        if state == .done {
            return
        }
                
        DispatchQueue.main.async {
            withAnimation {
                self.devices = devices
                self.objectWillChange.send()
            }
        }
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

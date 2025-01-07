//
//  WifiScannerViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import UIKit
import RxSwift
import SwiftUI

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
    @AppStorage("safe") var safeID = [String]()
    @Published var state: ScannerState = .ready
    @Published var percent: Double = 0
    @Published var seconds: Double = 0
    @Published var devices = [LANDevice]()
    @Published var showingDevice: LANDevice?
    
    @Published var isLoading: Bool = false
    @Published var isShowingLocationDialog: Bool = false
    @Published var isShowingLocalNetworkDialog: Bool = false
    
    @Published var networkName = NetworkUtils.getWifiName()
    @Published var ip = NetworkUtils.currentIPAddress()

    private var index: Int = 0
    private var timer: Timer?
    let hasButtonNext: Bool
    
    init(hasButtonNext: Bool) {
        self.hasButtonNext = hasButtonNext
        super.init()
    }
    
    override func config() {
        super.config()
        configLocalNetworkDetector()
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
            prepareToScan()
        }).disposed(by: self.disposeBag)
        
        input.viewResult.subscribe(onNext: { [weak self] _ in
            guard let self else {return}
            self.routing.routeToResult.onNext(devices)
            self.state = .ready
        }).disposed(by: self.disposeBag)
        
        input.didTapBack.subscribe(onNext: { [weak self] _ in
            LocalNetworkDetector.shared.stopScan()
            self?.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didTapNext.subscribe(onNext: { [weak self] _ in
            LocalNetworkDetector.shared.stopScan()
            self?.routing.nextTool.onNext(())
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
                
        // TODO: - Check Local network permission
        resetData()
        startScan()
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            seconds = ((seconds + 0.1) * 10).rounded() / 10
            self.percent = seconds / AppConfig.wifiDuration * 100
            
            if Double(Int(seconds)) == seconds {
                if devices.count > index {
                    withAnimation {
                        self.showingDevice = self.devices[self.index]
                    }
                    
                    index += 1
                }
            }
                        
            if seconds >= AppConfig.wifiDuration {
                timer?.invalidate()
                
                withAnimation {
                    self.state = .done
                }
            }
        })
    }
    
    private func startScan() {
        if state == .isScanning {
             return
        }
        
        self.state = .isScanning
        LocalNetworkDetector.shared.start()
    }
    
    private func configLocalNetworkDetector() {
        LocalNetworkDetector.shared.delegate = self
    }
    
    private func resetData() {
        self.devices.removeAll()
        self.showingDevice = nil
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
        return devices.filter({ device in
            return !isSafe(device: device)
        })
    }
    
    func isSafe(device: LANDevice) -> Bool {
        return safeID.contains(where: { $0 == device.ipAddress || $0 == device.hostname || $0 ==  device.deviceName() })
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

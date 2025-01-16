//
//  ScannerResultViewModel.swift
//  HiddenCamera
//
//  Created by CucPhung on 5/1/25.
//

import UIKit
import SwiftUI
import RxSwift
import CoreBluetooth
import GoogleMobileAds

struct ScannerResultViewModelInput: InputOutputViewModel {
    var didTapFix = PublishSubject<Device>()
    var moveToSafe = PublishSubject<String>()
    var remove = PublishSubject<String>()
    var didTapBack = PublishSubject<()>()
    var didTapNext = PublishSubject<()>()
}

struct ScannerResultViewModelOutput: InputOutputViewModel {

}

struct ScannerResultViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var showErrorMessage = PublishSubject<String>()
    var nextTool = PublishSubject<()>()
}

final class ScannerResultViewModel: BaseViewModel<ScannerResultViewModelInput, ScannerResultViewModelOutput, ScannerResultViewModelRouting> {
    @Published var currentTab: ScannerResultTab = .safe
    @Published var selectedDeviceID: String?
    @Published var removedDeviceID = [String]()
    
    @Published var safeDevices: [Device]
    @Published var suspiciousDevices: [Device]

    let type: ScannerResultType
    private var lastUpdate: Date?
    let scanOption: ScanOptionItem?
    
    private var nativeLoader: AdsMultiNativeLoader?
    @Published var natives = [GADNativeAd]()
    @Published var susCount: Int
    @Published var safeCount: Int
        
    init(scanOption: ScanOptionItem?, type: ScannerResultType, devices: [Device]) {
        self.type = type
        self.safeDevices = devices.filter({ $0.isSafe() })
        self.suspiciousDevices = devices.filter({ !$0.isSafe() })
        self.scanOption = scanOption
        self.susCount = devices.filter({ !$0.isSafe() }).count
        self.safeCount = devices.filter({ $0.isSafe() }).count
        super.init()
        
        configDiscovery()
        changeTabIfNeed()
        configAdLoader()
    }
    
    private func configAdLoader() {
        if isPremium {
            return
        }
        
        let count = max(susCount / 4, 1) + max(safeCount / 4, 1)
        self.nativeLoader = AdsMultiNativeLoader(numberOfAds: count)
        self.nativeLoader?.load()
        self.nativeLoader?.loadSuccess.subscribe(onNext: { [weak self] in
            guard let self, let natives = self.nativeLoader?.nativeAds else {
                return
            }
            
            DispatchQueue.main.async {
                self.natives = natives
            }
        }).disposed(by: self.disposeBag)
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapFix.subscribe(onNext: { [weak self] device in
            guard let self else { return }
            self.selectedDeviceID = device.id
        }).disposed(by: self.disposeBag)
        
        input.moveToSafe.subscribe(onNext: { [weak self] id in
            guard let self else { return }
            if let index = suspiciousDevices.firstIndex(where: { $0.id == id }) {
                let device = suspiciousDevices[index]
                
                self.selectedDeviceID = nil
                safeDevices.append(device)
                suspiciousDevices.remove(at: index)
                UserSetting.safeDeviceKeys.append(contentsOf: device.keystore)
                self.safeCount += 1
                self.susCount -= 1
                self.currentTab = .safe
                self.scanOption?.suspiciousResult[type == .bluetooth ? .bluetoothScanner : .wifiScanner] = numberOfSuspiciousDevice()
            }
        }).disposed(by: self.disposeBag)
        
        input.remove.subscribe(onNext: { [weak self] id in
            guard let self else { return }
            self.selectedDeviceID = nil
            self.removedDeviceID.append(id)
            self.suspiciousDevices.removeAll(where: { $0.id == id })
            self.scanOption?.suspiciousResult[type == .bluetooth ? .bluetoothScanner : .wifiScanner] = numberOfSuspiciousDevice()
        }).disposed(by: self.disposeBag)
        
        input.didTapBack.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didTapNext.subscribe(onNext: { [weak self] _ in
            self?.routing.nextTool.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    private func configDiscovery() {
        if type == .wifi {
            LocalNetworkDetector.shared.delegate = self
        } else {
            BluetoothScanner.shared.delegate = self
        }
    }
    
    private func changeTabIfNeed() {
        if self.numberOfSafeDevice() == 0 {
            self.currentTab = .suspicious
        }
        
        if self.numberOfSuspiciousDevice() == 0 {
            self.currentTab = .safe
        }
    }
}

// MARK: - LocalNetworkDetectorDelegate
extension ScannerResultViewModel: LocalNetworkDetectorDelegate, BluetoothScannerDelegate {
    func bluetoothScanner(_ scanner: BluetoothScanner, updateListDevice devices: [BluetoothDevice]) {
        if let lastUpdate, abs(lastUpdate.timeIntervalSinceNow) < 0.5 {
            return
        }
        
        self.lastUpdate = Date()
        
        let newsafeDevice = devices.filter({ $0.isSafe() })
        let newsuspiciousDevice = devices.filter({ !$0.isSafe() && !removedDeviceID.contains($0.id) })
        
        self.safeDevices = newsafeDevice
        self.suspiciousDevices = newsuspiciousDevice

        let toolItem: ToolItem = type == .bluetooth ? .bluetoothScanner : .wifiScanner
        self.scanOption?.suspiciousResult[toolItem] = numberOfSuspiciousDevice()
    }
    
    func bluetoothScanner(_ scanner: BluetoothScanner, didUpdateState state: CBManagerState) {
        switch state {
        case .poweredOff:
            self.routing.showErrorMessage.onNext("Your bluetooth is off. Please turn on bluetooth to continue this feature")
        default: break
        }
    }
    
    func localNetworkDetector(_ detector: LocalNetworkDetector, updateListDevice devices: [LANDevice]) {
        self.safeDevices = devices.filter({ $0.isSafe() })
        self.suspiciousDevices = devices.filter({ !$0.isSafe() })
    }
}

// MARK: - Get
extension ScannerResultViewModel {
    func numberOfSafeDevice() -> Int {
        return safeDevices.count
    }
    
    func numberOfSuspiciousDevice() -> Int {
        return suspiciousDevices.count
    }
    
    func device(id: String) -> Device? {
        if let safeDevice = safeDevices.first(where: { $0.id == id }) {
            return safeDevice
        }
        
        return suspiciousDevices.first(where: { $0.id == id })
    }
}

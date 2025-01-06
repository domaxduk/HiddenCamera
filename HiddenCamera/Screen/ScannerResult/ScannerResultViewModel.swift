//
//  ScannerResultViewModel.swift
//  HiddenCamera
//
//  Created by CucPhung on 5/1/25.
//

import UIKit
import SwiftUI
import RxSwift

struct ScannerResultViewModelInput: InputOutputViewModel {
    var didTapFix = PublishSubject<Device>()
    var moveToSafe = PublishSubject<Device>()
    var remove = PublishSubject<Device>()
    var didTapBack = PublishSubject<()>()
}

struct ScannerResultViewModelOutput: InputOutputViewModel {

}

struct ScannerResultViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
}

final class ScannerResultViewModel: BaseViewModel<ScannerResultViewModelInput, ScannerResultViewModelOutput, ScannerResultViewModelRouting> {
    @AppStorage("safe") var safeID = [String]()
    @Published var devices: [Device]
    @Published var currentTab: ScannerResultTab = .safe
    @Published var selectedDevice: Device?
    @Published var removedDevice = [Device]()
    
    private let type: ScannerResultType
    
    init(type: ScannerResultType, devices: [Device]) {
        self.type = type
        self.devices = devices
        super.init()
        
        
        configDiscovery()
        changeTabIfNeed()
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapFix.subscribe(onNext: { [weak self] device in
            guard let self else { return }
            withAnimation {
                self.selectedDevice = device
            }
        }).disposed(by: self.disposeBag)
        
        input.moveToSafe.subscribe(onNext: { [weak self] device in
            guard let self else { return }
            withAnimation {
                self.selectedDevice = nil
                self.safeID.append(contentsOf: device.keystore)
                self.changeTabIfNeed()
            }
        }).disposed(by: self.disposeBag)
        
        input.remove.subscribe(onNext: { [weak self] device in
            guard let self else { return }
            withAnimation {
                self.selectedDevice = nil
                self.removedDevice.append(device)
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapBack.subscribe(onNext: { [weak self] _ in
            self?.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    private func configDiscovery() {
        if type == .wifi {
            LocalNetworkDetector.shared.delegate = self
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
extension ScannerResultViewModel: LocalNetworkDetectorDelegate {
    func localNetworkDetector(_ detector: LocalNetworkDetector, updateListDevice devices: [Device]) {
        withAnimation {
            self.devices = devices
        }
    }
}

// MARK: - Get
extension ScannerResultViewModel {
    func isSafe(device: Device) -> Bool {
        return safeID.contains(where: { $0 == device.ipAddress || $0 == device.hostname || $0 ==  device.deviceName() })
    }
    
    func numberOfSafeDevice() -> Int {
        return safeDevices().count
    }
    
    func numberOfSuspiciousDevice() -> Int {
        return suspiciousDevices().count
    }
    
    func safeDevices() -> [Device] {
        return devices.filter({ device in
            return isSafe(device: device) && !removedDevice.contains(where: { $0.id == device.id })
        })
    }
    
    func suspiciousDevices() -> [Device] {
        return devices.filter({ device in
            return !isSafe(device: device) && !removedDevice.contains(where: { $0.id == device.id })
        })
    }
}

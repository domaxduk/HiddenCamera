//
//  BluetoothScannerViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 6/1/25.
//

import UIKit
import RxSwift
import CoreBluetooth
import SwiftUI

struct BluetoothScannerViewModelInput: InputOutputViewModel {
    var didTapScan = PublishSubject<()>()
    var viewResult = PublishSubject<()>()
    var didTapBack = PublishSubject<()>()
}

struct BluetoothScannerViewModelOutput: InputOutputViewModel {

}

struct BluetoothScannerViewModelRouting: RoutingOutput {
    var routeToResult =  PublishSubject<[BluetoothDevice]>()
    var stop = PublishSubject<()>()
}

final class BluetoothScannerViewModel: BaseViewModel<BluetoothScannerViewModelInput, BluetoothScannerViewModelOutput, BluetoothScannerViewModelRouting> {
    @Published var state: ScannerState = .ready
    @Published var percent: Double = 0
    @Published var seconds: Double = 0
    @Published var showingDevice: BluetoothDevice?
    @Published var devices = [BluetoothDevice]()
    
    private var index: Int = 0
    private var timer: Timer?

    override func config() {
        super.config()
        configBluetoothScanner()
    }
    
    private func configBluetoothScanner() {
        BluetoothScanner.shared.delegate = self
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapScan.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            withAnimation {
                self.state = .isScanning
            }
            
            resetData()
            BluetoothScanner.shared.startScanning()
            startTimer()
        }).disposed(by: self.disposeBag)
        
        input.viewResult.subscribe(onNext: { [weak self] _ in
            guard let self else {return}
            self.routing.routeToResult.onNext(devices)
            self.state = .ready
        }).disposed(by: self.disposeBag)
        
        input.didTapBack.subscribe(onNext: { [weak self] _ in
            BluetoothScanner.shared.stopScanning()
            self?.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    private func resetData() {
        self.timer?.invalidate()
        self.devices.removeAll()
        self.showingDevice = nil
        self.index = 0
        self.seconds = 0
        self.percent = 0
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
}

// MARK: - BluetoothScannerDelegate
extension BluetoothScannerViewModel: BluetoothScannerDelegate {
    func bluetoothScanner(_ scanner: BluetoothScanner, updateListDevice devices: [BluetoothDevice]) {
        if state == .done {
            return
        }
        
        self.devices = devices
    }
    
    func bluetoothScanner(_ scanner: BluetoothScanner, didUpdateState state: CBManagerState) {
        
    }
}

// MARK: - Get
extension BluetoothScannerViewModel {
    func suspiciousDevices() -> [Device] {
        return devices
    }
    
    func scanningText() -> String {
        var text = "Scanning"
        let numberOfDot = Int(seconds) % 4
        
        for _ in 0..<numberOfDot {
            text += "."
        }
        
        return text
    }
}

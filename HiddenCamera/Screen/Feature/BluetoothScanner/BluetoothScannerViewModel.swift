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
    var didTapNext = PublishSubject<()>()
}

struct BluetoothScannerViewModelOutput: InputOutputViewModel {

}

struct BluetoothScannerViewModelRouting: RoutingOutput {
    var routeToResult =  PublishSubject<[BluetoothDevice]>()
    var showErrorMessage = PublishSubject<String>()
    var stop = PublishSubject<()>()
    var nextTool = PublishSubject<()>()
}

final class BluetoothScannerViewModel: BaseViewModel<BluetoothScannerViewModelInput, BluetoothScannerViewModelOutput, BluetoothScannerViewModelRouting> {
    
    @Published var state: ScannerState = .ready
    @Published var percent: Double = 0
    @Published var seconds: Double = 0
    @Published var showingDevice: BluetoothDevice?
    @Published var devices = [BluetoothDevice]()
    
    @Published var isShowingBluetoothDialog: Bool = false
    
    private var index: Int = 0
    private var timer: Timer?
    let scanOption: ScanOptionItem?
    
    init(scanOption: ScanOptionItem?) {
        self.scanOption = scanOption
        super.init()
    }

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
            prepareToStart()
        }).disposed(by: self.disposeBag)
        
        input.viewResult.subscribe(onNext: { [weak self] _ in
            guard let self else {return}
            self.routing.routeToResult.onNext(devices)
        }).disposed(by: self.disposeBag)
        
        input.didTapBack.subscribe(onNext: { [weak self] _ in
            self?.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didTapNext.subscribe(onNext: { [weak self] _ in
            self?.routing.nextTool.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    private func prepareToStart() {
        switch BluetoothScanner.shared.currentState {
        case .unsupported:
            self.routing.showErrorMessage.onNext("Sorry, your device unsupported bluetooth!")
        case .unauthorized:
            withAnimation {
                self.isShowingBluetoothDialog = true
            }
        case .poweredOff:
            self.routing.showErrorMessage.onNext("Please turn on your bluetooth")
        case .poweredOn:
            withAnimation {
                self.state = .isScanning
            }
            
            resetData()
            BluetoothScanner.shared.startScanning()
            startTimer()
        default:
            self.routing.showErrorMessage.onNext("Please scan again after a few seconds!")
        }
    }
    
    private func resetData() {
        BluetoothScanner.shared.stopScanning()
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
            self.percent = seconds / AppConfig.bluetoothDuration * 100
            
            if Double(Int(seconds)) == seconds {
                if devices.count > index {
                    withAnimation {
                        self.showingDevice = self.devices[self.index]
                    }
                    
                    index += 1
                }
            }
                        
            if seconds >= AppConfig.bluetoothDuration {
                timer?.invalidate()
                self.scanOption?.suspiciousResult[.bluetoothScanner] = devices.count
                
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

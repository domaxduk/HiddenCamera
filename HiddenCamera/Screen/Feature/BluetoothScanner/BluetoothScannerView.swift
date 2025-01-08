//
//  BluetoothScannerView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 6/1/25.
//

import SwiftUI
import SakuraExtension
import Lottie
import RxSwift

struct BluetoothScannerView: View {
    @ObservedObject var viewModel: BluetoothScannerViewModel
    @State var currentTab: Int = 0
    
    @ViewBuilder
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                content
            }
            
            if viewModel.isShowingBluetoothDialog {
                PermissionDialogView(type: .bluetooth, isShowing: $viewModel.isShowingBluetoothDialog)
            }
        }
    }
    
    var navigationBar: some View {
        HStack {
            Image("ic_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
                .onTapGesture {
                    viewModel.input.didTapBack.onNext(())
                }
                .padding(.leading, 20)
            
            Text(ToolItem.bluetoothScanner.name)
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
            
            Spacer()
            
            if viewModel.scanOption != nil && viewModel.state != .isScanning {
                Button(action: {
                    viewModel.input.didTapNext.onNext(())
                }, label: {
                    Text("Next")
                        .textColor(.app(.main))
                        .font(Poppins.semibold.font(size: 16))
                        .padding(20)
                })
            }
        }
        .frame(height: AppConfig.navigationBarHeight)
        .frame(height: 56)
    }
    
    // MARK: - Done View
    @ViewBuilder
    var doneView: some View {
        VStack(spacing: 0) {
            Image("ic_bluetooth")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 88)
                .foreColor(.app(.main))
            
            Text("Scan completed!")
                .font(Poppins.semibold.font(size: 14))
                .textColor(.app(.light12))
                .padding(.top, 20)
            
            let numberOfRiskDevice = viewModel.suspiciousDevices().count
            
            if numberOfRiskDevice == 0 {
                AppColor.safeColor.opacity(0.1)
                    .frame(height: 48)
                    .cornerRadius(24, corners: .allCorners)
                    .overlay(
                        HStack {
                            Image("ic_safe")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                            
                            Text("You are safe now!")
                                .font(Poppins.regular.font(size: 14))
                                .scaledToFit()
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }.foreColor(.app(.safe))
                    )
                    .padding(.top, 16)
            } else {
                AppColor.warningColor.opacity(0.1)
                    .frame(height: 48)
                    .cornerRadius(24, corners: .allCorners)
                    .overlay(
                        HStack {
                            Image("ic_risk")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                            
                            Text("Suspicious Devices: \(numberOfRiskDevice)")
                                .font(Poppins.regular.font(size: 14))
                                .scaledToFit()
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }.foreColor(.app(.warning))
                    )
                    .padding(.top, 16)
            }
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(20, corners: .allCorners)
        .padding(.horizontal, 32)
        .padding(.top, UIScreen.main.bounds.height / 15)
        
        HStack(spacing: 12) {
            ZStack {
                Color.clearInteractive
                
                Text("Scan again")
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(.app(.main))
                
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.app(.main), lineWidth: 1.0)
            }.onTapGesture {
                viewModel.input.didTapScan.onNext(())
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.app(.main))
                
                Text("View Result")
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(.white)
            }
            .onTapGesture {
                viewModel.input.viewResult.onNext(())
            }
        }
        .frame(height: 56)
        .padding(.top, 40)
        .padding(.horizontal, 20)
    }
    
    var content: some View {
        VStack {
            if viewModel.state == .done {
                doneView
            }
                        
            if let device = viewModel.showingDevice, viewModel.state == .isScanning {
                LocalDeviceItemView(device: device)
                    .padding(.bottom, 28)
            }
            
            if viewModel.state != .done {
                scanView
            }
        
            if viewModel.state == .ready {
                Button(action: {
                    viewModel.input.didTapScan.onNext(())
                }, label: {
                    Text("Scan now")
                        .font(Poppins.semibold.font(size: 16))
                        .textColor(.white)
                        .padding(.horizontal, 71)
                        .padding(.vertical, 16)
                        .background(Color.app(.main))
                        .cornerRadius(36, corners: .allCorners)
                }).padding()
            }
            
            if viewModel.state == .isScanning {
                Text(viewModel.scanningText())
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(.app(.light11))
            }
            
            Spacer()
            
            
            if viewModel.state == .ready {
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("*")
                            .font(Poppins.semibold.font(size: 14))
                            .textColor(AppColor.warningColor)
                        
                        Text(" Notice:")
                            .font(Poppins.semibold.font(size: 14))
                            .textColor(.app(.light11))
                    }
                    
                    
                    Text("Use Bluetooth technology right on your phone to determine the location and distance of suspicious devices around you.")
                        .font(Poppins.regular.font(size: 14))
                        .textColor(.app(.light11))
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16, corners: .allCorners)
                .padding(20)
            }
        }
    }
    
    @ViewBuilder
    var scanView: some View {
        LottieView(animation: .named("blueCircle"))
            .playing()
            .looping()
            .overlay(
                ZStack {
                    switch viewModel.state {
                    case .ready:
                        Image("ic_bluetooth")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 64)
                    case .isScanning:
                        Text("\(Int(viewModel.percent))%")
                            .font(Poppins.semibold.font(size: 36))
                            .textColor(.white)
                    default:
                        Spacer()
                    }
                }
            )
            .frame(width: UIScreen.main.bounds.width - 60,
                   height: UIScreen.main.bounds.width - 60)
    }
}

// MARK:  - LocalDeviceItemView
fileprivate struct LocalDeviceItemView: View {
    @ObservedObject var device: Device
        
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.app(.main).opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                )
                
            VStack(alignment: .leading, spacing: 4) {
                Text(device.deviceName() ?? "Unknown")
                    .font(Poppins.semibold.font(size: 14))
                    .frame(height: 20)
                
                Text(device.note())
                    .font(Poppins.regular.font(size: 12))
                    .textColor(.app(.light11))
                    .lineLimit(1)
                    .frame(height: 18)
            }
            
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16, corners: .allCorners)
        .padding(.horizontal, 20)
    }
    
    var imageName: String {
        return device.imageName
    }
}

#Preview {
    BluetoothScannerView(viewModel: BluetoothScannerViewModel(scanOption: .init()))
}

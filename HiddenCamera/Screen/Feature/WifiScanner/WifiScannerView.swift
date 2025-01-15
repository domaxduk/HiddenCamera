//
//  WifiScannerView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import SwiftUI
import SakuraExtension
import Lottie
import RxSwift
import GoogleMobileAds

struct WifiScannerView: View {
    @ObservedObject var viewModel: WifiScannerViewModel
    @State var currentTab: Int = 0
    @State var isShowingBanner: Bool = false
    
    @ViewBuilder
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                ScrollView {
                    content.padding(.bottom, 100)
                }
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            if viewModel.isShowingLocationDialog {
                PermissionDialogView(type: .location,
                                     isShowing: $viewModel.isShowingLocationDialog)
            }
            
            if viewModel.isShowingLocalNetworkDialog {
                PermissionDialogView(type: .localNetwork,
                                     isShowing: $viewModel.isShowingLocalNetworkDialog)
            }
            
            if viewModel.isShowingRemoveAdDialog {
                RemoveAdDialogView(isShowing: $viewModel.isShowingRemoveAdDialog,
                                   didTapRemoveAd: viewModel.input.didTapRemoveAd,
                                   didTapContinueAds: viewModel.input.didTapContinueAds)
            }
            
            if !viewModel.isPremium {
                VStack {
                    Spacer()
                    
                    let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
                    
                    BannerView(isCollapse: false, isShowingBanner: $isShowingBanner)
                        .frame(height: isShowingBanner ? adSize.size.height : 0)
                }
            }
        }
    }
    
    var navigationBar: some View {
        HStack {
            if viewModel.showBackButton() {
                Image("ic_back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
                    .onTapGesture {
                        viewModel.input.didTapBack.onNext(())
                    }
            }
            
            Text(ToolItem.wifiScanner.name)
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
        .padding(.leading, 20)
        .frame(height: AppConfig.navigationBarHeight)
        .frame(height: 56)
    }
    
    var content: some View {
        VStack {
            if viewModel.state == .done {
                VStack(spacing: 0) {
                    Image("ic_wifi")
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
                    Button(action: {
                        viewModel.input.didTapScan.onNext(())
                    }, label: {
                        ZStack {
                            Color.clearInteractive
                            
                            Text("Scan again")
                                .font(Poppins.semibold.font(size: 14))
                                .textColor(.app(.main))
                            
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.app(.main), lineWidth: 1.0)
                        }
                    })
                    
                    Button(action: {
                        viewModel.input.viewResult.onNext(())
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.app(.main))
                            
                            Text("View Result")
                                .font(Poppins.semibold.font(size: 14))
                                .textColor(.white)
                        }
                    })
                }
                .frame(height: 56)
                .padding(.top, 40)
                .padding(.horizontal, 20)
            }
            
            if viewModel.state == .isScanning {
                ZStack {
                    ForEach(viewModel.showingDevice, id: \.id) { device in
                        LocalDeviceItemView(device: device)
                            .padding(.bottom, 28)
                    }
                }
            }
            
            if viewModel.state != .done {
                Text("Network name: \(viewModel.networkName ?? "Unknown")")
                    .font(Poppins.regular.font(size: 14))
                    .textColor(.app(.light09))
                
                HStack(spacing: 0) {
                    Text("IP: ")
                        .font(Poppins.regular.font(size: 14))
                    
                    + Text(viewModel.ip)
                        .font(Poppins.semibold.font(size: 14))
                }.foreColor(.app(.light09))
                
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
                        
            if viewModel.state == .ready {
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("*")
                            .font(Poppins.semibold.font(size: 14))
                            .textColor(AppColor.warningColor)
                        
                        Text(" Notice:")
                            .font(Poppins.semibold.font(size: 14))
                            .textColor(.black)
                    }
                    
                    Text("Allow the app to access your local network to detect any suspicious hidden devices, such as hidden cameras or other spy devices connected to the same network.")
                        .font(Poppins.regular.font(size: 14))
                        .textColor(.app(.light11))
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16, corners: .allCorners)
                .padding(20)
            } else {
                NativeContentView()
            }
            
            Spacer()
        }.frame(width: UIScreen.main.bounds.width)
    }
    
    @ViewBuilder
    var scanView: some View {
        LottieView(animation: .named(viewModel.state != .isScanning ? "blueCircle" : "scanning"))
            .playing()
            .looping()
            .overlay(
                ZStack {
                    switch viewModel.state {
                    case .ready:
                        Image("ic_wifi")
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
    @State var didAppear: Bool = false
    var device: LANDevice?

    @ViewBuilder
    var body: some View {
        if let device {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.app(.main).opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(device.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24)
                    )
                    
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.deviceName() ?? "Unknown")
                        .font(Poppins.semibold.font(size: 14))
                        .frame(height: 20)
                    
                    Text("IP Address: " + (device.ipAddress ?? ""))
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
            .offset(x: didAppear ? 0 : UIScreen.main.bounds.width)
            .animation(.easeInOut(duration: 0.3), value: didAppear)
            .onAppear(perform: {
                self.didAppear = true
            })
        }
    }
}

#Preview {
    WifiScannerView(viewModel: WifiScannerViewModel(scanOption: .init()))
}

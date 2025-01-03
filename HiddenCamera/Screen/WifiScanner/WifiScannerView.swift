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

struct WifiScannerView: View {
    @ObservedObject var viewModel: WifiScannerViewModel
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack {
                navigationBar
                content
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
                   
                }
            
            Text(ToolItem.wifiScanner.name)
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: AppConfig.navigationBarHeight)
        .frame(height: 56)
    }
    
    var content: some View {
        VStack {
            Text("Network name : \(NetworkUtils.getWifiName() ?? "No name")")
                .font(Poppins.regular.font(size: 14))
                .textColor(.app(.light09))
            
            HStack {
                Text("IP:")
                    .font(Poppins.regular.font(size: 14))
                    .textColor(.app(.light09))
                
                Text(NetworkUtils.currentIPAddress())
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(.app(.light09))
            }
            
            scanView
            
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
                Text("Scanning")
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
                    
                    
                    Text("Allow the app to access your local network to detect any suspicious hidden devices, such as hidden cameras or other spy devices connected to the same network.")
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
                        Image("ic_wifi")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 64)
                    case .isScanning:
                        Text("\(Int(viewModel.percent))%")
                            .font(Poppins.semibold.font(size: 36))
                            .textColor(.white)
                    case .done:
                        Spacer()
                    }
                }
            )
            .frame(width: UIScreen.main.bounds.width - 60,
                   height: UIScreen.main.bounds.width - 60)
    }
}

#Preview {
    WifiScannerView(viewModel: WifiScannerViewModel())
}

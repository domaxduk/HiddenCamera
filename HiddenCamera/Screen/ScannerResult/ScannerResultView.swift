//
//  ScannerResultVview.swift
//  HiddenCamera
//
//  Created by CucPhung on 5/1/25.
//

import SwiftUI
import RxSwift
import SakuraExtension
import WebKit

enum ScannerResultTab: String {
    case safe
    case suspicious
}

struct ScannerResultView: View {
    @ObservedObject var viewModel: ScannerResultViewModel
    @State var showing: Bool = false
    var body: some View {
        NavigationView(content: {
            ZStack {
                content
            }
        })
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
    }
    
    var emptyView: some View {
        VStack {
            Image("ic_listdevice_empty")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 64)
            
            Text("No devices found. Everything is safe.")
                .font(Poppins.regular.font(size: 14))
                .textColor(.app(.light09))
                .padding(.top, 8)
        }
    }
    
    var content: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                
                Text("Network name : \(NetworkUtils.getWifiName() ?? "No name")")
                    .font(Poppins.regular.font(size: 14))
                    .textColor(.app(.light09))
                    .padding(.top, 8)
                
                HStack {
                    Text("IP:")
                        .font(Poppins.regular.font(size: 14))
                        .textColor(.app(.light09))
                    
                    Text(NetworkUtils.currentIPAddress())
                        .font(Poppins.semibold.font(size: 14))
                        .textColor(.app(.light09))
                }
                
                if viewModel.numberOfSafeDevice() != 0 && viewModel.numberOfSuspiciousDevice() != 0 {
                    HStack {
                        ZStack {
                            Color.clearInteractive
                            
                            Text("Safe(\(viewModel.numberOfSafeDevice()))")
                                .font(Poppins.semibold.font(size: 14))
                                .textColor(viewModel.currentTab == .safe ? .white : .app(.light09))
                        }.onTapGesture {
                            viewModel.currentTab = .safe
                        }
                        
                        ZStack {
                            Color.clearInteractive
                            
                            Text("Suspicious(\(viewModel.numberOfSuspiciousDevice()))")
                                .font(Poppins.semibold.font(size: 14))
                                .textColor(viewModel.currentTab == .suspicious ? .white : .app(.light09))
                        }
                        .onTapGesture {
                            viewModel.currentTab = .suspicious
                        }
                    }
                    .background(
                        GeometryReader(content: { geometry in
                            HStack  {
                                Color.app(.main).cornerRadius(28, corners: .allCorners)
                                    .frame(width: geometry.size.width / 2)
                                    .padding(.leading, viewModel.currentTab == .safe ? 0 : geometry.size.width / 2)
                            }
                        })
                    )
                    .animation(.bouncy)
                    .background(Color.white)
                    .frame(height: 56)
                    .cornerRadius(28, corners: .allCorners)
                    .padding(.horizontal, 48)
                    .padding(.top, 20)
                }
                
                TabView(selection: $viewModel.currentTab,
                        content:  {
                    ZStack {
                        let safeDevices = self.viewModel.safeDevices()
                        if safeDevices.isEmpty {
                            emptyView
                        } else {
                            ScrollView(.vertical) {
                                VStack(spacing: 16) {
                                    ForEach(safeDevices, id: \.id) { device in
                                        LocalDeviceItemView(viewModel: viewModel,device: device)
                                    }
                                }
                            }
                        }
                    }
                    .tag(ScannerResultTab.safe)
                    
                    ZStack {
                        let safeDevices = self.viewModel.suspiciousDevices()
                        if safeDevices.isEmpty {
                            emptyView
                        } else {
                            ScrollView(.vertical) {
                                VStack(spacing: 16) {
                                    ForEach(safeDevices, id: \.id) { device in
                                        LocalDeviceItemView(viewModel: viewModel,device: device)
                                    }
                                }
                            }
                        }
                    }.tag(ScannerResultTab.suspicious)
                })
                .tabViewStyle(.page(indexDisplayMode: .never))
                .padding(.top, 20)
                .ignoresSafeArea()
            }
            
            if let device = viewModel.selectedDevice {
                fixDialog(device: device)
            }
        }
    }
    
    // MARK: - Dialog
    func fixDialog(device: Device) -> some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Text("Remove")
                        .font(Poppins.regular.font(size: 16))
                        .textColor(AppColor.warningColor)
                    Spacer()
                }
                .background(Color.clearInteractive)
                .frame(height: 56)
                .onTapGesture {
                    viewModel.input.remove.onNext(device)
                }
                .padding(.top, 30)
                
                Color.app(.light04).frame(height: 1)

                HStack {
                    Spacer()
                    Text("Move to safe")
                        .font(Poppins.regular.font(size: 16))
                        .textColor(.app(.light12))
                    Spacer()
                }
                .background(Color.clearInteractive)
                .frame(height: 56)
                .onTapGesture {
                    viewModel.input.moveToSafe.onNext(device)
                }
                
                Color.app(.light04).frame(height: 1)

                NavigationLink {
                    AddressView(device: device)
                } label: {
                    HStack {
                        Spacer()
                        Text("Check device")
                            .font(Poppins.regular.font(size: 16))
                            .textColor(.app(.light12))
                        Spacer()
                    }
                    .background(Color.clearInteractive)
                    .frame(height: 56)
                }
            }
            .overlay(
                ZStack(alignment: .topTrailing) {
                    Image("ic_close")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                        .padding(16)
                        .onTapGesture {
                            withAnimation {
                                viewModel.selectedDevice = nil
                            }
                        }
                    
                    Color.clear
                }
            )
            .background(Color.white)
            .cornerRadius(20, corners: .allCorners)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Navigation
    var navigationBar: some View {
        HStack {
            Image("ic_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
                .onTapGesture {
                    viewModel.input.didTapBack.onNext(())
                }
            
            Text("Scan Result")
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: AppConfig.navigationBarHeight)
        .frame(height: 56)
    }
}

// MARK: - Address View
fileprivate struct AddressView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var error: Error?
    
    var device: Device

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image("ic_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    
                    Text(device.deviceName() ?? "Unknown")
                        .textColor(.app(.light12))
                        .font(Poppins.semibold.font(size: 18))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(height: AppConfig.navigationBarHeight)
                .frame(height: 56)
                
                if let url = URL(string: "http://" + (device.ipAddress ?? "")) {
                    ZStack {
                        WebView(error: $error, request: URLRequest(url: url))
                            .background(ProgressView())
                            .ignoresSafeArea()
                        
                        if let error {
                            Text(error.localizedDescription)
                                .font(Poppins.semibold.font(size: 16))
                                .padding(20)
                                .foreColor(.red)
                        }
                    }
                }
            
                Spacer(minLength: 0)
            }
        } 
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

// MARK: - WebView
struct WebView: UIViewRepresentable {
    @Binding var error: Error?
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.backgroundColor = .clear
        view.load(request)
        view.navigationDelegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            print("fail \(error)")
            parent.error = error
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
            print("fail \(error)")
            parent.error = error
        }
    }
}

// MARK: - LocalDeviceItemView
fileprivate struct LocalDeviceItemView: View {
    @ObservedObject var viewModel: ScannerResultViewModel
    var device: Device
        
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
                
                Text("IP Address: " + (device.ipAddress ?? ""))
                    .font(Poppins.regular.font(size: 12))
                    .textColor(.app(.light11))
                    .lineLimit(1)
                    .frame(height: 18)
            }
            
            Spacer(minLength: 0)
            
            if isSafe {
                NavigationLink {
                    AddressView(device: device)
                } label: {
                    Text("Check")
                        .font(Poppins.medium.font(size: 14))
                        .textColor(.app(.main))
                        .frame(width: 76, height: 26)
                        .background(
                            Color.app(.main).opacity(0.1)
                        )
                        .cornerRadius(26, corners: .allCorners)
                }
            } else {
                Text("Fix")
                    .font(Poppins.medium.font(size: 14))
                    .textColor(AppColor.warningColor)
                    .frame(width: 76, height: 26)
                    .background(
                        Color.app(.warning).opacity(0.1)
                    )
                    .cornerRadius(26, corners: .allCorners)
                    .onTapGesture {
                        viewModel.input.didTapFix.onNext(device)
                    }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16, corners: .allCorners)
        .padding(.horizontal, 20)
    }
    
    var imageName: String {
        return device.imageName
    }
    
    var isSafe: Bool {
        return viewModel.isSafe(device: device)
    }
}

#Preview {
    ScannerResultView(viewModel: ScannerResultViewModel(type: .wifi, devices: [
        .init(ipAddress: "196.168.1.105", name: "Than", model: nil)
    ]))
}

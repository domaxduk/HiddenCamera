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
import CoreBluetooth
import MarqueeLabel

enum ScannerResultTab: String {
    case safe
    case suspicious
}

fileprivate struct Const {
    static let width = UIScreen.main.bounds.width - 20 * 2
}

struct ScannerResultView: View {
    @ObservedObject var viewModel: ScannerResultViewModel
    @State var showing: Bool = false
    
    var body: some View {
        NavigationView(content: {
            ZStack {
                content
                
                if let id = viewModel.selectedDeviceID {
                    fixDialog(id: id)
                }
            }
        })
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            Image("ic_listdevice_empty")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 64)
            
            Text("No devices found. Everything is safe.")
                .font(Poppins.regular.font(size: 14))
                .textColor(.app(.light09))
                .padding(.top, 8)
            
            if !UserSetting.isPremiumUser {
                NativeContentView().padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
    
    var content: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                
                if viewModel.type == .wifi {
                    Text("Network name: \(NetworkUtils.getWifiName() ?? "No name")")
                        .font(Poppins.regular.font(size: 14))
                        .textColor(.app(.light09))
                        .padding(.top, 8)
                    
                    HStack(spacing: 0) {
                        Text("IP: ")
                            .font(Poppins.regular.font(size: 14))
                            .textColor(.app(.light09))
                        
                        Text(NetworkUtils.currentIPAddress())
                            .font(Poppins.semibold.font(size: 14))
                            .textColor(.app(.light09))
                    }
                }
                
                tabView
                
                if viewModel.safeDevices.isEmpty && viewModel.suspiciousDevices.isEmpty {
                    emptyView
                } else {
                    ZStack {
                        safeDeviceView
                            .opacity(viewModel.currentTab == .safe ? 1 : 0)
                            .frame(height: viewModel.currentTab == .safe ? nil : 0)
                        
                        suspiciousDevicesView
                            .opacity(viewModel.currentTab == .suspicious ? 1 : 0)
                            .frame(height: viewModel.currentTab == .suspicious ? nil : 0)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var safeDeviceView: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16.0) {
                ForEach(viewModel.safeDevices.indices, id: \.self) { index in
                    let device = viewModel.safeDevices[index]
                    
                    if index % 4 == 0 && !UserSetting.isPremiumUser {
                        NativeContentView().padding(.horizontal, 20)
                    }
                    
                    DeviceItemView(viewModel: viewModel, device: device)
                }
            }
            .padding(.bottom, 100)
            .padding(.top, 20)
            .frame(width: UIScreen.main.bounds.width)
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    var suspiciousDevicesView: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16.0) {
                ForEach(viewModel.suspiciousDevices.indices, id: \.self) { index in
                    let device = viewModel.suspiciousDevices[index]
                    
                    if index % 4 == 0 && !UserSetting.isPremiumUser {
                        NativeContentView().padding(.horizontal, 20)
                    }
                    
                    DeviceItemView(viewModel: viewModel, device: device)
                }
            }
            .padding(.bottom, 100)
            .padding(.top, 20)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Tab View
    var tabView: some View {
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
        .background(Color.white)
        .frame(height: !viewModel.safeDevices.isEmpty && !viewModel.suspiciousDevices.isEmpty ? 56 : 0)
        .cornerRadius(28, corners: .allCorners)
        .padding(.horizontal, 48)
        .padding(.top, !viewModel.safeDevices.isEmpty && !viewModel.suspiciousDevices.isEmpty ? 20 : 0)
    }
    
    // MARK: - Dialog
    func fixDialog(id: String) -> some View {
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
                    viewModel.input.remove.onNext(id)
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
                    viewModel.input.moveToSafe.onNext(id)
                }
                
                Color.app(.light04).frame(height: 1)

                if let device = viewModel.device(id: id) as? LANDevice {
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
                
                if let device = viewModel.device(id: id) as? BluetoothDevice {
                    NavigationLink {
                        FindView(viewModel: viewModel, device: device)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Find device")
                                .font(Poppins.regular.font(size: 16))
                                .textColor(.app(.light12))
                            Spacer()
                        }
                        .background(Color.clearInteractive)
                        .frame(height: 56)
                    }
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
                            viewModel.selectedDeviceID = nil
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
                .padding(.leading, 20)
            
            Text("Scan Result")
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
            
            Spacer()
            
            if viewModel.scanOption != nil {
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
}

// MARK: - Find View
fileprivate struct FindView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: ScannerResultViewModel
    @ObservedObject var device: BluetoothDevice
    @State var isAnimation: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Image("ic_back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                        viewModel.selectedDeviceID = nil
                    }
                
                Text(device.deviceName() ?? "Unknown")
                    .textColor(.app(.light12))
                    .font(Poppins.semibold.font(size: 18))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: AppConfig.navigationBarHeight)
            .frame(height: 56)
            
            deviceView
            
            Text("Move around to find this device")
                .textColor(.app(.light11))
                .font(Poppins.regular.font(size: 14))
                .padding(.top, 24)
                .padding(.horizontal, 60)
            
            Spacer(minLength: 0)
            
            ZStack {
                
                Circle()
                    .stroke(gradientColor, lineWidth: 2)
                    .frame(height: isAnimation ? Const.width : 0)
                    .rotationEffect(.degrees(90))
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: false)
                        , value: isAnimation
                    )
                
                Circle()
                    .stroke(gradientColor, lineWidth: 2)
                    .frame(height: isAnimation ? Const.width : 0)
                    .rotationEffect(.degrees(90))
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: false)
                        .delay(0.25)
                        , value: isAnimation
                    )
                
                Circle()
                    .stroke(gradientColor, lineWidth: 2)
                    .frame(height: isAnimation ? Const.width : 0)
                    .rotationEffect(.degrees(90))
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: false)
                        .delay(0.5)
                        , value: isAnimation
                    )
                
                Circle()
                    .fill(circleColor)
                    .frame(height: Const.width / 388 * 175)
                    .overlay(
                        Text(meterDescription)
                            .textColor(.white)
                            .font(Poppins.semibold.font(size: Const.width / 388 * 36))
                            .scaledToFit()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    )
            }
            
            Spacer()
            
            Color.app(.main).frame(height: 56)
                .cornerRadius(28, corners: .allCorners)
                .overlay(
                    Text("Found it!")
                        .textColor(.white)
                        .font(Poppins.semibold.font(size: 16))
                )
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                    viewModel.selectedDeviceID = nil
                }
                .padding(.horizontal, 56)
                .padding(.bottom, 100)
        }
        .background(Color.app(.light03).ignoresSafeArea())
        .onAppear(perform: {
            self.isAnimation = true
        })
        .onDisappear(perform: {
            self.isAnimation = false
        })
        .navigationBarBackButtonHidden()
    }
    
    var deviceView: some View {
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
                
                Text(device.isSafe() ? "Safe Device" : "Suspicious Device")
                    .font(Poppins.regular.font(size: 12))
                    .textColor(.app(device.isSafe() ? .safe : .warning))
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
    
    var circleColor: Color {
        return device.meterDistance() <= 1.0 ? .app(.warning) : .app(.safe)
    }
    
    var gradientColor: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [circleColor, .clear, .clear]),
                startPoint: .leading,
                endPoint: .trailing)
    }
    
    var meterDescription: String {
        return String(format: "%.2f m", device.meterDistance())
    }
}

// MARK: - Address View
fileprivate struct AddressView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var error: Error?
    
    var device: LANDevice

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
            .background(Color.app(.light03).ignoresSafeArea())
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

// MARK: - DeviceItemView
fileprivate struct DeviceItemView: View {
    @ObservedObject var viewModel: ScannerResultViewModel
    @State var didAppear: Bool = false
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
                TeleprompterText(text: device.deviceName() ?? "Unknown")
                    .frame(height: 20)
                
                Text(device.note())
                    .font(Poppins.regular.font(size: 12))
                    .textColor(.app(.light11))
                    .scaledToFit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .frame(height: 18)
            }
                        
            if isSafe {
                if let device = device as? LANDevice {
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
                }
                
                if let device = device as? BluetoothDevice {
                    NavigationLink {
                        FindView(viewModel: viewModel, device: device)
                    } label: {
                        Text("Find")
                            .font(Poppins.medium.font(size: 14))
                            .textColor(.app(.main))
                            .frame(width: 76, height: 26)
                            .background(
                                Color.app(.main).opacity(0.1)
                            )
                            .cornerRadius(26, corners: .allCorners)
                    }
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
        return device.isSafe()
    }
}

fileprivate struct TeleprompterText: UIViewRepresentable {
    var text: String
    typealias UIViewType = MarqueeLabel
    
    func makeUIView(context: Context) -> MarqueeLabel {
        let label = MarqueeLabel()
        label.text = text
        label.font = Poppins.semibold.font(size: 14)
        label.textColor = .black
        label.allowsDefaultTighteningForTruncation = true
        
        // Compression resistance is important to enable auto resizing of this view,
        // that base on the SwiftUI layout.
        // Especially when the SwiftUI frame modifier applied to this view.
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        // Maybe this is not necessary.
        label.clipsToBounds = true
        
        return label
    }
    
    func updateUIView(_ uiView: MarqueeLabel, context: Context) {
        uiView.text = text
    }
}

// MARK: - Preview
#Preview {
    ScannerResultView(viewModel: ScannerResultViewModel(scanOption: ScanOptionItem(), type: .bluetooth, devices: [
        LANDevice(ipAddress: UUID().uuidString, name: "Fdsfsfs", model: "phone"),
        LANDevice(ipAddress: UUID().uuidString, name: UUID().uuidString, model: "phone")
    ]))
}

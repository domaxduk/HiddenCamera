//
//  ScanView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 8/1/25.
//

import SwiftUI
import SakuraExtension
import Lottie

fileprivate struct Const {
    static let screenWidth = UIScreen.main.bounds.width
    static let padding = 20.0
    static let itemSpacing = 16.0
    static let itemWidth = (screenWidth - padding * 2 - itemSpacing) / 2
    static let itemHeight = itemWidth / 186 * 172
    static let fontSize = itemWidth / 186 * 16
    static let itemPadding = itemWidth / 186 * 18
    static let circleHeight = itemHeight / 186 * 72
}

// MARK: - Scan View
struct ScanView: View {
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack {
                Text("Press the button bellow to Scan Full")
                    .font(Poppins.regular.font(size: 14))
                    .textColor(.app(.light09))
                    .padding(.top, 20)
                
                LottieView(animation: .named("blueCircle"))
                    .playing(loopMode: .loop)
                    .overlay(
                        Image("ic_home_eye")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 72)
                    )
                    .frame(height: UIScreen.main.bounds.width - 40 * 2)
                    .onTapGesture {
                        viewModel.input.didTapScanFull.onNext(())
                    }
                
                HStack {
                    ScanItemView(color: .init(rgb: 0x9747FF), icon: "ic_tool_quickscan", name: "Quick Scan")
                        .onTapGesture {
                            viewModel.input.didTapQuickScan.onNext(())
                        }
                    
                    Spacer()
                    
                    ScanItemView(color: .init(rgb: 0xFFA63D), icon: "ic_tool_scanoption", name: "Scan Options")
                        .onTapGesture {
                            viewModel.input.didTapScanOption.onNext(())
                        }
                }
                            
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Const.padding)
            .padding(.bottom, 50)
        }
        .frame(width: UIScreen.main.bounds.width)
        .navigationBarHidden(true)
    }
}

// MARK: - ScanOptionView
struct ScanOptionView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image("ic_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(20)
                        .background(Color.clearInteractive)
                        .onTapGesture {
                            withAnimation {
                                viewModel.isShowingScanOption = false
                            }
                        }
                    
                    Text("Scan Options")
                        .textColor(.app(.light12))
                        .font(Poppins.semibold.font(size: 18))
                    
                    Spacer()
                    
                    if !viewModel.scanOptions.isEmpty {
                        Button(action: {
                            withAnimation {
                                viewModel.input.removeAllScanOption.onNext(())
                            }
                        }, label: {
                            Text("Cancel")
                                .textColor(.app(.main))
                                .font(Poppins.semibold.font(size: 16))
                                .padding(20)
                        })
                    }
                }
                .frame(height: AppConfig.navigationBarHeight)
                
                Text("Choose options to scan")
                    .font(Poppins.regular.font(size: 14))
                    .textColor(.app(.light09))
                    .padding(.top, 16)
                
                ScrollView(.vertical) {
                    VStack {
                        LazyVGrid(columns: [.init(), .init()],spacing: 20, content: {
                            ForEach(ToolItem.allCases, id: \.self) { tool in
                                ToolItemView(tool: tool)
                                    .overlay(
                                        ZStack(alignment: .topTrailing) {
                                            Color.clear
                                            Image("ic_ratio_\(viewModel.isSelected(tool: tool) ? "" : "un")select")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24)
                                                .padding(8)
                                        }
                                    )
                                    .onTapGesture {
                                        viewModel.input.didSelectToolOption.onNext(tool)
                                    }
                            }
                        })
                    }.padding(Const.padding)
                }
            }
            
            VStack {
                Spacer()
                
                Button(action: {
                    viewModel.input.didTapStartScanOption.onNext(())
                }, label: {
                    Text("Scan now")
                        .font(Poppins.semibold.font(size: 16))
                        .textColor(.white)
                        .padding(.horizontal, 71)
                        .padding(.vertical, 16)
                        .background(Color.app(.main))
                        .cornerRadius(36, corners: .allCorners)
                }).opacity(viewModel.scanOptions.isEmpty ? 0 : 1)
                
                if !viewModel.isPremium && viewModel.isShowingScanOption {
                    BannerContentView(isCollapse: true, needToReload: nil)
                }
            }
        }
    }
}

// MARK: - ScanItemView
fileprivate struct ScanItemView: View {
    var color: Color
    var icon: String
    var name: String
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            Circle()
                .fill(color.opacity(0.1))
                .frame(height: Const.circleHeight)
                .overlay(
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Const.circleHeight / 72 * 40)
                )
            
            Text(name)
                .multilineTextAlignment(.center)
                .font(Poppins.semibold.font(size: Const.fontSize))
                .padding(.top, Const.circleHeight / 72 * 16)
                .foreColor(.app(.light12))
            
            Spacer(minLength: 0)
        }
        .padding(Const.itemPadding)
        .frame(width: Const.itemWidth,
               height: Const.itemHeight)
        .background(Color.white)
        .cornerRadius(20, corners: .allCorners)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}


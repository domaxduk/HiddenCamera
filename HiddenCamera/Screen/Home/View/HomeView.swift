//
//  HomeView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
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

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack {
                navigationBar.padding(.horizontal, 24)
                content
                tabbar
            }
        }.environmentObject(viewModel)
    }
    
    // MARK: - NavigationBar
    var navigationBar: some View {
        HStack {
            Text(AppConfig.appName)
                .font(Poppins.bold.font(size: 20))
            
            Spacer()
        }.frame(height: AppConfig.navigationBarHeight)
    }
    
    // MARK: - Tabbar
    var tabbar: some View {
        HStack {
            Spacer()
            ForEach(HomeTab.allCases, id: \.rawValue) { tab in
                VStack(spacing: 4) {
                    Image("ic_tab_\(tab.rawValue)")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foreColor(.app(tab == viewModel.currentTab ? .main : .light06))
                        .frame(width: 24)
                    
                    Text(tab.rawValue.capitalized)
                        .font(Poppins.medium.font(size: 14))
                        .foreColor(.app(tab == viewModel.currentTab ? .main : .light06))
                        .frame(height: 20)
                }
                .animation(.bouncy, value: viewModel.currentTab)
                .padding()
                .background(Color.clearInteractive)
                .onTapGesture {
                    viewModel.currentTab = tab
                }
                
                Spacer()
            }
        }
        .background(Color.white.cornerRadius(28, corners: [.topLeft, .topRight]).ignoresSafeArea())
    }
    
    // MARK: - Content
    var content: some View {
        ZStack {
            switch viewModel.currentTab {
            case .scan:
                ScanView()
            case .tools:
                ToolsView()
            case .history:
                Color.clear
            case .setting:
                Color.clear
            }
            
        }
    }
}

struct ScanView: View {
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text("Press the button bellow to scan full ")
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
            
            ScrollView {
                HStack {
                    ToolItemView(color: .init(rgb: 0x9747FF), icon: "ic_tool_quickscan", name: "Quick Scan")
                        .onTapGesture {
                            viewModel.input.didTapQuickScan.onNext(())
                        }
                    
                    Spacer()
                    
                    ToolItemView(color: .init(rgb: 0xFFA63D), icon: "ic_tool_scanoption", name: "Scan Options")
                }
                .padding(.horizontal, Const.padding)
                .padding(.bottom, 100)
            }
        }
    }
}

fileprivate struct ToolItemView: View {
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

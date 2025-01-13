//
//  HomeView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import SwiftUI
import SakuraExtension
import Lottie
import RxSwift
import GoogleMobileAds

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
    @State var isShowingBanner: Bool = false
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar.padding(.horizontal, 24)
                content
                tabbar
            }
            
            ScanOptionView(viewModel: viewModel)
                .offset(x: viewModel.isShowingScanOption ? 0 : UIScreen.main.bounds.width)
        }.environmentObject(viewModel)
    }
    
    // MARK: - NavigationBar
    var navigationBar: some View {
        HStack {
            switch viewModel.currentTab {
            case .scan:
                Text(AppConfig.appName)
                    .font(Poppins.bold.font(size: 20))
            case .tools:
                Text("Tools")
                    .font(Poppins.bold.font(size: 20))
            case .history:
                Text("History")
                    .font(Poppins.bold.font(size: 20))
            case .setting:
                Text("Setting")
                    .font(Poppins.bold.font(size: 20))
            }
            
            
            Spacer()
        }.frame(height: AppConfig.navigationBarHeight)
    }
    
    // MARK: - Tabbar
    var tabbar: some View {
        VStack(spacing: 0) {
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
                        viewModel.input.selectTab.onNext(tab)
                    }
                    
                    Spacer()
                }
            }
            
            if !viewModel.isPremium && viewModel.didAppear {
                let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
                
                BannerView(isCollapse: true, isShowingBanner: $isShowingBanner)
                    .frame(height: isShowingBanner ? adSize.size.height : 0)
            }
        }
        .background(Color.white.cornerRadius(28, corners: [.topLeft, .topRight]).ignoresSafeArea())
    }
    
    // MARK: - Content
    var content: some View {
        ZStack {
            if viewModel.didLoadTab.contains(where: { $0 == .scan}) {
                ScanView().opacity(viewModel.currentTab == .scan ? 1 : 0)
            }
            
            if viewModel.didLoadTab.contains(where: { $0 == .tools}) {
                ToolsView().opacity(viewModel.currentTab == .tools ? 1 : 0)
            }
            
            if viewModel.didLoadTab.contains(where: { $0 == .history}) {
                HistoryView().opacity(viewModel.currentTab == .history ? 1 : 0)
            }
            
            if viewModel.didLoadTab.contains(where: { $0 == .setting}) {
                SettingView().opacity(viewModel.currentTab == .setting ? 1 : 0)
            }
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

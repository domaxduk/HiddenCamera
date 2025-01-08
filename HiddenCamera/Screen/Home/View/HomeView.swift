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
        NavigationView(content: {
            ZStack {
                Color.app(.light03).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    navigationBar.padding(.horizontal, 24)
                    content
                    tabbar
                }
                
            }.environmentObject(viewModel)
        }).navigationBarHidden(true)
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
                HistoryView()
            case .setting:
                Color.clear
            }
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

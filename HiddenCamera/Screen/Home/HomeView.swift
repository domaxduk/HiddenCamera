//
//  HomeView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import SwiftUI
import SakuraExtension



struct HomeView: View {
    @State var currentTab: HomeTab = .scan
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack {
                navigationBar.padding(.horizontal, 24)
                content
                tabbar
            }
        }
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
                        .foreColor(.app(tab == currentTab ? .main : .light06))
                        .frame(width: 24)
                    
                    Text(tab.rawValue.capitalized)
                        .font(Poppins.medium.font(size: 14))
                        .foreColor(.app(tab == currentTab ? .main : .light06))
                        .frame(height: 20)
                }
                .animation(.bouncy, value: currentTab)
                .padding()
                .background(Color.clearInteractive)
                .onTapGesture {
                    currentTab = tab
                }
                
                Spacer()
            }
        }
        .background(Color.white.cornerRadius(28, corners: [.topLeft, .topRight]).ignoresSafeArea())
    }
    
    // MARK: - Content
    var content: some View {
        ZStack {
            ToolsView()
        }
    }
}

#Preview {
    HomeView()
}

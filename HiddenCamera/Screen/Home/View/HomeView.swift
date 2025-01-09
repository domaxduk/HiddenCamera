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
                SettingView()
            }
        }
    }
}

enum SettingItem: String {
    case rate
    case share
    case policy
    case term
    case contact
    case restore
}

struct SettingView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("App interaction")
                    .font(Poppins.semibold.font(size: 14))
                    .padding(.top, 20)
                VStack(alignment: .leading, spacing: 0) {
                    itemView(icon: "ic_setting_share", title: "Share app")
                        .onTapGesture {
                            viewModel.input.selectSettingItem.onNext(.share)
                        }
                    
                    Color.app(.light04).frame(height: 1).padding(.horizontal, 20)
                    itemView(icon: "ic_setting_star", title: "Rate app")
                        .onTapGesture {
                            viewModel.input.selectSettingItem.onNext(.rate)
                        }
                }
                .foreColor(.app(.light12))
                .background(Color.white)
                .cornerRadius(24, corners: .allCorners)
                .padding(.top, 12)
                
                Text("Legal info")
                    .font(Poppins.semibold.font(size: 14))
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 0) {
                    itemView(icon: "ic_setting_lock", title: "Privacy Policy")
                        .onTapGesture {
                            viewModel.input.selectSettingItem.onNext(.policy)
                        }
                    
                    Color.app(.light04).frame(height: 1).padding(.horizontal, 20)
                    itemView(icon: "ic_setting_term", title: "Term of Condition")
                        .onTapGesture {
                            viewModel.input.selectSettingItem.onNext(.term)
                        }
                    
                    Color.app(.light04).frame(height: 1).padding(.horizontal, 20)
                    itemView(icon: "ic_setting_contact", title: "Contact Us")
                        .onTapGesture {
                            viewModel.input.selectSettingItem.onNext(.contact)
                        }
                    
                    Color.app(.light04).frame(height: 1).padding(.horizontal, 20)
                    itemView(icon: "ic_setting_restore", title: "Restore")
                        .onTapGesture {
                            viewModel.input.selectSettingItem.onNext(.restore)
                        }
                }
                .foreColor(.app(.light12))
                .background(Color.white)
                .cornerRadius(24, corners: .allCorners)
                .padding(.top, 12)
                
                
                
            }.padding(.horizontal, 20)
        }
    }
    
    func itemView(icon: String, title: String) -> some View {
        HStack(spacing: 0) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
            
            Text(title)
                .font(Poppins.regular.font(size: 14))
                .padding(.leading, 12)
            
            Spacer()
        }
        .padding(20)
        .background(Color.clearInteractive)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

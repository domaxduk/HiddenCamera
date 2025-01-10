//
//  SettingView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import Foundation
import SwiftUI
import RxSwift
import SakuraExtension

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

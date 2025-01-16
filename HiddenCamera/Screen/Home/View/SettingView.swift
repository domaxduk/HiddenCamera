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
                if !viewModel.isPremium {
                    Image("setting_banner")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20, corners: .allCorners)
                        .overlay(
                            GeometryReader(content: { geometry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Get PREMIUM to\nUnlimited Access")
                                            .textColor(.white)
                                            .font(Poppins.bold.font(size: 18))
                                            .autoResize(numberLines: 2)
                                        
                                        Spacer(minLength: 0)
                                        
                                        Button(action: {
                                            viewModel.input.didTapPremiumButton.onNext(())
                                        }, label: {
                                            ZStack {
                                                Color.app(.main)
                                                Text("Go Premium")
                                                    .textColor(.white)
                                                    .font(Poppins.medium.font(size: 13))
                                            }
                                            .frame(height: 30)
                                            .cornerRadius(30, corners: .allCorners)
                                        })
                                    }
                                    
                                    Spacer(minLength: geometry.size.width / 2.5)
                                }.padding(20)
                            })
                        )
                }
                
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
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
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

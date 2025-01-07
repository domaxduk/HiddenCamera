//
//  HistoryDetailView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import SwiftUI
import RxSwift
import SakuraExtension

struct HistoryDetailView: View {
    @ObservedObject var viewModel: HistoryDetailViewModel
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack {
                navigationBar
                
                ScrollView {
                    VStack {
                        ForEach(viewModel.scanOption.tools, id: \.self) { tool in
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 0) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(tool.color.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Image(tool.icon)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 24)
                                        )
                                    
                                    VStack(alignment: .leading) {
                                        Text(tool.name)
                                            .font(Poppins.semibold.font(size: 14))
                                            .textColor(.app(.light12))
                                        
                                        Text(tool.description)
                                            .font(Poppins.regular.font(size: 12))
                                            .textColor(.app(.light10))
                                    }
                                    .padding(.leading, 8)
                                    
                                    Spacer(minLength: 0)
                                }
                                
                                if viewModel.scanOption.isEnd {
                                    if let result = viewModel.scanOption.suspiciousResult[tool] {
                                        Text(result == 0 ? "You are safe now!" : "\(result) devices suspicious")
                                            .font(Poppins.regular.font(size: 12))
                                            .textColor(.app(result == 0 ? .safe : .warning))
                                            .padding(.leading, 52)
                                    }
                                } else {
                                    if let result = viewModel.scanOption.suspiciousResult[tool] {
                                        if result == 0 {
                                            Text("You are safe now!")
                                                .font(Poppins.regular.font(size: 12))
                                                .textColor(.app(.safe))
                                                .padding(.leading, 52)
                                        } else {
                                            Button(action: {
                                                viewModel.input.didTapFix.onNext(tool)
                                            }, label: {
                                                Text("Fix")
                                                    .font(Poppins.regular.font(size: 12))
                                                    .textColor(.white)
                                                    .frame(width: 96, height: 26)
                                                    .background(Color.app(.warning))
                                                    .cornerRadius(13, corners: .allCorners)
                                                    .padding(.leading, 52)
                                                    .padding(.top, 7)
                                            })
                                        }
                                    } else {
                                        Text("Scan")
                                            .font(Poppins.regular.font(size: 12))
                                            .textColor(.white)
                                            .frame(width: 96, height: 26)
                                            .background(Color.app(.main))
                                            .cornerRadius(13, corners: .allCorners)
                                            .padding(.leading, 52)
                                            .padding(.top, 7)
                                    }
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(16, corners: .allCorners)
                        }
                    }.padding(.horizontal, 20)
                }
            }
        }
    }
    
    var navigationBar: some View {
        HStack {
            Image("ic_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
                .onTapGesture {
                    viewModel.routing.stop.onNext(())
                }
            
            Text("Scan Full")
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: AppConfig.navigationBarHeight)
        .frame(height: 56)
    }
}

#Preview {
    HistoryDetailView(viewModel: HistoryDetailViewModel(scanOption: ScanOptionItem(suspiciousResult: [
        ToolItem.bluetoothScanner: 0,
        ToolItem.wifiScanner: 1,
    ], tools: ToolItem.allCases, index: 0, isEnd: false)))
}

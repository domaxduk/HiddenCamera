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
                    ZStack(alignment: .leading) {
                        if viewModel.numberOfTool != 1 {
                            Color.app(.main).frame(width: 4).cornerRadius(2, corners: .allCorners)
                                .padding(.leading, 56)
                        }
                        
                        VStack {
                            ForEach(viewModel.scanOption.tools.indices, id: \.self) { index in
                                let tool = viewModel.scanOption.tools[index]
                                HStack(alignment: .top, spacing: 0) {
                                    if viewModel.numberOfTool != 1 {
                                        let isUsed = viewModel.scanOption.suspiciousResult.contains(where: { $0.key == tool })
                                        HStack(spacing: 0) {
                                            Text("\(index)")
                                                .font(Poppins.semibold.font(size: 14))
                                                .textColor(isUsed ? .white : .app(.light11))
                                                .frame(width: 36, height: 36)
                                                .background(Color.app(isUsed ? .main : .light01))
                                                .cornerRadius(18, corners: .allCorners)
                                            
                                            Circle()
                                                .fill(Color.app(.main))
                                                .frame(width: 12)
                                                .padding(.horizontal, 16)
                                        }.padding(.top, 16)
                                    }
                                   
                                    
                                    HistoryDetailItemView(viewModel: viewModel, tool: tool, result: viewModel.scanOption)
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 16)
                                    .background(Color.white)
                                    .cornerRadius(16, corners: .allCorners)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
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
            
            if let dateString {
                Text(dateString)
                    .font(Poppins.regular.font(size: 12))
                    .textColor(.app(.light09))
            }
        }
        .padding(.horizontal, 20)
        .frame(height: AppConfig.navigationBarHeight)
        .frame(height: 56)
    }
    
    var dateString: String? {
        let date = viewModel.scanOption.date
        return date?.string(format: "HH:mm dd/MM/yyyy")
    }
}

// MARK: - HistoryDetailItemView
fileprivate struct HistoryDetailItemView: View {
    @ObservedObject var viewModel: HistoryDetailViewModel

    let tool: ToolItem
    let result: ScanOptionItem
    
    var body: some View {
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
            
            if isSave {
                if let result = viewModel.scanOption.suspiciousResult[tool] {
                    if result == 0 {
                        safeStatus()
                    } else {
                        switch tool {
                        case .bluetoothScanner, .wifiScanner:
                            warningStatus(number: result)
                        case .cameraDetector, .magnetic, .infraredCamera:
                            warningStatus()
                        }
                    }
                }
            } else {
                if let result = viewModel.scanOption.suspiciousResult[tool] {
                    if result == 0 {
                        Text("You are safe now!")
                            .font(Poppins.regular.font(size: 12))
                            .textColor(.app(.safe))
                            .padding(.leading, 52)
                    } else {
                        fixButton()
                    }
                } else {
                    scanButton()
                }
            }
        }
    }
    
    private func warningStatus(number: Int? = nil) -> some View {
        Text(number != nil ? "\(number!) devices suspicious" : "Suspicious device detected")
            .font(Poppins.regular.font(size: 12))
            .textColor(.app(.warning))
            .padding(.leading, 52)
    }
    
    private func safeStatus() -> some View {
        Text("You are safe now!")
            .font(Poppins.regular.font(size: 12))
            .textColor(.app(.safe))
            .padding(.leading, 52)
    }
    
    private func scanButton() -> some View {
        Button(action: {
            viewModel.input.reopenTool.onNext(tool)
        }, label: {
            Text("Scan")
                .font(Poppins.regular.font(size: 12))
                .textColor(.white)
                .frame(width: 96, height: 26)
                .background(Color.app(.main))
                .cornerRadius(13, corners: .allCorners)
                .padding(.leading, 52)
                .padding(.top, 7)
        })
    }
    
    private func fixButton() -> some View {
        Button(action: {
            viewModel.input.reopenTool.onNext(tool)
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
    
    var isSave: Bool {
        return result.isSave
    }
}

#Preview {
    HistoryDetailView(viewModel: HistoryDetailViewModel(scanOption: ScanOptionItem()))
}

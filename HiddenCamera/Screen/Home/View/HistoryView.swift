//
//  HistoryView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 8/1/25.
//

import SwiftUI
import SakuraExtension
import Lottie

// MARK: - HistoryView
struct HistoryView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    @ViewBuilder
    var body: some View {
        if viewModel.historyItems.isEmpty {
            VStack(spacing: 0) {
                Spacer()
                Image("ic_history_empty")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 64)
                
                Text("You have never scanned before. Scan now to ensure the safety of your area.")
                    .font(Poppins.regular.font(size: 14))
                    .textColor(.app(.light09))
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 44)
                
                Button(action: {
                    viewModel.currentTab = .scan
                }, label: {
                    Text("Scan now")
                        .font(Poppins.semibold.font(size: 16))
                        .textColor(.white)
                        .padding(.horizontal, 71)
                        .padding(.vertical, 16)
                        .background(Color.app(.main))
                        .cornerRadius(36, corners: .allCorners)
                })
                .padding(.top, 28)
                
                NativeContentView().padding(.top, 20)
                
                Spacer()
            }
        } else {
            ScrollView(.vertical) {
                VStack {
                    ForEach(viewModel.historyItems.indices, id: \.self) { index in
                        let item = viewModel.historyItems[index]
                        
                        if index % 4 == 0 {
                            NativeContentView()
                        }
                        
                        HistoryItemView(item: item)
                            .onTapGesture {
                                viewModel.routing.routeToHistoryDetail.onNext(item)
                            }
                    }
                }.padding(.horizontal, 20)
            }
        }
    }
}

fileprivate struct HistoryItemView: View {
    var item: ScanOptionItem
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(titleString)
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(.app(.light12))
                
                Text(dateString)
                    .font(Poppins.regular.font(size: 12))
                    .textColor(.app(.light09))
            }.padding(.leading, 16)
            
            
            Spacer(minLength: 0)
            
            Image(isSafe ? "ic_safe" : "ic_risk")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16, corners: .allCorners)
        .onAppear(perform: {
            print(item.rlmObject())
        })
    }
    
    var dateString: String {
        let date = item.date ?? Date()
        return date.string(format: "HH:mm dd/MM/yyyy")
    }
    
    var titleString: String {
        switch item.type {
        case .quick:
            "Quick Scan"
        case .full:
            "Scan Full"
        case .option:
            "Scan Options"
        }
    }
    
    var imageName: String {
        switch item.type {
        case .quick:
            "ic_tool_quickscan"
        case .full:
            "ic_tool_scanfull"
        case .option:
            "ic_tool_scanoption"
        }
    }
    
    var color: Color {
        switch item.type {
        case .quick:
                .init(rgb: 0x9747FF)
        case .full:
                .init(rgb: 0x0090FF)
        case .option:
                .init(rgb: 0xFFA63D)
        }
    }
    
    var isSafe: Bool {
        return !item.suspiciousResult.contains(where: { $0.value > 0})
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}


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
                Spacer()
            }
        } else {
            ScrollView(.vertical) {
                VStack {
                    ForEach(viewModel.historyItems, id: \.id) { item in
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
        return item.isScanOption ? "Scan Option" : "Quick Scan"
    }
    
    var imageName: String {
        return item.isScanOption ? "ic_tool_scanoption" : "ic_tool_quickscan"
    }
    
    var color: Color {
        return item.isScanOption ? .init(rgb: 0xFFA63D) : .init(rgb: 0x9747FF)
    }
    
    var isSafe: Bool {
        return !item.suspiciousResult.contains(where: { $0.value > 0})
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}


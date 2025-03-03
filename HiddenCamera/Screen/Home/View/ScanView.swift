//
//  ScanView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 8/1/25.
//

import SwiftUI
import SakuraExtension
import Lottie
import RxSwift

fileprivate struct Const {
    static let screenWidth = UIScreen.main.bounds.width
    static let padding = 20.0
    static let itemSpacing = 16.0
    
    static let itemWidth = screenWidth - padding * 2
    static let itemHeight = itemWidth / 388 * 136
    static let itemCorner = itemWidth / 388 * 20
    static let itemStrokeWidth = itemWidth / 388 * 2
    static let titleFontSize = itemWidth / 388 * 16
    static let normalFontSize = itemWidth / 388 * 12
}

// MARK: - Scan View
struct ScanView: View {
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Button(action: {
                    viewModel.input.didTapQuickScan.onNext(())
                }, label: {
                    itemView(isOdd: true,
                             title: "Quick Scan",
                             description: "Quickly detect hidden devices by scanning Wi-Fi and Bluetooth to protect your privacy.",
                             imageName: "ic_home_quickscan")
                })
                
                Button(action: {
                    viewModel.input.didTapScanFull.onNext(())
                }, label: {
                    itemView(isOdd: false,
                             title: "Scan Full",
                             description: "Perform deep scans by combining sensors and algorithms to detect hidden cameras.",
                             imageName: "ic_home_scanfull")
                })
                .padding(.top, Const.itemSpacing)
                
                if !viewModel.isPremium {
                    NativeContentView(padding: .init(top: Const.itemSpacing))
                }
                
                Button(action: {
                    viewModel.input.didTapHistory.onNext(())
                }, label: {
                    itemView(isOdd: false,
                             title: "History",
                             description: "View past scan results and detected devices for easy tracking and analysis.",
                             imageName: "ic_home_history")
                }).padding(.top, Const.itemSpacing)
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, Const.padding)
            .padding(.bottom, 50)
            .padding(.top, 16)
        }
        .frame(width: UIScreen.main.bounds.width)
        .navigationBarHidden(true)
    }
    
    func itemView(isOdd: Bool, title: String, description: String, imageName: String) -> some View {
        HStack {
            if isOdd {
                Spacer(minLength: 0)
            }
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            if !isOdd {
                Spacer(minLength: 0)
            }
        }
        .frame(width: Const.itemWidth,
               height: Const.itemHeight)
        .background(Color(rgb: 0x040210))
        .cornerRadius(Const.itemCorner, corners: .allCorners)
        .overlay(
            LinearGradient(colors: [
                .init(rgb: 0x2898FF),
                .init(rgb: 0xFF3DF7)
            ], startPoint: .bottomTrailing, endPoint: .topLeading)
            .mask(
                RoundedRectangle(cornerRadius: Const.itemCorner)
                    .stroke(lineWidth: Const.itemStrokeWidth)
            )
        )
        .overlay(
            VStack(alignment: isOdd ? .leading : .trailing, spacing: 0) {
                Text(title)
                    .font(Poppins.semibold.font(size: Const.titleFontSize))
                    .textColor(.white)
                
                Text(description)
                    .font(Poppins.regular.font(size: Const.normalFontSize))
                    .textColor(.app(.light03))
                    .multilineTextAlignment(isOdd ? .leading : .trailing)
                    .padding(.top, 4)
                
                Color.clear.frame(height: 1)
            }
            .padding(isOdd ? .leading : .trailing, 
                     Const.itemWidth / 388 * 20)
            .padding(isOdd ? .trailing : .leading, 
                     Const.itemWidth / 388 * (isOdd ? 129 : 156))
        )
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}


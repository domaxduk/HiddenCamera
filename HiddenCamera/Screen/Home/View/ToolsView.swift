//
//  ToolsView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import SwiftUI
import SakuraExtension
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

struct ToolsView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 12) {
                LazyVGrid(columns: [.init(), .init()], content: {
                    ForEach(ToolItem.allCases, id: \.self) { tool in
                        Button(action: {
                            viewModel.input.didSelectTool.onNext(tool)
                        }, label: {
                            ToolItemView(tool: tool)
                        })
                    }
                })
            }
            .padding(.horizontal, Const.padding)
            .padding(.bottom, Const.padding)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - ToolItemView
struct ToolItemView: View {
    let tool: ToolItem
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            Circle()
                .fill(tool.color.opacity(0.1))
                .frame(height: Const.circleHeight)
                .overlay(
                    Image(tool.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Const.circleHeight / 72 * 40)
                )
            
            Text(tool.name)
                .multilineTextAlignment(.center)
                .font(Poppins.semibold.font(size: Const.fontSize))
                .padding(.top, Const.circleHeight / 72 * 16)
                .foreColor(.app(.light12))
                .scaledToFit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                
            
            Spacer(minLength: 0)
        }
        .padding(Const.itemPadding)
        .frame(width: Const.itemWidth,
               height: Const.itemHeight)
        .background(Color.white)
        .cornerRadius(20, corners: .allCorners)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}

//
//  ToolsView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import SwiftUI

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
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                LazyVGrid(columns: [.init(), .init()], content: {
                    ForEach(ToolItem.allCases, id: \.self) { tool in
                        VStack {
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
                            
                            Spacer(minLength: 0)
                        }
                        .padding(Const.itemPadding)
                        .frame(width: Const.itemWidth,
                               height: Const.itemHeight)
                        .background(Color.white)
                        .cornerRadius(20, corners: .allCorners)
                        
                       
                    }
                })
            }.padding(Const.padding)
        }
    }
}

#Preview {
    HomeView()
}

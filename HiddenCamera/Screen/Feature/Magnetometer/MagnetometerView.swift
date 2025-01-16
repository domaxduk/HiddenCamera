//
//  MetalDetectorView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import SwiftUI
import SakuraExtension
import RxSwift
import Charts
import GoogleMobileAds

fileprivate struct Const {
    static let circleRadius = UIScreen.main.bounds.width / 1.6
    static let lineWidth = circleRadius / 6
}

struct MagnetometerView: View {
    @ObservedObject var viewModel: MagnetometerViewModel
    @State var isShowingBanner: Bool = false
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                content
            }
            
            VStack {
                Spacer()
                
                if !viewModel.isPremium {
                    BannerContentView(isCollapse: false, needToReload: nil)
                }
            }
        }.frame(width: UIScreen.main.bounds.width)
    }
    
    // MARK: - navigationBar
    var navigationBar: some View {
        HStack(spacing: 0) {
            if viewModel.showBackButton() {
                Image("ic_back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(20)
                    .background(Color.clearInteractive)
                    .onTapGesture {
                        viewModel.input.didTapBack.onNext(())
                    }
            }
           
            Text(ToolItem.magnetic.name)
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
            
            Spacer()
            
            if viewModel.scanOption != nil {
                Button(action: {
                    viewModel.input.didTapNext.onNext(())
                }, label: {
                    Text("Next")
                        .textColor(.app(.main))
                        .font(Poppins.semibold.font(size: 16))
                        .padding(20)
                })
            }
        }
        .padding(.leading, viewModel.showBackButton() ? 0 : 20)
        .frame(height: AppConfig.navigationBarHeight)
    }
    
    // MARK: - content
    @ViewBuilder
    var content: some View {
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    SeverityCircleView(value: $viewModel.strength)
                    startButton.padding(.vertical, 16)
                    attributeView
                    noteView
                }
                .padding(.bottom, 100)
                .frame(width: UIScreen.main.bounds.width)
            }
        }
    }
    
    var startButton: some View {
        Button {
            viewModel.input.didTapStart.onNext(())
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .stroke(lineWidth: 1.0)
                    
                Color.app(.main).cornerRadius(28, corners: .allCorners)
                    .opacity(viewModel.isDetecting ? 0 : 1)
                
                Text(viewModel.isDetecting ? "Stop" : "Start")
                    .font(Poppins.semibold.font(size: 16))
                    .textColor(viewModel.isDetecting ? .app(.main) : .white)
            }
            .frame(height: 56)
            .padding(.horizontal, 82)
        }
    }
    
    var attributeView: some View {
        HStack(spacing: 0) {
            let width: CGFloat? = (UIScreen.main.bounds.width - 58 * 2 - 20 * 2) / 3
            VStack(spacing: 12) {
                Text("X")
                    .font(Poppins.semibold.font(size: 18))
                    .textColor(.app(.light12))
                    .frame(height: 26)
                
                Text(String(format: "%.1f", viewModel.x))
                    .font(Poppins.regular.font(size: 16))
                    .textColor(.app(.light12))
                    .autoResize(numberLines: 1)
                    .frame(height: 20)
            }.frame(width: width)
                        
            VStack(spacing: 12) {
                Text("Y")
                    .font(Poppins.semibold.font(size: 18))
                    .textColor(.app(.light12))
                    .frame(height: 26)
                
                Text(String(format: "%.1f", viewModel.y))
                    .font(Poppins.regular.font(size: 16))
                    .textColor(.app(.light12))
                    .autoResize(numberLines: 1)
                    .frame(height: 20)
            }.frame(width: width)
                        
            VStack(spacing: 12) {
                Text("Z")
                    .font(Poppins.semibold.font(size: 18))
                    .textColor(.app(.light12))
                    .frame(height: 26)
                
                Text(String(format: "%.1f", viewModel.z))
                    .font(Poppins.regular.font(size: 16))
                    .textColor(.app(.light12))
                    .autoResize(numberLines: 1)
                    .frame(height: 20)
            }.frame(width: width)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(20, corners: .allCorners)
        .padding(.horizontal, 58)
    }
    
    var noteView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("*")
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(AppColor.warningColor)
                
                Text(" Notice:")
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(.black)
            }
            
            Text("Most cameras are made of metal components. So using metal sensors to find them is quite effective. You need to pay attention to the indicators. If they suddenly increase, try to find the lens of the hidden camera around that area.")
                .font(Poppins.regular.font(size: 12))
                .textColor(.app(.light11))
                .padding(.top, 8)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16, corners: .allCorners)
        .padding(20)
    }
}

// MARK: - SeverityCircleView
struct SeverityCircleView: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ForEach(0...180, id: \.self) { index in
                    if index % 4 != 0 {
                        let from = CGFloat(index) / 180.0
                        let to = from + 1.0 / 180.0
                        
                        // Khoang tu 250 den 500: 0 -> 25
                        if index >= 0 && index < 25 {
                            let standardValue = 0.1 * value - 25
                            let color = Double(index) <= standardValue ? Color(rgb: 0xC1272D) : .app(.light06)
                            
                            Circle()
                                .trim(from: from, to: to)
                                .stroke(color, lineWidth: Const.lineWidth)
                                .frame(width: Const.circleRadius)
                        }
                        
                        // Khoảng trống
                        else if 25 <= index  && index <= 63 {
                            Circle()
                                .trim(from: from, to: to)
                                .stroke(.clear, lineWidth: Const.lineWidth)
                                .frame(width: Const.circleRadius)
                        }
                        
                        // Khoang tu 0 den 25: 63 -> 91
                        else if 63 < index && index <= 91 {
                            let standardValue = 1.12 * value + 63
                            let color = Double(index) <= standardValue ? Color(rgb: 0x009245) : .app(.light06)
                            
                            Circle()
                                .trim(from: from, to: to)
                                .stroke(color, lineWidth: Const.lineWidth)
                                .frame(width: Const.circleRadius)
                        }
                        
                        // Khoang tu 25 den 65: 91 -> 119
                        else if index > 91 && index <= 119 {
                            let standardValue = 0.7 * value + 73.5
                            let color = Double(index) <= standardValue ? Color(rgb: 0xA5E94A) : .app(.light06)
                            
                            Circle()
                                .trim(from: from, to: to)
                                .stroke(color, lineWidth: Const.lineWidth)
                                .frame(width: Const.circleRadius)
                        }
                        
                        // Khoang tu 65 den 100: 119 -> 147
                        else if index > 119 && index <= 147 {
                            let standardValue = 0.8 * value + 67
                            let color = Double(index) <= standardValue ? Color(rgb: 0xF3DC0F) : .app(.light06)
                            
                            Circle()
                                .trim(from: from, to: to)
                                .stroke(color, lineWidth: Const.lineWidth)
                                .frame(width: Const.circleRadius)
                        }
                        // Khoang tu 100 den 200: 147 -> 175
                        else if index > 147 && index <= 175 {
                            let standardValue = 0.28 * value + 119
                            let color = Double(index) <= standardValue ? Color(rgb: 0xF7931E) : .app(.light06)
                            
                            Circle()
                                .trim(from: from, to: to)
                                .stroke(color, lineWidth: Const.lineWidth)
                                .frame(width: Const.circleRadius)
                        } 
                        // Khoang tu 200 den 250: 175 -> 180
                        else if index > 175 && index <= 180 {
                            let standardValue = 0.1 * value + 155
                            let color = Double(index) <= standardValue ? Color(rgb: 0xC1272D) : .app(.light06)
                            
                            Circle()
                                .trim(from: from, to: to)
                                .stroke(color, lineWidth: Const.lineWidth)
                                .frame(width: Const.circleRadius)
                        }
                    
                    }
                }
                
                Color.black.frame(
                    width: Const.circleRadius / 11 / 28 * 8,
                    height: Const.circleRadius / 11 / 28 * 120
                )
                .cornerRadius(Const.circleRadius / 11 / 28 * 8, corners: .allCorners)
                .offset(y: -Const.circleRadius / 11 / 28 * 108 / 4)
                .rotationEffect(.degrees(220))
                .rotationEffect(.degrees(degrees))

                Circle()
                    .stroke(lineWidth: Const.circleRadius / 11 / 6)
                    .frame(width: Const.circleRadius / 11)
                    .background(
                        Color.white.cornerRadius(Const.circleRadius / 11, corners: .allCorners)
                    )
            }
            .animation(.default)
            .frame(height: Const.circleRadius + Const.lineWidth)
            .overlay(
                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Text(String(format: "%.2f", value))
                            .font(Poppins.medium.font(size: Const.circleRadius / 308 * 40))
                        
                        Text("μT")
                            .font(Poppins.italic.font(size: Const.circleRadius / 308 * 30))
                    }
                }
            )
        }
    }

    var degrees: Double {
        // tổng góc: 280 độ
        // mỗi khoảng: 56 độ
        var degree: Double = 0
        
        // Khoang tu 0 den 25: 0 -> 56
        if value <= 25 {
            degree = 2.24 * value
        }
        
        // Khoang tu 25 den 65: 56 -> 112
        if 25 < value && value <= 65 {
            degree = 1.4 * value + 21
        }
        
        // Khoang tu 65 den 100: 112 -> 168
        if 65 < value && value <= 100 {
            degree = 1.6 * value + 8
        }
        
        // Khoang tu 100 den 200: 168 -> 224
        if 100 < value && value <= 200 {
            degree = 0.56 * value + 112
        }
        
        // Khoang 200 - 500: 224 -> 280
        if value > 200 {
            degree = 56.0 / 300.0 * min(value, 500.0) + 224.0 - 56.0 / 300.0 * 200.0
        }
        
        return degree
    }
}

#Preview {
    MagnetometerView(viewModel: MagnetometerViewModel(scanOption: .init()))
}

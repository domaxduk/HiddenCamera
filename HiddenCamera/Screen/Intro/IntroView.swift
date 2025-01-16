//
//  IntroView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import SwiftUI
import SakuraExtension
import RxSwift

fileprivate struct Const {
    // 428 la size width cua man hinh trong design
    static let screenWidth = UIScreen.main.bounds.width
    static let titleSize = screenWidth / 428 * 16
    static let normalSize = screenWidth / 428 * 14
    static let circleSize = screenWidth / 428 * 44
    static let smallTextSize = screenWidth / 428 * 12
    
    static let indexCircleSize = screenWidth / 428 * 36
    static let subCircleSize = screenWidth / 428 * 12
}

struct IntroItem {
    var title: String
    var description: String
}

struct IntroView: View {
    @ObservedObject var viewModel: IntroViewModel
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack {
                thumbnailImage
                
                ScrollViewReader(content: { proxy in
                    ZStack {
                        ScrollView {
                            if viewModel.isRequested && viewModel.currentIndex != viewModel.intros.count {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.intros.indices, id: \.self) { index in
                                        let intro = viewModel.intros[index]
                                        ZStack {
                                            Color.clear.frame(height: 1)
                                            HStack(spacing: 0) {
                                                Circle()
                                                    .fill(Color.app(viewModel.currentIndex >= index ? .main : .light01))
                                                    .frame(height: Const.indexCircleSize)
                                                    .overlay(
                                                        Text("\(index + 1)")
                                                            .font(Poppins.semibold.font(size: Const.normalSize))
                                                            .textColor(.app(viewModel.currentIndex >= index ? .light01 : .light11))
                                                    )
                                                
                                                Circle()
                                                    .fill(Color.app(.main))
                                                    .frame(height: Const.subCircleSize)
                                                    .padding(.leading, 16)
                                                
                                                
                                                VStack(alignment: .leading) {
                                                    Color.clear.frame(height: 0)
                                                    Text(intro.title)
                                                        .font(Poppins.semibold.font(size: Const.normalSize))
                                                        .textColor(.app(viewModel.currentIndex == index ? .light12 : .light10))
                                                    
                                                    if viewModel.currentIndex == index {
                                                        Text(intro.description)
                                                            .textColor(.app(.light10))
                                                            .font(Poppins.regular.font(size: Const.smallTextSize))
                                                            .fixedSize(horizontal: false, vertical: true)
                                                    }
                                                }
                                                .padding(16)
                                                .background(viewModel.currentIndex == index ? Color.white : .clear)
                                                .cornerRadius(16, corners: .allCorners)
                                                .padding(.leading, 16)
                                            }
                                        }
                                        .background(
                                            HStack {
                                                Color.clear
                                                    .frame(width: Const.screenWidth / 428 * 4)
                                                    .background(
                                                        GeometryReader(content: { geometry in
                                                            VStack(spacing: 0) {
                                                                if viewModel.currentIndex == index {
                                                                    Color.app(.main)
                                                                        .frame(height: geometry.size.height / 2)
                                                                    
                                                                    if viewModel.currentIndex != viewModel.intros.count - 1 {
                                                                        Color.app(.light05)
                                                                    }
                                                                } else if viewModel.currentIndex > index {
                                                                    Color.app(.main)
                                                                        .frame(height: geometry.size.height)
                                                                } else {
                                                                    Color.app(.light05)
                                                                }
                                                            }
                                                            
                                                        })
                                                    )
                                                    .padding(.leading, Const.indexCircleSize + 16 + Const.subCircleSize / 2 - Const.screenWidth / 428 * 4 / 2)
                                                
                                                Spacer()
                                            }
                                        )
                                        .id("\(index)")
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 100)
                            } else if viewModel.currentIndex == viewModel.intros.count {
                                introLast()
                            } else {
                                permissionView()
                            }
                        }
                        
                        VStack {
                            Spacer()
                            
                            Button(action: {
                                viewModel.input.didTapContinue.onNext(())
                                proxy.scrollTo("\(viewModel.currentIndex)", anchor: .center)
                            }, label: {
                                Text(viewModel.currentIndex == viewModel.intros.count ? "Let's started" : "Continue")
                                    .font(Poppins.medium.font(size: Const.titleSize))
                                    .textColor(.white)
                                    .padding(.vertical, 16)
                                    .frame(width: Const.screenWidth - 58 * 2)
                                    .background(Color.app(.main))
                                    .cornerRadius(Const.screenWidth, corners: .allCorners)
                            })
                            
                            if !viewModel.isPremium {
                                BannerContentView(isCollapse: false, hasOneKeyAd: true, needToReload: viewModel.input.didTapContinue)
                            }
                        }
                    }
                })
            }
        }
    }
    
    func permissionView() -> some View {
        VStack(spacing: 0) {
            Text("Grant permission for this app to keep enhancing your ad experience")
                .font(Poppins.medium.font(size: Const.titleSize))
                .textColor(.app(.light12))
                .multilineTextAlignment(.center)
                
            HStack {
               Circle()
                    .fill(Color.app(.main).opacity(0.1))
                    .frame(height: Const.circleSize)
                    .overlay(
                        Image("ic_intro_allow_2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Const.circleSize / 44 * 24)
                    )
                
                Text("Improve with personalized ads experience")
                    .font(Poppins.regular.font(size: Const.normalSize))
                    .textColor(.app(.light10))
                    .padding(.leading, 16)
                Spacer(minLength: 0)
            }
            
            HStack {
               Circle()
                    .fill(Color.app(.main).opacity(0.1))
                    .frame(height: Const.circleSize)
                    .overlay(
                        Image("ic_intro_allow_1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Const.circleSize / 44 * 24)
                    )
                
                Text("Allow businesses to reach customers with ads")
                    .font(Poppins.regular.font(size: Const.normalSize))
                    .textColor(.app(.light10))
                    .padding(.leading, 16)
                Spacer(minLength: 0)
            }.padding(.top, 12)
            
            HStack {
               Circle()
                    .fill(Color.app(.main).opacity(0.1))
                    .frame(height: Const.circleSize)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .resizable()
                            .renderingMode(.template)
                            .foreColor(.app(.main))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Const.circleSize / 44 * 24)
                    )
                
                Text("Help keep this app free of charge")
                    .font(Poppins.regular.font(size: Const.normalSize))
                    .textColor(.app(.light10))
                    .padding(.leading, 16)
                Spacer(minLength: 0)
            }.padding(.top, 12)
            
            Group {
                Text("Tap")
                    .font(Poppins.regular.font(size: Const.normalSize))
                    .textColor(.app(.light11))
                
                + Text(" Allow").textColor(.black).font(Poppins.bold.font(size: Const.normalSize))
                
                + Text(" and allow us to provide a better experience with personalized ad, we need permission to use future activity that other apps and websites send us from this device. This permission will not give us access to any new types of information.")
                    .font(Poppins.regular.font(size: Const.normalSize))
                    .textColor(.app(.light11))
            }.padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
    
    func introLast() -> some View {
        VStack(spacing: 0) {
            Text("Everything is safe and secure")
                .font(Poppins.bold.font(size: Const.titleSize / 16 * 20))
                .textColor(.app(.light12))
                .multilineTextAlignment(.center)
            
            Text("Protect your peace of mind and ensure your security with advanced hidden camera detection features, giving you confidence that your personal space is free from any unwanted surveillance")
                .font(Poppins.regular.font(size: Const.normalSize))
                .textColor(.app(.light11))
                .multilineTextAlignment(.center)
                .padding(.top, 24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(16, corners: .allCorners)
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
    
    @ViewBuilder
    var thumbnailImage: some View {
        if viewModel.isRequested {
            if viewModel.currentIndex == viewModel.intros.count {
                Image("intro_last")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image("intro_\(viewModel.currentIndex + 1)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else {
            Image("ic_intro_permission")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
       
    }
}

#Preview {
    IntroView(viewModel: IntroViewModel())
}

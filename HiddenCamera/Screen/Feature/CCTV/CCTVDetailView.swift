//
//  CCTVDetailView.swift
//  HiddenCamera
//
//  Created by Tra Le on 11/2/25.
//

import SwiftUI
import SakuraExtension
import VideoPlayer
import AVKit
import RxSwift

fileprivate struct Const {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height

    static let videoWidth = screenWidth - 20 * 2
    static let videoHeight = videoWidth / 388 * 224
    static let videoCorner = videoWidth / 388 * 20

}

struct CCTVDetailView: View {
    @ObservedObject var viewModel: CCTVViewModel
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
           
            VStack(spacing: 0) {
                if !viewModel.isZoom {
                    HStack {
                        Image("ic_back")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24)
                        
                        Text(viewModel.title)
                            .font(Poppins.semibold.font(size: 18))
                            .textColor(.app(.light12))
                        
                        Spacer(minLength: 0)
                    }
                    .frame(height: AppConfig.navigationBarHeight)
                    .onTapGesture {
                        viewModel.input.back.onNext(())
                    }
                }
                
                Color.black
                    .frame(
                        width: viewModel.isZoom ? nil : Const.videoWidth,
                        height: viewModel.isZoom ? nil : Const.videoHeight)
                    .overlay(
                        ZStack {
                            ProgressView()
                                .circleprogressColor(.white)
                            
                            if let link = viewModel.link {
                                VideoPlayer(url: link, play: .constant(true))
                                    .contentMode(.scaleAspectFit)
                                    .mute(viewModel.isMuted)
                                    .frame(
                                        width: viewModel.isZoom ? Const.screenHeight : Const.videoWidth,
                                        height: viewModel.isZoom ? Const.screenWidth : Const.videoHeight)
                                    .overlay(
                                        VStack {
                                            let padding = Const.screenHeight / 18
                                            if viewModel.isZoom {
                                                HStack {
                                                    Image("ic_back")
                                                        .renderingMode(.template)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 24)
                                                        .foreColor(.white)
                                                        .padding(5)
                                                        .onTapGesture {
                                                            viewModel.input.back.onNext(())
                                                        }
                                                    
                                                    Spacer()
                                                }
                                                .frame(height: 36)
                                                .padding(.top, 24)
                                                .padding(.horizontal, padding)
                                                .overlay(
                                                    Text(viewModel.title)
                                                        .font(Poppins.semibold.font(size: 18))
                                                        .textColor(.white)
                                                )
                                            }
                                            
                                            overlayView
                                                .padding(.horizontal, viewModel.isZoom ? Const.screenHeight / 926 * 24 : 0)
                                        }
                                    )
                                    .rotationEffect(.degrees(viewModel.isZoom ? 90 : 0))
                            }
                        }
                    )
                    .cornerRadius(
                        viewModel.isZoom ? 0 : Const.videoCorner,
                        corners: .allCorners
                    )
                    .ignoresSafeArea()
                
                if !viewModel.isZoom {
                    infoView.padding(.top, 20)
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, viewModel.isZoom ? 0 : 20)
            
            if !viewModel.isPremium && viewModel.didAppear {
                VStack {
                    Spacer()
                    BannerContentView(isCollapse: true, needToReload: nil)
                }
            }
        }
    }
    
    var infoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Color.clear.frame(height: 1)
            Text(viewModel.title)
                .font(Poppins.semibold.font(size: 16))
            
            Text(viewModel.location)
                .font(Poppins.semibold.font(size: 14))

            if let views = viewModel.views {
                Text(views + " views")
                    .font(Poppins.regular.font(size: 14))
            }
        }
    }
    
    var overlayView: some View {
        HStack(alignment: .bottom) {
            Color.clear
            Button(action: {
                withAnimation {
                    viewModel.isMuted.toggle()
                }
            }, label: {
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: viewModel.isMuted ? "speaker.slash.fill" : "volume.2.fill")
                            .foreColor(.white)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16)
                    )
            })
            
            Button(action: {
                viewModel.input.didTapZoom.onNext(())
            }, label: {
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: viewModel.isZoom ? "arrow.up.right.and.arrow.down.left" : "arrow.up.backward.and.arrow.down.forward")
                            .foreColor(.white)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16)
                    )
            })
        }.padding(16)
    }
}

#Preview {
    CCTVDetailView(viewModel: CCTVViewModel(cctv: .init(name: "Sydney Harbor",
                                                        location: "Sydney, Australia",
                                                        path: "https://www.youtube.com/watch?v=5uZa3-RMFos")))
}

//
//  CameraResultView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import SwiftUI
import AVKit
import SakuraExtension
import RxSwift

fileprivate struct Const {
    static let widthVideo = UIScreen.main.bounds.width - 20 * 2
    static let heightVideo = widthVideo / 388 * 466
}

struct CameraResultView: View {
    @ObservedObject var viewModel: CameraResultViewModel
    @State var isShowingConfirmDialog: Bool = false
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack {
                navigationBar
                videoView.padding(.top, 20)
                seekBar.padding(.top, 16)
                controlView.padding(.top, 24)
                Spacer()
                
                if viewModel.tag == nil {
                    decideTypeView
                }
                
                Spacer(minLength: 0)
            }
            
            if isShowingConfirmDialog {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Text("Did you notice any devices in the video that seem suspicious?")
                            .textColor(.app(.light12))
                            .font(Poppins.semibold.font(size: 16))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                            .padding(.top, 32)
                        
                        
                        Color.app(.light04).frame(height: 1)
                        
                        HStack {
                            Spacer()
                            Text("Trusted")
                                .font(Poppins.regular.font(size: 16))
                                .textColor(AppColor.safeColor)
                            Spacer()
                        }
                        .background(Color.clearInteractive)
                        .frame(height: 56)
                        .onTapGesture {
                            withAnimation {
                                viewModel.input.mask.onNext(.trusted)
                                isShowingConfirmDialog = false
                            }
                        }
                        
                        Color.app(.light04).frame(height: 1)

                        HStack {
                            Spacer()
                            Text("Mark as risk")
                                .font(Poppins.regular.font(size: 16))
                                .textColor(AppColor.warningColor)
                            Spacer()
                        }
                        .background(Color.clearInteractive)
                        .frame(height: 56)
                        .onTapGesture {
                            withAnimation {
                                viewModel.input.mask.onNext(.risk)
                                isShowingConfirmDialog = false
                            }
                        }
                    }
                    .overlay(
                        ZStack(alignment: .topTrailing) {
                            Image("ic_close")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                                .padding(16)
                            
                            Color.clear
                        }
                    )
                    .background(Color.white)
                    .cornerRadius(20, corners: .allCorners)
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    var decideTypeView: some View {
        HStack(spacing: 12) {
            ZStack {
                AppColor.warningColor.opacity(0.1)
                Text("Mark as risk")
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(AppColor.warningColor)
            }
            .frame(height: 48)
            .cornerRadius(24, corners: .allCorners)
            .onTapGesture {
                viewModel.input.mask.onNext(.risk)
            }
            
            ZStack {
                AppColor.safeColor.opacity(0.1)
                Text("Trusted")
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(AppColor.safeColor)
            }
            .frame(height: 48)
            .cornerRadius(24, corners: .allCorners)
            .onTapGesture {
                viewModel.input.mask.onNext(.trusted)
            }
        }.padding(.horizontal, 20)
    }
    
    var seekBar: some View {
        HStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * viewModel.percent)
                    
                    Spacer()
                }
                .cornerRadius(3)
                .overlay(
                    HStack(spacing: 0) {
                        if geometry.size.width * viewModel.percent - 16 >= 0 {
                            Color.clear.frame(width: geometry.size.width * viewModel.percent - 16)
                        }
                        
                        Circle()
                            .fill(Color.app(.main))
                            .frame(height: 16)
                        
                        Spacer(minLength: 0)
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        let process = min(max(0, CGFloat(value.location.x / geometry.size.width)), 1)
                        viewModel.isSeeking = true
                        viewModel.pauseVideo()
                        viewModel.seek(process: process)
                    })
                    .onEnded({ _ in
                        viewModel.isSeeking = false
                    
                        if viewModel.isPlaying {
                            viewModel.playVideo()
                        }
                    })
                )
            }.frame(height: 6)
                
            HStack {
                Spacer(minLength: 0)
                Text(viewModel.currentTime())
                    .font(Poppins.regular.font(size: 12))
                    .textColor(.app(.main))
            }.frame(width: 40)
            
        }.padding(.horizontal, 20)
    }
    
    var controlView: some View {
        HStack(spacing: 40) {
            
            Image("ic_backward")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
                .onTapGesture {
                    viewModel.player.rewindVideo(by: 10)
                }
            
            Circle()
                .fill(Color.black)
                .frame(width: 60)
                .overlay(
                    Image("ic_\(viewModel.isPlaying ? "pause" : "play")")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28)
                )
                .onTapGesture {
                    viewModel.input.didTapPlay.onNext(())
                }
            
            Image("ic_forward")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
                .onTapGesture {
                    viewModel.player.forwardVideo(by: 10)
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
                    if viewModel.item.tag != nil {
                        viewModel.input.didTapBack.onNext(())
                    } else {
                        withAnimation {
                            isShowingConfirmDialog = true
                        }
                    }
                }
            
            Text(viewModel.title)
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: AppConfig.navigationBarHeight)
        .frame(height: 56)
    }
    
    var videoView: some View {
        ZStack(alignment: .topLeading) {
            Color(rgb: 0xD9D9D9)
            
            SakuraVideoPlayerLayer(player: viewModel.player, videoGravity: .resizeAspect)
            
            
            tag()
        }
        .frame(width: Const.widthVideo, height: Const.heightVideo)
        .cornerRadius(20, corners: .allCorners)
    }
    
    @ViewBuilder
    func tag() -> some View {
        if let tag = viewModel.item.tag {
            HStack(spacing: 4) {
                
                Image(systemName: tag == .risk ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16)
                    .foreColor(.white)
                
                Text(tag.rawValue.capitalized)
                    .font(Poppins.semibold.font(size: 12))
                    .textColor(.white)
                    .frame(height: 18)
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .background(tag == .risk ? AppColor.warningColor : AppColor.safeColor)
            .cornerRadius(24, corners: .allCorners)
            .padding(.top, 20)
            .padding(.leading, 24)
        }
    }
}

#Preview {
    CameraResultView(viewModel: CameraResultViewModel(item: .init(id: "", fileName: "test", type: .infrared)))
}

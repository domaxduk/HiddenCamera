//
//  InfraredCameraView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import SwiftUI
import SakuraExtension
import RxSwift
import AVFoundation
import Lottie
import GoogleMobileAds

struct InfraredCameraView: View {
    @ObservedObject var viewModel: InfraredCameraViewModel
    @State var isShowingNoteView: Bool = false
    @State var isShowingBanner: Bool = false
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()

            VStack {
                navigationBar
                content
            }
            
            if viewModel.isShowingCameraDialog {
                PermissionDialogView(type: .camera, isShowing: $viewModel.isShowingCameraDialog)
            } else if viewModel.isTheFirst {
                guideView()
            }
        }
    }
    
    @ViewBuilder
    func guideView() -> some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                bottomToolView
                    .padding(.horizontal, 51)
                    .padding(.bottom, 20)
                    .animation(.bouncy)
                
                ZStack {
                    recordButton.zIndex(1).overlay(
                        LottieView(animation: .named("tapfinger"))
                            .playing(loopMode: .loop)
                            .frame(width: 200, height: 200)
                            .allowsHitTesting(false)
                    )
                }.padding(.bottom, 10)
            }
        }
        .onTapGesture {
            viewModel.isTheFirst = false
        }
    }
    
    // MARK: - Content
    var content: some View {
        ZStack {
            Spacer()
            
            VStack {
                HStack {
                    Spacer().frame(width: 32)
                    Spacer()

                    Text(viewModel.durationDescription())
                        .textColor(.white)
                        .font(Poppins.semibold.font(size: 14))
                        .frame(height: 20)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.isRecording ? Color.app(.warning) : .white.opacity(0.2))
                        .cornerRadius(8, corners: .allCorners)
                        .animation(.bouncy, value: viewModel.isRecording)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isShowingNoteView = true
                        }
                        
                        withAnimation(.default.delay(2)) {
                            isShowingNoteView = false
                        }
                    }, label: {
                        Image("ic_info")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 32)
                    })
                }.padding(.horizontal, 20)
                
                VStack(alignment: .leading) {
                    Text("* Notice")
                        .font(Poppins.semibold.font(size: 16))
                    
                    Text("Easily and quickly detect infrared cameras using your device's camera and the app's bright color filter feature.")
                        .font(Poppins.regular.font(size: 14))
                }
                .padding(16)
                .background(Color.black.opacity(0.5))
                .foreColor(.white)
                .cornerRadius(12, corners: .allCorners)
                .padding(.top, 12)
                .padding(.horizontal, 24)
                .opacity(isShowingNoteView ? 1 : 0)
                
                Spacer()
                
                bottomToolView
                    .padding(.horizontal, 51)
                    .padding(.bottom, 20)
                    .animation(.bouncy)
                
                ZStack {
                    recordButton.zIndex(1)
                    
                    if let image = viewModel.previewGalleryImage, viewModel.scanOption == nil && !viewModel.isRecording {
                        HStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                )
                        }
                        .onTapGesture {
                            viewModel.input.didTapGallery.onNext(())
                        }
                        .padding(.horizontal, 36)
                    }
                }.padding(.bottom, 10)
                
                if !viewModel.isPremium && !viewModel.isTheFirst {
                    let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
                    
                    BannerView(isCollapse: false, isShowingBanner: $isShowingBanner)
                        .frame(height: isShowingBanner ? adSize.size.height : 0)
                }
            }
        }
    }
    
    var bottomToolView: some View {
        HStack {
            if !viewModel.isTheFirst {
                FilterItemView(viewModel: viewModel, color: .red)
                FilterItemView(viewModel: viewModel, color: .green)
                FilterItemView(viewModel: viewModel, color: .blue)
                FilterItemView(viewModel: viewModel, color: .yellow)
            
                
                // Flash Button
                if CameraManager.isFlashAvailable() {
                    Circle().fill(.white.opacity(0.25))
                        .overlay(
                            Image(viewModel.isTurnFlash ? "ic_flash_off" : "ic_flash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 24)
                        )
                        .frame(height: 32)
                        .onTapGesture {
                            viewModel.input.toggleFlash.onNext(())
                        }
                        .padding(.leading, 20)
                }
            } else {
                Text("Tap this button to start feature")
                    .textColor(.app(.main))
                    .font(Poppins.semibold.font(size: 16))
                    .scaledToFit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal, 30)
            }
        }
        .padding(8)
        .frame(height: 48)
        .background(
            Color(
                hue: !viewModel.isTheFirst ? 1 : 0,
                saturation: !viewModel.isTheFirst ? 1 : 0,
                brightness: !viewModel.isTheFirst ? 0 : 1).opacity(!viewModel.isTheFirst ? 0.5 : 1)
        )
        .cornerRadius(24, corners: .allCorners)
    }
    
    var recordButton: some View {
        Circle()
            .fill(Color.white)
            .frame(height: 64)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: viewModel.isRecording ? 5 : 24)
                        .fill(Color.app(.warning))
                        .frame(
                            width: viewModel.isRecording ? 24 : 48,
                            height: viewModel.isRecording ? 24 : 48)
                }
            )
            .animation(.easeInOut, value: viewModel.isRecording)
            .onTapGesture {
                viewModel.input.didTapRecord.onNext(())
            }
            .opacity(recordButtonOpacity)
    }
    
    var recordButtonOpacity: Double {
        if viewModel.isRecording {
            return viewModel.seconds >= 1 ? 1 : 0
        }
        
        return 1
    }
    
    // MARK: - navigationBar
    var navigationBar: some View {
        HStack {
            if viewModel.showBackButton() {
                Image("ic_back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
                    .onTapGesture {
                        viewModel.input.back.onNext(())
                    }
            }
            
            Text(ToolItem.infraredCamera.name)
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
            
            Spacer()
            
            if viewModel.scanOption != nil && !viewModel.isRecording {
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
        .padding(.leading, 20)
        .frame(height: AppConfig.navigationBarHeight)
        .padding(.bottom, 12)
        .background(
            Color.white
                .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
                .ignoresSafeArea()
        )
    }
}

// MARK: - CameraSwiftUIView
fileprivate struct CameraSwiftUIView: UIViewRepresentable {
    typealias UIViewType = PreviewCameraView
    var captureSession: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewCameraView {
        let view = PreviewCameraView(captureSession: captureSession)
        view.configCamera()
        return view
    }
    
    func updateUIView(_ uiView: PreviewCameraView, context: Context) {
        uiView.configCamera()
    }
}

// MARK: - FilterItem
fileprivate struct FilterItemView: View {
    @ObservedObject var viewModel: InfraredCameraViewModel
    
    var color: Color
    var body: some View {
        Circle()
            .stroke(color,lineWidth: 2.0)
            .overlay(
                Circle().fill(color)
                    .padding(3)
                    
            )
            .frame(height: 32)
            .onTapGesture {
                viewModel.filterColor = color
            }
    }
}

#Preview {
    InfraredCameraView(viewModel: InfraredCameraViewModel(scanOption: .init()))
}

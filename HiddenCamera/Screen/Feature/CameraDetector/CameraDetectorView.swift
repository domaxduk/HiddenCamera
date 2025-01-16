//
//  CameraDetectorView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import GoogleMobileAds
import SwiftUI
import SakuraExtension
import RxSwift
import AVFoundation
import Lottie

struct CameraDetectorView: View {
    @ObservedObject var viewModel: CameraDetectorViewModel
    @State var isShowingNoteView: Bool = false
    @State var isShowingBanner: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CameraSwiftUIView(captureSession: viewModel.captureSession)
                .ignoresSafeArea()
            
            OverlayView(boxes: viewModel.boxes)
                .ignoresSafeArea()
                .opacity(viewModel.isRecording ? 1 : 0)
            
            VStack {
                navigationBar
                content
            }
            
            if viewModel.isShowingCameraDialog {
                PermissionDialogView(type: .camera, isShowing: $viewModel.isShowingCameraDialog)
            } else if viewModel.isTheFirst {
                guideView()
            }
            
            if viewModel.isShowingTimeLimitDialog {
                TimeLimitDialogView(isShowing: $viewModel.isShowingTimeLimitDialog,
                                   didTapRemoveAd: viewModel.input.didTapRemoveAd,
                                   didTapContinueAds: viewModel.input.didTapContinueAds)
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
                    
                    Text("Use your phone's camera combined with AI technology to detect hidden cameras in your surroundings in real time.")
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
                    BannerContentView(isCollapse: false, needToReload: nil)
                }
            }
        }
    }
    
    @ViewBuilder
    var bottomToolView: some View {
        HStack {
            if !viewModel.boxes.isEmpty && viewModel.isRecording {
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .foreColor(.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16)
                    
                    Text("Detect suspicious devices!")
                        .textColor(.white)
                        .foreColor(.white)
                        .font(Poppins.semibold.font(size: 16))
                        .scaledToFit()
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(8)
                .frame(height: 48)
                .background(
                    Color(
                        hue: !viewModel.isTheFirst ? 356 / 360 : 0,
                        saturation: !viewModel.isTheFirst ? 0.73 : 0,
                        brightness: !viewModel.isTheFirst ? 0.93 : 1)
                )
                .cornerRadius(24, corners: .allCorners)
            } else if viewModel.isTheFirst {
                Text("Tap this button to start feature")
                    .textColor(.app(.main))
                    .font(Poppins.semibold.font(size: 16))
                    .scaledToFit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal, 30)
                    .padding(8)
                    .frame(height: 48)
                    .background(
                        Color(
                            hue: !viewModel.isTheFirst ? 356 / 360 : 0,
                            saturation: !viewModel.isTheFirst ? 0.73 : 0,
                            brightness: !viewModel.isTheFirst ? 0.93 : 1)
                    )
                    .cornerRadius(24, corners: .allCorners)
            }
        }
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
        HStack(spacing: 0) {
            if viewModel.showBackButton() {
                Image("ic_back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(20)
                    .background(Color.clearInteractive)
                    .onTapGesture {
                        viewModel.input.back.onNext(())
                    }
            }
            
            Text(ToolItem.cameraDetector.name)
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
                .scaledToFit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
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

// MARK: - OverlayView
fileprivate struct OverlayView: View {
    var boxes: [BoundingBox]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(boxes.indices, id: \.self) { index in
                    let box = boxes[index]
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    let w = CGFloat(box.w) * width
                    let h = CGFloat(box.h) * height
                    
                    let centerX = CGFloat(box.cx) * width
                    let centerY = CGFloat(box.cy) * height
                    
                    Image("ic_frame_camera")
                        .resizable()
                        .frame(width: max(w, h), height: max(w, h))
                        .position(x: centerX, y: centerY)
                }
            }
        }
        .clipped()
    }
}

#Preview {
    CameraDetectorView(viewModel: CameraDetectorViewModel(scanOption: nil))
}

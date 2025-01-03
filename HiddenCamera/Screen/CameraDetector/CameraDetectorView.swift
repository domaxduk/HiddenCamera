//
//  CameraDetectorView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import SwiftUI

import SwiftUI
import SakuraExtension
import RxSwift
import AVFoundation

struct CameraDetectorView: View {
    @ObservedObject var viewModel: CameraDetectorViewModel
    @State var isShowingNoteView: Bool = false
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()

            VStack {
                navigationBar
                content
            }
            
            if viewModel.isTheFirst {
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
                    recordButton.zIndex(1)
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
                        .background(viewModel.isRecording ? Color.app(.ee404c) : .white.opacity(0.2))
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
                    
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                            .frame(width: 64, height: 64)
                    }
                    .onTapGesture {
                        viewModel.input.didTapGallery.onNext(())
                    }
                    .padding(.horizontal, 36)
                }.padding(.bottom, 10)
            }
        }
    }
    
    var bottomToolView: some View {
        HStack {
            if !viewModel.isTheFirst {
                
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
                        .fill(Color.app(.ee404c))
                        .frame(
                            width: viewModel.isRecording ? 24 : 48,
                            height: viewModel.isRecording ? 24 : 48)
                }
            )
            .animation(.easeInOut, value: viewModel.isRecording)
            .onTapGesture {
                viewModel.input.didTapRecord.onNext(())
            }
    }
    
    // MARK: - navigationBar
    var navigationBar: some View {
        HStack {
            Image("ic_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
                .onTapGesture {
                    viewModel.input.back.onNext(())
                }
            
            Text(ToolItem.cameraDetector.name)
                .textColor(.app(.light12))
                .font(Poppins.semibold.font(size: 18))
            
            Spacer()
        }
        .padding(.horizontal, 20)
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

#Preview {
    CameraDetectorView(viewModel: CameraDetectorViewModel())
}

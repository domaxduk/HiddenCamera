//
//  RemoveAdDialogView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import SwiftUI
import SakuraExtension
import RxSwift

struct RemoveAdDialogView: View {
    @Binding var isShowing: Bool
    var didTapRemoveAd: PublishSubject<()>
    var didTapContinueAds: PublishSubject<()>
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                        self.didTapContinueAds.onNext(())
                    }
                }
            
            VStack(spacing: 0) {
                Image("ic_dialog_removeAd")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 96)
                
                Text("Ad - Free Expperience")
                    .textColor(.app(.light12))
                    .font(Poppins.semibold.font(size: 18))
                    .padding(.top, 12)
                
                Text("Tired of watching ADS? Get rid all of the ADS and support developers of the app for better experience!")
                    .textColor(.app(.light11))
                    .font(Poppins.regular.font(size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                
                Color.app(.main).frame(height: 56)
                    .cornerRadius(28, corners: .allCorners)
                    .overlay(
                        Text("Remove ads")
                            .font(Poppins.semibold.font(size: 16))
                            .textColor(.white)
                    )
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                            self.didTapRemoveAd.onNext(())
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 40)
                
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.app(.main), lineWidth: 1)
                    .frame(height: 56)
                    .overlay(
                        Text("Continue with Ads Version")
                            .font(Poppins.semibold.font(size: 16))
                            .textColor(Color.app(.main))
                            .autoResize(numberLines: 1)
                            .padding(.horizontal, 25)
                    )
                    .onTapGesture {
                        withAnimation {
                            self.isShowing = false
                            self.didTapContinueAds.onNext(())
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 11)
            }
            .padding(22)
            .background(Color.white)
            .cornerRadius(20, corners: .allCorners)
            .overlay(
                ZStack(alignment: .topTrailing) {
                    Image("ic_close")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                        .padding(16)
                        .onTapGesture {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    
                    Color.clear
                }
            )
            .padding(20)
        }
    }
}

#Preview {
    RemoveAdDialogView(isShowing: .constant(true), didTapRemoveAd: .init(), didTapContinueAds: .init())
}

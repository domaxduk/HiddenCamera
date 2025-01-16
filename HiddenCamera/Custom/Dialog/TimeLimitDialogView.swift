//
//  TimeLimitDialogView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 15/1/25.
//

import SwiftUI
import SakuraExtension
import RxSwift

struct TimeLimitDialogView: View {
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
                Image("ic_dialog_timelimit")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 96)
                
                Text("Limited time")
                    .textColor(.app(.light12))
                    .font(Poppins.semibold.font(size: 18))
                    .padding(.top, 12)
                
                Text("You have reached the limit of 1 scan. Enjoy unlimited experience with Premium version.")
                    .textColor(.app(.light11))
                    .font(Poppins.regular.font(size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                
                Color.app(.main).frame(height: 56)
                    .cornerRadius(28, corners: .allCorners)
                    .overlay(
                        Text("Get Premium")
                            .font(Poppins.semibold.font(size: 16))
                            .textColor(.white)
                    )
                    .onTapGesture {
                        withAnimation {
                            self.didTapRemoveAd.onNext(())
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 40)
                
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.app(.main), lineWidth: 1)
                    .frame(height: 56)
                    .overlay(
                        Text("Continue with Free Version")
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
                                self.didTapContinueAds.onNext(())
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
    TimeLimitDialogView(isShowing: .constant(true), didTapRemoveAd: .init(), didTapContinueAds: .init())
}

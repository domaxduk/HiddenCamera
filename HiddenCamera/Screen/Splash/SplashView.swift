//
//  SplashView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import SwiftUI

fileprivate struct Const {
    static let widthTriangle: CGFloat = UIScreen.main.bounds.width / 2
    static let heightTriangle = widthTriangle / 394 * 352
}

struct SplashView: View {
    @State var didAppear: Bool = false
    @State var isAnimatingText: Bool = false
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack {
                ZStack {
                    Image("ic_splash_triangle")
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: didAppear ? .fit: .fill)
                        .frame(width: didAppear ? Const.widthTriangle : UIScreen.main.bounds.height * 2)
                        .animation(.easeInOut(duration: 2))
                        .onAppear(perform: {
                            self.didAppear = true
                        })
                        
                    
                    Image("ic_splash_camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Const.widthTriangle)
                        .opacity(didAppear ? 1 : 0)
                        .animation(.easeInOut(duration: 1))
                    
                }
                .zIndex(1)
                
                Text("Hidden Camera")
                    .font(Poppins.semibold.font(size: 30))
                    .padding(.top, 10)
                    .overlay(
                        GeometryReader(content: { geometry in
                            HStack {
                                if isAnimatingText {
                                    Color.clear
                                        .frame(width: isAnimatingText ? geometry.size.width : 0)
                                }
                                
                                Color.app(.light03)
                                    .frame(width: !isAnimatingText ? geometry.size.width : 0)
                            }
                        })
                    )
                    .animation(.easeInOut(duration: 1), value: isAnimatingText)
            }.offset(y: -Const.heightTriangle/2)
        }
        .onAppear(perform: {
            self.didAppear = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isAnimatingText = true
            }
        })
    }
}

#Preview {
    SplashView()
}

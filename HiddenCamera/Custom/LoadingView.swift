//
//  LoadingView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import SwiftUI
import SakuraExtension

struct LoadingView: View {
    var body: some View {
        ZStack {
            BlurSwiftUIView(effect: .init(style: .dark))
            
            ProgressView()
                .circleprogressColor(.white)
        }.ignoresSafeArea()
    }
}

#Preview {
    LoadingView()
}

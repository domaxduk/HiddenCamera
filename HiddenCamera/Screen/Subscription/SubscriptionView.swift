//
//  SubscriptionView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import SwiftUI
import SakuraExtension

struct SubscriptionView: View {
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack {
                ZStack {
                    Text("Hidden camera PRO")
                        .font(Poppins.semibold.font(size: 18))
                        .textColor(.app(.light12))
                    HStack {
                        
                        Image("ic_back")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24)
                            .padding()
                        
                        Spacer()
                    }
                }
                Spacer()
                
                VStack {
                    
                }
            }
        }
    }
}

#Preview {
    SubscriptionView()
}

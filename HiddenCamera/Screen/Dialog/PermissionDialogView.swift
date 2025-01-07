//
//  PermissionDialogView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 6/1/25.
//

import Foundation
import RxSwift
import SwiftUI
import SakuraExtension
 
// MARK: - PermissionDialogType
enum PermissionDialogType {
    case location
    case localNetwork
    case camera
    case bluetooth
    
    var image: String {
        switch self {
        case .location:
            "ic_permission_location"
        case .localNetwork:
            "ic_permission_localnetwork"
        case .camera:
            "ic_permission_camera"
        case .bluetooth:
            "ic_tool_bluetooth"
        }
    }
    
    var title: String {
        switch self {
        case .location:
            "Location Access Needed"
        case .localNetwork:
            "Local Network Access Needed"
        case .camera:
            "Camera Access Needed"
        case .bluetooth:
            "Bluetooth Access Needed"
        }
    }
    
    var description: String {
        switch self {
        case .location:
            "Oh! It looks like you have denied access to your location. Please enable this permission in your settings to use this feature!"
        case .localNetwork:
            "Oh! It looks like you have denied access to your local network. Please enable this permission in your settings to use this feature!"
        case .camera:
            "Oh! It looks like you have denied camera access. Please enable this permission in your settings to use this feature!"
        case .bluetooth:
            "Oh! It looks like you have denied bluetooth access. Please enable this permission in your settings to use this feature!"
        }
    }
}

// MARK: - PermissionDialogView
struct PermissionDialogView: View {
    let type: PermissionDialogType
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }
            
            VStack(spacing: 0) {
                Image(type.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 96)
                
                Text(type.title)
                    .textColor(.app(.light12))
                    .font(Poppins.semibold.font(size: 18))
                    .padding(.top, 12)
                
                Text(type.description)
                    .textColor(.app(.light11))
                    .font(Poppins.regular.font(size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                
                Color.app(.main).frame(height: 56)
                    .cornerRadius(28, corners: .allCorners)
                    .overlay(
                        Text("Go to settings")
                            .font(Poppins.semibold.font(size: 16))
                            .textColor(.white)
                    )
                    .onTapGesture {
                        UIApplication.shared.openSetting()
                        withAnimation {
                            isShowing = false
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 40)
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
    PermissionDialogView(type: .camera, isShowing: .constant(true))
}

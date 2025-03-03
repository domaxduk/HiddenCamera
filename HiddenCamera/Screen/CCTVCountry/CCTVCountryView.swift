//
//  CCTVCountryView.swift
//  HiddenCamera
//
//  Created by Tra Le on 11/2/25.
//

import SwiftUI
import SakuraExtension
import SDWebImageSwiftUI
import RxSwift

fileprivate struct Const {
    static let screenWidth = UIScreen.main.bounds.width
    static let padding = 20.0
    static let itemWidth = screenWidth - padding * 2
    static let itemHeight = itemWidth / 388 * 190
    static let itemCorner = itemWidth / 388 * 16
}

struct CCTVCountryView: View {
    @ObservedObject var viewModel: CCTVCountryViewModel
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Image("ic_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                    
                    Text(viewModel.title)
                        .font(Poppins.semibold.font(size: 18))
                        .textColor(.app(.light12))
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .frame(height: AppConfig.navigationBarHeight)
                .onTapGesture {
                    viewModel.input.back.onNext(())
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.items.indices, id: \.self) { index in
                            let cctv = viewModel.items[index]
                            
                            CCTVItemView(
                                item: cctv,
                                views: viewModel.infos[cctv.name]?.views,
                                imagePath: viewModel.infos[cctv.name]?.imagePath)
                            .onTapGesture {
                                viewModel.input.didSelectItem.onNext(cctv)
                            }
                            .padding(.top, 16)
                            
                            if !viewModel.isPremium && (index + 1) % 3 == 0 {
                                NativeContentView(padding: .init(top: 16))
                            }
                        }
                    }
                    .padding(.init(top: 0, leading: 20, bottom: 20, trailing: 20))
                    .padding(.bottom, 100)
                }
                
                if !viewModel.isPremium {
                    BannerContentView(isCollapse: true, needToReload: nil)
                }
            }
        }
    }
}

// MARK: - CCTVItemView
fileprivate struct CCTVItemView: View {
    let item: CCTV
    let views: String?
    let imagePath: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Spacer(minLength: 0)
                Text(item.name)
                    .font(Poppins.semibold.font(size: 16))
                    .textColor(.app(.light01))
                Text(item.location)
                    .font(Poppins.semibold.font(size: 14))
                    .textColor(.app(.light01))
                
                if let views {
                    Text("\(views) views")
                        .font(Poppins.regular.font(size: 14))
                        .textColor(.app(.light01))
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.leading, 20)
        .padding(.bottom, 18)
        .frame(width: Const.itemWidth, height: Const.itemHeight)
        .background(
            LinearGradient(colors: [
                .black.opacity(0.1),
                .black.opacity(0.1),
                .black.opacity(0.8)
            ], startPoint: .top, endPoint: .bottom)
        )
        .background(backgroundView)
        .background(Color.app(.light01))
        .cornerRadius(Const.itemCorner, corners: .allCorners)
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if let imagePath, let url = URL(string: imagePath) {
            WebImage(url: url)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            VStack {
                Image("ic_live")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Const.itemHeight / 190 * 64)
                    .padding(.top, Const.itemHeight / 190 * 16)
                Spacer()
            }
        }
    }
}

#Preview {
    CCTVCountryView(viewModel: CCTVCountryViewModel(country: CCTVCountry(name: "Australia", imagePath: "https://i.ibb.co/LgYWdSr/australia.png", priority: 2, items: [
        .init(name: "Sydney Harbor",
              location: "Sydney, Australia",
              path: "https://www.youtube.com/watch?v=5uZa3-RMFos"),
        .init(name: "VN",
              location: "Sydney, Australia",
              path: "https://www.youtube.com/watch?v=5uZa3-RMFos"),
        .init(name: "VN",
              location: "Sydney, Australia",
              path: "https://www.youtube.com/watch?v=5uZa3-RMFos"),
        .init(name: "Sydney Harbor",
              location: "Sydney, Australia",
              path: "https://www.youtube.com/watch?v=5uZa3-RMFos"),
        .init(name: "VN",
              location: "Sydney, Australia",
              path: "https://www.youtube.com/watch?v=5uZa3-RMFos"),
        .init(name: "VN",
              location: "Sydney, Australia",
              path: "https://www.youtube.com/watch?v=5uZa3-RMFos"),
        .init(name: "Sydney Harbor",
              location: "Sydney, Australia",
              path: "https://www.youtube.com/watch?v=5uZa3-RMFos"),
        .init(name: "VN",
              location: "Sydney, Australia",
              path: "https://www.youtube.com/watch?v=5uZa3-RMFos"),
    ])))
}

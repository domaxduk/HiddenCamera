//
//  CCTVView.swift
//  HiddenCamera
//
//  Created by Tra Le on 11/2/25.
//

import SwiftUI
import SDWebImageSwiftUI
import RxSwift
import SakuraExtension

struct CCTVView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.countries.isEmpty {
                    ProgressView()
                        .circleprogressColor(.black)
                } else {
                    ForEach(viewModel.countries.indices, id: \.self) { index in
                        let country = viewModel.countries[index]
                        Button(action: {
                            viewModel.input.selectCCTVCountry.onNext(country)
                        }, label: {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(Color.app(.light09))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        ZStack {
                                            ProgressView().circleprogressColor(.white)
                                            
                                            if let url = country.thumbnail {
                                                WebImage(url: url)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            }
                                        }
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(country.name)
                                        .font(Poppins.semibold.font(size: 14))
                                        .textColor(.app(.light12))
                                        .frame(height: 20)
                                    Text("\(country.items.count) channels")
                                        .font(Poppins.regular.font(size: 12))
                                        .textColor(.app(.light09))
                                        .frame(height: 18)
                                }
                                
                                Spacer(minLength: 0)
                            }
                            .padding(20)
                            .background(Color.app(.light01))
                            .cornerRadius(20, corners: .allCorners)
                        })
                        .padding(.top, 16)
                        
                        if (index + 1) % 4 == 0 && !viewModel.isPremium {
                            NativeContentView(padding: .init(top: 20))
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 100)
        }
    }
}

extension CCTVCountry {
    var thumbnail: URL? {
        return URL(string: imagePath)
    }
}

#Preview {
    CCTVView()
        .environmentObject(HomeViewModel())
        .background(Color.black)
}

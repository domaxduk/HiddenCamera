//
//  Copyright 2022 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import GoogleMobileAds
import SwiftUI

// [START add_view_model_to_view]
struct NativeContentView: View {
    @StateObject private var nativeViewModel = AdsNativeLoader()
    
    @ViewBuilder
    var body: some View {
        ZStack {
            if let nativeAd = nativeViewModel.nativeAd {
                SmallNativeView(nativeAd: nativeAd)
                    .frame(height: 160)
                    .background(Color.red)
            }
        }
        .onAppear(perform: {
            nativeViewModel.load()
        })
    }
}

#Preview {
    NativeContentView()
}

// MARK: - SmallNativeView
struct SmallNativeView: UIViewRepresentable {
    typealias UIViewType = GADNativeAdView
    var nativeAd: GADNativeAd
    
    func makeUIView(context: Context) -> GADNativeAdView {
        return Bundle.main.loadNibNamed("SmallNativeView", owner: nil, options: nil)?.first as! GADNativeAdView
    }
    
    func updateUIView(_ nativeAdView: GADNativeAdView, context: Context) {
        // Each UI property is configurable using your native ad.
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
                
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        
        // For the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        // Associate the native ad view with the native ad object. This is required to make the ad
        // clickable.
        // Note: this should always be done after populating the ad views.
        nativeAdView.nativeAd = nativeAd
    }
}

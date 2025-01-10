//
//  BannerContentView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import GoogleMobileAds
import SwiftUI

struct BannerContentView: View {
    let navigationTitle: String
    
    var body: some View {
        GeometryReader { geometry in
            let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(geometry.size.width)
            
            VStack(spacing: 0) {
                Color.red
                BannerView(adSize: adSize, isCollapse: true, isShowingBanner: .constant(true))
                    .frame(height: adSize.size.height)
            }
        }
        .navigationTitle(navigationTitle)
    }
}

struct BannerContentView_Previews: PreviewProvider {
    static var previews: some View {
        BannerContentView(navigationTitle: "Banner")
    }
}

struct BannerView: UIViewRepresentable {
    @Binding var isShowingBanner: Bool
    let adSize: GADAdSize
    let isCollapse: Bool
    
    init(adSize: GADAdSize? = nil, isCollapse: Bool, isShowingBanner: Binding<Bool>) {
        self.adSize = adSize ?? GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
        self.isCollapse = isCollapse
        self._isShowingBanner = isShowingBanner
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.addSubview(context.coordinator.bannerView)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.bannerView.adSize = adSize
    }
    
    func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator(self)
    }
    
    class BannerCoordinator: NSObject, GADBannerViewDelegate {
        
        private(set) lazy var bannerView: GADBannerView = {
            let banner = GADBannerView(adSize: parent.adSize)
            // [START load_ad]
            
            if parent.isCollapse {
                banner.adUnitID = GoogleAdsKey.collapse
            } else {
                banner.adUnitID = GoogleAdsKey.banner
            }
            
            let request = GADRequest()
            
            // Create an extra parameter that aligns the bottom of the expanded ad to
            // the bottom of the bannerView.
            if parent.isCollapse {
                let extras = GADExtras()
                extras.additionalParameters = ["collapsible" : "bottom"]
                request.register(extras)
            }
            
            banner.load(request)
            banner.delegate = self
            
            // [END set_delegate]
            return banner
        }()
        
        let parent: BannerView
        
        init(_ parent: BannerView) {
            self.parent = parent
        }
        
        // MARK: - GADBannerViewDelegate methods
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("DID RECEIVE AD.")
            parent.isShowingBanner = true
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("FAILED TO RECEIVE AD: \(error.localizedDescription)")
        }
    }
}

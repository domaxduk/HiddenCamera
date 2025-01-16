//
//  BannerContentView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import GoogleMobileAds
import SwiftUI
import RxSwift

struct BannerContentView: View {
    @State var isShowingBanner: Bool = false
    var isCollapse: Bool
    var hasOneKeyAd: Bool = false
    let needToReload: PublishSubject<()>?
    
    var body: some View {
        ZStack {
            let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
            
            BannerView(adSize: adSize, isCollapse: isCollapse, isShowingBanner: $isShowingBanner, hasOneKeyAd: hasOneKeyAd, needToReload: needToReload)
                .frame(height: isShowingBanner ? adSize.size.height : 0)
        }
    }
}

fileprivate struct BannerView: UIViewRepresentable {
    @Binding var isShowingBanner: Bool
    let adSize: GADAdSize
    let isCollapse: Bool
    let hasOneKeyAd: Bool
    let needToReload: PublishSubject<()>?
    
    init(adSize: GADAdSize? = nil, isCollapse: Bool, isShowingBanner: Binding<Bool>, hasOneKeyAd: Bool, needToReload: PublishSubject<()>?) {
        self.adSize = adSize ?? GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
        self.isCollapse = isCollapse
        self._isShowingBanner = isShowingBanner
        self.hasOneKeyAd = hasOneKeyAd
        self.needToReload = needToReload
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
                banner.adUnitID = GoogleAdsKey.allCollapse
            } else {
                banner.adUnitID = GoogleAdsKey.allBanner
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
        
        private let parent: BannerView
        private let disposeBag = DisposeBag()
        private var isReloading: Bool = true
        
        init(_ parent: BannerView) {
            self.parent = parent
            super.init()
            self.parent.needToReload?.subscribe(onNext: { [weak self] _ in
                self?.reload()
            }).disposed(by: self.disposeBag)
        }
        
        // MARK: - GADBannerViewDelegate methods
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("[BANNER] DID RECEIVE AD.")
            parent.isShowingBanner = true
            self.isReloading = false
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("[BANNER] FAILED TO RECEIVE AD: \(error.localizedDescription)")
            self.isReloading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.reload()
            }
        }
        
        private func reload() {
            if isReloading { return }
            print("[BANNER] reload banner")
            setKey()
            let request = GADRequest()
            if parent.isCollapse {
                let extras = GADExtras()
                extras.additionalParameters = ["collapsible" : "bottom"]
                request.register(extras)
            }
            
            bannerView.load(request)
        }
        
        private func setKey() {
            if parent.hasOneKeyAd {
                bannerView.adUnitID = parent.isCollapse ? GoogleAdsKey.allCollapse : GoogleAdsKey.allBanner
                return
            }
            
            if let adUnitID = bannerView.adUnitID {
                switch adUnitID {
                case GoogleAdsKey.highCollapse, GoogleAdsKey.highCollapse:
                    bannerView.adUnitID = parent.isCollapse ? GoogleAdsKey.mediumCollapse : GoogleAdsKey.mediumBanner
                case GoogleAdsKey.mediumCollapse, GoogleAdsKey.mediumBanner:
                    bannerView.adUnitID = parent.isCollapse ? GoogleAdsKey.allCollapse : GoogleAdsKey.allBanner
                case GoogleAdsKey.allCollapse, GoogleAdsKey.allBanner: break
                default:
                    bannerView.adUnitID = parent.isCollapse ? GoogleAdsKey.highCollapse : GoogleAdsKey.highCollapse
                }
            } else {
                bannerView.adUnitID = parent.isCollapse ? GoogleAdsKey.highCollapse : GoogleAdsKey.highCollapse
            }
        }
    }
}

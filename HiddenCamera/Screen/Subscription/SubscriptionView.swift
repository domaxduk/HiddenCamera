//
//  SubscriptionView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import SwiftUI
import SakuraExtension
import RxSwift
import SwiftyStoreKit
import FirebaseAnalytics

// MARK: - SubscriptionItem
class SubscriptionItem {
    var type: SubscriptionType
    var title: String
    var id: String
    var priceString: String
    var pricePerWeek: String
    var color: Color
    var noteString: String
    
    init(type: SubscriptionType, title: String, id: String, priceString: String, pricePerWeek: String, color: Color, noteString: String) {
        self.type = type
        self.title = title
        self.id = id
        self.priceString = priceString
        self.pricePerWeek = pricePerWeek
        self.color = color
        self.noteString = noteString
    }
    
    enum SubscriptionType {
        case week
        case year
    }
}

// MARK: - SubscriptionViewModel
class SubscriptionViewModel: ObservableObject {
    @Published var items: [SubscriptionItem] = [
        SubscriptionItem(type: .week, title: "Weekly",
                         id: "com.trale.hidden.camera.week",
                         priceString: "$9.99",
                         pricePerWeek: "",
                         color: Color(rgb: 0x00BA00), noteString: ""),
        SubscriptionItem(type: .year,
                         title: "Yearly",
                         id: "com.trale.hidden.camera.year",
                         priceString: "$19.99",
                         pricePerWeek: "Only $0.38 per week",
                         color: Color(rgb: 0xFFC53D), noteString: "Save 96%")
    ]
    
    @Published var currentItem: SubscriptionItem?
    @Published var isShowingLoading: Bool = false
    @Published var descriptionString: String = "- The price of weekly subscription is $9.99 and yearly subscription is $19.99\n- One you confirm the purchase, your payment will be charged to your iTunes Account.\n- Your subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.\n- Your account will be charged for renewal within 24-hours prior to the end of the current period.\n- Subscription maybe managed by the user and auto-renewal maybe turned off by going to the user's account setting after purchasing."
    
    var actionAfterDismiss: (() -> Void)
    var didTapBack = PublishSubject<()>()
    var presentAlert = PublishSubject<String>()

    init(actionAfterDismiss: @escaping (() -> Void)) {
        self.actionAfterDismiss = actionAfterDismiss
    }
    
    func loadInfo() {
        self.isShowingLoading = true
        let ids = Set(items.map({ $0.id }))
        
        SwiftyStoreKit.retrieveProductsInfo(ids) { [weak self] results in
            guard let self else { return }
            var year: Double?
            var week: Double?
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            
            for product in results.retrievedProducts {
                if let item = self.items.first(where: { $0.id == product.productIdentifier }) {
                    formatter.locale = product.priceLocale
                    
                    if product.localizedPrice != nil {
                        let price = round(product.price.doubleValue * 100.0) / 100.0
                        let priceText = formatter.string(for: price) ?? ""
                        item.priceString = priceText
                        
                        switch item.type {
                        case .week:
                            week = price
                        case .year:
                            year = price
                            let weekPrice = round(product.price.doubleValue / 52.0 * 100.0) / 100.0
                            item.pricePerWeek =  "Only " + (formatter.string(for: weekPrice) ?? "") + " per week"
                        }
                    }
                }
            }
            
            if let year, let week, let item = items.first(where: { $0.type == .year }) {
                let save = Int(((week - year / 52.0) / week) * 100.0)
                item.noteString = "Save \(save)%"
            }
            
            self.configMoreDescriptionLabel(
                week: formatter.string(for: week) ?? "",
                year: formatter.string(for: year) ?? "")
            
            self.isShowingLoading = false
        }
    }
    
    private func configMoreDescriptionLabel(week: String, year: String) {
        self.descriptionString = "- The price of weekly subscription is \(week) and yearly subscription is \(year)\n- One you confirm the purchase, your payment will be charged to your iTunes Account.\n- Your subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.\n- Your account will be charged for renewal within 24-hours prior to the end of the current period.\n- Subscription maybe managed by the user and auto-renewal maybe turned off by going to the user's account setting after purchasing."
    }
    
    func didTapContinue() {
        if let currentItem {
            switch currentItem.type {
            case .week:
                Analytics.logEvent("continue_week", parameters: nil)
            case .year:
                Analytics.logEvent("continue_year", parameters: nil)
            }
            self.isShowingLoading = true
            
            SwiftyStoreKit.purchaseProduct(currentItem.id) { [weak self] result in
                guard let self else { return }
                self.isShowingLoading = false
                
                switch result {
                case .success(let purchase):
                    switch currentItem.type {
                    case .week:
                        Analytics.logEvent("purchase_week_success", parameters: nil)
                    case .year:
                        Analytics.logEvent("continue_year_success", parameters: nil)
                    }
                    
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    
                    UserSetting.isPremiumUser = true
                    self.didTapBack.onNext(())
                case .error(error: let error):
                    print("error: \(error)")
                    self.presentAlert.onNext("Purchase fail")
                    
                    switch currentItem.type {
                    case .week:
                        Analytics.logEvent("purchase_week_fail", parameters: nil)
                    case .year:
                        Analytics.logEvent("continue_year_fail", parameters: nil)
                    }
                }
            }
        }
    }
    
    func restore() {
        self.isShowingLoading = true
        
        SwiftyStoreKit.restorePurchases { [weak self] result in
            guard let self else { return }
            self.isShowingLoading = false
            UserSetting.isPremiumUser = result.restoredPurchases.count > 0
            
            if result.restoredPurchases.count > 0 {
                self.presentAlert.onNext("Restore successed!")
            } else {
                self.presentAlert.onNext("Nothing to restore!")
            }
        }
    }
}

// MARK: - SubscriptionView
struct SubscriptionView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @State var isAnimating: Bool = false
    @State var heightContent: Double = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            Image("sub_background")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
            content.ignoresSafeArea()
            
            VStack {
                navigationBar
                Spacer()
                HStack {
                    Spacer()
                    Text("Privacy Policy")
                        .underline()
                        .font(.system(size: 12))
                        .textColor(Color(rgb: 0x787878))
                    Spacer()
                    Text("Term of Service")
                        .underline()
                        .font(.system(size: 12))
                        .textColor(Color(rgb: 0x787878))
                    Spacer()
                    Text("Restore")
                        .underline()
                        .font(.system(size: 12))
                        .textColor(Color(rgb: 0x787878))
                        .onTapGesture {
                            viewModel.restore()
                        }
                    Spacer()
                }
                .background(Color.white.ignoresSafeArea())
            }
            
            ZStack {
                BlurSwiftUIView(effect: .init(style: .dark)).ignoresSafeArea()
                ProgressView().circleprogressColor(.white)
            }
            .opacity(viewModel.isShowingLoading ? 1 : 0)
        }.onAppear(perform: {
            self.viewModel.currentItem = self.viewModel.items.last
        })
        .frame(width: UIScreen.main.bounds.width)
    }
    
    var navigationBar: some View {
        ZStack {
            Text(AppConfig.appName)
                .font(Poppins.semibold.font(size: 18))
                .textColor(.app(.light01))
            
            HStack {
                Image("ic_back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
                    .padding()
                    .onTapGesture {
                        viewModel.didTapBack.onNext(())
                    }
                
                Spacer()
            }
        }.frame(height: 56)
    }
    
    var content: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: UIScreen.main.bounds.height - heightContent - 56)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("100% No Ads")
                                .textColor(.app(.light12))
                                .font(Poppins.regular.font(size: 14))
                                .autoResize(numberLines: 1)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(38, corners: .allCorners)
                            
                            Text("Fastest find all spy devices")
                                .textColor(.app(.light12))
                                .font(Poppins.regular.font(size: 14))
                                .autoResize(numberLines: 1)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(38, corners: .allCorners)
                        }
                        .offset(x: isAnimating ? 20 : -20)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                        .shadow(radius: 5)
                        .padding(.bottom, 15)
                        
                        HStack {
                            Text("Find all hidden devices")
                                .textColor(.app(.light12))
                                .font(Poppins.regular.font(size: 14))
                                .autoResize(numberLines: 1)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(38, corners: .allCorners)
                            
                            Text("Access to all features")
                                .textColor(.app(.light12))
                                .font(Poppins.regular.font(size: 14))
                                .autoResize(numberLines: 1)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(38, corners: .allCorners)
                        }
                        .offset(x: isAnimating ? -20 : 20)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                        .shadow(radius: 5)
                        .padding(.bottom, 30)
                        
                        HStack(spacing: 20) {
                            ForEach(viewModel.items, id: \.type) { item in
                                VStack(spacing: 0) {
                                    Color.clear.frame(height: 0)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(item.color.opacity(0.1))
                                        .frame(width: 48,height: 48)
                                        .overlay(
                                            Image("ic_sub_\(item.type == .week ? "week" : "year")")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24)
                                        )
                                    
                                    Text(item.title)
                                        .font(Poppins.regular.font(size: 16))
                                        .textColor(.app(.light11))
                                        .frame(height: 24)
                                        .padding(.top, 8)
                                    
                                    Text(item.priceString)
                                        .font(Poppins.bold.font(size: 24))
                                        .textColor(.app(.light12))
                                        .frame(height: 36)
                                    
                                    Text(item.pricePerWeek)
                                        .font(Poppins.regular.font(size: 12))
                                        .textColor(.app(.light11))
                                        .frame(height: 18)
                                }
                                .padding(.bottom, 20)
                                .padding(.top, 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.app(viewModel.currentItem?.id == item.id ? .warning : .light08),lineWidth: 2)
                                        .background(Color.clearInteractive)
                                )
                                .overlay(
                                    VStack {
                                        if !item.noteString.isEmpty {
                                            Text(item.noteString)
                                                .font(Poppins.bold.font(size: 12))
                                                .textColor(.white)
                                                .frame(height: 24)
                                                .padding(.horizontal, 20)
                                                .background(Color.app(.warning))
                                                .cornerRadius(12, corners: .allCorners)
                                                .offset(y: -12)
                                        }
                                        
                                        Spacer()
                                    }
                                )
                                .onTapGesture {
                                    self.viewModel.currentItem = item
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                        HStack(spacing: 6) {
                            Image("ic_protect")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16)
                            
                            Text("Secured with Apple Store. Cancel Anytime")
                                .font(.system(size: 10))
                                .textColor(.app(.light08))
                        }.padding(.bottom, 10)
                        
                        Color.app(.main).frame(height: 56)
                            .cornerRadius(28, corners: .allCorners)
                            .overlay(
                                Text("CONTINUE")
                                    .font(Poppins.semibold.font(size: 16))
                                    .textColor(.white)
                            )
                            .scaleEffect(isAnimating ? 0.9 : 1.1)
                            .onTapGesture {
                                viewModel.didTapContinue()
                            }
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                    }
                    .background(
                        ZStack {
                            GeometryReader(content: { geometry in
                                Color.clear
                                    .onAppear(perform: {
                                        heightContent = geometry.size.height
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.isAnimating = true
                                        }
                                    })
                            })
                            
                            VStack(spacing: 0) {
                                let paddingTop: CGFloat = 30
                                LinearGradient(colors: [.clear, .white], startPoint: .top, endPoint: .bottom)
                                    .frame(height: paddingTop)
                                Color.white.ignoresSafeArea()
                            }
                        }
                    )
                    
                    VStack {
                        Color.clear.frame(height: 1)
                        LabelText(text: viewModel.descriptionString)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                    }
                    .background(Color.white.ignoresSafeArea())
                }
            }
        }
    }
}

// MARK: - LabelText
fileprivate struct LabelText: UIViewRepresentable {
    var text: String
    typealias UIViewType = UILabel
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.text = text
        label.font = Poppins.regular.font(size: 14)
        label.textColor = .black
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.lineBreakStrategy = .hangulWordPriority
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
        uiView.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 20 * 2
    }
}

#Preview {
    SubscriptionView(viewModel: SubscriptionViewModel(actionAfterDismiss: {
        
    }))
}

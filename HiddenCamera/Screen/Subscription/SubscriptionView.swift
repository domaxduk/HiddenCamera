//
//  SubscriptionView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import SwiftUI
import SakuraExtension



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

struct SubscriptionView: View {
    @State var items: [SubscriptionItem] = [
        SubscriptionItem(type: .week, title: "Weekly",
                         id: "week", priceString: "$9.99", pricePerWeek: "", color: .black, noteString: ""),
        SubscriptionItem(type: .year, title: "Yearly",
                         id: "year", priceString: "$19.99",
                         pricePerWeek: "Only $.. per week", color: .black, noteString: "Save 50%")
    ]
    
    @State var currentItem: SubscriptionItem?
    @State var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            Color.app(.safe).ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true))
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
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true))
                .padding(.bottom, 30)
                
                HStack(spacing: 20) {
                    ForEach(items, id: \.type) { item in
                        VStack(spacing: 0) {
                            Color.clear.frame(height: 0)
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 48,height: 48)
                            
                            Text(item.title)
                                .font(Poppins.regular.font(size: 16))
                                .textColor(.app(.light11))
                                .frame(height: 24)
                                .padding(.top, 8)
                            
                            Text(item.priceString)
                                .font(Poppins.bold.font(size: 24))
                                .textColor(.app(.light12))
                                .frame(height: 26)
                            
                            Text(item.noteString)
                                .font(Poppins.regular.font(size: 12))
                                .textColor(.app(.light11))
                                .frame(height: 18)
                        }
                        .padding(.bottom, 20)
                        .padding(.top, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.app(currentItem?.id == item.id ? .warning : .light08),lineWidth: 2)
                                .background(Color.clearInteractive)
                        )
                        .overlay(
                            VStack {
                                if !item.noteString.isEmpty {
                                    Text("Save 50%")
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
                            self.currentItem = item
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
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                
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
                    Spacer()
                }
            }
        }.onAppear(perform: {
            self.currentItem = self.items.last
            self.isAnimating = true
        })
        .frame(width: UIScreen.main.bounds.width)
    }
}

#Preview {
    SubscriptionView()
}

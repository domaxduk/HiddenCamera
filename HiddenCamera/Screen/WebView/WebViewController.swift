//
//  WebViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import UIKit
import SwiftUI
import SakuraExtension

class WebViewController: ViewController {
    
    let urlString: String
    let navigationTitle: String
    
    fileprivate init(urlString: String, navigationTitle: String) {
        self.urlString = urlString
        self.navigationTitle = navigationTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let view = MainView(url: URL(string: urlString), title: navigationTitle)
        insertSwiftUIView(rootView: view)
    }
    
    static func open(urlString: String, title: String) {
        let vc = WebViewController(urlString: urlString, navigationTitle: title)
        vc.modalPresentationStyle = .overFullScreen
        let topVC = UIApplication.shared.navigationController?.topVC
        topVC?.present(vc, animated: true)
    }
}

fileprivate struct MainView: View {
    var url: URL?
    let title: String
    @State var error: Error?
    
    var body: some View {
        ZStack {
            Color.app(.light03).ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image("ic_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                        .padding()
                        .onTapGesture {
                            dismiss()
                        }
                    
                    Text(title)
                        .font(Poppins.semibold.font(size: 16))
                        .textColor(.app(.light12))
                        .autoResize(numberLines: 1)
                    
                    Spacer()
                }.frame(height: AppConfig.navigationBarHeight)
                
                if let url {
                    WebView(error: $error, request: URLRequest(url: url))
                        .background(ProgressView())
                        .ignoresSafeArea()
                } else {
                    Text("Wrong url")
                    Spacer()
                }
            }
        }
    }
    
    private func dismiss() {
        if let topVC = UIApplication.shared.navigationController?.topVC, topVC is WebViewController {
            topVC.dismiss(animated: true)
        }
    }
}

#Preview {
    MainView(url: URL(string: AppConfig.policy), title: "Policy")
}

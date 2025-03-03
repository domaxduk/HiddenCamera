//
//  UserAddressDialog.swift
//  HiddenCamera
//
//  Created by Tra Le on 14/2/25.
//

import SwiftUI
import SakuraExtension
import RxSwift

class UserAddressViewModel: ObservableObject {
    @Published var customAddress: String = "" {
        didSet {
            self.currentChoice = 1
        }
    }
    
    @Published var currentAddress: String = ""
    @Published var currentChoice: Int = 1
    var didChooseAddress = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    init() {
        LocationManager.shared.getCurrentLocation().subscribe(onNext: { [weak self] address in
            DispatchQueue.main.async {
                self?.currentAddress = address
            }
        }).disposed(by: self.disposeBag)
    }
    
    func didTapContinue() {
        switch currentChoice {
        case 0:
            if currentAddress.isEmpty {
                chooseCustomAddress()
            } else {
                didChooseAddress.onNext(currentAddress)
            }
        case 1: 
            chooseCustomAddress()
        default: break
        }
    }
    
    private func chooseCustomAddress() {
        if customAddress.isEmpty {
            let alertVC = UIAlertController(title: "Oops!", message: "Please enter your location!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
            alertVC.addAction(cancelAction)
            
            UIApplication.shared.navigationController?.topVC?.present(alertVC, animated: true)
        } else {
            self.didChooseAddress.onNext(customAddress)
        }
    }
}

struct UserAddressDialog: View {
    @ObservedObject var viewModel: UserAddressViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Color.clear.frame(height: 1)
                Text("Is this the location you want to scan for suspicious hidden devices?")
                    .textColor(.app(.light12))
                    .font(Poppins.semibold.font(size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.top, 36)
                    .padding(.horizontal, 33)
                
                if !viewModel.currentAddress.isEmpty {
                    HStack(spacing: 0) {
                        SelectedRatioView(isSelected: viewModel.currentChoice == 0)
                        
                        Text(viewModel.currentAddress)
                            .textColor(.app(.light12))
                            .font(Poppins.regular.font(size: 16))
                            .padding(.leading, 14)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 18)
                    .frame(minWidth: 24)
                    .onTapGesture {
                        viewModel.currentChoice = 0
                    }
                    .padding(.top, 26)
                    
                    Color.app(.light04).frame(height: 1)
                        .padding(.top, 20)
                }

                HStack(spacing: 0) {
                    SelectedRatioView(isSelected: viewModel.currentChoice == 1)
                        .onTapGesture {
                            viewModel.currentChoice = 1
                        }
                    
                    Color.black.opacity(0.1)
                        .cornerRadius(12, corners: .allCorners)
                        .overlay(
                            ZStack(alignment: .leading) {
                                if viewModel.customAddress.isEmpty {
                                    Text("Your location")
                                        .font(Poppins.regular.font(size: 16))
                                        .textColor(.init(hex: "#8d8d8d"))
                                }
                                
                                TextField("", text: $viewModel.customAddress)
                                    .font(Poppins.regular.font(size: 16))
                            }.padding(.leading, 10)
                        )
                        .padding(.leading, 14)
                }
                .padding(.horizontal, 18)
                .frame(height: 44)
                .padding(.top, 20)
                
                Button(action: {
                    viewModel.didTapContinue()
                }, label: {
                    Color.app(.main)
                        .frame(height: 56)
                        .overlay(
                            Text("Continue")
                                .textColor(.white)
                                .font(Poppins.semibold.font(size: 16))
                        )
                        .cornerRadius(28, corners: .allCorners)
                })
                .padding(.horizontal, 68)
                .padding(.vertical, 26)
            }
            .background(Color.app(.light01))
            .cornerRadius(20, corners: .allCorners)
            .padding(.horizontal, 20)
        }
    }
}

fileprivate struct SelectedRatioView: View {
    var isSelected: Bool
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.app(.main),lineWidth: 1.5)
                .overlay(
                    Circle()
                        .fill(Color.app(.main))
                        .padding(3)
                        .opacity(isSelected ? 1 : 0)
                )
                .padding(2)
        }
        .frame(width: 24, height: 24)
    }
}

#Preview {
    UserAddressDialog(viewModel: UserAddressViewModel())
}

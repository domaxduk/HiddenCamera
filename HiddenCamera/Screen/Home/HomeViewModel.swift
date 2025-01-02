//
//  HomeViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit
import RxSwift

struct HomeViewModelInput: InputOutputViewModel {
    var didSelectTool = PublishSubject<ToolItem>()
}

struct HomeViewModelOutput: InputOutputViewModel {

}

struct HomeViewModelRouting: RoutingOutput {
    var routeToInfraredCamera = PublishSubject<()>()
}

final class HomeViewModel: BaseViewModel<HomeViewModelInput, HomeViewModelOutput, HomeViewModelRouting> {
    @Published var currentTab: HomeTab = .tools
    
    override func configInput() {
        super.configInput()
        
        input.didSelectTool.subscribe(onNext: { [weak self] tool in
            switch tool {
            case .infraredCamera:
                self?.routeToInfraredCamera()
            default: break
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func routeToInfraredCamera() {
        Permission.requestCamera { [weak self] granted in
            DispatchQueue.main.async {
                self?.routing.routeToInfraredCamera.onNext(())
            }
        }
    }
}

//
//  HistoryDetailViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import UIKit
import RxSwift

struct HistoryDetailViewModelInput: InputOutputViewModel {
    var didTapFix = PublishSubject<ToolItem>()
}

struct HistoryDetailViewModelOutput: InputOutputViewModel {

}

struct HistoryDetailViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var routeToTool = PublishSubject<ToolItem>()
}

final class HistoryDetailViewModel: BaseViewModel<HistoryDetailViewModelInput, HistoryDetailViewModelOutput, HistoryDetailViewModelRouting> {
    let scanOption: ScanOptionItem
    
    init(scanOption: ScanOptionItem) {
        self.scanOption = scanOption
        super.init()
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapFix.subscribe(onNext: { [weak self] tool in
            self?.routing.routeToTool.onNext(tool)
        }).disposed(by: self.disposeBag)
    }
}

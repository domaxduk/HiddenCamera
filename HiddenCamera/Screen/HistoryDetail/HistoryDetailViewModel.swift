//
//  HistoryDetailViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import UIKit
import RxSwift
import FirebaseAnalytics

struct HistoryDetailViewModelInput: InputOutputViewModel {
    var reopenTool = PublishSubject<ToolItem>()
    var didTapBack = PublishSubject<()>()
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
        
        if scanOption.isThreadAfterIntro {
            Analytics.logEvent("first_result", parameters: nil)
        }
    }
    
    override func configInput() {
        super.configInput()
        
        input.reopenTool.subscribe(onNext: { [weak self] tool in
            self?.routing.routeToTool.onNext(tool)
        }).disposed(by: self.disposeBag)
        
        input.didTapBack.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            
            if !scanOption.isSave {
                let dao = ScanHistoryDAO()
                dao.addObject(item: scanOption)
                self.scanOption.isSave = true
            }
            
            self.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    var numberOfTool: Int {
        return scanOption.tools.count
    }
}

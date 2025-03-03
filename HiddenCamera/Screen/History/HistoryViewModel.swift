//
//  HistoryViewModel.swift
//  HiddenCamera
//
//  Created by Tra Le on 12/2/25.
//

import UIKit
import RxSwift

struct HistoryViewModelInput: InputOutputViewModel {
    var didTapBack = PublishSubject<()>()
}

struct HistoryViewModelOutput: InputOutputViewModel {

}

struct HistoryViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var routeToHistoryDetail = PublishSubject<ScanOptionItem>()
}

final class HistoryViewModel: BaseViewModel<HistoryViewModelInput, HistoryViewModelOutput, HistoryViewModelRouting> {
    @Published var historyItems = [ScanOptionItem]()

    override func config() {
        super.config()
        getListHistory()
        NotificationCenter.default.addObserver(self, selector: #selector(getListHistory), name: .updateListHistory, object: nil)
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapBack.subscribe(onNext: { [weak self] in
            self?.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    @objc private func getListHistory() {
        let dao = ScanHistoryDAO()
        self.historyItems = dao.getAll()
    }
}

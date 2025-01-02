//
//  BaseViewModel.swift
//
//

import Foundation
import RxSwift

public protocol InputOutputViewModel {
    init()
}

public protocol RoutingOutput {
    init()
}

public class BaseViewModel<Input: InputOutputViewModel, Output: InputOutputViewModel, Routing: RoutingOutput>: NSObject, ObservableObject {
    var input = Input()
    var output = Output()
    var routing = Routing()
    var disposeBag = DisposeBag()
    
    public override init() {
        super.init()
        config()
    }
    
    func config() {
        configInput()
        configOutput()
        configRouting()
    }
    
    func configInput() {
        
    }
    
    func configOutput() {
        
    }
    
    func configRouting() {
        
    }
}


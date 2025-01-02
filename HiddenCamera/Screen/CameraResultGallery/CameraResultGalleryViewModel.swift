//
//  CameraResultGalleryViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import UIKit
import RxSwift
import SwiftUI

struct CameraResultGalleryViewModelInput: InputOutputViewModel {
    var didTapBack = PublishSubject<()>()
    var didTapItem = PublishSubject<CameraResultItem>()
    var didTapChangeMode = PublishSubject<()>()
    var didTapDelete = PublishSubject<()>()
}

struct CameraResultGalleryViewModelOutput: InputOutputViewModel {

}

struct CameraResultGalleryViewModelRouting: RoutingOutput {
    var back = PublishSubject<()>()
    var preview = PublishSubject<CameraResultItem>()
}

final class CameraResultGalleryViewModel: BaseViewModel<CameraResultGalleryViewModelInput, CameraResultGalleryViewModelOutput, CameraResultGalleryViewModelRouting> {
    @Published var isEditing: Bool = false
    @Published var selectedItems = [CameraResultItem]()
    @Published var items = [CameraResultItem]()
    private var dao = CameraResultDAO()
    let type: CameraType
    
    init(type: CameraType) {
        self.type = type
        super.init()
        getData()
    }
    
    private func getData() {
        items = dao.getAll().filter({ $0.type == .infrared })
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapBack.subscribe(onNext: { [weak self] tag in
            guard let self else { return }
            self.routing.back.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didTapDelete.subscribe(onNext: { [weak self] tag in
            guard let self else { return }
            dao.deleteItems(items: selectedItems)
            withAnimation {
                self.getData()
                self.selectedItems = []
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapChangeMode.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            withAnimation {
                self.isEditing.toggle()
                
                if !self.isEditing {
                    self.selectedItems = []
                }
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapItem.subscribe(onNext: { [weak self] item in
            guard let self else { return }
            
            if isEditing {
                if isSelectedItem(id: item.id) {
                    selectedItems.removeAll(where: { $0.id == item.id})
                } else {
                    selectedItems.append(item)
                }
            } else {
                self.routing.preview.onNext(item)
            }
        }).disposed(by: self.disposeBag)
    }
    
    func isSelectedItem(id: String) -> Bool {
        return selectedItems.contains(where: { $0.id == id })
    }
}

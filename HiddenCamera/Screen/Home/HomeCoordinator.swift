//
//  HomeCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit
import RxSwift

final class HomeCoordinator: WindowBasedCoordinator {
    private var navigationController: UINavigationController!
    private var infraredCameraCoordinator: InfraredCameraCoordinator?
    private var cameraDetectorCoordinator: CameraDetectorCoordinator?
    private var wifiScannerCoordinator: WifiScannerCoordinator?
    private var bluetoothScannerCoordinator: BluetoothScannerCoordinator?

    lazy var controller: HomeViewController = {
        let viewModel = HomeViewModel()
        let controller = HomeViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }

    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is InfraredCameraCoordinator {
            self.infraredCameraCoordinator = nil
        }
        
        if child is CameraDetectorCoordinator {
            self.cameraDetectorCoordinator = nil
        }
        
        if child is WifiScannerCoordinator {
            self.wifiScannerCoordinator = nil
        }
        
        if child is BluetoothScannerCoordinator {
            self.bluetoothScannerCoordinator = nil
        }
    }
}

// MARK: - Route
extension HomeCoordinator {
    func routeToInfraredCamera() {
        self.infraredCameraCoordinator = InfraredCameraCoordinator(navigationController: navigationController)
        self.infraredCameraCoordinator?.start()
        self.addChild(infraredCameraCoordinator!)
    }
    
    func routeToCameraDetector() {
        self.cameraDetectorCoordinator = CameraDetectorCoordinator(navigationController: navigationController)
        self.cameraDetectorCoordinator?.start()
        self.addChild(cameraDetectorCoordinator!)
    }
    
    func routeToWifiScanner() {
        if self.wifiScannerCoordinator != nil {
            return
        }
        
        self.wifiScannerCoordinator = WifiScannerCoordinator(navigationController: navigationController)
        self.wifiScannerCoordinator?.start()
        self.addChild(wifiScannerCoordinator!)
    }
    
    func routeToBluetoothScanner() {
        if self.bluetoothScannerCoordinator != nil {
            return
        }
        
        self.bluetoothScannerCoordinator = BluetoothScannerCoordinator(navigationController: navigationController)
        self.bluetoothScannerCoordinator?.start()
        self.addChild(bluetoothScannerCoordinator!)
    }
}

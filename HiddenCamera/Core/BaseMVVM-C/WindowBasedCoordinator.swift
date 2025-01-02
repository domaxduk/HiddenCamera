//
//  WindowBasedCoordinator.swift
//
//  Created by Duc apple  on 26/7/24.
//

import Foundation
import UIKit

open class WindowBasedCoordinator: Coordinator {
    var window: UIWindow

    public init(window: UIWindow) {
        self.window = window
        super.init()
    }
}

//
//  PresentedCoordinator.swift
//
//

import Foundation
import UIKit

open class PresentedCoordinator: Coordinator {
    weak var presentingViewController: UIViewController?

    public init(presentingViewController: UIViewController?) {
        self.presentingViewController = presentingViewController
    }
}

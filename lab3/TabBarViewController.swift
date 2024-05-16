//
//  TabBarViewController.swift
//  MovieLibrary
//
//  Created by Maxin4rm on 5/14/24.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.isModalInPresentation = true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    
        if let navigationController = viewController as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
        return true
    }
}


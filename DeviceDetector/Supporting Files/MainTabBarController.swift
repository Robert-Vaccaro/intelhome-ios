//
//  MainTabViewController.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//
//
//  MainTabViewController.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        SessionData.tabBarVC = self
        customizeTabBarAppearance()

        // Instantiate view controllers
        let devicesVC = DevicesVC()
        let profileVC = AccountVC()
        let locationsVC = LocationsVC() // New LocationsVC

        // Configure tab bar items
        devicesVC.tabBarItem = UITabBarItem(
            title: "Devices",
            image: UIImage(systemName: "laptopcomputer.and.iphone")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(systemName: "laptopcomputer.and.iphone")?.withTintColor(primaryColor, renderingMode: .alwaysOriginal)
        )
        
        profileVC.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(systemName: "person.fill")?.withTintColor(primaryColor, renderingMode: .alwaysOriginal)
        )
        
        locationsVC.tabBarItem = UITabBarItem(
            title: "Locations",
            image: UIImage(systemName: "list.bullet")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(systemName: "list.bullet")?.withTintColor(primaryColor, renderingMode: .alwaysOriginal)
        )

        // Wrap each view controller in a navigation controller
        let devicesNavVC = UINavigationController(rootViewController: devicesVC)
        let profileNavVC = UINavigationController(rootViewController: profileVC)
        let locationsNavVC = UINavigationController(rootViewController: locationsVC) // Add LocationsVC to navigation controller

        // Assign view controllers to the tab bar
        viewControllers = [devicesNavVC, locationsNavVC, profileNavVC]

        // Set title text attributes globally
        let appearance = UITabBarItem.appearance()
        let attributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        let attributesSelected = [NSAttributedString.Key.foregroundColor: primaryColor]

        appearance.setTitleTextAttributes(attributesNormal, for: .normal)
        appearance.setTitleTextAttributes(attributesSelected, for: .selected)
    }

    private func customizeTabBarAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black

            // Set title text attributes for normal and selected states
            let normalAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lightGray]
            let selectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: primaryColor]

            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes

            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        } else {
            tabBar.barTintColor = .black
            tabBar.isTranslucent = false

            let appearance = UITabBarItem.appearance()
            let attributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            let attributesSelected = [NSAttributedString.Key.foregroundColor: primaryColor]

            appearance.setTitleTextAttributes(attributesNormal, for: .normal)
            appearance.setTitleTextAttributes(attributesSelected, for: .selected)
        }

        // Add shadow to the tab bar
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.5
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 3
        tabBar.layer.masksToBounds = false
    }

    // Function to programmatically switch to a view controller at a given index
    @objc public func changeViewController(to index: Int) {
        if index >= 0 && index < viewControllers?.count ?? 0 {
            self.selectedIndex = index
        }
    }
}

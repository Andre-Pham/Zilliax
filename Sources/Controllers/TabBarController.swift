//
//  TabBarController.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class TabBarController: UITabBarController, UITabBarControllerDelegate {
    // MARK: Nested Types

    private class TabBarOption {
        // MARK: Properties

        public let iconConfig: Icon.Config
        public let selectedIconConfig: Icon.Config
        public let label: String
        public let viewController: UIViewController
        public let button = TabBarButton()

        // MARK: Lifecycle

        public init(icon: Icon.Config, selectedIcon: Icon.Config, label: String, viewController: UIViewController) {
            self.iconConfig = icon
            self.selectedIconConfig = selectedIcon
            self.label = label
            self.viewController = viewController
        }
    }

    // MARK: Properties

    /// The tab bar's height constraint
    private var tabBarHeightConstraint: NSLayoutConstraint? = nil
    private let tabBarStack = HStack()
    private let tabBarBorder = View()
    private var tabBarOptions = [TabBarOption]()

    // MARK: Computed Properties

    /// The tab bar's height, safe area included
    public var tabBarHeight: Double {
        return self.tabBarContentHeight + WindowContext.bottomSafeAreaHeight
    }

    /// The tab bar's height, excluding the safe area
    private var tabBarContentHeight: Double {
        guard let bottomSafeArea = WindowContext.window?.safeAreaInsets.bottom else {
            // If we can't read the bottom safe area, fallback to device type
            assertionFailure("Bottom safe area could not be read")
            switch DeviceContext.deviceType {
            case .phone:
                return 49.0
            case .pad:
                return 52.0
            default:
                // We have no clue what device we're on
                // Resort to 0 safe area height
                return 68.0
            }
        }
        if bottomSafeArea.isEqual(to: 34.0) {
            // Ideal height for iPhones
            return 49.0
        }
        if bottomSafeArea.isEqual(to: 25.0) {
            // Ideal height for iPads (Full-Screen Apps mode)
            return 52.0
        }
        if bottomSafeArea.isEqual(to: 20.0) {
            // Ideal height for iPads (Windowed Apps mode, in full-screen mode)
            return 57.0
        }
        if bottomSafeArea.isEqual(to: 10.0) {
            // Ideal height for iPads (Windowed Apps mode, in windowed mode)
            return 60.0
        }
        if bottomSafeArea.isEqual(to: 0.0) {
            // Ideal height for no safe area (home button iPhones, macOS)
            return 68.0
        }
        assertionFailure("Unexpected bottom safe area: \(bottomSafeArea)")
        // Extrapolate ideal tab bar height based on safe area
        return 0.0090196 * bottomSafeArea * bottomSafeArea - 0.86549 * bottomSafeArea + 68.0
    }

    private var itemIconConfigs: [Icon.Config] {
        return self.tabBarOptions.map(\.iconConfig)
    }

    private var selectedItemIconConfigs: [Icon.Config] {
        return self.tabBarOptions.map(\.selectedIconConfig)
    }

    private var tabBarItemLabels: [String] {
        return self.tabBarOptions.map(\.label)
    }

    private var allViewControllers: [UIViewController] {
        return self.tabBarOptions.map(\.viewController)
    }

    private var tabBarButtons: [TabBarButton] {
        return self.tabBarOptions.map(\.button)
    }

    // MARK: Overridden Functions

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        self.tabBarOptions.append(TabBarOption(
            icon: Icon.Config(systemName: "folder"),
            selectedIcon: Icon.Config(systemName: "folder.fill"),
            label: "Views",
            viewController: NavigationController(rootViewController: ViewsViewController())
        ))
        self.tabBarOptions.append(TabBarOption(
            icon: Icon.Config(systemName: "gearshape"),
            selectedIcon: Icon.Config(systemName: "gearshape.fill"),
            label: "Settings",
            viewController: SettingsViewController()
        ))

        self.tabBar.isTranslucent = true

        self.setViewControllers(self.allViewControllers, animated: false)

        self.view.add(self.tabBarStack)

        self.tabBarStack
            .setBackgroundColor(to: Colors.fillForeground)
            .constrainBottom(respectSafeArea: false)
            .matchWidthConstraint()
            .setDistribution(to: .fillEqually)

        self.tabBarHeightConstraint = self.tabBarStack.setHeightConstraintValue(to: self.tabBarHeight)

        self.tabBarBorder
            .addAsSubview(of: self.tabBarStack)
            .constrainToOnTop()
            .constrainHorizontal()
            .setHeightConstraint(to: 1.0)
            .setBackgroundColor(to: Colors.fillBackground)

        for itemButton in self.tabBarButtons {
            self.tabBarStack.append(itemButton)
        }

        for (index, itemButton) in self.tabBarButtons.enumerated() {
            itemButton
                .setIcon(to: self.itemIconConfigs[index])
                .setColor(to: Colors.fillForeground)
                .constrainVertical(respectSafeArea: false)
                .setOnTap({
                    self.tabBarOptionSelected(index: index)
                })
                .setLabel(to: self.tabBarItemLabels[index])
        }

        if !self.tabBarButtons.isEmpty {
            self.tabBarButtons[0]
                .setIcon(to: self.selectedItemIconConfigs[0])
        } else {
            assertionFailure("Tab bar is defined without any options")
        }

        if #available(iOS 18.0, *) {
            self.isTabBarHidden = true
        } else {
            self.tabBar.isHidden = true
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for viewController in self.viewControllers ?? [] {
            viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.tabBarContentHeight, right: 0)
        }
    }

    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        self.tabBarHeightConstraint?.constant = self.tabBarHeight

        for viewController in self.viewControllers ?? [] {
            viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.tabBarContentHeight, right: 0)
        }

        self.view.layoutIfNeededAnimated()
    }

    // MARK: Functions

    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.tabBarOptionSelected(index: self.selectedIndex)
    }

    private func tabBarOptionSelected(index: Int) {
        // Very occasionally if you switch fast enough you can skip an update if you only update the selected item icon
        // To avoid this we just refresh all of them
        for itemButtonIndex in self.tabBarButtons.indices {
            guard itemButtonIndex != index else {
                continue
            }
            self.tabBarButtons[itemButtonIndex]
                .setIcon(to: self.itemIconConfigs[itemButtonIndex])
        }
        // Pop the target tab's navigation stack to root if applicable
        if let nav = (self.viewControllers?[index] as? UINavigationController) {
            nav.popToRootViewController(animated: true)
        }
        self.selectedIndex = index
        self.tabBarButtons[index]
            .setIcon(to: self.selectedItemIconConfigs[index])
    }
}

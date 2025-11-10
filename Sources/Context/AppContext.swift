//
//  AppContext.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class AppContext {
    // MARK: Static Computed Properties

    public static var versionNumber: String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return "\(version)"
        }
        assertionFailure("Failed to get version number")
        return ""
    }

    public static var versionAndBuildNumber: String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
           let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return "\(version) (\(build))"
        }
        assertionFailure("Failed to get version number")
        return ""
    }

    public static var applicationState: UIApplication.State {
        UIApplication.shared.applicationState
    }

    // MARK: Lifecycle

    private init() {}
}

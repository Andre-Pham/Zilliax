//
//  EnvironmentContext.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import Foundation

public class EnvironmentContext {
    // MARK: Nested Types

    public enum Environment {
        /// The app is running locally using a debug or release scheme
        case local
        /// The app is running using a release scheme in TestFlight
        case testFlight
        /// The app is running as installed from the App Store
        case appStore
    }

    // MARK: Static Computed Properties

    public static var environment: Environment {
        #if DEBUG
            return .local
        #else
            guard !self.isSimulator else {
                return .local
            }
            if Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil {
                return .local
            }
            if let receiptURL = Bundle.main.appStoreReceiptURL {
                let isSandbox = receiptURL.lastPathComponent == "sandboxReceipt"
                return isSandbox ? .testFlight : .appStore
            }
            return .local
        #endif
    }

    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    public static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    public static var isUnitTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    // MARK: Lifecycle

    private init() {}
}

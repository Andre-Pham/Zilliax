//
//  DeviceContext.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class DeviceContext {
    // MARK: Static Computed Properties

    public static var deviceID: UUID? {
        guard let uuidString = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }

    public static var deviceType: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }

    public static var deviceIsMac: Bool {
        return ProcessInfo.processInfo.isiOSAppOnMac
    }

    public static var deviceOrientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }

    public static var deviceIsTiny: Bool {
        return WindowContext.windowHeight.isLessOrEqual(to: 667.0)
    }

    public static var deviceIsLarge: Bool {
        return Self.deviceType != .phone
    }

    // MARK: Lifecycle

    private init() {}
}

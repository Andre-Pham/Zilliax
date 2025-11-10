//
//  WindowContext.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

import UIKit

public class WindowContext {
    // MARK: Static Computed Properties

    /// The top safe area for the current window
    public static var topSafeAreaHeight: CGFloat {
        return Self.safeAreaInsets?.top ?? 0.0
    }

    /// The bottom safe area for the current window
    public static var bottomSafeAreaHeight: CGFloat {
        return Self.safeAreaInsets?.bottom ?? 0.0
    }

    /// The height of the full device screen (not window)
    public static var screenHeight: CGFloat {
        return Self.screen?.bounds.height ?? 0.0
    }

    /// The width of the full device screen (not window)
    public static var screenWidth: CGFloat {
        return Self.screen?.bounds.width ?? 0.0
    }

    /// The screen scale (1.0 / scale gives the size of 1 physical pixel)
    public static var screenScale: CGFloat {
        return Self.screen?.scale ?? 2.0
    }

    /// The window scene's screen instance
    public static var screen: UIScreen? {
        return Self.window?.windowScene?.screen
    }

    /// The height of the application window
    public static var windowHeight: CGFloat {
        guard let window = Self.window else {
            // If there's no window, fall back to screen height
            return Self.screenHeight
        }
        return window.frame.size.height
    }

    /// The width of the application window
    public static var windowWidth: CGFloat {
        guard let window = Self.window else {
            // If there's no window, fall back to screen width
            return Self.screenWidth
        }
        return window.frame.size.width
    }

    /// The orientation of the application window
    public static var windowOrientation: UIInterfaceOrientation {
        return Self.window?.windowScene?.effectiveGeometry.interfaceOrientation ?? .unknown
    }

    /// The aspect ratio (width/height) of the application window
    public static var windowAspectRatio: CGFloat {
        guard Self.window != nil else {
            // If there's no window, fall back to screen aspect ratio
            return Self.screenWidth / Self.screenHeight
        }
        return Self.windowWidth / Self.windowHeight
    }

    /// The application window
    public static var window: UIWindow? {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
    }

    /// The safe area insets of the current window
    private static var safeAreaInsets: UIEdgeInsets? {
        return Self.window?.safeAreaInsets
    }

    // MARK: Lifecycle

    private init() {}
}

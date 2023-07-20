//
//  AppDelegate.swift
//  FinalPhoto
//
//  Created by Alex Luna on 06/07/2023.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {

    static var orientationLock = UIInterfaceOrientationMask.all // By default you want all your views to rotate freely

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

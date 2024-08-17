//
//  Blink_Screen_TimeApp.swift
//  Blink Screen Time
//
//  Created by Pieter Yoshua Natanael on 28/07/24.
//

import SwiftUI

@main
struct BlinkScreenTimeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

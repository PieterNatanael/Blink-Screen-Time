//
//  AppDelegate.swift
//  Blink Screen Time
//
//  Created by Pieter Yoshua Natanael on 28/07/24.
//



import UIKit
import AVFoundation
import MediaPlayer


class AppDelegate: UIResponder, UIApplicationDelegate {
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category and activate it: \(error.localizedDescription)")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: audioSession)

        setupRemoteTransportControls()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        startBackgroundTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        endBackgroundTask()
    }

    func startBackgroundTask() {
        endBackgroundTask()
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MyAppBackgroundTask") {
            // Attempt to extend background task if expiration is imminent
            self.endBackgroundTask()
            self.startBackgroundTask()
        }
        
        if backgroundTask == .invalid {
            print("Failed to start background task")
        }
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    func setupNowPlaying() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Blink Screen Time"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Don't forget to blink :)"
        
        if let image = UIImage(named: "remoteControlImage") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            // Start playback
            self.startPlayback()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            // Pause playback
            self.stopPlayback()
            return .success
        }
    }

    func startPlayback() {
        // Your start playback logic here
        NotificationCenter.default.post(name: .startBlinkTimer, object: nil)
        setupNowPlaying()
    }

    func stopPlayback() {
        // Your stop playback logic here
        NotificationCenter.default.post(name: .stopBlinkTimer, object: nil)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            // Interruption began, take appropriate actions (e.g., pause playback)
        } else if type == .ended {
            // Interruption ended, reactivate audio session
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to reactivate audio session after interruption: \(error.localizedDescription)")
            }
        }
    }
}


/*
import UIKit
import AVFoundation
import MediaPlayer


class AppDelegate: UIResponder, UIApplicationDelegate {
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category and activate it: \(error.localizedDescription)")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: audioSession)

        setupRemoteTransportControls()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        startBackgroundTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        endBackgroundTask()
    }

    func startBackgroundTask() {
        endBackgroundTask()
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MyAppBackgroundTask") {
            // End the task if time expires.
            self.endBackgroundTask()
        }
        
        if backgroundTask == .invalid {
            print("Failed to start background task")
        }
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    func setupNowPlaying() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Blink Screen Time"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Don't forget to blink :)"
        
        if let image = UIImage(named: "remoteControlImage") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            // Start playback
            self.startPlayback()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            // Pause playback
            self.stopPlayback()
            return .success
        }
    }

    func startPlayback() {
        // Your start playback logic here
        NotificationCenter.default.post(name: .startBlinkTimer, object: nil)
        setupNowPlaying()
    }

    func stopPlayback() {
        // Your stop playback logic here
        NotificationCenter.default.post(name: .stopBlinkTimer, object: nil)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            // Interruption began, take appropriate actions (e.g., pause playback)
        } else if type == .ended {
            // Interruption ended, reactivate audio session
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to reactivate audio session after interruption: \(error.localizedDescription)")
            }
        }
    }
}

*/

/*
import UIKit
import AVFoundation
import MediaPlayer

class AppDelegate: UIResponder, UIApplicationDelegate {
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category and activate it: \(error.localizedDescription)")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: audioSession)

        setupRemoteTransportControls()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        startBackgroundTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        endBackgroundTask()
    }

    func startBackgroundTask() {
        endBackgroundTask()
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MyAppBackgroundTask") {
            // End the task if time expires.
            self.endBackgroundTask()
        }
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    func setupNowPlaying() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Blink Screen Time"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Don't forget to blink :)"
        
        if let image = UIImage(named: "remoteControlImage") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            // Start playback
            self.startPlayback()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            // Pause playback
            self.stopPlayback()
            return .success
        }
    }

    func startPlayback() {
        // Your start playback logic here
        NotificationCenter.default.post(name: .startBlinkTimer, object: nil)
        setupNowPlaying()
    }

    func stopPlayback() {
        // Your stop playback logic here
        NotificationCenter.default.post(name: .stopBlinkTimer, object: nil)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            // Interruption began, take appropriate actions (e.g., pause playback)
        } else if type == .ended {
            // Interruption ended, reactivate audio session
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to reactivate audio session after interruption: \(error.localizedDescription)")
            }
        }
    }
}

*/




/*
import UIKit
import AVFoundation
import MediaPlayer

class AppDelegate: UIResponder, UIApplicationDelegate {
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category and activate it: \(error.localizedDescription)")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: audioSession)

        setupRemoteTransportControls()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        startBackgroundTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        endBackgroundTask()
    }

    func startBackgroundTask() {
        endBackgroundTask()
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MyAppBackgroundTask") {
            // End the task if time expires.
            self.endBackgroundTask()
        }
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    func setupNowPlaying() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Blink Screen Time"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Don't forget to blink :)"
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            // Start playback
            self.startPlayback()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            // Pause playback
            self.stopPlayback()
            return .success
        }
    }

    func startPlayback() {
        // Your start playback logic here
        NotificationCenter.default.post(name: .startBlinkTimer, object: nil)
        setupNowPlaying()
    }

    func stopPlayback() {
        // Your stop playback logic here
        NotificationCenter.default.post(name: .stopBlinkTimer, object: nil)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            // Interruption began, take appropriate actions (e.g., pause playback)
        } else if type == .ended {
            // Interruption ended, reactivate audio session
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to reactivate audio session after interruption: \(error.localizedDescription)")
            }
        }
    }
}

*/


/*
//bagus tapi mau ada add control from lockscreen
import UIKit
import AVFoundation

class AppDelegate: UIResponder, UIApplicationDelegate {
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category and activate it: \(error.localizedDescription)")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: audioSession)

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        startBackgroundTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        endBackgroundTask()
    }

    func startBackgroundTask() {
        endBackgroundTask()
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MyAppBackgroundTask") {
            // End the task if time expires.
            self.endBackgroundTask()
        }
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            // Interruption began, take appropriate actions (e.g., pause playback)
        } else if type == .ended {
            // Interruption ended, reactivate audio session
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to reactivate audio session after interruption: \(error.localizedDescription)")
            }
        }
    }
}

*/

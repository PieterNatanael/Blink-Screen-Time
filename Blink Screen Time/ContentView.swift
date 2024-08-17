//
//  ContentView.swift
//  Blink Screen Time
//
//  Created by Pieter Yoshua Natanael on 28/07/24.
//


import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var blinkRate: Int = 15
    @State private var timer: Timer?
    @State private var blinkPlayer: AVAudioPlayer?
    @State private var rulePlayer: AVAudioPlayer?
    @State private var backgroundPlayer: AVAudioPlayer?
    @State private var isBlinking: Bool = false
    @State private var volume: Float = 1.0
    @State private var showExplain: Bool = false
    @State private var showVolumeSlider: Bool = false
    @State private var is20RuleEnabled: Bool = false // Track the state of the 20-20-20 rule toggle
    @State private var twentyRuleTimer: Timer?

    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("")
                        .frame(width: 30, height: 30)
                        .padding()
                    Spacer()
                    Text("Blink Screen Time")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                            .padding()
                    }
                }

                Spacer()

                Picker("Blink Rate", selection: $blinkRate) {
                    Text("15 times per minute").tag(15)
                    Text("20 times per minute").tag(20)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button(action: {
                    isBlinking.toggle()
                    if isBlinking {
                        startBlinking()
                    } else {
                        stopBlinking()
                    }
                }) {
                    Text(isBlinking ? "Stop" : "Start")
                        .font(.title.bold())
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(isBlinking ? Color.white : Color.black)
                        .background(isBlinking ? Color.red : Color.green)
                        .cornerRadius(25.0)
                }
                .padding()

                Button(action: {
                    playBackgroundSound()
                }) {
                    Text("Background Mode")
                        .font(.title3.bold())
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(Color.black)
                        .background(Color.gray)
                        .cornerRadius(25.0)
                }
                .padding()
                
                Button("Volume") {
                    showVolumeSlider.toggle()
                }
                .font(.title2.bold())
                .padding()
                .frame(width: 233)
                .background(Color.black)
                .cornerRadius(25)
                .foregroundColor(.white)
                .padding()

                Spacer()
            }
            .sheet(isPresented: $showExplain) {
                ShowExplainView(is20RuleEnabled: $is20RuleEnabled, onConfirm: {
                    showExplain = false
                })
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: .startBlinkTimer, object: nil, queue: .main) { _ in
                    startBlinking()
                }
                NotificationCenter.default.addObserver(forName: .stopBlinkTimer, object: nil, queue: .main) { _ in
                    stopBlinking()
                }
            }

            if showVolumeSlider {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Slider(value: $volume, in: 0...1, step: 0.1)
                            .padding()
                            .accentColor(.green)
                            .background(Color.primary)
                            .cornerRadius(25)
                            .padding()
                            .onChange(of: volume) { newValue in
                                volume = Float(newValue)
                                blinkPlayer?.volume = volume
                                rulePlayer?.volume = volume
                                backgroundPlayer?.volume = volume
                            }

                        Spacer()
                    }
                    .padding(.bottom)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
            }
        }
    }

    func startBlinking() {
        stopBlinking() // Stop any existing timer
        let interval = 60.0 / Double(blinkRate)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            playBlinkSound()
        }

        // Start the 20-20-20 rule if enabled
        if is20RuleEnabled {
            start20RuleTimer()
        }
    }

    func stopBlinking() {
        timer?.invalidate()
        timer = nil
        stop20RuleTimer()
    }

    func start20RuleTimer() {
        stop20RuleTimer() // Stop any existing 20-20-20 rule timer
        twentyRuleTimer = Timer.scheduledTimer(withTimeInterval: 1 * 60, repeats: true) { _ in
            play20RuleSound()
        }
    }

    func stop20RuleTimer() {
        twentyRuleTimer?.invalidate()
        twentyRuleTimer = nil
    }

    func playBlinkSound() {
        guard let url = Bundle.main.url(forResource: "blink_sound", withExtension: "mp3") else { return }
        do {
            blinkPlayer = try AVAudioPlayer(contentsOf: url)
            blinkPlayer?.volume = volume
            blinkPlayer?.play()
        } catch {
            print("Failed to play blink sound: \(error.localizedDescription)")
        }
    }

    func play20RuleSound() {
        guard let url = Bundle.main.url(forResource: "20rule", withExtension: "mp3") else { return }
        do {
            rulePlayer = try AVAudioPlayer(contentsOf: url)
            rulePlayer?.volume = volume
            rulePlayer?.play()
        } catch {
            print("Failed to play 20-20-20 rule sound: \(error.localizedDescription)")
        }
    }

    func playBackgroundSound() {
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else { return }
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.volume = volume
            backgroundPlayer?.play()
        } catch {
            print("Failed to play background sound: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let startBlinkTimer = Notification.Name("startBlinkTimer")
    static let stopBlinkTimer = Notification.Name("stopBlinkTimer")
}

// MARK: - Explain View
struct ShowExplainView: View {
    @Binding var is20RuleEnabled: Bool
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                Toggle("Bonus 20-20-20 Rule", isOn: $is20RuleEnabled)
                    .padding()
                    .font(.title2)

                // Add other explanations or content here

                Spacer()

                Button("Close") {
                    onConfirm()
                }
                .font(.title)
                .padding()
                .cornerRadius(25.0)
                .padding()
            }
            .padding()
            .cornerRadius(15.0)
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

/*
//rubah agar sound 20rule tidak ke cut sound click

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var blinkRate: Int = 15
    @State private var timer: Timer?
    @State private var player: AVAudioPlayer?
    @State private var backgroundPlayer: AVAudioPlayer?
    @State private var isBlinking: Bool = false
    @State private var volume: Float = 1.0
    @State private var showExplain: Bool = false
    @State private var showVolumeSlider: Bool = false
    @State private var is20RuleEnabled: Bool = false // Track the state of the 20-20-20 rule toggle
    @State private var twentyRuleTimer: Timer?

    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("")
                        .frame(width: 30, height: 30)
                        .padding()
                    Spacer()
                    Text("Blink Screen Time")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                            .padding()
                    }
                }

                Spacer()

                Picker("Blink Rate", selection: $blinkRate) {
                    Text("15 times per minute").tag(15)
                    Text("20 times per minute").tag(20)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button(action: {
                    isBlinking.toggle()
                    if isBlinking {
                        startBlinking()
                    } else {
                        stopBlinking()
                    }
                }) {
                    Text(isBlinking ? "Stop" : "Start")
                        .font(.title.bold())
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(isBlinking ? Color.white : Color.black)
                        .background(isBlinking ? Color.red : Color.green)
                        .cornerRadius(25.0)
                }
                .padding()

                Button(action: {
                    playBackgroundSound()
                }) {
                    Text("Background Mode")
                        .font(.title3.bold())
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(Color.black)
                        .background(Color.gray)
                        .cornerRadius(25.0)
                }
                .padding()
                
                Button("Volume") {
                    showVolumeSlider.toggle()
                }
                .font(.title2.bold())
                .padding()
                .frame(width: 233)
                .background(Color.black)
                .cornerRadius(25)
                .foregroundColor(.white)
                .padding()

                Spacer()
            }
            .sheet(isPresented: $showExplain) {
                ShowExplainView(is20RuleEnabled: $is20RuleEnabled, onConfirm: {
                    showExplain = false
                })
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: .startBlinkTimer, object: nil, queue: .main) { _ in
                    startBlinking()
                }
                NotificationCenter.default.addObserver(forName: .stopBlinkTimer, object: nil, queue: .main) { _ in
                    stopBlinking()
                }
            }

            if showVolumeSlider {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Slider(value: $volume, in: 0...1, step: 0.1)
                            .padding()
                            .accentColor(.green)
                            .background(Color.primary)
                            .cornerRadius(25)
                            .padding()
                            .onChange(of: volume) { newValue in
                                volume = Float(newValue)
                                player?.volume = volume
                                backgroundPlayer?.volume = volume
                            }

                        Spacer()
                    }
                    .padding(.bottom)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
            }
        }
    }

    func startBlinking() {
        stopBlinking() // Stop any existing timer
        let interval = 60.0 / Double(blinkRate)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            playBlinkSound()
        }

        // Start the 20-20-20 rule if enabled
        if is20RuleEnabled {
            start20RuleTimer()
        }
    }

    func stopBlinking() {
        timer?.invalidate()
        timer = nil
        stop20RuleTimer()
    }

    func start20RuleTimer() {
        stop20RuleTimer() // Stop any existing 20-20-20 rule timer
        twentyRuleTimer = Timer.scheduledTimer(withTimeInterval: 1 * 60, repeats: true) { _ in
            play20RuleSound()
        }
    }

    func stop20RuleTimer() {
        twentyRuleTimer?.invalidate()
        twentyRuleTimer = nil
    }

    func playBlinkSound() {
        guard let url = Bundle.main.url(forResource: "blink_sound", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = volume
            player?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }

    func play20RuleSound() {
        guard let url = Bundle.main.url(forResource: "20rule", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = volume
            player?.play()
        } catch {
            print("Failed to play 20-20-20 rule sound: \(error.localizedDescription)")
        }
    }

    func playBackgroundSound() {
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else { return }
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.volume = volume
            backgroundPlayer?.play()
        } catch {
            print("Failed to play background sound: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let startBlinkTimer = Notification.Name("startBlinkTimer")
    static let stopBlinkTimer = Notification.Name("stopBlinkTimer")
}

// MARK: - Explain View
struct ShowExplainView: View {
    @Binding var is20RuleEnabled: Bool
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                Toggle("Bonus 20-20-20 Rule", isOn: $is20RuleEnabled)
                    .padding()
                    .font(.title2)

                // Add other explanations or content here

                Spacer()

                Button("Close") {
                    onConfirm()
                }
                .font(.title)
                .padding()
                .cornerRadius(25.0)
                .padding()
            }
            .padding()
            .cornerRadius(15.0)
            .padding()
        }
    }
}
#Preview {
    ContentView()
}

*/
/*

//good but want add improvement
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var blinkRate: Int = 15
    @State private var timer: Timer?
    @State private var player: AVAudioPlayer?
    @State private var backgroundPlayer: AVAudioPlayer?
    @State private var isBlinking: Bool = false
    @State private var volume: Float = 1.0
    @State private var showExplain: Bool = false
    @State private var showVolumeSlider: Bool = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("")
                        .frame(width: 30, height: 30)
                        .padding()
                    Spacer()
                    Text("Blink Screen Time")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                            .padding()
                    }
                }

                Spacer()

                Picker("Blink Rate", selection: $blinkRate) {
                    Text("15 times per minute").tag(15)
                    Text("20 times per minute").tag(20)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button(action: {
                    isBlinking.toggle()
                    if isBlinking {
                        startBlinking()
                    } else {
                        stopBlinking()
                    }
                }) {
                    Text(isBlinking ? "Stop" : "Start")
                        .font(.title.bold())
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(isBlinking ? Color.white : Color.black)
                        .background(isBlinking ? Color.red : Color.green)
                        .cornerRadius(25.0)
                }
                .padding()

                Button(action: {
                    playBackgroundSound()
                }) {
                    Text("Background Mode")
                        .font(.title3.bold())
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(Color.black)
                        .background(Color.gray)
                        .cornerRadius(25.0)
                }
                .padding()
                
                Button("Volume") {
                    showVolumeSlider.toggle()
                }
                .font(.title2.bold())
                .padding()
                .frame(width: 233)
                .background(Color.black)
                .cornerRadius(25)
                .foregroundColor(.white)
                .padding()

//                Slider(value: Binding(
//                    get: { Double(volume) },
//                    set: { newValue in
//                        volume = Float(newValue)
//                        player?.volume = volume
//                        backgroundPlayer?.volume = volume
//                    }
//                ), in: 0...1)
//                .padding()
//                .background(Color.primary)
//                .accentColor(.green)

                Spacer()
            }
            
            
            
            .sheet(isPresented: $showExplain) {
                ShowExplainView(onConfirm: {
                    showExplain = false
                })
            }
            
           
            
            
            .onAppear {
                NotificationCenter.default.addObserver(forName: .startBlinkTimer, object: nil, queue: .main) { _ in
                    startBlinking()
                }
                NotificationCenter.default.addObserver(forName: .stopBlinkTimer, object: nil, queue: .main) { _ in
                    stopBlinking()
                }
            }
            
            if showVolumeSlider {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Slider(value: $volume, in: 0...1, step: 0.1)
                            .padding()
                            .accentColor(.green)
                            .background(Color.primary)
                            .cornerRadius(25)
                            .padding()
                            .onChange(of: volume) { newValue in
                                volume = Float(newValue)
                                player?.volume = volume
                                backgroundPlayer?.volume = volume
                            }

                        Spacer()
                    }
                    .padding(.bottom)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
            }

        }
    }

    func startBlinking() {
        stopBlinking() // Stop any existing timer
        let interval = 60.0 / Double(blinkRate)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            playBlinkSound()
        }
    }

    func stopBlinking() {
        timer?.invalidate()
        timer = nil
    }

    func playBlinkSound() {
        guard let url = Bundle.main.url(forResource: "blink_sound", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = volume
            player?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }

    func playBackgroundSound() {
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else { return }
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.volume = volume
            backgroundPlayer?.play()
        } catch {
            print("Failed to play background sound: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let startBlinkTimer = Notification.Name("startBlinkTimer")
    static let stopBlinkTimer = Notification.Name("stopBlinkTimer")
}

#Preview {
    ContentView()
}


// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("")
                       .font(.title2.bold())
                   Spacer()
               }
                Spacer()
                
                HStack{
                    Text("")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                
                ZStack {
//                    Image("threedollar")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .cornerRadius(25)
//                        .clipped()
//                        .onTapGesture {
//                            if let url = URL(string: "https://b33.biz/three-dollar/") {
//                                UIApplication.shared.open(url)
//                            }
//                        }
                }
                
                // App Cards
                VStack {
                    
//                    Divider().background(Color.gray)
//                    AppCardView(imageName: "sos", appName: "SOS Light", appDescription: "SOS Light is designed to maximize the chances of getting help in emergency situations.", appURL: "https://apps.apple.com/app/s0s-light/id6504213303")
//                    Divider().background(Color.gray)
//
//
//                    Divider().background(Color.gray)
//                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
//                    Divider().background(Color.gray)
//                    // Add more AppCardViews here if needed
//                    // App Data
//
//
//                    AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
//
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "worry", appName: "Worry Bin", appDescription: "A place for worry.", appURL: "https://apps.apple.com/id/app/worry-bin/id6498626727")
//                    Divider().background(Color.gray)
                
                }
                Spacer()
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               • Adjust Blink Rate: Choose between 15 blinks per minute or 20 blinks per minute before pressing the start button.
                • Start/Stop Blinking: Press the button to start or stop the blink reminder function.
                • Volume Control: Adjust the volume of the reminder sound using the slider.
                • Start Background Mode: Press the "Start" button as usual, then tap the "Background Mode" button to enable the app to run the blink reminder in the background. Once activated, you can leave the app, and the reminder will continue to function.
               
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                HStack {
                    Text("Blink Screen Time is developed by Three Dollar.")
                        .font(.title3.bold())
                        .onTapGesture {
                            if let url = URL(string: "https://b33.biz/three-dollar/") {
                                UIApplication.shared.open(url)
                            }}
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}

*/

/*
//add volume slider
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var blinkRate: Int = 15
    @State private var timer: Timer?
    @State private var player: AVAudioPlayer?
    @State private var backgroundPlayer: AVAudioPlayer?
    @State private var isBlinking: Bool = false
    @State private var volume: Float = 1.0
    @State private var showExplain: Bool = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("")
                        .frame(width: 30, height: 30)
                        .padding()
                    Spacer()
                    Text("Blink Screen Time")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                            .padding()
                    }
                }

                Spacer()

                Picker("Blink Rate", selection: $blinkRate) {
                    Text("15 times per minute").tag(15)
                    Text("20 times per minute").tag(20)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button(action: {
                    isBlinking.toggle()
                    if isBlinking {
                        startBlinking()
                    } else {
                        stopBlinking()
                    }
                }) {
                    Text(isBlinking ? "Stop" : "Start")
                        .font(.title.bold())
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(isBlinking ? Color.white : Color.black)
                        .background(isBlinking ? Color.red : Color.green)
                        .cornerRadius(25.0)
                }
                .padding()

                Button(action: {
                    playBackgroundSound()
                }) {
                    Text("Background Mode")
                        .font(.title3.bold())
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .cornerRadius(25.0)
                }
                .padding()

                Slider(value: Binding(
                    get: { Double(volume) },
                    set: { newValue in
                        volume = Float(newValue)
                        player?.volume = volume
                        backgroundPlayer?.volume = volume
                    }
                ), in: 0...1)
                .padding()
                .background(Color.primary)
                .accentColor(.green)

                Spacer()
            }
            .sheet(isPresented: $showExplain) {
                ShowExplainView(onConfirm: {
                    showExplain = false
                })
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: .startBlinkTimer, object: nil, queue: .main) { _ in
                    startBlinking()
                }
                NotificationCenter.default.addObserver(forName: .stopBlinkTimer, object: nil, queue: .main) { _ in
                    stopBlinking()
                }
            }
        }
    }

    func startBlinking() {
        stopBlinking() // Stop any existing timer
        let interval = 60.0 / Double(blinkRate)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            playBlinkSound()
        }
    }

    func stopBlinking() {
        timer?.invalidate()
        timer = nil
    }

    func playBlinkSound() {
        guard let url = Bundle.main.url(forResource: "blink_sound", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = volume
            player?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }

    func playBackgroundSound() {
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else { return }
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.volume = volume
            backgroundPlayer?.play()
        } catch {
            print("Failed to play background sound: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let startBlinkTimer = Notification.Name("startBlinkTimer")
    static let stopBlinkTimer = Notification.Name("stopBlinkTimer")
}

#Preview {
    ContentView()
}


// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("")
                       .font(.title2.bold())
                   Spacer()
               }
                Spacer()
                
                HStack{
                    Text("")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                
                ZStack {
//                    Image("threedollar")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .cornerRadius(25)
//                        .clipped()
//                        .onTapGesture {
//                            if let url = URL(string: "https://b33.biz/three-dollar/") {
//                                UIApplication.shared.open(url)
//                            }
//                        }
                }
                
                // App Cards
                VStack {
                    
//                    Divider().background(Color.gray)
//                    AppCardView(imageName: "sos", appName: "SOS Light", appDescription: "SOS Light is designed to maximize the chances of getting help in emergency situations.", appURL: "https://apps.apple.com/app/s0s-light/id6504213303")
//                    Divider().background(Color.gray)
//
//
//                    Divider().background(Color.gray)
//                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
//                    Divider().background(Color.gray)
//                    // Add more AppCardViews here if needed
//                    // App Data
//
//
//                    AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
//
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "worry", appName: "Worry Bin", appDescription: "A place for worry.", appURL: "https://apps.apple.com/id/app/worry-bin/id6498626727")
//                    Divider().background(Color.gray)
                
                }
                Spacer()
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               • Adjust Blink Rate: Choose between 15 blinks per minute or 20 blinks per minute before pressing the start button.
                • Start/Stop Blinking: Press the button to start or stop the blink reminder function.
                • Volume Control: Adjust the volume of the reminder sound using the slider.
                • Start Background Mode: Press the "Start" button as usual, then tap the "Background Mode" button to enable the app to run the blink reminder in the background. Once activated, you can leave the app, and the reminder will continue to function.
               
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                HStack {
                    Text("Blink Screen Time is developed by Three Dollar.")
                        .font(.title3.bold())
                        .onTapGesture {
                            if let url = URL(string: "https://b33.biz/three-dollar/") {
                                UIApplication.shared.open(url)
                            }}
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}


*/


/*

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var blinkRate: Int = 15
    @State private var timer: Timer?
    @State private var player: AVAudioPlayer?
    @State private var isBlinking: Bool = false
    @State private var volume: Float = 1.0
    @State private var showExplain: Bool = false
 

    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            

            VStack {
                HStack {
                    Text("")
                        .frame(width: 30, height: 30)
                        .padding()
                    Spacer()
                    Text("Blink Screen Time")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        showExplain = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                
                Spacer()

                
                
                Picker("Blink Rate", selection: $blinkRate) {
                    Text("15 times per minute").tag(15)
                    Text("20 times per minute").tag(20)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button(action: {
                    isBlinking.toggle()
                    if isBlinking {
                        startBlinking()
                    } else {
                        stopBlinking()
                    }
                }) {
                    Text(isBlinking ? "Stop" : "Start")
                        .font(.title.bold())
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(isBlinking ?
                            Color.white :
                            Color.black)
                        .background(isBlinking ? Color.red : Color.green)
                        .cornerRadius(25.0)
                }
                .padding()
                Slider(value: Binding(
                    get: { Double(volume) },
                    set: { newValue in
                        volume = Float(newValue)
                        player?.volume = volume
                    }
                ), in: 0...1)
                .padding()
                .background(Color.primary)
                .accentColor(.green)
                
                Spacer()
            }
            .sheet(isPresented: $showExplain) {
                ShowExplainView(onConfirm: {
                    showExplain = false
                })
            }
            
            .onAppear {
                NotificationCenter.default.addObserver(forName: .startBlinkTimer, object: nil, queue: .main) { _ in
                    startBlinking()
                }
                NotificationCenter.default.addObserver(forName: .stopBlinkTimer, object: nil, queue: .main) { _ in
                    stopBlinking()
                }
            }
        }
    }

    func startBlinking() {
        stopBlinking() // Stop any existing timer
        let interval = 60.0 / Double(blinkRate)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            playSound()
        }
    }

    func stopBlinking() {
        timer?.invalidate()
        timer = nil
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "blink_sound", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = volume
            player?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let startBlinkTimer = Notification.Name("startBlinkTimer")
    static let stopBlinkTimer = Notification.Name("stopBlinkTimer")
}

#Preview {
    ContentView()
}



// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("")
                       .font(.title2.bold())
                   Spacer()
               }
                Spacer()
                
                HStack{
                    Text("")
                        .font(.largeTitle.bold())
                    Spacer()
                }
                
                ZStack {
//                    Image("threedollar")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .cornerRadius(25)
//                        .clipped()
//                        .onTapGesture {
//                            if let url = URL(string: "https://b33.biz/three-dollar/") {
//                                UIApplication.shared.open(url)
//                            }
//                        }
                }
                
                // App Cards
                VStack {
                    
//                    Divider().background(Color.gray)
//                    AppCardView(imageName: "sos", appName: "SOS Light", appDescription: "SOS Light is designed to maximize the chances of getting help in emergency situations.", appURL: "https://apps.apple.com/app/s0s-light/id6504213303")
//                    Divider().background(Color.gray)
//
//
//                    Divider().background(Color.gray)
//                    AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
//                    Divider().background(Color.gray)
//                    // Add more AppCardViews here if needed
//                    // App Data
//
//
//                    AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
//
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
//                    Divider().background(Color.gray)
//
//                    AppCardView(imageName: "worry", appName: "Worry Bin", appDescription: "A place for worry.", appURL: "https://apps.apple.com/id/app/worry-bin/id6498626727")
//                    Divider().background(Color.gray)
                
                }
                Spacer()
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               • Adjust Blink Rate: Choose between 15 blinks per minute or 20 blinks per minute before pressing the start button.
                • Start/Stop Blinking: Press the button to start or stop the blink reminder function.
                • Volume Control: Adjust the volume of the reminder sound using the slider.
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                HStack {
                    Text("Blink Screen Time is developed by Three Dollar.")
                        .font(.title3.bold())
                        .onTapGesture {
                            if let url = URL(string: "https://b33.biz/three-dollar/") {
                                UIApplication.shared.open(url)
                            }}
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}


*/


/*

//udah bagus mau tambah showexplain
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var blinkRate: Int = 15
    @State private var timer: Timer?
    @State private var player: AVAudioPlayer?
    @State private var isBlinking: Bool = false
    @State private var volume: Float = 1.0
 

    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                Picker("Blink Rate", selection: $blinkRate) {
                    Text("15 times per minute").tag(15)
                    Text("20 times per minute").tag(20)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button(action: {
                    isBlinking.toggle()
                    if isBlinking {
                        startBlinking()
                    } else {
                        stopBlinking()
                    }
                }) {
                    Text(isBlinking ? "Stop" : "Start")
                        .font(.title)
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(isBlinking ?
                            Color.black :
                            Color.white)
                        .background(isBlinking ? Color.red : Color.green)
                        .cornerRadius(25.0)
                }
                .padding()
                Slider(value: Binding(
                    get: { Double(volume) },
                    set: { newValue in
                        volume = Float(newValue)
                        player?.volume = volume
                    }
                ), in: 0...1)
                .padding()
                .background(Color.primary)
                .accentColor(.green)
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: .startBlinkTimer, object: nil, queue: .main) { _ in
                    startBlinking()
                }
                NotificationCenter.default.addObserver(forName: .stopBlinkTimer, object: nil, queue: .main) { _ in
                    stopBlinking()
                }
            }
        }
    }

    func startBlinking() {
        stopBlinking() // Stop any existing timer
        let interval = 60.0 / Double(blinkRate)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            playSound()
        }
    }

    func stopBlinking() {
        timer?.invalidate()
        timer = nil
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "blink_sound", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = volume
            player?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let startBlinkTimer = Notification.Name("startBlinkTimer")
    static let stopBlinkTimer = Notification.Name("stopBlinkTimer")
}

#Preview {
    ContentView()
}

*/


/*
//bagus mau ada tperubahan startstop dan add voume

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var blinkRate: Int = 15
    @State private var timer: Timer?
    @State private var player: AVAudioPlayer?

    var body: some View {
        ZStack {
            
            //BG
            LinearGradient(colors: [Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
//                Text("Blink Screen Time")
//                    .font(.title)
//                    .padding()

                Picker("Blink Rate", selection: $blinkRate) {
                    Text("15 times per minute").tag(15)
                    Text("20 times per minute").tag(20)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button(action: {
                    startBlinking()
                }) {
                    Text("Start")
                        .font(.title)
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .cornerRadius(25.0)
                }

                Button(action: {
                    stopBlinking()
                }) {
                    Text("Stop")
                        .font(.title)
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(Color.black)
                        .background(Color.green)
                        .cornerRadius(25.0)
                
                }
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: .startBlinkTimer, object: nil, queue: .main) { _ in
                    startBlinking()
                }
                NotificationCenter.default.addObserver(forName: .stopBlinkTimer, object: nil, queue: .main) { _ in
                    stopBlinking()
                }
        }
        }
    }

    func startBlinking() {
        stopBlinking() // Stop any existing timer
        let interval = 60.0 / Double(blinkRate)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            playSound()
        }
    }

    func stopBlinking() {
        timer?.invalidate()
        timer = nil
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "blink_sound", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}

extension Notification.Name {
    static let startBlinkTimer = Notification.Name("startBlinkTimer")
    static let stopBlinkTimer = Notification.Name("stopBlinkTimer")
}
#Preview {
    ContentView()
}
*/




/*
//bagus tapi mau add add sesuatu di screenlock

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var blinkRate: Int = 15
    @State private var isBlinking: Bool = false
    @State private var timer: Timer?
    @State private var player: AVAudioPlayer?

    var body: some View {
        ZStack {
            
            //BG
            LinearGradient(colors: [Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                Picker("Blink Rate", selection: $blinkRate) {
                    Text("15 times per minute").tag(15)
                    Text("20 times per minute").tag(20)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Button(action: startBlinking) {
                    Text("Start")
                        .font(.title)
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .cornerRadius(25.0)
                }
                .padding()

                Button(action: stopBlinking) {
                    Text("Stop")
                        .font(.title)
                        .padding()
                        .frame(width: 233)
                        .foregroundColor(Color.black)
                        .background(Color.green)
                        .cornerRadius(25.0)
                }
                .padding()
            }
        }
    }

    private func startBlinking() {
        stopBlinking()  // Ensure any existing timer is stopped
        isBlinking = true
        let interval = 60.0 / Double(blinkRate)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            playSound()
        }
    }

    private func stopBlinking() {
        isBlinking = false
        timer?.invalidate()
        timer = nil
    }

    private func playSound() {
        guard let url = Bundle.main.url(forResource: "blink_sound", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}


*/

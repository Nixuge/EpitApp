//
//  SetAlarmView.swift
//  EpitApp
//
//  Created by Quenting on 24/09/2025.
//

import SwiftUI

// Todo?: show a notification here instead of in the shortcut (or none at all?)

struct SetAlarmView: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var isPresented: Bool
    var dayStartsAt: Int
    
    var currentAlarmTime: String {
        let time = dayStartsAt - 60*hours - minutes
        
        let h = (time / 60)
        let hStr = (h < 10) ? "0\(h)" : "\(h)"
        
        let m = time % 60
        let mStr = (m < 10) ? "0\(m)" : "\(m)"
        return "\(hStr):\(mStr)"
    }
    
    @State private var showInstallShortcutView = false
    @State private var showSuccessView = false
    
    @ObservedObject var alarmSetter = AlarmSetter.shared
    
    @State var hours: Int = ZeusSettings.shared.alarmHoursBeforeClass
    @State var minutes: Int =  ZeusSettings.shared.alarmMinutesBeforeClass
        
    var body: some View {
        VStack {
            HStack {
                Label("Info", systemImage: "info.circle")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.orange)
                Button("Setup instructions") {
                    showInstallShortcutView = true
                }
            }
            .padding(.top, 30)
            
            Spacer()
            
            Text("Set an alarm for class")
                .font(.largeTitle)
                .padding(.bottom, 30)
                .foregroundStyle(.orange)
            
            HStack {
                VStack(spacing: 0) {
                    Text(hours <= 1 ? "hour" : "hours")
                    Picker("", selection: $hours){
                        ForEach(0..<4, id: \.self) { i in
                            Text("\(i)").tag(i)
                        }
                    }.pickerStyle(WheelPickerStyle())
                }
                Text("   ")
                VStack(spacing: 0) {
                    Text(minutes <= 1 ? "minute" : "minutes")
                    Picker("", selection: $minutes){
                        ForEach(0..<60, id: \.self) { i in
                            Text("\(i)").tag(i)
                        }
                    }.pickerStyle(WheelPickerStyle())
                }
            }
            Text("Before school starts")
            
            Spacer()
            
            Button("Set alarm at \(currentAlarmTime)") {
                AlarmSetter.shared.clearAlarmSet()
                UIApplication.shared.open(URL(string: "shortcuts://run-shortcut?name=EpitApp%20Alarm%20Setter%201.0&input=text&text=\(currentAlarmTime)")!)
            }
            .font(.title)
            .foregroundStyle(.white)
            .padding()
            .background(
                RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                    .foregroundStyle(.green)
            )
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showInstallShortcutView, content: {
            InstallShortcutView(isPresented: $showInstallShortcutView)
            .background(
                ZStack {
                    // Note: unsure if looks best #000 black or not
                    // Background color
                    if (colorScheme == .dark) {
                        Color.black.edgesIgnoringSafeArea(.all)
                    }
                    // Border (offset down otherwise not looking good)
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white.opacity(0.15), lineWidth: 2)
                            .frame(height: geometry.size.height + 100)
                    }
                }
            )
        })
        .sheet(isPresented: $showSuccessView, content: {
            AlarmSuccessView(alarmTime: currentAlarmTime, isPresented: $showSuccessView, isParentPresented: $isPresented)
                .background(
                    ZStack {
                        // Note: unsure if looks best #000 black or not
                        // Background color
                        if (colorScheme == .dark) {
                            Color.black.edgesIgnoringSafeArea(.all)
                        }
                        // Border (offset down otherwise not looking good)
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white.opacity(0.15), lineWidth: 2)
                                .frame(height: geometry.size.height + 100)
                        }
                    }
                )
        })
        .onChange(of: showSuccessView) { newValue in // Auto close this view when the success view gets closed
            if (!newValue) {
                isPresented = false
            }
        }
        .onChange(of: alarmSetter.receivedAlarmSet) { alarm in // "Receive" updates from the alarmSetter
            info("New alarm set: \(String(describing: alarm))")
            guard let alarm = alarm else { return }
            
            if (alarm.time == currentAlarmTime) {
                showSuccessView = true
            } else {
                warn("Wrong alarm time received: \(alarm.time), expected: \(currentAlarmTime)")
            }
        }
        .onChange(of: hours) { newHours in // Update saved val every time we update it
//            info("Set hour set: \(newHours)")
            ZeusSettings.shared.alarmHoursBeforeClass = newHours
        }
        .onChange(of: minutes) { newMinutes in // same
//            info("Set minute set: \(newMinutes)")
            ZeusSettings.shared.alarmMinutesBeforeClass = newMinutes
        }
    }
}

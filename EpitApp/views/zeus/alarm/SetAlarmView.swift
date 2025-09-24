//
//  SetAlarmView.swift
//  EpitApp
//
//  Created by Quenting on 24/09/2025.
//

import SwiftUI

// TODO: Instead of closing on success, make a success page (& an error page)

struct SetAlarmView: View {
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
                UIApplication.shared.open(URL(string: "shortcuts://run-shortcut?name=EpitApp%20Alarm%20Setter&input=text&text=\(currentAlarmTime)")!)
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
        })
        .onChange(of: alarmSetter.receivedAlarmSet) { alarm in
            info("New alarm set: \(String(describing: alarm))")
            guard let alarm = alarm else { return }
            
            if (alarm.time == currentAlarmTime) {
                isPresented = false
            } else {
                warn("Wrong alarm time received: \(alarm.time), expected: \(currentAlarmTime)")
            }
        }
        .onChange(of: hours) { newHours in
//            info("Set hour set: \(newHours)")
            ZeusSettings.shared.alarmHoursBeforeClass = newHours
        }
        .onChange(of: minutes) { newMinutes in
//            info("Set minute set: \(newMinutes)")
            ZeusSettings.shared.alarmMinutesBeforeClass = newMinutes
        }
    }
}

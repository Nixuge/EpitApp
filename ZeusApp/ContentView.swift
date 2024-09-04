//
//  ContentView.swift
//  ZeusApp
//
//  Created by Quenting on 03/09/2024.
//

import SwiftUI

struct AgendaView: View {
    @Binding var data: [Course]
    @Binding var index: Int
    @State var forwards: Bool = true

    @ViewBuilder
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.orange)
            if data.isEmpty {
                Text("No data?")
            } else {
                Text(data[index].name)
            }
        }
        
        Button(forwards ? "Next" : "Previous") {
            print(data.count)
            print(index)
            if (forwards) {
                index += 1
                if index >= data.count-1 {
                    forwards = false
                }
            } else {
                index -= 1
                if (index == 0) {
                    forwards = true
                }
            }
            //index = forwards ? index+1 : index-1
        }
        
        .padding()
    }
}

struct LoadingView: View {
    @Binding var courses: [Course]
    @Binding var auth: String
    
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
            .onAppear {
                // Artifical delay to make sure this works.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Task {
                        courses = try await performRequest(auth: auth)
                    }
                }
            }
    }
}

struct LoginView: View {
    @Binding var auth: String?
    
    @State var inputText: String = ""
    
    var body: some View {
        TextField("Enter your Auth token here", text: $inputText)
            .border(.orange, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            .padding(10)
        
        Button("Submit") {
            auth = inputText
            UserDefaults.standard.set(auth, forKey: "Auth")
        }
    }
}

struct ContentView: View {
    let defaults = UserDefaults.standard
    @State var auth: String?
    @State var courseIndex: Int = 0
    @State var courses: [Course] = []
    
    var body: some View {
        if let unwrappedAuth = auth {
            if courses.isEmpty {
                LoadingView(courses: $courses, auth: .constant(unwrappedAuth))
            } else {
                AgendaView(data: $courses, index: $courseIndex)
            }
        } else {
            LoginView(auth: $auth)
        }
    }
    
    init() {
        _auth = State(wrappedValue: UserDefaults.standard.string(forKey: "Auth"))
    }
}

#Preview {
    ContentView()
}

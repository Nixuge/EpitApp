import SwiftUI

func minutesToTime(minutes: Int) -> String {
    let hours = minutes/60 < 10 ? "0\(minutes/60)" : "\(minutes/60)"
    let minutesFormatted = minutes%60 < 10 ? "0\(minutes%60)" : "\(minutes%60)"
    return "\(hours):\(minutesFormatted)"
}

struct CourseRange : Identifiable {
    let id = UUID()
    let start: Int
    let end: Int
    let courses: [Course]
    
    init(startTime: Int, endTime: Int, courses: [Course]? = nil) {
        self.start = startTime
        self.end = endTime
        if (courses == nil) {
            self.courses = []
        } else {
            self.courses = courses!
        }
    }
}

struct LoadedCalendarView: View {
    @Environment(\.colorScheme) var colorScheme

    
    private var currentDayStartsAt: Int {
        guard let courses = courseCache.courses[selectedDate.FNT] else {
            return 0
        }
        if (courses.1.isEmpty) {
            return 0
        }
        
        // Note: unsure as to if I should really go through the whole array or just stop when I find a non empty course, but meh might as well
        var start = 999999
        for course in courses.1 {
            if (course.courses.isEmpty) {
                continue
            }
            if (course.start < start) {
                start = course.start
            }
        }
        
        return start
    }
    
    private var shouldShowAlarmSetter: Bool {
        if (currentDayStartsAt == 0) {
            return false
        }
        let minutesSinceMidnight = Calendar.current.dateComponents([.hour, .minute], from: Date()).hour! * 60 + Calendar.current.dateComponents([.minute], from: Date()).minute!
        
        if Calendar.current.isDateInTomorrow(selectedDate) {
            return true
        }
        
        return (Calendar.current.isDateInToday(selectedDate) && currentDayStartsAt > minutesSinceMidnight)
    }

    @ObservedObject var zeusAuthModel = ZeusAuthModel.shared
    @ObservedObject var courseCache = CourseCache.shared
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var displayedDates: [Date] = []
    
    @State private var showClassPicker = false
    @State private var showAlarmSetter = false

    private let preloadedTabAmount = 14

    //todo:
    // if is multi, do not round and no padding
    // if next is multi, do not round bottom, if previous is multi, do not round top (see if multi includes it tho)
    

    var body: some View {
        ZStack {
            VStack {
                LoadedCalendarHeader(selectedDate: $selectedDate, showDatePicker: $showDatePicker)
                    .padding()
                    .task(id: selectedDate) {
                        await courseCache.loadCourses(date: selectedDate)
                    }
                
                TabView(selection: $selectedDate) {
                    ForEach(displayedDates, id: \.self) { date in
                        content(for: date).tag(date)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: selectedDate) { newDate in
                    // First two checks: check if currently at a border (when just swiping)
                    // Second two checks: check if jumped (eg using calendar)
                    // This is made because refreshing the displayedDates makes the screen flicker a bit.
                    // TODO: Make it refresh on sundays where theres a lot less classes.
                    if (displayedDates.last!.FNT == selectedDate.FNT || displayedDates.first!.FNT == selectedDate.FNT ||
                        displayedDates.first! > selectedDate || displayedDates.last! < selectedDate) {
                        log("Refreshing tabview.")
                        log("Old bounds: \(displayedDates.first!.FNT) -> \(displayedDates.last!.FNT)")
                        updateDisplayedDates(for: selectedDate)
                        log("New bounds: \(displayedDates.first!.FNT) -> \(displayedDates.last!.FNT)")
                    }
                }
                .onAppear() {
                    updateDisplayedDates(for: selectedDate, delayMS: 0)
                }
                //            Text("Valid token found and checked (len of \(zeusAuthModel.token!.count)). Token start: '\(zeusAuthModel.token!.prefix(30))'.")
            }.refreshable {
              await refresh()
            }
            
            
            FancySheetButton(
                label: { Label("Picker", systemImage: "tag.fill").labelStyle(.iconOnly) },
                color: .gray.opacity(0.15),
                textColor: colorScheme == .dark ? .white : .gray,
                isPresented: $showClassPicker,
                action: {
                    showClassPicker = true
                },
                sheetContent: {
                    ChooseIdView(isPresented: $showClassPicker)
                        .ignoresSafeArea(.all)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(5)
            
            if (shouldShowAlarmSetter) {
                FancySheetButton(
                    label: { Label("Alarm", systemImage: "alarm.fill").labelStyle(.iconOnly) },
                    color: .gray.opacity(0.15),
                    textColor: colorScheme == .dark ? .white : .gray,
                    isPresented: $showAlarmSetter,
                    action: {
                        showAlarmSetter = true
                    },
                    sheetContent: {
                        SetAlarmView(isPresented: $showAlarmSetter, dayStartsAt: currentDayStartsAt)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.bottom, 5)
                .padding(.trailing, 70)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: shouldShowAlarmSetter)
    }

    private func refresh() async {
        courseCache.clearAllCourses()
        CourseDetailsCache.shared.clearAll()
//        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await courseCache.loadCourses(date: selectedDate)
    }
    

    @ViewBuilder
    private func content(for date: Date) -> some View {
        VStack {
            if courseCache.courses[date.FNT] == nil {
                VStack {
                    Spacer()
                    Text("Loading content for " + date.formatted(.dateTime.year().month().day()))
                    ProgressView()
                    Spacer()
                }
            } else {
                if courseCache.courses[date.FNT]!.1.isEmpty {
                    VStack {
                        Spacer()
                        Text("No courses this day.")
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(courseCache.courses[date.FNT]!.1) { range in
                                let isCurrentDay = date.FNT == Date().FNT
                                
                                if range.courses.count == 0 {
                                    LoadedCalendarSeparator(isCurrentDay: isCurrentDay, range: range)
                                } else {
                                    LoadedCalendarCourse(isCurrentDay: isCurrentDay, range: range)
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .animation(.easeInOut, value: courseCache.courses.keys.contains(date.FNT))
    }
    
    // Note: The delay helps avoid the weird rolback thing when going too fast. Still not perfect tho.
    private func updateDisplayedDates(for date: Date, delayMS: Float = 120) {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(Int(delayMS)))) {
            let calendar = Calendar.current
            guard let startDate = calendar.date(byAdding: .day, value: -preloadedTabAmount / 2, to: date) else {
                return
            }
            displayedDates = (0..<preloadedTabAmount).compactMap { calendar.date(byAdding: .day, value: $0, to: startDate) }
        }
    }
}

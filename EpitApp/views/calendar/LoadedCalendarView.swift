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
    @ObservedObject var zeusAuthModel: ZeusAuthModel
    @ObservedObject var courseCache: CourseCache
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var displayedDates: [Date] = []

    
    private let preloadedTabAmount = 14

    //todo:
    // if is multi, do not round and no padding
    // if next is multi, do not round bottom, if previous is multi, do not round top (see if multi includes it tho)
    

    var body: some View {
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
                    print("Old bounds: \(displayedDates.first!.FNT) -> \(displayedDates.last!.FNT)")
                    updateDisplayedDates(for: selectedDate)
                    print("New bounds: \(displayedDates.first!.FNT) -> \(displayedDates.last!.FNT)")
                }
            }
            .onAppear() {
                updateDisplayedDates(for: selectedDate)
            }
            //            Text("Valid token found and checked (len of \(zeusAuthModel.token!.count)). Token start: '\(zeusAuthModel.token!.prefix(30))'.")
        }.refreshable {
          await refresh()
        }
    }

    private func refresh() async {
        courseCache.clearAllCourses()
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
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange))
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
                                if range.courses.count == 0 {
                                    LoadedCalendarSeparator(range: range)
                                } else {
                                    LoadedCalendarCourse(range: range)
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        
    }
    
    private func updateDisplayedDates(for date: Date) {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -preloadedTabAmount / 2, to: date) else {
            return
        }
        displayedDates = (0..<preloadedTabAmount).compactMap { calendar.date(byAdding: .day, value: $0, to: startDate) }
    }
}

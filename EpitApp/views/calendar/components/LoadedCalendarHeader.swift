//
//  LoadedCalendarCourseSheet.swift
//  EpitApp
//
//  Created by Quenting on 17/02/2025.
//

import SwiftUI


struct LoadedCalendarHeader: View {
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool

    var body: some View {
        HStack {
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            }) {
                Image(systemName: "arrow.left")
            }

            Spacer()

            Button(action: {
                // Show date picker popup
                showDatePicker = true
            }) {
                Text("\(selectedDate, formatter: dateFormatter)")
            }
            .popover(isPresented: $showDatePicker) {
                DatePicker(
                    "Select a date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
                .padding()
                .presentationCompactAdaptation(.popover)
                .frame(width: 350)
            }

            Spacer()

            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            }) {
                Image(systemName: "arrow.right")
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}

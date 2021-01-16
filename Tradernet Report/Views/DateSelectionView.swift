//
//  DateSelectionView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 12/01/21.
//

import SwiftUI


class TimeFrame: ObservableObject {
    @Published var isSingleDay = false
    @Published var selectedDay = Date()
    
    @Published var dateStart = Date()
    @Published var dateEnd = Date()
    
    @Published var timePeriod = TimePeriod.evening
    
    enum TimePeriod: String, CaseIterable, Identifiable {
        case morning = "08:40:00"
        case evening = "23:59:59"
        
        var id: TimePeriod { self }
    }
    
    
    static let dayDuration = TimeInterval(24 * 60 * 60)
    
    var dateInterval: DateInterval {
        let hours = timePeriod == TimePeriod.morning
            ? DateComponents(hour: 8, minute: 40, second: 59)
            : DateComponents(second: -1) // 23:59:59 of the previous day
        
        if isSingleDay {
            let startDate = Calendar.current.date(byAdding: hours, to: stripTime(from: selectedDay))!
            return DateInterval(start: startDate, duration: TimeFrame.dayDuration)
        } else {
            let startDate = Calendar.current.date(byAdding: hours, to: stripTime(from: dateStart))!
            let endDate = Calendar.current.date(byAdding: hours, to: stripTime(from: dateEnd))!
            
            let duration = DateInterval(start: startDate, end: endDate).duration + TimeFrame.dayDuration
            
            return DateInterval(start: startDate, duration: duration)
        }
    }
    
    var isValid: Bool { isSingleDay || DateInterval(start: stripTime(from: dateStart), end: stripTime(from: dateEnd)).duration >= TimeFrame.dayDuration }
}

extension AnyTransition {
    static func moveAndOpacity(edge: Edge) -> AnyTransition {
        return AnyTransition.move(edge: edge)
            .combined(with: .opacity)
    }
}


struct DateSelectionView: View {
    @ObservedObject var timeFrame: TimeFrame
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Toggle("Single Day", isOn: $timeFrame.isSingleDay.animation())
            }
            
            if timeFrame.isSingleDay {
                singleDayDatePicker
                    .transition(.moveAndOpacity(edge: .leading))
            }
            else {
                startEndDatePickers
                    .transition(.moveAndOpacity(edge: .leading))
            }
        }
    }
    
    private var startEndDatePickers: some View {
        let rangeStart = Date(timeInterval: TimeFrame.dayDuration, since: stripTime(from: timeFrame.dateStart))
        let rangeEnd = Date()
        let endDateSelectionRange = timeFrame.isValid ? rangeStart...rangeEnd : Date(timeIntervalSinceReferenceDate: 0)...Date()
        
        return HStack {
            VStack {
                Text("Start Date")
                    .font(.headline)
                DatePicker("Start Date", selection: $timeFrame.dateStart, in: ...Date(), displayedComponents: [.date])
            }
            VStack {
                Text("End Date")
                    .font(.headline)
                DatePicker("End Date", selection: $timeFrame.dateEnd, in: endDateSelectionRange, displayedComponents: [.date])
                    .disabled(!timeFrame.isValid)
            }
        }
        .labelsHidden()
    }
    
    private var singleDayDatePicker: some View {
        VStack {
            Text("Select Day")
                .font(.headline)
            DatePicker("Select Day", selection: $timeFrame.selectedDay, in: ...Date(), displayedComponents: [.date])
                .labelsHidden()
        }
    }
}


struct DateSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        let singleDayTimeFrame = TimeFrame()
        singleDayTimeFrame.isSingleDay = true
        return Group {
            DateSelectionView(timeFrame: TimeFrame())
            DateSelectionView(timeFrame: singleDayTimeFrame)
        }
    }
}

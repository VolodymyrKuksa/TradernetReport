//
//  DateSelectionView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 12/01/21.
//

import SwiftUI


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
                Toggle("single.day", isOn: $timeFrame.isSingleDay.animation())
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
                Text("start.date")
                    .font(.headline)
                DatePicker("start.date", selection: $timeFrame.dateStart, in: ...Date(), displayedComponents: [.date])
            }
            VStack {
                Text("end.date")
                    .font(.headline)
                DatePicker("end.date", selection: $timeFrame.dateEnd, in: endDateSelectionRange, displayedComponents: [.date])
                    .disabled(!timeFrame.isValid)
            }
        }
        .labelsHidden()
    }
    
    private var singleDayDatePicker: some View {
        VStack {
            Text("select.day")
                .font(.headline)
            DatePicker("select.day", selection: $timeFrame.selectedDay, in: ...Date(), displayedComponents: [.date])
                .labelsHidden()
        }
    }
}


struct DateSelectionView_Previews: PreviewProvider {
    static let previewApiKeys = fetchAPIKeys()
    static let previewManyApiKeys = fetchAPIKeys(.previewMany)
    
    static var previews: some View {
        let keyStorageWithSelection = APIKeyStorage(keys: previewApiKeys)
        keyStorageWithSelection.selectedIdentifiers.insert(keyStorageWithSelection.keys[0].id)

        let singleDayTimeFrame = TimeFrame(dbTimeFrame: keyStorageWithSelection.selectedKey!.configs!.timeFrame!)
        singleDayTimeFrame.isSingleDay = true
        
        let dateRangeTimeFrame = TimeFrame(dbTimeFrame: keyStorageWithSelection.selectedKey!.configs!.timeFrame!)
        dateRangeTimeFrame.isSingleDay = false
        
        return Group {
            DateSelectionView(timeFrame: dateRangeTimeFrame)
            DateSelectionView(timeFrame: singleDayTimeFrame)
        }
    }
}

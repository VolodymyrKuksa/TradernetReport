//
//  GetBrokerReportConfigs.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 27/01/21.
//

import Foundation
import Combine



class TimeFrame: ObservableObject {
    var dbTimeFrame: TimeFrameEntity
    
    @Published var isSingleDay: Bool
    @Published var selectedDay: Date

    @Published var dateStart: Date
    @Published var dateEnd: Date

    @Published var timePeriod: TimePeriod

    enum TimePeriod: String, CaseIterable, Identifiable {
        case morning = "08:40:00"
        case evening = "23:59:59"

        var id: TimePeriod { self }
    }

    var anyCancellables = [AnyCancellable]()
    
    init(dbTimeFrame entity: TimeFrameEntity) {
        dbTimeFrame = entity
        
        isSingleDay = Bool(truncating: entity.isSingleDay!)
        selectedDay = entity.selectedDay!
        dateStart = entity.dateStart!
        dateEnd = entity.dateEnd!
        timePeriod = TimePeriod(rawValue: entity.timePeriod!)!
        
        anyCancellables.append(self.objectWillChange.sink { [weak self] (_) in
            DispatchQueue.main.async {
                if self != nil {
                    self!.dbTimeFrame.isSingleDay = NSNumber(value: self!.isSingleDay)
                    self!.dbTimeFrame.selectedDay = self!.selectedDay
                    self!.dbTimeFrame.dateStart = self!.dateStart
                    self!.dbTimeFrame.dateEnd = self!.dateEnd
                    self!.dbTimeFrame.timePeriod = self!.timePeriod.rawValue
                    
                    PersistenceController.shared.saveContext()
                }
            }
        })
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

class GetBrokerReportConfigs: ObservableObject {
    var dbConfig: BrokerReportConfigsEntity
    
    @Published var timeFrame: TimeFrame
    @Published var fileFormat: FileFormat
    @Published var downloadURL: String

    enum FileFormat: String, CaseIterable, Identifiable {
        case html = "html"
        case json = "json"
        case pdf = "pdf"
        case xls = "xls"
        case xml = "xml"

        var id: FileFormat { self }
    }

    var anyCancellables = [AnyCancellable]()

    init(dbConfig entity: BrokerReportConfigsEntity) {
        dbConfig = entity
        
        timeFrame = TimeFrame(dbTimeFrame: entity.timeFrame!)
        fileFormat = GetBrokerReportConfigs.FileFormat(rawValue: entity.fileFormat!)!
        downloadURL = entity.downloadURL!
        
        anyCancellables.append(timeFrame.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        })
        anyCancellables.append(self.objectWillChange.sink { [weak self] (_) in
            DispatchQueue.main.async {
                if self != nil {
                    self!.dbConfig.fileFormat = self!.fileFormat.rawValue
                    self!.dbConfig.downloadURL = self!.downloadURL
                    PersistenceController.shared.saveContext()
                }
            }
        })
    }

    var isValid: Bool { timeFrame.isValid }
}

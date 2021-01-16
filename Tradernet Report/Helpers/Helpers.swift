//
//  Helpers.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import Foundation
import AppKit


func insertIntoPasteboard(text: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short

        let dateString = formatter.string(from: value)
        appendLiteral(dateString)
    }
}

func stripTime(from originalDate: Date) -> Date {
    let components = Calendar.current.dateComponents([.year, .month, .day], from: originalDate)
    let date = Calendar.current.date(from: components)
    return date!
}

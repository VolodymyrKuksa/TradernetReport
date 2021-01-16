//
//  Tradernet_ReportApp.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import SwiftUI

@main
struct Tradernet_ReportApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//
//  ContentView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        PersistenceController.shared = PersistenceController.preview
        return HomeView()
            .environmentObject(APIKeysData(keys: fetchAPIKeys(.shared)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .environment(\.locale, .init(identifier: "uk"))
        }
    }
}

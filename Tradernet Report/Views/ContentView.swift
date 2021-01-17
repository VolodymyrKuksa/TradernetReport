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
        // for debug purposes
//        PersistenceController.shared = .previewMany
        return HomeView()
            .environmentObject(APIKeysData(keys: fetchAPIKeys(.shared)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

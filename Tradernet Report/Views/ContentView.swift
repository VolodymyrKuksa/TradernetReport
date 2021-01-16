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
        HomeView()
            .environmentObject(APIKeysData(keys: fetchAPIKeys(.previewMany)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

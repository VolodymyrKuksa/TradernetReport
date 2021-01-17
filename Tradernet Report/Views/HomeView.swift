//
//  HomeView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import SwiftUI

struct HomeView: View {
    
    @State var isDisabled = false
        
    var body: some View {
        NavigationView {
            APIKeyListView()
//            Divider()
            GetBrokerReportView(configs: GetBrokerReportConfigs(), isDisabled: $isDisabled)
        }
        .frame(width: 880)
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static let previewApiKeys = fetchAPIKeys()
    static let previewManyApiKeys = fetchAPIKeys(.previewMany)
    
    static var previews: some View {
        let keysDataWithSelection = APIKeysData(keys: previewApiKeys)
        keysDataWithSelection.selectedIdentifiers.insert(keysDataWithSelection.keys[0].id)
        return Group {
            HomeView()
                .environmentObject(keysDataWithSelection)
//            HomeView(isDisabled: true)
//                .environmentObject(keysDataWithSelection)
            HomeView()
                .environmentObject(APIKeysData(keys: previewManyApiKeys))
                .environment(\.colorScheme, .dark)
            HomeView()
                .environmentObject(APIKeysData(keys: previewManyApiKeys))
                .environment(\.colorScheme, .light)
        }
    }
}

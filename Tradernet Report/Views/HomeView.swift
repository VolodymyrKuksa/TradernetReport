//
//  HomeView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var keyStorage: APIKeyStorage
    
    @State var isDisabled = false
        
    var body: some View {
        NavigationView {
            APIKeyListView()
                .blur(radius: isDisabled ? 3 : 0)
            
            switch keyStorage.selectedKeys.count {
            case 0:
                Text("select.api.key")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            case 1:
                GetBrokerReportView(configs: GetBrokerReportConfigs(dbConfig: keyStorage.selectedKey!.configs!), isDisabled: $isDisabled)
            default:
                Text("err.multiple.keys.selected")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
        }
        .disabled(isDisabled)
        .allowsHitTesting(!isDisabled)
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static let previewApiKeys = fetchAPIKeys()
    static let previewManyApiKeys = fetchAPIKeys(.previewMany)
    
    static var previews: some View {
        let keysStorageWithSelection = APIKeyStorage(keys: previewApiKeys)
        keysStorageWithSelection.selectedIdentifiers.insert(keysStorageWithSelection.keys[0].id)
        return Group {
            HomeView()
                .environmentObject(keysStorageWithSelection)
            HomeView()
                .environmentObject(keysStorageWithSelection)
                .environment(\.locale, .init(identifier: "uk"))
            HomeView()
                .environmentObject(keysStorageWithSelection)
                .environment(\.locale, .init(identifier: "ru"))
            HomeView(isDisabled: true)
                .environmentObject(keysStorageWithSelection)
            HomeView()
                .environmentObject(APIKeyStorage(keys: previewManyApiKeys))
                .environment(\.colorScheme, .dark)
            HomeView()
                .environmentObject(APIKeyStorage(keys: previewManyApiKeys))
                .environment(\.colorScheme, .light)
        }
    }
}

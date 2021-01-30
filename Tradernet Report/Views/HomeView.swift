//
//  HomeView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var keysData: APIKeysData
    
    @State var isDisabled = false
        
    var body: some View {
        NavigationView {
            APIKeyListView()
                .blur(radius: isDisabled ? 3 : 0)
            
            switch keysData.selectedKeys.count {
            case 0:
                Text("Select an API Key to proceed")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            case 1:
                GetBrokerReportView(configs: GetBrokerReportConfigs(dbConfig: keysData.selectedKey!.configs!), isDisabled: $isDisabled)
            default:
                Text("Multiple API Keys are currently not supported :(")
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
        let keysDataWithSelection = APIKeysData(keys: previewApiKeys)
        keysDataWithSelection.selectedIdentifiers.insert(keysDataWithSelection.keys[0].id)
        return Group {
            HomeView()
                .environmentObject(keysDataWithSelection)
            HomeView(isDisabled: true)
                .environmentObject(keysDataWithSelection)
            HomeView()
                .environmentObject(APIKeysData(keys: previewManyApiKeys))
                .environment(\.colorScheme, .dark)
            HomeView()
                .environmentObject(APIKeysData(keys: previewManyApiKeys))
                .environment(\.colorScheme, .light)
        }
    }
}

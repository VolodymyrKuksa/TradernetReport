//
//  APIKeyListView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import SwiftUI


class APIKeysData: ObservableObject {
    @Published public var selectedIdentifiers = Set<ObjectIdentifier>()
    public let keys: [APIKey]
    
    public var selectedKeys: [APIKey] {
        keys.filter { selectedIdentifiers.contains($0.id) }
    }
    
    init(keys: [APIKey]) {
        self.keys = keys
    }
}

struct APIKeyListView: View {
    
    @State var isDisabled = false
    
    @EnvironmentObject var keysData: APIKeysData
    
    var body: some View {
        List(selection: $keysData.selectedIdentifiers) {
            Section(header: listHeader) {
                ForEach(keysData.keys) { apiKey in
                    let isGrayedOut = (keysData.keys.firstIndex(of: apiKey)! % 2) != 0 && !keysData.selectedKeys.contains(apiKey)
                    
                    NavigationLink(destination: GetBrokerReportView(configs:GetBrokerReportConfigs(), isDisabled: $isDisabled)) {
                        APIKeyListCellView(apiKey: apiKey)
                            .padding(6)
                            .onLongPressGesture { print("long press") }
                            .background(isGrayedOut ? Color(CGColor(gray: 0.6, alpha: 0.3)) : Color.clear)
                            .cornerRadius(8)
                            .contextMenu {
                                Button(action: {}) {
                                    Text("Edit")
                                    Image(systemName: "pencil.circle")
                                }
                                Button(action: {}) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                
                                Divider()
                                
                                Button(action: { insertIntoPasteboard(text: apiKey.publicKey!) }) {
                                    Text("Copy Public Key: \(apiKey.publicKey!)")
                                    Image(systemName: "doc.on.clipboard")
                                }
                                
                                Button(action: { insertIntoPasteboard(text: apiKey.secret!) }) {
                                    Text("Copy Secret")
                                    Image(systemName: "doc.on.clipboard")
                                }
                            }
                        }
                    }
            }
        }
        .navigationTitle("API Keys")
        .frame(minWidth: 350)
    }
    
    var listHeader: some View {
        HStack {
            Spacer()
            Text("API Keys")
                .font(.largeTitle)
            Spacer()
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image(systemName: "plus")
            }
            .help("Add New API Key")
        }
    }
}

struct APIKeyListView_Previews: PreviewProvider {
    static let previewAPIKeys = fetchAPIKeys()
    static let previewManyAPIKeys = fetchAPIKeys(.previewMany)
    
    static var previews: some View {
        Group {
            APIKeyListView()
                .environmentObject(APIKeysData(keys: previewManyAPIKeys))
            
            APIKeyListView()
                .environmentObject(APIKeysData(keys: previewAPIKeys))
                .environment(\.colorScheme, .dark)
            
            APIKeyListView()
                .environmentObject(APIKeysData(keys: previewAPIKeys))
                .environment(\.colorScheme, .light)
        }
    }
}

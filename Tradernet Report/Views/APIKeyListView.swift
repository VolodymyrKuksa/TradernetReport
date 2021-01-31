//
//  APIKeyListView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import SwiftUI


class APIKeysData: ObservableObject {
    @Published public var selectedIdentifiers = Set<ObjectIdentifier>()
    @Published public var keys: [APIKey]
    @Published public var changed = true
    
    public var selectedKeys: [APIKey] {
        keys.filter { selectedIdentifiers.contains($0.id) }
    }
    
    public var selectedKey: APIKey? {
        let selected = selectedKeys
        return selected.count == 1 ? selected[0] : nil
    }
    
    init(keys: [APIKey]) {
        self.keys = keys
    }
}

struct APIKeyListView: View {    
    @EnvironmentObject var keysData: APIKeysData
    
    @State var isShowingCreateKeyModal = false
    @State var isShowingEditKeyModal = false
    @State var editedKey: APIKey? = nil
    
    var body: some View {
        List(selection: $keysData.selectedIdentifiers) {
            Section(header: listHeader) {
                ForEach(keysData.keys) { apiKey in
                    let isGrayedOut = (keysData.keys.firstIndex(of: apiKey)! % 2) != 0 && !keysData.selectedKeys.contains(apiKey)
                    
                    APIKeyListCellView(apiKey: apiKey)
                        .padding(6)
                        .background(isGrayedOut ? Color(CGColor(gray: 0.6, alpha: 0.3)) : Color.clear)
                        .cornerRadius(8)
                        .contextMenu {
                            Button(action: { insertIntoPasteboard(text: apiKey.publicKey!) }) {
                                Text("copy.public.key: \(apiKey.publicKey!)")
                                Image(systemName: "doc.on.clipboard")
                            }
                            
                            Button(action: { insertIntoPasteboard(text: apiKey.secret!) }) {
                                Text("copy.secret")
                                Image(systemName: "doc.on.clipboard")
                            }
                        }
                    }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("api.keys.title")
        .frame(minWidth: 350, idealWidth: 350)
        .sheet(isPresented: $isShowingCreateKeyModal) {
            EditAPIKeyView(isShown: $isShowingCreateKeyModal, persistenceController: .shared)
        }
    }
    
    var listHeader: some View {
        HStack {
            Spacer()
            Text("api.keys.title")
                .font(.largeTitle)
            Spacer()
            Button(action: { withAnimation { isShowingCreateKeyModal = true } }) {
                Image(systemName: "plus")
            }
            .help("add.api.key.help")
        }
    }
}

struct APIKeyListView_Previews: PreviewProvider {
    static let previewAPIKeys = fetchAPIKeys()
    static let previewManyAPIKeys = fetchAPIKeys(.previewMany)
    
    static var previews: some View {
        PersistenceController.shared = .previewMany
        return Group {
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

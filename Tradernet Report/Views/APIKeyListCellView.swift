//
//  APIKeyListCellView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import SwiftUI


struct APIKeyListCellView: View {
    
    @EnvironmentObject var keysData: APIKeysData
    @ObservedObject var apiKey: APIKey
    
    @State private var isShowingEditModal = false
    @State private var isShowingDeleteAlert = false
    
    /// LAYOUT
    var body: some View {
        VStack {
            HStack {
                apiKeyName
                Spacer()
                editButton
                deleteButton
            }
            
            Spacer()
            
            HStack {
                clientCode
                Spacer()
                clientName
            }
        }
        .frame(height: 50)
        .sheet(isPresented: $isShowingEditModal) {
            EditAPIKeyView(isShown: $isShowingEditModal, persistenceController: .shared, keyToEdit: apiKey)
        }
    }
    
    /// ELEMENTS
    private var apiKeyName: some View {
        Text(apiKey.friendlyName ?? "")
            .font(.headline)
    }
    
    private var clientCode: some View {
        Text(apiKey.clientCode ?? "")
            .font(.body)
            .foregroundColor(.secondary)
    }
    
    private let modificationButtonSize: CGFloat = 18
    
    private var editButton: some View {
        return Button(action: { withAnimation { isShowingEditModal = true } }) {
            Image(systemName: "pencil.circle")
                .resizable()
                .scaledToFit()
                .frame(width: modificationButtonSize, height: modificationButtonSize)
        }
        .buttonStyle(PlainButtonStyle())
        .help("Edit")
    }
    
    private var deleteButton: some View {
        return Button(action: { withAnimation { isShowingDeleteAlert = true } }) {
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: modificationButtonSize, height: modificationButtonSize)
        }
        .alert(isPresented: $isShowingDeleteAlert) {
            Alert(
                title: Text("Key Deletion"),
                message: Text("Are you sure you want to delete key \"\(apiKey.friendlyName!)\""),
                primaryButton: .destructive(Text("Delete")) {
                    PersistenceController.shared.container.viewContext.delete(apiKey)
                    PersistenceController.shared.saveContext()
                    keysData.keys = fetchAPIKeys(.shared)
                },
                secondaryButton: .cancel()
            )
        }
        .buttonStyle(PlainButtonStyle())
        .help("Delete")
    }
    
    private var clientName: some View {
        Text(apiKey.clientName ?? "")
            .font(.body)
            .foregroundColor(.secondary)
    }
}



struct APIKeyListCellView_Previews: PreviewProvider {
    
    static let previewAPIKeys = fetchAPIKeys()
    
    static var previews: some View {
        PersistenceController.shared = .previewMany
        return Group {
            ForEach(previewAPIKeys.indices) { idx in
                APIKeyListCellView(apiKey: previewAPIKeys[idx])
                    .environment(\.colorScheme, idx % 2 == 1 ? .light : .dark)
            }
            
            ForEach(previewAPIKeys) { key in
                APIKeyListCellView(apiKey: key)
            }
            .frame(width: 400)
        }
    }
}

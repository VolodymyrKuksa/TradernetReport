//
//  APIKeyListCellView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import SwiftUI


struct APIKeyListCellView: View {
    
    let apiKey: APIKey
    
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
            
//            Divider()
        }
        .frame(height: 50)
    }
    
    /// ELEMENTS
    private var apiKeyName: some View {
        Text(apiKey.friendlyName!)
            .font(.headline)
    }
    
    private var clientCode: some View {
        // TODO: Replace this
        Text("108435")
            .font(.body)
            .foregroundColor(.secondary)
    }
    
    private let modificationButtonSize: CGFloat = 18
    
    private var editButton: some View {
        return Button(action: {}) {
            Image(systemName: "pencil.circle")
                .resizable()
                .scaledToFit()
                .frame(width: modificationButtonSize, height: modificationButtonSize)
        }
        .buttonStyle(PlainButtonStyle())
        .help("Edit")
    }
    
    private var deleteButton: some View {
        return Button(action: {}) {
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: modificationButtonSize, height: modificationButtonSize)
        }
        .buttonStyle(PlainButtonStyle())
        .help("Delete")
    }
    
    private var clientName: some View {
        // TODO: Replace this
        Text("Volodymyr Kuksa")
            .font(.body)
            .foregroundColor(.secondary)
    }
}



struct APIKeyListCellView_Previews: PreviewProvider {
    
    static let previewAPIKeys = fetchAPIKeys()
    
    static var previews: some View {
        Group {
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

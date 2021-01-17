//
//  APIKeyCreateView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 16/01/21.
//

import SwiftUI

struct EditAPIKeyView: View {
    @EnvironmentObject var keysData: APIKeysData
    
    @Binding var isShown: Bool
    var persistenceController: PersistenceController
    var editedKey: APIKey
    
    @State var friendlyName = ""
    @State var publicKey = ""
    @State var secret = ""
    
    @State var displayErrors = false
    
    private let title: String
    
    init(isShown shown: Binding<Bool>, persistenceController pc: PersistenceController, keyToEdit: APIKey? = nil) {
        self._isShown = shown
        title = keyToEdit == nil ? "Add API Key" : "Edit API Key"
        
        persistenceController = pc
        
        if let keyUnwrapped = keyToEdit {
            editedKey = keyUnwrapped
        } else {
            editedKey = APIKey(context: persistenceController.container.viewContext)
            editedKey.friendlyName = ""
            editedKey.publicKey = ""
            editedKey.secret = ""
        }
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
            
            editorialTextField(label: "Name", $friendlyName)
            editorialTextField(label: "Public Key", $publicKey)
            editorialTextField(label: "Secret", $secret)
            
            Spacer()
            
            HStack {
                Button(action: { withAnimation { isShown = false }}) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: saveAction) {
                    Text("Save")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .padding()
        .frame(width: 450, height: 300)
        .onAppear {
            friendlyName = editedKey.friendlyName!
            publicKey = editedKey.publicKey!
            secret = editedKey.secret!
        }
    }
    
    private func editorialTextField(label: String, _ value: Binding<String>) -> some View {
        
        let labelWidth: CGFloat = 80 // this might cause issues for larger font sizes
        return HStack {
            Text("\(label):")
                .frame(width: labelWidth)
            VStack {
                TextField("", text: value)
                if displayErrors && value.wrappedValue.isEmpty {
                    Text("This field cannot be empty!")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func saveAction() {
        
        if friendlyName.isEmpty || publicKey.isEmpty || secret.isEmpty {
            withAnimation { displayErrors = true }
            return
        }
        
        editedKey.friendlyName = friendlyName
        editedKey.publicKey = publicKey
        editedKey.secret = secret
        
        persistenceController.saveContext()
        
        keysData.objectWillChange.send()
        keysData.changed.toggle()
        keysData.keys = fetchAPIKeys(persistenceController)
        withAnimation { isShown = false }
    }
}

struct APIKeyCreateView_Previews: PreviewProvider {
    @State static var isShown = true
    
    static var previews: some View {
        EditAPIKeyView(isShown: $isShown, persistenceController: PersistenceController.preview)
    }
}

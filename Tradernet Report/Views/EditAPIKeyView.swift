//
//  APIKeyCreateView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 16/01/21.
//

import SwiftUI

struct GetBrokerReportResponse: Decodable {
    let plainAccountInfoData: PlainAccountInfoData
}

struct EditAPIKeyView: View {
    @EnvironmentObject var keysData: APIKeysData
    
    @Binding var isShown: Bool
    var persistenceController: PersistenceController
    var editedKey: APIKey
    
    @State var friendlyName = ""
    @State var publicKey = ""
    @State var secret = ""
    
    @State var displayErrors = false
    @State var isDisplayingErrorAlert = false
    
    private let title: LocalizedStringKey
    
    init(isShown shown: Binding<Bool>, persistenceController pc: PersistenceController, keyToEdit: APIKey? = nil) {
        self._isShown = shown
        title = keyToEdit == nil ? "add.api.key" : "edit.api.key"
        
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
            
            editorialTextField(label: "name", $friendlyName)
            editorialTextField(label: "public.key", $publicKey)
            editorialTextField(label: "secret", $secret)
            
            Spacer()
            
            HStack {
                Button(action: { withAnimation { isShown = false }}) {
                    Text("cancel")
                }
                Spacer()
                Button(action: saveAction) {
                    Text("save")
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
        .alert(isPresented: $isDisplayingErrorAlert) {
            Alert(title: Text("err.api.key.invalid"), message: Text("err.api.key.invalid.message"))
        }
    }
    
    private func editorialTextField(label: LocalizedStringKey, _ value: Binding<String>) -> some View {
        
        let labelWidth: CGFloat = 80 // this might cause issues for larger font sizes
        return HStack {
            Text(label)
                .frame(width: labelWidth)
            VStack {
                TextField("", text: value)
                if displayErrors && value.wrappedValue.isEmpty {
                    Text("err.field.empty")
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
        
        let result = getBrokerReport(
            publicKey: publicKey,
            secret: secret
        )
        result.debugPrint()
        if result.code != 0 {
            isDisplayingErrorAlert = true
            return
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let response = try! decoder.decode(GetBrokerReportResponse.self, from: result.out.data(using: .utf8)!)
        
        editedKey.clientCode = response.plainAccountInfoData.clientCode
        editedKey.clientName = response.plainAccountInfoData.clientName
        editedKey.friendlyName = friendlyName
        editedKey.publicKey = publicKey
        editedKey.secret = secret
        
        if editedKey.configs == nil {
            editedKey.configs = BrokerReportConfigsEntity(context: persistenceController.container.viewContext)
            editedKey.configs!.downloadURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].path
        }
        if editedKey.configs!.timeFrame == nil {
            editedKey.configs!.timeFrame = TimeFrameEntity(context: persistenceController.container.viewContext)
            let timeFrame = editedKey.configs!.timeFrame!
            timeFrame.dateStart = Date()
            timeFrame.dateEnd = Date()
            timeFrame.selectedDay = Date()
        }
        
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

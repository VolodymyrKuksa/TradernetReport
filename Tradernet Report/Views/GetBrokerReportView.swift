//
//  GetBrokerReportView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import Foundation
import AppKit
import SwiftUI
import Combine


class GetBrokerReportConfigs: ObservableObject {
    @Published var timeFrame = TimeFrame()
    @Published var fileFormat = FileFormat.json
    @Published var downloadURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
    
    enum FileFormat: String, CaseIterable, Identifiable {
        case html = "html"
        case json = "json"
        case pdf = "pdf"
        case xls = "xls"
        case xml = "xml"
        
        var id: FileFormat { self }
    }
    
    var anyCancellable: AnyCancellable? = nil
        
    init() {
        anyCancellable = timeFrame.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
}


struct GetBrokerReportView: View {
    
    @ObservedObject var configs: GetBrokerReportConfigs
    @EnvironmentObject var keysData: APIKeysData
    @Binding var isDisabled: Bool
    
    @State var showAdvanced = false
    
    var body: some View {
        ZStack {
            if keysData.selectedIdentifiers.count == 0 {
                Text("Select an API Key to proceed")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            } else {
                main
            }
        }
        .frame(minWidth: 350)
        .padding()
    }
    
    private let topOffset: CGFloat = 0.16
    private var main: some View {
        GeometryReader { geometry in
            let offsetHeight = geometry.size.height * topOffset
            let contentHeight = geometry.size.height * (1 - topOffset)
            
            VStack {
                Spacer()
                    .frame(height: offsetHeight)
                content
                    .frame(height: contentHeight, alignment: .top)
            }
        }
    }
    
    private var content: some View {
        VStack {
            DateSelectionView(timeFrame: configs.timeFrame)
            
            Picker("File Format", selection: $configs.fileFormat) {
                ForEach(GetBrokerReportConfigs.FileFormat.allCases) { format in
                    Text(format.rawValue)
                }
            }
            
            HStack {
                Text("Download To: \(configs.downloadURL.path)")
                
                Button(action: selectDownloadPathAction) {
                    Text("Change...")
                }
            }
            
            Spacer()
            
            Button(action: downloadReportAction, label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text(keysData.selectedIdentifiers.count == 1 ? "Download Report" : "Download Reports")
                }
                .font(.headline)
            })
            .padding()
            
            Divider()
            HStack {
                Spacer()
                Button(action: { withAnimation { showAdvanced.toggle() } }, label: {
                    Text("Advanced")
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(showAdvanced ? 0 : 180))
                })
                .buttonStyle(PlainButtonStyle())
            }
            
            if showAdvanced {
                VStack {
                    Picker("Time Period", selection: $configs.timeFrame.timePeriod) {
                        ForEach(TimeFrame.TimePeriod.allCases) { period in
                            Text(period.rawValue)
                        }
                    }
                    Text(composeTimeFrameHint())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                }
                .transition(.moveAndOpacity(edge: .bottom))
            }
        }
    }
    
    private func downloadReportAction() {
        withAnimation { isDisabled = true }
        DispatchQueue.global(qos: .background).async {
            sleep(2)
            
            DispatchQueue.main.async {
                withAnimation { isDisabled = false }
            }
        }
    }
    
    private func getFileDialog() -> NSOpenPanel {
        let openPanel = NSOpenPanel()
        openPanel.title = "Download Location"
        openPanel.message = "Choose or Create a Folder"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = true
        return openPanel
    }
    
    private func selectDownloadPathAction() {
        let fileDialog = getFileDialog()
        if fileDialog.runModal() == NSApplication.ModalResponse.OK,
           let newPath = fileDialog.url {
            configs.downloadURL = newPath
        }
    }
    
    private func composeTimeFrameHint() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.y hh:mm:ss"
        
        let interval = configs.timeFrame.dateInterval
        return "Since \(formatter.string(from: interval.start)) to \(formatter.string(from: interval.end))"
    }
}

struct GetBrokerReportView_Previews: PreviewProvider {
    static let previewApiKeys = fetchAPIKeys()
    static let previewManyApiKeys = fetchAPIKeys(.previewMany)
    
    @State static var isDisabled = false
    
    static var previews: some View {
        let keysDataWithSelection = APIKeysData(keys: previewApiKeys)
        keysDataWithSelection.selectedIdentifiers.insert(keysDataWithSelection.keys[0].id)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.y hh:mm:ss"
        
        let edgeCase = GetBrokerReportConfigs()
        edgeCase.timeFrame.dateStart = formatter.date(from: "01.01.2021 00:00:00")!
                
        return Group {
            GetBrokerReportView(configs: GetBrokerReportConfigs(), isDisabled: $isDisabled)
                .environmentObject(keysDataWithSelection)
            GetBrokerReportView(configs: edgeCase, isDisabled: $isDisabled, showAdvanced: true)
                .environmentObject(keysDataWithSelection)
            GetBrokerReportView(configs: GetBrokerReportConfigs(), isDisabled: $isDisabled)
                .environmentObject(APIKeysData(keys: previewApiKeys))
        }
    }
}

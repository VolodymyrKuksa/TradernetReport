//
//  GetBrokerReportView.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 7/01/21.
//

import Foundation
import AppKit
import SwiftUI


struct GetBrokerReportView: View {
    
    @ObservedObject var configs: GetBrokerReportConfigs
    
    @EnvironmentObject var keysData: APIKeysData
    @Binding var isDisabled: Bool
    
    @State var showAdvanced = false
    
    private let topOffset: CGFloat = 0.16
    var body: some View {
        GeometryReader { geometry in
            let offsetHeight = geometry.size.height * topOffset
            let contentHeight = geometry.size.height * (1 - topOffset)
            
            VStack {
                HStack {
                    Text(keysData.selectedKey?.friendlyName ?? "")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
                .frame(height: offsetHeight)
                content
                    .frame(height: contentHeight, alignment: .top)
            }
        }
        .frame(minWidth: 250)
        .padding()
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
                Text("Download To: \(configs.downloadURL)")
                
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
            .disabled(!configs.isValid)
            
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        DispatchQueue.global(qos: .background).async {

            let selectedAPIKey = keysData.selectedKeys[0]
            let result = getBrokerReport(
                publicKey: selectedAPIKey.publicKey!,
                secret: selectedAPIKey.secret!,
                fileFormat: configs.fileFormat.rawValue,
                outputDirectory: configs.downloadURL,
                dateStart: configs.timeFrame.dateInterval.start,
                dateEnd: configs.timeFrame.dateInterval.end,
                timePeriod: configs.timeFrame.timePeriod == TimeFrame.TimePeriod.morning ? "morning" : "evening"
            )
            
            print("code: \(result.code)\nout: \(result.out)\nerr: \(result.err)")
            
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
        openPanel.directoryURL = URL(fileURLWithPath: configs.downloadURL)
        return openPanel
    }
    
    private func selectDownloadPathAction() {
        let fileDialog = getFileDialog()
        if fileDialog.runModal() == NSApplication.ModalResponse.OK,
           let newPath = fileDialog.url {
            configs.downloadURL = newPath.path
        }
    }
    
    private func composeTimeFrameHint() -> String {
        if !configs.timeFrame.isValid {
            return "Invalid time frame."
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.y hh:mm:ss"
        
        let interval = configs.timeFrame.dateInterval
        return "Since \(formatter.string(from: interval.start)) to \(formatter.string(from: interval.end))"
    }
}

//struct GetBrokerReportView_Previews: PreviewProvider {
//    static let previewApiKeys = fetchAPIKeys()
//    static let previewManyApiKeys = fetchAPIKeys(.previewMany)
//
//    @State static var isDisabled = false
//
//    static var previews: some View {
//        let keysDataWithSelection = APIKeysData(keys: previewApiKeys)
//        keysDataWithSelection.selectedIdentifiers.insert(keysDataWithSelection.keys[0].id)
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd.MM.y hh:mm:ss"
//
//        let edgeCase = GetBrokerReportConfigs()
//        edgeCase.timeFrame.dateStart = formatter.date(from: "01.01.2021 00:00:00")!
//
//        return Group {
//            GetBrokerReportView(isDisabled: $isDisabled)
//                .environmentObject(keysDataWithSelection)
//            GetBrokerReportView(isDisabled: $isDisabled, showAdvanced: true)
//                .environmentObject(keysDataWithSelection)
//            GetBrokerReportView(isDisabled: $isDisabled)
//                .environmentObject(APIKeysData(keys: previewApiKeys))
//        }
//    }
//}

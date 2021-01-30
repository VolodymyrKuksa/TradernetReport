//
//  GetBrokerReportCommand.swift
//  Tradernet Report
//
//  Created by VolodymyrKuksa on 27/01/21.
//

import Foundation

class Python {
    static var current: String? = locateVersion()
    
    static func locateVersion() -> String? {
        let minorVersions = 7...30
        let searchPaths = ["/usr/local/Frameworks/Python.framework/Versions/3.[minorVersion]/bin/python3", "/Library/Frameworks/Python.framework/Versions/3.[minorVersion]/bin/python3"]
        
        for version in minorVersions.reversed() {
            for path in searchPaths {
                let currentPath = path.replacingOccurrences(of: "[minorVersion]", with: "\(version)")
                if FileManager.default.fileExists(atPath: currentPath) {
                    let task = Process()
                    task.executableURL = URL(fileURLWithPath: currentPath)
                    task.arguments = ["--version"]
                    do {
                        try task.run()
                        task.waitUntilExit()
                        if task.terminationStatus == 0 {
                            return currentPath
                        }
                    } catch {
                        continue
                    }
                }
            }
        }
        
        return nil
    }
}

class TemporaryDirectory {
    static var path: String? = getTempDirectoryPath()
    
    static func getTempDirectoryPath() -> String? {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TradernetReport")
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
            } catch {
                return nil
            }
        }
        return url.path
    }
}

struct CommandResult {
    let code: Int32
    let out: String
    let err: String
    
    func debugPrint() {
        print("code: \(code)\nout: \(out)\nerr: \(err)")
    }
}

func runPythonCommand(_ args: [String]? = []) -> CommandResult {
    guard let pythonPath = Python.current else {
        print("Failed to locate python3.7+ !!!")
        exit(1)
    }
    
    let task = Process()
    
    task.executableURL = URL(fileURLWithPath: pythonPath)
    task.arguments = args
    
    let out = Pipe()
    let err = Pipe()
    
    task.standardOutput = out
    task.standardError = err
    
    do {
        try task.run()
    } catch {
        print(error)
    }
    task.waitUntilExit()

    let outputData = out.fileHandleForReading.readDataToEndOfFile()
    let errorData = err.fileHandleForReading.readDataToEndOfFile()
    
    let exitCode = task.terminationStatus
    let output = String(decoding: outputData, as: UTF8.self)
    let error = String(decoding: errorData, as: UTF8.self)
    
    return CommandResult(code: exitCode, out: output, err: error)
}

func getBrokerReport(
    publicKey: String,
    secret: String,
    fileFormat: String? = nil,
    outputDirectory: String? = nil,
    dateStart: Date? = nil,
    dateEnd: Date? = nil,
    timePeriod: String? = nil
) -> CommandResult {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    var params = ["-m", "tradernet_cli", "get_broker_report",
                  "--public_key", publicKey,
                  "--secret", secret]
    
    if fileFormat != nil {
        params.append(contentsOf: ["--get_broker_report_format", fileFormat!])
    }

    params.append(contentsOf: ["--get_broker_report_output_directory", outputDirectory ?? TemporaryDirectory.path!])

    if dateStart != nil && dateEnd != nil {
        params.append(contentsOf: ["--get_broker_report_date_start", formatter.string(from: dateStart!),
                                   "--get_broker_report_date_end", formatter.string(from: dateEnd!)])
    }
    if timePeriod != nil {
        params.append(contentsOf: ["--get_broker_report_time_period", timePeriod!])
    }
    
    var result = runPythonCommand(params)
    
    if outputDirectory == nil && result.code == 0 {
        // TODO: add some error checking
        let regex = try! NSRegularExpression(pattern: "\\[get_broker_report\\] Created file at: \\\"(.*)\\\"")
        let range = NSRange(location: 0, length: result.out.utf16.count)
        let match = regex.firstMatch(in: result.out, options: [], range: range)
        let filename = String(result.out[Range(match!.range(at: 1), in: result.out)!])
        
        let content = try! String(contentsOf: URL(fileURLWithPath: filename))
        result = CommandResult(code: result.code, out: content, err: result.err)
    }
    
    return result
}

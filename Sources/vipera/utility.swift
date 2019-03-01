//
//  utility.swift
//  vipera
//
//  Created by Tibor Bödecs on 2019. 02. 26..
//

import Foundation
import Dir

extension String {
    func capitalizedFirstLetter() -> String {
        return prefix(1).uppercased() + self.dropFirst()
    }
}

func getFormattedDate() -> String {
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    return dateFormatter.string(from: now)
}

func getGitUserName() -> String? {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launchPath = "/usr/bin/env"
    task.arguments = ["git", "config", "--global", "user.name"]
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    task.waitUntilExit()
    return output
}

func getProjectName(from url: URL) -> String? {
    //NOTE: change this ! to ? after Swift 5 release
    return try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        .map { $0.lastPathComponent }
        .filter { $0.hasSuffix("xcodeproj") || $0.hasSuffix("xcworkspace") }
        .compactMap { $0.split(separator: ".").first }
        .map(String.init)
        .first
}

func replace(_ parameters: [String: String], in text: String) -> String {
    var result = text
    parameters.forEach { key, value in
        result = result.replacingOccurrences(of: "{\(key)}", with: value)
    }
    return result
}

func createModuleComponent(from url: URL, to moduleUrl: URL, using fileManager: FileManager = .default) throws {
    let items = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    try items.forEach { item in
        if Dir(path: item.path).isExistingDirectory {
            let itemUrl = moduleUrl.appendingPathComponent(item.lastPathComponent)
            try fileManager.createDirectory(at: itemUrl, withIntermediateDirectories: true, attributes: nil)
            try createModuleComponent(from: item, to: itemUrl)
        }
        else {
            guard item.pathExtension == "swift" else { return }
            let template = try String(contentsOf: item)
            let fileName = replace(params, in: item.lastPathComponent)
            let content = replace(params, in: template)
            let fileUrl = moduleUrl.appendingPathComponent(fileName)
            try content.write(to: fileUrl, atomically: true, encoding: .utf8)
        }
    }
}

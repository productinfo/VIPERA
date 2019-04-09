//
//  main.swift
//  Dir
//
//  Created by Tibor Bödecs on 2019. 02. 28..
//

import Foundation
import Dir
import SPM


var installTemplates        = false
var installXcodeTemplates   = false

if CommandLine.arguments.count > 1 {
    installTemplates        = CommandLine.arguments.contains("--with-templates")
    installXcodeTemplates   = CommandLine.arguments.contains("--with-xcode-templates")
}

struct Constants {

    struct CommandLineValues {
        static let yes = "YES"
        static let no = "NO"
    }

    struct File {
        static let scriptName = "vipera"
        static let xcodeTemplateDir = "Xcode-Templates"
        static let templateName = "VIPER Module.xctemplate"
        static let destinationRelativePath = "/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates/Project Templates/iOS/Application"
    }

    struct Messages {
        static let successMessage = "✅ VIPER Module 🐍 Xcode Template was installed succesfully 🎉. Enjoy it 🙂"
        static let successfullReplaceMessage = "✅  The VIPER Module 🐍 Xcode Template has been replaced for you with the new version 🎉. Enjoy it 🙂"
        static let errorMessage = "❌  Ooops! Something went wrong 😡"
        static let exitMessage = "Bye Bye 👋"
        static let promptReplace = "The VIPER Module 🐍 Xcode Template already exists. Do you want to replace it? (YES or NO)"
        static let successViperaTemplateMessage = "✅ VIPERA 🐍 Template was installed succesfully 🎉. Enjoy it 🙂"
        static let successViperaMessage = "✅ VIPERA 🐍 was installed succesfully 🎉. Enjoy it 🙂"
    }

    struct Print {
        static let separator = "===================================="
    }
}

final class Utilities {
    static func askForReplacePermission() -> String {
        var input = ""
        repeat {
            guard let textFormCommandLine = readLine(strippingNewline: true) else {
                continue
            }
            input = textFormCommandLine.uppercased()
        } while (input != Constants.CommandLineValues.yes && input != Constants.CommandLineValues.no)
        return input
    }

    static func bash(command: String, arguments: [String]) -> String {
        let whichPathForCommand = Utilities.shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
        return Utilities.shell(launchPath: whichPathForCommand, arguments: arguments)
    }

    static func printToConsole(_ message: Any) {
        print(Constants.Print.separator)
        print("\(message)")
        print(Constants.Print.separator)
    }

    static func replaceItemAt(_ url: URL, withItemAt itemAtUrl: URL) throws {
        let fileManager = FileManager.default
        try fileManager.removeItem(at: url)
        try fileManager.copyItem(atPath: itemAtUrl.path, toPath: url.path)
    }

    static func shell(launchPath: String, arguments: [String]) -> String {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        if output.count > 0 {
            // remove newline character
            let lastIndex = output.index(before: output.endIndex)
            return String(output[output.startIndex ..< lastIndex])
        }
        return output
    }
}

func moveXcodeTemplate() {
    do {
        let fileManager = FileManager.default
        let destinationPath = Utilities.bash(command: "xcode-select", arguments: ["--print-path"]).appending(Constants.File.destinationRelativePath)
        Utilities.printToConsole("Template will be copied to: \(destinationPath)")

        if !fileManager.fileExists(atPath: "\(destinationPath)/\(Constants.File.templateName)") {
            try fileManager.copyItem(atPath: "\(Constants.File.xcodeTemplateDir)/\(Constants.File.templateName)", toPath: "\(destinationPath)/\(Constants.File.templateName)")
            Utilities.printToConsole(Constants.Messages.successMessage)
        } else {
            print(Constants.Messages.promptReplace)
            let input = Utilities.askForReplacePermission()

            if input == Constants.CommandLineValues.yes {
                try Utilities.replaceItemAt(URL(fileURLWithPath: "\(destinationPath)/\(Constants.File.templateName)"), withItemAt: URL(fileURLWithPath: "\(Constants.File.xcodeTemplateDir)/\(Constants.File.templateName)"))
                Utilities.printToConsole(Constants.Messages.successfullReplaceMessage)
            } else {
                print(Constants.Messages.exitMessage)
            }
        }
    } catch let error as NSError {
        Utilities.printToConsole("\(Constants.Messages.errorMessage) : \(error.localizedFailureReason!)")
    }
}

// MARK: - create work dir & default template

let homeDir = Dir()
let workDir = try homeDir.add(Constants.File.scriptName, isHidden: true)

func moveTemplate() {
    let templatesSource = Dir.current.child("Templates")
    do {
        try templatesSource.copy(to: workDir.child("Templates"), force: true)
        print(Constants.Messages.successViperaTemplateMessage)
    } catch {
        print(Constants.Messages.errorMessage)
    }
}

if installTemplates {
    moveTemplate()
}

if installXcodeTemplates {
    moveXcodeTemplate()
}

// MARK: - build & copy executable

let spm = SPM(path: ".")
try spm.run(.build, flags: [.config(.release)])
let buildPath = try spm.run(.build, flags: [.config(.release), .showBinaryPath])

let destination = Dir(path: "/usr/local/bin").child(Constants.File.scriptName)
let source = Dir(path: buildPath).child(Constants.File.scriptName)

try source.copy(to: destination, force: true)
try source.chmod(0o755)

print(Constants.Messages.successViperaMessage)

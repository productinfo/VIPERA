import Foundation
import Dir

guard CommandLine.arguments.count > 1 else {
    print("You have to to provide a module name as the first argument.")
    exit(-1)
}

let moduleName = CommandLine.arguments[1].capitalizedFirstLetter()
let scriptName = URL(fileURLWithPath: CommandLine.arguments.first!).lastPathComponent
var templateName = "Default"
if CommandLine.arguments.count > 2 {
    templateName = CommandLine.arguments[2]
}

let currentDir = Dir.current
let homeDir = Dir()
let workDir = homeDir.child(scriptName, isHidden: true)
let templatesDir = workDir.child("Templates")
let templateDir = templatesDir.child(templateName)

let userName = getGitUserName() ?? "VIPERA Generator"
let date = getFormattedDate()
let projectName = getProjectName(from: currentDir.url) ?? moduleName

let params = [
    "module": moduleName,
    "project": projectName,
    "author": userName,
    "date": date,
]

do {
    let moduleDir = try currentDir.add(moduleName)
    try createModuleComponent(from: templateDir.url, to: moduleDir.url)
}
catch {
    print(error.localizedDescription)
}

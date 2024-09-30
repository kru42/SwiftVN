import SwiftUI

class ScriptExecutor: ObservableObject {
    @Published var currentBackground: UIImage?
    @Published var currentText: String = ""
    @Published var choices: [String] = []
    
    private var script: [String] = []
    private var currentLine: Int = 0
    private var variables: [String: Any] = [:]
    private var globalVariables: [String: Any] = [:]
    private var labels: [String: Int] = [:]
    
    private let archiveManager: ArchiveManager = ArchiveManager(zipFileName: "script.zip")
    private let logger = LoggerFactory.shared
    
    func loadScript(named scriptName: String) {
        guard let scriptData = archiveManager.extractFile(named: scriptName) else {
            logger.critical("Failed to load script: \(scriptName)")
            fatalError()
        }
        
        guard let scriptContent = String(data: scriptData, encoding: .utf8) else {
            logger.critical("Failed to decode script data")
            fatalError()
        }
        
        script = scriptContent.components(separatedBy: .newlines)
        parseLabels()
    }
    
    private func parseLabels() {
        for (index, line) in script.enumerated() {
            if line.hasPrefix("label ") {
                let label = line.dropFirst(6).trimmingCharacters(in: .whitespaces)
                labels[label] = index
            }
        }
    }
    
    func executeNextLine() {
        guard currentLine < script.count else { return }
        
        let line = script[currentLine].trimmingCharacters(in: .whitespaces)
        let components = line.components(separatedBy: " ")
        
        switch components[0] {
        case "bgload":
            executeBgLoad(components)
        case "setimg":
            executeSetImg(components)
        case "sound":
            executeSound(components)
        case "music":
            executeMusic(components)
        case "text":
            executeText(components)
        case "choice":
            executeChoice(components)
        case "setvar":
            executeSetVar(components, isGlobal: false)
        case "gsetvar":
            executeSetVar(components, isGlobal: true)
        case "if":
            executeIf(components)
        case "fi":
            // Do nothing, just move to the next line
            break
        case "jump":
            executeJump(components)
        case "delay":
            executeDelay(components)
        case "random":
            executeRandom(components)
        case "label":
            // Labels are parsed at load time, so we can skip them during execution
            break
        case "goto":
            executeGoto(components)
        default:
            print("Unknown command: \(components[0])")
        }
        
        currentLine += 1
    }
    
    private func executeBgLoad(_ components: [String]) {
        
    }
    
    private func executeSetImg(_ components: [String]) {
        // Similar to bgload, but for foreground images
        // Implement based on your specific requirements
    }
    
    private func executeSound(_ components: [String]) {
        
    }
    
    private func executeMusic(_ components: [String]) {
        // Similar to sound, but for background music
        // You might want to use a different AVAudioPlayer instance for music
    }
    
    private func executeText(_ components: [String]) {
        let text = components.dropFirst().joined(separator: " ")
        let interpolatedText = interpolateText(text)
        currentText = interpolatedText
    }
    
    private func interpolateText(_ text: String) -> String {
        var result = text
        let pattern = #"\{([^}]+)\}"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        for match in matches.reversed() {
            let variableName = (text as NSString).substring(with: match.range(at: 1))
            if let value = variables[variableName] ?? globalVariables[variableName] {
                result = (result as NSString).replacingCharacters(in: match.range, with: "\(value)")
            }
        }
        
        return result
    }
    
    private func executeChoice(_ components: [String]) {
//        choices = components.dropFirst()
//        variables["selected"] = 0 // Will be updated when user makes a choice
    }
    
    private func executeSetVar(_ components: [String], isGlobal: Bool) {
        guard components.count >= 4 else { return }
        let varName = components[1]
        let operation = components[2]
        let value = components[3]
        
        var targetVariables = isGlobal ? globalVariables : variables
        
        switch operation {
        case "=":
            targetVariables[varName] = value
        case "+":
            if let currentValue = targetVariables[varName] as? Int, let addValue = Int(value) {
                targetVariables[varName] = currentValue + addValue
            }
        case "-":
            if let currentValue = targetVariables[varName] as? Int, let subtractValue = Int(value) {
                targetVariables[varName] = currentValue - subtractValue
            }
        default:
            print("Unknown operation: \(operation)")
        }
        
        if isGlobal {
            globalVariables = targetVariables
        } else {
            variables = targetVariables
        }
    }
    
    private func executeIf(_ components: [String]) {
        guard components.count >= 4 else { return }
        let varName = components[1]
        let operation = components[2]
        let value = components[3]
        
        let variableValue = (variables[varName] ?? globalVariables[varName]) as? String ?? ""
        
        let condition: Bool
        switch operation {
        case "==":
            condition = variableValue == value
        case "!=":
            condition = variableValue != value
        case ">":
            condition = (Int(variableValue) ?? 0) > (Int(value) ?? 0)
        case "<":
            condition = (Int(variableValue) ?? 0) < (Int(value) ?? 0)
        case ">=":
            condition = (Int(variableValue) ?? 0) >= (Int(value) ?? 0)
        case "<=":
            condition = (Int(variableValue) ?? 0) <= (Int(value) ?? 0)
        default:
            print("Unknown operation: \(operation)")
            condition = false
        }
        
        if !condition {
            // Skip to matching 'fi'
            var nestedIfCount = 0
            while currentLine < script.count {
                currentLine += 1
                let line = script[currentLine].trimmingCharacters(in: .whitespaces)
                if line.hasPrefix("if") {
                    nestedIfCount += 1
                } else if line == "fi" {
                    if nestedIfCount == 0 {
                        break
                    }
                    nestedIfCount -= 1
                }
            }
        }
    }
    
    private func executeJump(_ components: [String]) {
        guard components.count >= 2 else { return }
        let scriptName = components[1]
        loadScript(named: scriptName)
        currentLine = 0
        
        if components.count >= 4 && components[2] == ":" {
            executeGoto(["goto", components[3]])
        }
    }
    
    private func executeDelay(_ components: [String]) {
        guard components.count >= 2, let frames = Int(components[1]) else { return }
        let seconds = Double(frames) / 60.0
        // Stub: Implement actual delay
        print("Delaying for \(seconds) seconds")
    }
    
    private func executeRandom(_ components: [String]) {
        guard components.count >= 5 else { return }
        let varName = components[1]
        guard let min = Int(components[3]), let max = Int(components[4]) else { return }
        let randomValue = Int.random(in: min...max)
        variables[varName] = randomValue
    }
    
    private func executeGoto(_ components: [String]) {
        guard components.count >= 2 else { return }
        let label = components[1]
        if let lineNumber = labels[label] {
            currentLine = lineNumber
        } else {
            print("Label not found: \(label)")
        }
    }
}
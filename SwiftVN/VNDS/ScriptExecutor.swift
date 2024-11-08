//
//  ScriptExecutor.swift
//  SwiftVN
//
//  Created by Kru on 29/09/24.
//

//
// TODO
// - Interpolate in most instructions, even choices?
//

import SwiftUI
import SpriteKit

class ScriptExecutor: ObservableObject {
    private var script: [String] = []
    private var currentLine: Int = 0
    private var variables: [String: Any] = [:]
    private var globalVariables: [String: Any] = [:]
    private var labels: [String: Int] = [:]
    
    @Published var isLoadingMusic = false
    @Published var isWaitingForInput = true
    @Published var isWaitingForChoice = false
    
    var skip = false
    
    private let scene: NovelScene
    private let archiveManager: ArchiveManager = ArchiveManager(zipFileName: "script.zip")
    private let choiceManager: ChoiceManager
    private let logger = LoggerFactory.shared
    
    init(scene: NovelScene) {
        self.scene = scene
        self.choiceManager = ChoiceManager(scene: scene)
    }
    
    func loadScript(named scriptName: String) {
        archiveManager.extractFile(named: "script/\(scriptName)") { scriptData in
            if scriptData == nil {
                fatalError("Failed to extract script file")
            }
            
            guard let scriptContent = String(data: scriptData!, encoding: .utf8) else {
                self.logger.critical("Failed to decode script data")
                fatalError()
            }
            
            self.script = scriptContent.components(separatedBy: .newlines)
            self.parseLabels()
        }
    }
    
    private func parseLabels() {
        for (index, line) in script.enumerated() {
            if line.hasPrefix("label ") {
                let label = line.dropFirst(6).trimmingCharacters(in: .whitespaces)
                labels[label] = index
            }
        }
    }
    
    func next() {
        if isWaitingForChoice {
            // Do nothing, wait for choice selection
            return
        }
        
        if isWaitingForInput {
            isWaitingForInput = false
            currentLine += 1
            executeUntilStopped()
        } else {
            scene.textManager?.textNode.skipAnimation()
            isWaitingForInput = true
        }
    }
    
    func executeUntilStopped() {
        while currentLine < script.count {
            let line = script[currentLine - 1].trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                currentLine += 1
                continue
            }
            
            let components = line.components(separatedBy: " ")
            
            logger.debug("Executing command \(line)")

            switch components[0] {
            case "text":
                executeText(components)
                return
            case "cleartext":
                // Simulate `text ~`
                executeText(["text", "~"])
                return
            case "choice":
                executeChoice(components)
                currentLine += 1
                return
            case "bgload":
                executeBgLoad(components)
            case "setimg":
                executeSetImg(components)
            case "sound":
                executeSound(components)
            case "music":
                executeMusic(components)
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
    }
    
    private func toCgFloat(_ str: String) -> CGFloat {
        guard let result = (Double(str).map{ CGFloat($0) }) else {
            fatalError("Could not convert \(str) to CGFloat")
        }
        
        return result
    }
    
    private func executeBgLoad(_ components: [String]) {
        scene.textManager?.textNode.clearText()
        scene.spriteManager?.setBackground(path: components[1], withAnimationFrames: 60)
    }
    
    private func executeSetImg(_ components: [String]) {
        scene.spriteManager?.setForeground(fileName: components[1], x: toCgFloat(components[2]), y: toCgFloat(components[3]))
    }
    
    private func executeSound(_ components: [String]) {
        // TODO: components[2]
        // components.forEach { logger.debug("\($0)") }
        if components[1] == "~" {
            scene.audioManager.clearSound()
        } else {
            scene.audioManager.playSound(soundPath: components[1]) // TODO: , loop: components[2] == "-1")
        }
    }
    
    private func executeMusic(_ components: [String]) {
        // TODO: components[2]
        if components[1] == "~" {
            scene.audioManager.clearMusic()
        } else {
            //self.isLoadingMusic = true
            scene.audioManager.playMusic(songPath: components[1]) {
                //self.isLoadingMusic = false
            }
        }
    }
    
    private func executeText(_ components: [String]) {
        let text = components.dropFirst().joined(separator: " ")
        let interpolatedText = interpolateText(text)
        
        guard let textManager = scene.textManager else {
            logger.error("TextManager not initialized")
            return
        }
        
        if components[1] == "!" {
            textManager.clearText()
            self.isWaitingForInput = true
            return
        }
        
        if interpolatedText.starts(with: "@") {
            textManager.setText(String(interpolatedText.dropFirst())) { [weak self] in
                guard let self = self else { return }
                self.scene.historyOverlay.addHistoryLine(String(interpolatedText.dropFirst()))
                self.currentLine += 1
                self.executeUntilStopped()
            }
            
            return
        }

        textManager.setText(interpolatedText) { [weak self] in
            guard let self = self else { return }
            if interpolatedText == "~" {
                self.currentLine += 1
                self.executeUntilStopped()
            } else {
                self.scene.historyOverlay.addHistoryLine(interpolatedText)
                self.isWaitingForInput = true
            }
        }
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
        let choices = components.dropFirst().joined(separator: " ").components(separatedBy: "|")
        
        choiceManager.presentChoices(choices) { [weak self] selectedIndex in
            guard let self = self else { return }
            self.globalVariables["selected"] = selectedIndex
            self.isWaitingForChoice = false
            self.currentLine += 1
            self.executeUntilStopped()
        }
        
        isWaitingForChoice = true
    }
    
    func handleTap(at position: CGPoint) {
        if isWaitingForChoice && choiceManager.hasActiveChoices {
            let choiceHandled = choiceManager.handleTap(at: position)
            if choiceHandled {
                isWaitingForChoice = false
                return
            }
        }
        next()
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
        let comparisonValue = components[3]
        
        let variableValue = (variables[varName] ?? globalVariables[varName]) ?? 0 // else {
//            logger.warning("Variable \(varName) not found")
//        }
        
        let condition: Bool
        if let intVariableValue = variableValue as? Int, let intComparisonValue = Int(comparisonValue) {
            // Compare as integers if both are Ints
            condition = evaluateCondition(intVariableValue, operation: operation, value: intComparisonValue)
        } else if let strVariableValue = variableValue as? String {
            // Compare as strings if the variable is a String
            condition = evaluateCondition(strVariableValue, operation: operation, value: comparisonValue)
        } else {
            // Handle unsupported types
            logger.error("Unsupported variable type for \(varName)")
            fatalError()
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
    
    private func evaluateCondition<T: Comparable>(_ variableValue: T, operation: String, value: T) -> Bool {
        switch operation {
        case "==":
            return variableValue == value
        case "!=":
            return variableValue != value
        case ">":
            return variableValue > value
        case "<":
            return variableValue < value
        case ">=":
            return variableValue >= value
        case "<=":
            return variableValue <= value
        default:
            logger.error("Unknown operation: \(operation)")
            return false
        }
    }
    
    private func executeJump(_ components: [String]) {
        guard components.count >= 2 else { return }
        let scriptName = interpolateText(components[1])
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
        unistd.usleep(UInt32(seconds * 1_000_000))
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

//
//  Scriptswift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import Foundation

enum Opcode {
    case BgLoad, SetImg, Sound, Music, Delay, ClearText, Text, Choice, SetVar, GSetVar, If, Goto, Jump, Random, Label
}

typealias OperatorFunction = (Double, Double) -> Double

let operators: [String: OperatorFunction] = [
    "==": { (a, b) in a == b ? 1 : 0 },
    "!=": { (a, b) in a != b ? 1 : 0 },
    ">=": { (a, b) in a >= b ? 1 : 0 },
    "<=": { (a, b) in a <= b ? 1 : 0 },
    "<":  { (a, b) in a < b ? 1 : 0 },
    ">":  { (a, b) in a > b ? 1 : 0 },
    "+":  { (a, b) in a + b },
    "-":  { (a, b) in a - b },
    "=":  { _, _ in fatalError("Assignment operator not implemented") }, // Handle assignment separately
    "~":  { _, _ in return 0 },
    "if": { _, _ in return 1 },
    "fi": { _, _ in return -1 }
]

struct Instruction {
    var opcode: Opcode
    var label: String?
    var value: (literal: Int?, var: String?)
    var modifier: String?
    var text: String?
    var path: String?
    var choices: [String]?
    var low: Int?
    var high: Int?
}

struct Script {
    var locals: [String: Any] = [:]
    var globals: [String: Any] = [:]
}

class ScriptManager {
    var baseDir: String = "scripts"
    
    init() {
    }
    
    func find(fileName: String) -> String? {
        var files: [String]?
        
        guard let directoryUrl = Bundle.main.resourceURL?.appendingPathComponent(baseDir) else {
            print("Could not find script base directory")
            return nil
        }
        
        do {
            files = try FileManager.default.contentsOfDirectory(atPath: directoryUrl.path)
        } catch {
            print("Could not find script file \(fileName): \(error)")
            return nil
        }
        
        for scriptFile in files! {
            if scriptFile.lowercased() == fileName.lowercased() {
                return scriptFile
            }
        }
        
        return nil
    }

    func load(baseDir: String) {
        
    }
}

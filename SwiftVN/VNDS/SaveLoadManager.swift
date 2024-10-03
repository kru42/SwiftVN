import Foundation
import SWXMLHash

class SaveLoadManager {
    private let scriptExecutor: ScriptExecutor
    private let scene: NovelScene
    
    private let logger = LoggerFactory.shared
    
    init(scriptExecutor: ScriptExecutor, scene: NovelScene) {
        self.scriptExecutor = scriptExecutor
        self.scene = scene
    }
    
    func loadState(slot: Int) -> Bool {
        let path = "save/save\(String(format: "%02d", slot)).sav"
        guard FileManager.default.fileExists(atPath: path) else {
            print("Error loading savefile \"\(path)\". File not found.")
            return false
        }
        
        let xmlString = try? String(contentsOfFile: path)
        let xml = XMLHash.parse(xmlString ?? "")
        
        guard let rootElement = xml["save"].element else {
            print("Error parsing XML file.")
            return false
        }
        
        // Load variables
        if let variablesElement = xml["save"]["variables"].element {
            // loadVars(varsMap: &scriptExecutor.variables, varsElement: variablesElement)
        }
        
        // Load global variables
        if let globalVariablesElement = xml["save"]["globalVariables"].element {
            // loadVars(varsMap: &scriptExecutor.globalVariables, varsElement: globalVariablesElement)
        }
        
        // Load script state
        if let scriptName = xml["save"]["script"]["file"].element?.text,
           let position = xml["save"]["script"]["position"].element?.text,
           let lineNumber = Int(position) {
            scriptExecutor.loadScript(named: scriptName)
            scriptExecutor.currentLine = lineNumber
        }
        
        // Load game state
        if let stateElement = xml["save"]["state"].element {
            if let backgroundPath = xml["save"]["state"]["background"].element?.text {
                scene.spriteManager?.setBackground(path: backgroundPath, withAnimationFrames: 1)
            }
            
            let sprites = xml["save"]["state"]["sprites"]["sprite"].all
            for spriteElement in sprites {
                // TODO: Triple-check this
                let x = CGFloat(Double(spriteElement.value(ofAttribute: "x") ?? "0") ?? 0)
                let y = CGFloat(Double(spriteElement.value(ofAttribute: "y") ?? "0") ?? 0)
                do {
                    let path: String = try spriteElement.value<String>(ofAttribute: "path")
                    scene.spriteManager?.setForeground(fileName: path, x: x, y: y)
                } catch {
                    logger.error("Failed to load sprite: \(error)")
                    fatalError()
                }
            }
            
            if let musicPath = xml["save"]["state"]["music"].element?.text {
                scene.audioManager.playMusic(songPath: musicPath) {
                    
                }
            }
        }
        
        return true
    }
    
    func saveState(slot: Int) -> Bool {
        // let savePath = "save/save\(String(format: "%02d", slot)).sav"
        
        // First check if save directory exists - if not, create it
        if !FileManager.default.fileExists(atPath: SwiftVN.baseDirectory.appendingPathComponent("save").path()) {
            do {
                try FileManager.default.createDirectory(at: SwiftVN.baseDirectory.appendingPathComponent("save"), withIntermediateDirectories: true, attributes: nil)
            } catch {
                logger.error("Error creating save directory: \(error)")
                fatalError()
            }
        }
        
        let savePath = saveFileURL(slot)
        
        let currentScriptName = scriptExecutor.scriptName
        
        var xmlString = """
        <save>
            <script>
                <file>\(currentScriptName)</file>
                <position>\(scriptExecutor.currentLine)</position>
            </script>
            <date>\(currentDateString())</date>
        """
        
        // Variables
        xmlString += "<variables>"
        xmlString += saveVars(varsMap: scriptExecutor.variables)
        xmlString += "</variables>"
        
        // Global Variables
        xmlString += "<globalVariables>"
        xmlString += saveVars(varsMap: scriptExecutor.globalVariables)
        xmlString += "</globalVariables>"
        
        // Game State
        xmlString += "<state>"
        
        if let musicPath = scene.audioManager.currentMusicPath {
            xmlString += "<music>\(musicPath)</music>"
        }
        
        if let backgroundPath = scene.spriteManager?.backgroundPath{
            xmlString += "<background>\(backgroundPath)</background>"
        }
        
        xmlString += "<sprites>"
        if let currentSprites = scene.spriteManager?.spritePaths {
            for sprite in currentSprites {
                xmlString += """
                <sprite path="\(sprite.path)" x="\(sprite.x)" y="\(sprite.y)" />
                """
            }
        }
        xmlString += "</sprites>"
        xmlString += "</state>"
        xmlString += "</save>"
        
        do {
            try xmlString.write(to: savePath, atomically: true, encoding: .utf8)
            saveImage(slot: slot)
            return true
        } catch {
            print("Error saving game state: \(error.localizedDescription)")
            return false
        }
    }
    
    func saveFileURL(_ slot: Int) -> URL {
        return SwiftVN.baseDirectory.appendingPathComponent("save/save\(String(format: "%02d", slot)).sav")
    }
    
//    private func loadVars(varsMap: inout [String: Any], varsElement: XMLIndexer) {
//        for varElement in varsElement["var"].all {
//            guard let name = varElement.element?.attribute(by: "name")?.text,
//                  let type = varElement.element?.attribute(by: "type")?.text,
//                  let value = varElement.element?.attribute(by: "value")?.text else {
//                continue
//            }
//            
//            switch type {
//            case "int":
//                varsMap[name] = Int(value) ?? 0
//            case "string":
//                varsMap[name] = value
//            default:
//                print("Unable to load unknown type of variable: \"\(type)\"")
//            }
//        }
//    }
    
    private func saveVars(varsMap: [String: Any]) -> String {
        var varsString = ""
        for (name, variable) in varsMap {
            if let intValue = variable as? Int {
                varsString += "<var name=\"\(name)\" type=\"int\" value=\"\(intValue)\" />"
            } else if let stringValue = variable as? String {
                varsString += "<var name=\"\(name)\" type=\"string\" value=\"\(stringValue)\" />"
            } else {
                print("Unknown variable type for \(name)")
            }
        }
        return varsString
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm yyyy/MM/dd"
        return formatter.string(from: Date())
    }
    
    private func saveImage(slot: Int) {
        // Implement image saving logic here
        // This would involve capturing the current game screen and saving it as an image
        print("Saving image for slot \(slot) is not implemented in this example")
    }
}

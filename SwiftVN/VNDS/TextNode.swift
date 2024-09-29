//
//  TextNode.swift
//  SwiftVN
//
//  Created by Kru on 29/09/24.
//

import SpriteKit

class TextNode: SKNode {
    private var textLines: [String] = []
    private let maxLines: Int
    private let padding: CGFloat
    private let fontSize: CGFloat
    private var textFont: UIFont
    
    init(fontSize: CGFloat = 16, maxLines: Int = 3, padding: CGFloat = 20) {
        self.fontSize = fontSize
        self.maxLines = maxLines
        self.padding = padding
        
        let fontURL = SwiftVN.baseDirectory.appendingPathComponent("default.ttf")
        
        // Load novel custom font
        if let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
           let font = CGFont(fontDataProvider) {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
            self.textFont = UIFont(name: font.postScriptName as String? ?? "", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        } else {
            self.textFont = UIFont.systemFont(ofSize: fontSize)
        }
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addLineWithAnimation(_ line: String, delay: TimeInterval = 0.05) {
        textLines.append("") // Add an empty line first to prepare for animation
        if textLines.count > maxLines {
            textLines.removeFirst()
        }
        
        setNeedsDisplay() // Draw the initial state
        
        let lineIndex = textLines.count - 1
        let characters = Array(line)
        
        // Display each character one by one
        for (index, character) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) {
                self.textLines[lineIndex].append(character)
                self.setNeedsDisplay()
            }
        }
    }
    
    func setNeedsDisplay() {
        removeAllChildren()
        drawText()
    }
    
    private func drawText() {
        guard !textLines.isEmpty else { return }
        
        let lineHeight = textFont.lineHeight + padding
        let width = UIScreen.main.bounds.width - 2 * padding
        var wrappedLines: [String] = []
        
        // NOTE: Text lines that may contain Japanese characters
        for line in textLines {
            var currentLine = ""
            
            for character in line {
                let testLine = currentLine.isEmpty ? String(character) : "\(currentLine)\(character)"
                let testLineSize = (testLine as NSString).size(withAttributes: [NSAttributedString.Key.font: textFont])

                // If adding the character following the current character exceeds the width, start a new line
                if testLineSize.width + fontSize > width {
                    wrappedLines.append(currentLine)
                    currentLine = String(character) // Start a new line with the current character
                } else {
                    currentLine = testLine // Continue building the current line
                }
            }

            // Add any remaining text in currentLine to wrappedLines
            if !currentLine.isEmpty {
                wrappedLines.append(currentLine)
            }
        }
        
        // Clear existing children before drawing
        removeAllChildren()
        
        // Draw the wrapped lines
        let totalHeight = CGFloat(wrappedLines.count) * lineHeight + padding
        
        let background = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: totalHeight))
        background.fillColor = UIColor(red: 0.18, green: 0.204, blue: 0.251, alpha: 0.8)
        background.strokeColor = .clear
        addChild(background)
        
        // FIXME: Workaround, idk why the text has an offset
        let verticalOffset: CGFloat = 20
        
        for (index, line) in wrappedLines.enumerated() {
            let label = SKLabelNode(fontNamed: textFont.fontName)
            label.text = line
            label.fontSize = fontSize
            label.fontColor = .white
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .top
            label.position = CGPoint(x: padding, y: totalHeight - CGFloat(index + 1) * lineHeight + verticalOffset)
            addChild(label)
        }
        
        // Position the node at the bottom of the screen
        position = CGPoint(x: padding, y: padding)
    }
}

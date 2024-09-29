//
//  TextNode.swift
//  SwiftVN
//
//  Created by Kru on 29/09/24.
//

import SpriteKit

class TextNode: SKNode {
    private var fullLine: String = ""
    private var textLine: String = ""
    private let maxLines: Int
    private let padding: CGFloat
    private let fontSize: CGFloat
    private var textFont: UIFont
    
    private var background: SKShapeNode?
    private var labelNodes: [SKLabelNode] = []
    private var isAnimating: Bool = false
    
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
    
    func setTextWithAnimation(_ line: String, delay: TimeInterval = 0.05) -> Bool {
        self.fullLine = line
        
        // If currently animating, render all text instantly and return
        if isAnimating {
            drawTextInstantly(line)
            return false // Indicates instant render
        }
        
        let characters = Array(line)
        
        textLine = "" // Prepare for animation
        self.isAnimating = true
        
        // Timer to manage the character display
        var currentCharacterIndex = 0
        
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { timer in
            // Append the next character to the line
            if currentCharacterIndex < characters.count {
                self.textLine.append(characters[currentCharacterIndex])
                self.setNeedsDisplay()
                currentCharacterIndex += 1
            } else {
                timer.invalidate()
                self.isAnimating = false
            }
        }
        
        RunLoop.main.add(timer, forMode: .common)
        return true // Indicates animation started
    }
    
    func setNeedsDisplay() {
        removeAllChildren()
        drawText()
    }
    
    private func drawTextInstantly(_ line: String) {
        // Render all text instantly
        textLine = line
        setNeedsDisplay()
        
        isAnimating = false
    }
    
    private func drawText() {
        let lineHeight = textFont.lineHeight + padding
        let width = UIScreen.main.bounds.width - 2 * padding
        var wrappedLines: [String] = []
        
        // NOTE: Text lines that may contain Japanese characters
        var currentLine = ""
        
        for character in Array(textLine) {
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
        
        // Clear existing children before drawing if needed
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
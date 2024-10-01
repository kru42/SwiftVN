//
//  TextNode.swift
//  SwiftVN
//
//  Created by Kru on 29/09/24.
//

import SpriteKit

class TextNode: SKNode {
    private var textString: String = ""
    private var currentTextLine: String = ""
    private let maxLines: Int
    private var lines: [String] = []
    private var maxWidth: CGFloat = 0
    private let padding: CGFloat
    private let fontSize: CGFloat
    var textFont: UIFont
    
    private var background: SKShapeNode?
    private var labelNodes: [SKLabelNode] = []
    private var animationTimer: Timer?
    var isAnimating: Bool = false
    var isAnimationComplete: Bool = true
    
    private let logger = LoggerFactory.shared
    
    init(fontSize: CGFloat = 16, maxLines: Int = 3, padding: CGFloat = 20) {
        self.fontSize = fontSize
        self.maxLines = maxLines
        self.padding = padding
        
        logger.info("Loading font...")
        var fontURL = SwiftVN.baseDirectory.appendingPathComponent("default.ttf")
        if !FileManager.default.fileExists(atPath: fontURL.path) {
            logger.info("Falling back to sazanami-gothic.ttf")
            fontURL = Bundle.main.bundleURL.appendingPathComponent("sazanami-gothic.ttf")
        }
        
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
    
    func setCurrentLine(_ line: String, wrap: Bool = false) {
        currentTextLine = line
        
        if wrap {
            
        }
    }
    
    func addTextWithAnimation(_ line: String, wrap: Bool = false, delay: TimeInterval = 0.05, completion: @escaping () -> Void) {
        if line == "~" {
            clearText()
            completion()
            return
        }
        
        var currentCharacterIndex: Int
        
        // Concatenate new text with existing text
        if !textString.isEmpty {
            currentTextLine = textString
            textString = "\(textString)  \(line)"
            currentCharacterIndex = currentTextLine.count
        } else {
            currentTextLine = ""
            textString = line
            currentCharacterIndex = 0
        }
        
        self.isAnimating = true
        self.isAnimationComplete = false
        
        let characters = Array(textString)
        
        // Stop any existing animation
        stopAnimation()
        
        // Timer to manage the character display
        animationTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            
            // Append the next character to the line
            if currentCharacterIndex < characters.count {
                self.currentTextLine.append(characters[currentCharacterIndex])
                self.setNeedsDisplay()
                currentCharacterIndex += 1
            } else {
                self.stopAnimation()
                completion()
            }
        }
        
        RunLoop.main.add(animationTimer!, forMode: .common)
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        isAnimating = false
        isAnimationComplete = true
    }
    
    func skipAnimation() {
        stopAnimation()
        currentTextLine = textString
        setNeedsDisplay()
    }
    
    func setNeedsDisplay() {
        removeAllChildren()
        self.drawText()
    }
    
    func clearText() {
        self.textString = ""
    }
    
    private func drawText() {
        let lineHeight = textFont.lineHeight
        let width = UIScreen.main.bounds.width - 2 * padding
        var wrappedLines: [String] = []
        
        // Wrap text into lines
        var currentLine = ""
        for character in Array(currentTextLine) {
            let testLine = currentLine.isEmpty ? String(character) : "\(currentLine)\(character)"
            let testLineSize = (testLine as NSString).size(withAttributes: [NSAttributedString.Key.font: textFont])
            
            if testLineSize.width > width - 2 * padding {
                wrappedLines.append(currentLine)
                currentLine = String(character)
            } else {
                currentLine = testLine
            }
        }
        if !currentLine.isEmpty {
            wrappedLines.append(currentLine)
        }
        
        // Calculate total height and create background
        let totalHeight = CGFloat(wrappedLines.count) * lineHeight + 2 * padding
        let cornerRadius: CGFloat = 8.0
        let backgroundRect = CGRect(x: 0, y: 0, width: width, height: totalHeight)
        let backgroundPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: cornerRadius)
        
        let background = SKShapeNode(path: backgroundPath.cgPath)
        background.fillColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.8)
        background.strokeColor = .clear
        addChild(background)
        
        // Create and position text labels
        let centerY = totalHeight / 2
        let startY = centerY + (CGFloat(wrappedLines.count - 1) / 2) * lineHeight
        
        for (index, line) in wrappedLines.enumerated() {
            let label = SKLabelNode(fontNamed: textFont.fontName)
            label.text = line
            label.fontSize = fontSize
            label.fontColor = .white
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .center
            
            let labelY = startY - CGFloat(index) * lineHeight
            label.position = CGPoint(x: padding, y: labelY)
            
            addChild(label)
        }
        
        // Position the entire node at the bottom center of the screen
        position = CGPoint(x: padding, y: padding)
    }
}


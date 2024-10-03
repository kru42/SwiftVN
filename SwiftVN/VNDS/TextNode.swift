//
//  TextNode.swift
//  SwiftVN
//
//  Created by Kru on 29/09/24.
//

import SpriteKit

// Extension to help find the range of a word
extension String {
    func rangeOfWord(at index: String.Index) -> Range<String.Index>? {
        // Check if the character at the index is a whitespace
        guard !self[index].isWhitespace else { return nil }
        
        // Find the start of the word
        let start = self[..<index].lastIndex(where: { $0.isWhitespace }) ?? self.startIndex
        let wordStart = self.index(after: start)
        
        // Find the end of the word
        let end = self[index...].firstIndex(where: { $0.isWhitespace }) ?? self.endIndex
        
        return wordStart..<end
    }
}

class TextNode: SKNode {
    private var textString: String = ""
    private var currentTextLine: String = ""
    private let maxLines: Int
    private let padding: CGFloat
    private let fontSize: CGFloat
    private let lineHeightMultiplier: CGFloat = 1.5
    var textFont: UIFont
    
    private var background: SKShapeNode?
    private var labelNodes: [SKLabelNode] = []
    private var animationTimer: Timer?
    private var currentCharacterIndex: Int = 0
    var isAnimating: Bool = false
    var isAnimationComplete: Bool = true
    
    private let logger = LoggerFactory.shared
    
    init(fontSize: CGFloat = 16, maxLines: Int = 3, padding: CGFloat = 20) {
        self.fontSize = fontSize
        self.maxLines = maxLines
        self.padding = padding
        
        for familyName in UIFont.familyNames {
            print("Family: \(familyName)")
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print("    Font: \(fontName)")
            }
        }
        
        // Great Japanese typeface from Apple, let's just use this for the time being
        // TODO: Can I fall back to it just for Japanese characters? Not sure, noob
        self.textFont = UIFont(name: "HiraginoSans-W4", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        logger.info("FontName: \(self.textFont.fontName)")

//        logger.info("Loading font...")
//        var fontURL = SwiftVN.baseDirectory.appendingPathComponent("default.ttf")
//        if !FileManager.default.fileExists(atPath: fontURL.path) {
//            logger.info("Falling back to sazanami-gothic.ttf")
//            fontURL = Bundle.main.bundleURL.appendingPathComponent("sazanami-gothic.ttf")
//        }
//        
//        // Load novel custom font
//        if let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
//           let font = CGFont(fontDataProvider) {
//            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
//            self.textFont = UIFont(name: font.postScriptName as String? ?? "", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
//        } else {
//            self.textFont = UIFont.systemFont(ofSize: fontSize)
//        }
//        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCurrentLine(_ line: String) {
        currentTextLine = line
        setNeedsDisplay()
    }
    
    func addTextWithAnimation(_ line: String, delay: TimeInterval = 0.05, completion: @escaping () -> Void) {
        if line == "~" {
            clearText()
            completion()
            return
        }
        
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
        let lineHeight = textFont.lineHeight * lineHeightMultiplier
        let width = UIScreen.main.bounds.width - 2 * padding
        var wrappedLines: [String] = []

        // Wrap text into lines
        var currentLine = ""
        let characters = Array(currentTextLine)
        var i = 0
        
        while i < characters.count {
            let character = String(characters[i])
            let testLine = currentLine + character
            let testLineSize = (testLine as NSString).size(withAttributes: [NSAttributedString.Key.font: textFont])

            // Test if text width is within boundaries - if not so, wrap.
            // Also always wrap if last word is too short
            if testLineSize.width <= width - 2 * padding {
                currentLine += character
                i += 1
            } else {
                if !currentLine.isEmpty {
                    // Check for Japanese line break rules
                    if isJapaneseCharacter(character) {
                        let (breakPoint, shouldAddCurrentChar) = findJapaneseLineBreak(currentLine: currentLine, nextChar: character)
                        wrappedLines.append(String(currentLine[..<breakPoint]))
                        currentLine = String(currentLine[breakPoint...])
                        if shouldAddCurrentChar {
                            currentLine += character
                            i += 1
                        }
                    } else {
                        // Wrap non-Japanese text
                        let currentWord = wordAtCharacterIndex(index: i)
                        let testWordSize = ((currentWord ?? "") as NSString).size(withAttributes: [NSAttributedString.Key.font: textFont])
                        
                         let lineSize = (currentLine as NSString).size(withAttributes: [NSAttributedString.Key.font: textFont])
                        
//                        if let word = currentWord, word.count < 7 && lineSize.width + testWordSize.width > width - 2 * padding {
//                            logger.debug("newline at \(word)")
//                            logger.debug("current character at \(i)")
//                            wrappedLines.append(currentLine)
//                            currentLine = character
//                            continue
//                        }
                        
//                         If the current word is shorter than 7 characters and doesn't fit, wrap without hyphen
//                        if currentWord?.count ?? 7 < 7 && lineSize.width + testWordSize.width > width - 2 * padding {
//                            logger.debug("wrapping word \(currentWord ?? "")")
//                            wrappedLines.append(currentLine)
//                            currentLine = ""
                        if shouldAddHyphen(currentLine: currentLine, nextChar: character) {
                            currentLine += "—"
                        } else {
                            wrappedLines.append(currentLine)
                            currentLine = ""
                        }
                    }
                } else {
                    // If the current line is empty but the character is still too wide,
                    // we need to force-break it (this should be rare)
                    wrappedLines.append(character)
                    i += 1
                }
            }
        }
        
        if !currentLine.isEmpty {
            wrappedLines.append(currentLine)
        }
        
        // Calculate total height and create background
        let totalHeight = CGFloat(wrappedLines.count) * lineHeight + padding
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
    
    func wordAtCharacterIndex(index: Int) -> String? {
        let text = self.textString
        guard index >= 0 && index < text.count else { return nil }
        
        let stringIndex = text.index(text.startIndex, offsetBy: index)
        
        // Find the start of the word
        let wordStart = text[..<stringIndex].lastIndex(where: { !$0.isLetter }) ?? text.startIndex
        let actualWordStart = text.index(after: wordStart)
        
        // Find the end of the word
        let wordEnd = text[stringIndex...].firstIndex(where: { !$0.isLetter }) ?? text.endIndex
        
        return String(text[actualWordStart..<wordEnd])
    }
    
    private func isJapaneseCharacter(_ char: String) -> Bool {
        let japaneseRanges = [
            0x3000...0x303f,  // Japanese-style punctuation
            0x3040...0x309f,  // Hiragana
            0x30a0...0x30ff,  // Katakana
            0x4e00...0x9faf,  // CJK Unified Ideographs (Common and Uncommon Kanji)
            0xff00...0xffef   // Full-width Roman characters and half-width Katakana
        ]
        
        guard let unicodeScalar = char.unicodeScalars.first else { return false }
        return japaneseRanges.contains { $0.contains(Int(unicodeScalar.value)) }
    }
    
    // Enforce Kinsoku rules
    // TODO: https://en.wikipedia.org/wiki/Line_breaking_rules_in_East_Asian_languages
    private func findJapaneseLineBreak(currentLine: String, nextChar: String) -> (String.Index, Bool) {
        let forbiddenStart = "、。，．）」』】,.)]}"
        let forbiddenEnd = "（「『【([{"
        
        var breakPoint = currentLine.endIndex
        var shouldAddCurrentChar = false
        
        // Check if we can break at the current position
        if forbiddenStart.contains(nextChar) {
            // If the next character can't start a line, include it in the current line
            shouldAddCurrentChar = true
        } else if let lastChar = currentLine.last, forbiddenEnd.contains(String(lastChar)) {
            // If the last character of the current line can't end a line, move the break point back
            breakPoint = currentLine.index(before: breakPoint)
        }
        
        return (breakPoint, shouldAddCurrentChar)
    }
    
    private func shouldAddHyphen(currentLine: String, nextChar: String) -> Bool {
        // Check if the current line ends with a partial English word
        let englishWordPattern = "[a-zA-Z]+"
        if let range = currentLine.range(of: englishWordPattern, options: .regularExpression, range: currentLine.index(currentLine.endIndex, offsetBy: -1)..<currentLine.endIndex),
           range.upperBound == currentLine.endIndex,
           nextChar.range(of: englishWordPattern, options: .regularExpression) != nil {
            return true
        }
        
        return false
    }
}


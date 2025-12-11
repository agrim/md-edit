import Foundation
import SwiftUI

/// Utility for rendering Markdown to AttributedString and HTML.
/// Uses native Apple frameworks only - no third-party dependencies.
struct MarkdownRenderer {
    
    // MARK: - Platform-specific colors
    
    #if os(macOS)
    private static var codeBackgroundColor: Color {
        Color(nsColor: NSColor.quaternaryLabelColor.withAlphaComponent(0.1))
    }
    private static var quoteColor: Color {
        Color(nsColor: NSColor.secondaryLabelColor)
    }
    #else
    private static var codeBackgroundColor: Color {
        Color(uiColor: UIColor.secondarySystemFill)
    }
    private static var quoteColor: Color {
        Color(uiColor: UIColor.secondaryLabel)
    }
    #endif
    
    // MARK: - Markdown to AttributedString
    
    /// Renders Markdown text to an AttributedString for display
    /// - Parameter text: The Markdown source text
    /// - Returns: An AttributedString with Markdown formatting applied
    static func renderMarkdown(_ text: String) -> AttributedString {
        var result = AttributedString()
        let lines = text.components(separatedBy: "\n")
        var inCodeBlock = false
        var codeBlockContent = ""
        
        for (index, line) in lines.enumerated() {
            // Handle fenced code blocks
            if line.hasPrefix("```") {
                if inCodeBlock {
                    // End of code block
                    var codeAttr = AttributedString(codeBlockContent)
                    codeAttr.font = .system(size: 13, design: .monospaced)
                    codeAttr.backgroundColor = codeBackgroundColor
                    result.append(codeAttr)
                    codeBlockContent = ""
                    inCodeBlock = false
                } else {
                    // Start of code block
                    inCodeBlock = true
                }
                if index < lines.count - 1 {
                    result.append(AttributedString("\n"))
                }
                continue
            }
            
            if inCodeBlock {
                codeBlockContent += line + "\n"
                continue
            }
            
            // Parse the line and append to result
            let parsedLine = parseLine(line)
            result.append(parsedLine)
            
            // Add newline between lines (except for the last line)
            if index < lines.count - 1 {
                result.append(AttributedString("\n"))
            }
        }
        
        return result
    }
    
    /// Parses a single line of markdown and returns an AttributedString
    private static func parseLine(_ line: String) -> AttributedString {
        // Check for headers
        if line.hasPrefix("######") {
            return parseHeader(line, prefix: "######", fontSize: 14, weight: .medium)
        } else if line.hasPrefix("#####") {
            return parseHeader(line, prefix: "#####", fontSize: 15, weight: .medium)
        } else if line.hasPrefix("####") {
            return parseHeader(line, prefix: "####", fontSize: 16, weight: .semibold)
        } else if line.hasPrefix("###") {
            return parseHeader(line, prefix: "###", fontSize: 18, weight: .semibold)
        } else if line.hasPrefix("##") {
            return parseHeader(line, prefix: "##", fontSize: 22, weight: .bold)
        } else if line.hasPrefix("#") {
            return parseHeader(line, prefix: "#", fontSize: 28, weight: .bold)
        }
        
        // Check for blockquote
        if line.hasPrefix(">") {
            var content = String(line.dropFirst())
            if content.hasPrefix(" ") {
                content = String(content.dropFirst())
            }
            var attr = parseInlineFormatting(content)
            attr.foregroundColor = quoteColor
            
            // Add quote indicator
            var quoteIndicator = AttributedString("│ ")
            quoteIndicator.foregroundColor = quoteColor
            return quoteIndicator + attr
        }
        
        // Check for unordered list
        if line.hasPrefix("- ") || line.hasPrefix("* ") {
            let content = String(line.dropFirst(2))
            var bullet = AttributedString("• ")
            bullet.font = Font(regularFont())
            let parsedContent = parseInlineFormatting(content)
            return bullet + parsedContent
        }
        
        // Check for ordered list
        if let match = line.range(of: "^\\d+\\. ", options: .regularExpression) {
            let number = String(line[match])
            let content = String(line[match.upperBound...])
            var numberAttr = AttributedString(number)
            numberAttr.font = Font(regularFont())
            let parsedContent = parseInlineFormatting(content)
            return numberAttr + parsedContent
        }
        
        // Check for checkbox list
        if line.hasPrefix("- [ ] ") {
            let content = String(line.dropFirst(6))
            var checkbox = AttributedString("☐ ")
            checkbox.font = Font(regularFont())
            let parsedContent = parseInlineFormatting(content)
            return checkbox + parsedContent
        }
        if line.hasPrefix("- [x] ") || line.hasPrefix("- [X] ") {
            let content = String(line.dropFirst(6))
            var checkbox = AttributedString("☑ ")
            checkbox.font = Font(regularFont())
            let parsedContent = parseInlineFormatting(content)
            return checkbox + parsedContent
        }
        
        // Check for horizontal rule
        if line.trimmingCharacters(in: .whitespaces).range(of: "^(-{3,}|\\*{3,}|_{3,})$", options: .regularExpression) != nil {
            var hr = AttributedString("───────────────────────────")
            hr.foregroundColor = .secondary
            return hr
        }
        
        // Regular paragraph - parse inline formatting
        return parseInlineFormatting(line)
    }
    
    /// Parses a header line
    private static func parseHeader(_ line: String, prefix: String, fontSize: CGFloat, weight: Font.Weight) -> AttributedString {
        var content = String(line.dropFirst(prefix.count))
        if content.hasPrefix(" ") {
            content = String(content.dropFirst())
        }
        var attr = parseInlineFormatting(content)
        attr.font = .system(size: fontSize, weight: weight)
        return attr
    }
    
    // MARK: - Platform-specific fonts
    
    #if os(macOS)
    private static func boldFont(size: CGFloat = 15) -> NSFont {
        return NSFont.boldSystemFont(ofSize: size)
    }
    
    private static func italicFont(size: CGFloat = 15) -> NSFont {
        let systemFont = NSFont.systemFont(ofSize: size)
        return NSFontManager.shared.convert(systemFont, toHaveTrait: .italicFontMask)
    }
    
    private static func boldItalicFont(size: CGFloat = 15) -> NSFont {
        let boldFont = NSFont.boldSystemFont(ofSize: size)
        return NSFontManager.shared.convert(boldFont, toHaveTrait: .italicFontMask)
    }
    
    private static func regularFont(size: CGFloat = 15) -> NSFont {
        return NSFont.systemFont(ofSize: size)
    }
    
    private static func monoFont(size: CGFloat = 13) -> NSFont {
        return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }
    #else
    private static func boldFont(size: CGFloat = 17) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size)
    }
    
    private static func italicFont(size: CGFloat = 17) -> UIFont {
        return UIFont.italicSystemFont(ofSize: size)
    }
    
    private static func boldItalicFont(size: CGFloat = 17) -> UIFont {
        guard let descriptor = UIFont.systemFont(ofSize: size).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) else {
            return UIFont.boldSystemFont(ofSize: size)
        }
        return UIFont(descriptor: descriptor, size: size)
    }
    
    private static func regularFont(size: CGFloat = 17) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
    
    private static func monoFont(size: CGFloat = 15) -> UIFont {
        return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }
    #endif
    
    /// Parses inline formatting (bold, italic, code, links)
    private static func parseInlineFormatting(_ text: String, isBold: Bool = false, isItalic: Bool = false) -> AttributedString {
        var result = AttributedString()
        var currentIndex = text.startIndex
        
        while currentIndex < text.endIndex {
            // Check for inline code first (highest priority for escaping)
            if text[currentIndex] == "`" {
                if let endIndex = text[text.index(after: currentIndex)...].firstIndex(of: "`") {
                    let codeStart = text.index(after: currentIndex)
                    let codeContent = String(text[codeStart..<endIndex])
                    var codeAttr = AttributedString(codeContent)
                    #if os(macOS)
                    codeAttr.font = Font(monoFont())
                    #else
                    codeAttr.font = Font(monoFont())
                    #endif
                    codeAttr.backgroundColor = codeBackgroundColor
                    result.append(codeAttr)
                    currentIndex = text.index(after: endIndex)
                    continue
                }
            }
            
            // Check for bold (**text** or __text__)
            if text[currentIndex] == "*" || text[currentIndex] == "_" {
                let marker = text[currentIndex]
                let nextIndex = text.index(after: currentIndex)
                
                if nextIndex < text.endIndex && text[nextIndex] == marker {
                    // Potential bold
                    let contentStart = text.index(after: nextIndex)
                    if contentStart < text.endIndex, let endRange = findClosingMarker(in: text, from: contentStart, marker: String(repeating: String(marker), count: 2)) {
                        let boldContent = String(text[contentStart..<endRange.lowerBound])
                        let boldAttr = parseInlineFormatting(boldContent, isBold: true, isItalic: isItalic)
                        result.append(boldAttr)
                        currentIndex = endRange.upperBound
                        continue
                    }
                } else if nextIndex < text.endIndex {
                    // Potential italic
                    let contentStart = nextIndex
                    if let endRange = findClosingMarker(in: text, from: contentStart, marker: String(marker)) {
                        let italicContent = String(text[contentStart..<endRange.lowerBound])
                        let italicAttr = parseInlineFormatting(italicContent, isBold: isBold, isItalic: true)
                        result.append(italicAttr)
                        currentIndex = endRange.upperBound
                        continue
                    }
                }
            }
            
            // Check for links [text](url)
            if text[currentIndex] == "[" {
                if let linkResult = parseLink(in: text, from: currentIndex) {
                    result.append(linkResult.attributedString)
                    currentIndex = linkResult.endIndex
                    continue
                }
            }
            
            // Regular character - apply accumulated styles
            var charAttr = AttributedString(String(text[currentIndex]))
            #if os(macOS)
            if isBold && isItalic {
                charAttr.font = Font(boldItalicFont())
            } else if isBold {
                charAttr.font = Font(boldFont())
            } else if isItalic {
                charAttr.font = Font(italicFont())
            } else {
                charAttr.font = Font(regularFont())
            }
            #else
            if isBold && isItalic {
                charAttr.font = Font(boldItalicFont())
            } else if isBold {
                charAttr.font = Font(boldFont())
            } else if isItalic {
                charAttr.font = Font(italicFont())
            } else {
                charAttr.font = Font(regularFont())
            }
            #endif
            result.append(charAttr)
            currentIndex = text.index(after: currentIndex)
        }
        
        return result
    }
    
    /// Finds a closing marker in the text
    private static func findClosingMarker(in text: String, from startIndex: String.Index, marker: String) -> Range<String.Index>? {
        guard startIndex < text.endIndex else { return nil }
        
        var searchIndex = startIndex
        while searchIndex < text.endIndex {
            if let range = text.range(of: marker, range: searchIndex..<text.endIndex) {
                // Make sure it's not at the very start (empty content)
                if range.lowerBound > startIndex {
                    return range
                }
                searchIndex = text.index(after: range.lowerBound)
            } else {
                return nil
            }
        }
        return nil
    }
    
    /// Parses a markdown link and returns the attributed string and end index
    private static func parseLink(in text: String, from startIndex: String.Index) -> (attributedString: AttributedString, endIndex: String.Index)? {
        guard text[startIndex] == "[" else { return nil }
        
        let afterBracket = text.index(after: startIndex)
        guard let closeBracket = text[afterBracket...].firstIndex(of: "]") else { return nil }
        
        let linkText = String(text[afterBracket..<closeBracket])
        
        let afterCloseBracket = text.index(after: closeBracket)
        guard afterCloseBracket < text.endIndex, text[afterCloseBracket] == "(" else { return nil }
        
        let afterParen = text.index(after: afterCloseBracket)
        guard let closeParen = text[afterParen...].firstIndex(of: ")") else { return nil }
        
        let urlString = String(text[afterParen..<closeParen])
        
        var linkAttr = AttributedString(linkText)
        linkAttr.foregroundColor = .blue
        linkAttr.underlineStyle = .single
        if let url = URL(string: urlString) {
            linkAttr.link = url
        }
        
        return (linkAttr, text.index(after: closeParen))
    }
    
    // MARK: - Markdown to HTML
    
    /// Converts Markdown text to HTML string
    /// - Parameter text: The Markdown source text
    /// - Returns: An HTML string representation
    static func htmlFromMarkdown(_ text: String) -> String {
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                    line-height: 1.6;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 20px;
                    color: #333;
                }
                @media (prefers-color-scheme: dark) {
                    body { background-color: #1a1a1a; color: #e0e0e0; }
                    a { color: #6db3f2; }
                    code { background-color: #2d2d2d; }
                    pre { background-color: #2d2d2d; }
                    blockquote { border-left-color: #555; color: #aaa; }
                }
                h1, h2, h3, h4, h5, h6 { margin-top: 1.5em; margin-bottom: 0.5em; }
                h1 { font-size: 2em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
                h2 { font-size: 1.5em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
                code {
                    font-family: 'SF Mono', Menlo, Monaco, Consolas, monospace;
                    background-color: #f6f8fa;
                    padding: 0.2em 0.4em;
                    border-radius: 3px;
                    font-size: 0.9em;
                }
                pre {
                    background-color: #f6f8fa;
                    padding: 16px;
                    border-radius: 6px;
                    overflow-x: auto;
                }
                pre code { background: none; padding: 0; }
                blockquote {
                    margin: 0;
                    padding-left: 1em;
                    border-left: 4px solid #ddd;
                    color: #666;
                }
                ul, ol { padding-left: 2em; }
                li { margin: 0.25em 0; }
                a { color: #0366d6; text-decoration: none; }
                a:hover { text-decoration: underline; }
                img { max-width: 100%; height: auto; }
                table { border-collapse: collapse; width: 100%; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #f6f8fa; }
            </style>
        </head>
        <body>
        """
        
        // Convert Markdown to HTML using simple regex-based conversion
        var body = text
        
        // Escape HTML entities first
        body = body.replacingOccurrences(of: "&", with: "&amp;")
        body = body.replacingOccurrences(of: "<", with: "&lt;")
        body = body.replacingOccurrences(of: ">", with: "&gt;")
        
        // Convert Markdown syntax to HTML
        body = convertMarkdownToHTML(body)
        
        html += body
        html += """
        
        </body>
        </html>
        """
        
        return html
    }
    
    /// Converts Markdown syntax to HTML
    private static func convertMarkdownToHTML(_ text: String) -> String {
        var result = text
        
        // Code blocks (must be done before other processing)
        result = convertCodeBlocks(result)
        
        // Headers
        result = result.replacingOccurrences(
            of: "(?m)^###### (.+)$",
            with: "<h6>$1</h6>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: "(?m)^##### (.+)$",
            with: "<h5>$1</h5>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: "(?m)^#### (.+)$",
            with: "<h4>$1</h4>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: "(?m)^### (.+)$",
            with: "<h3>$1</h3>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: "(?m)^## (.+)$",
            with: "<h2>$1</h2>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: "(?m)^# (.+)$",
            with: "<h1>$1</h1>",
            options: .regularExpression
        )
        
        // Bold
        result = result.replacingOccurrences(
            of: "\\*\\*(.+?)\\*\\*",
            with: "<strong>$1</strong>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: "__(.+?)__",
            with: "<strong>$1</strong>",
            options: .regularExpression
        )
        
        // Italic
        result = result.replacingOccurrences(
            of: "\\*(.+?)\\*",
            with: "<em>$1</em>",
            options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: "_(.+?)_",
            with: "<em>$1</em>",
            options: .regularExpression
        )
        
        // Inline code
        result = result.replacingOccurrences(
            of: "`([^`]+)`",
            with: "<code>$1</code>",
            options: .regularExpression
        )
        
        // Blockquotes
        result = result.replacingOccurrences(
            of: "(?m)^&gt; (.+)$",
            with: "<blockquote>$1</blockquote>",
            options: .regularExpression
        )
        
        // Unordered lists
        result = convertUnorderedLists(result)
        
        // Ordered lists
        result = convertOrderedLists(result)
        
        // Links
        result = result.replacingOccurrences(
            of: "\\[([^\\]]+)\\]\\(([^)]+)\\)",
            with: "<a href=\"$2\">$1</a>",
            options: .regularExpression
        )
        
        // Horizontal rules
        result = result.replacingOccurrences(
            of: "(?m)^(-{3,}|\\*{3,}|_{3,})$",
            with: "<hr>",
            options: .regularExpression
        )
        
        // Paragraphs - wrap remaining text blocks
        result = wrapParagraphs(result)
        
        return result
    }
    
    /// Converts fenced code blocks to HTML
    private static func convertCodeBlocks(_ text: String) -> String {
        var result = text
        
        // Fenced code blocks with language
        let codeBlockPattern = "```(\\w*)\\n([\\s\\S]*?)```"
        if let regex = try? NSRegularExpression(pattern: codeBlockPattern, options: []) {
            let range = NSRange(text.startIndex..., in: text)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: range,
                withTemplate: "<pre><code class=\"language-$1\">$2</code></pre>"
            )
        }
        
        return result
    }
    
    /// Converts Markdown unordered lists to HTML
    private static func convertUnorderedLists(_ text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        var result: [String] = []
        var inList = false
        
        for line in lines {
            if line.hasPrefix("- ") || line.hasPrefix("* ") {
                if !inList {
                    result.append("<ul>")
                    inList = true
                }
                let content = String(line.dropFirst(2))
                result.append("<li>\(content)</li>")
            } else {
                if inList {
                    result.append("</ul>")
                    inList = false
                }
                result.append(line)
            }
        }
        
        if inList {
            result.append("</ul>")
        }
        
        return result.joined(separator: "\n")
    }
    
    /// Converts Markdown ordered lists to HTML
    private static func convertOrderedLists(_ text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        var result: [String] = []
        var inList = false
        
        let orderedListPattern = "^\\d+\\. "
        
        for line in lines {
            if let range = line.range(of: orderedListPattern, options: .regularExpression) {
                if !inList {
                    result.append("<ol>")
                    inList = true
                }
                let content = String(line[range.upperBound...])
                result.append("<li>\(content)</li>")
            } else {
                if inList {
                    result.append("</ol>")
                    inList = false
                }
                result.append(line)
            }
        }
        
        if inList {
            result.append("</ol>")
        }
        
        return result.joined(separator: "\n")
    }
    
    /// Wraps loose text in paragraph tags
    private static func wrapParagraphs(_ text: String) -> String {
        let lines = text.components(separatedBy: "\n")
        var result: [String] = []
        var paragraphBuffer: [String] = []
        
        let blockElements = ["<h1>", "<h2>", "<h3>", "<h4>", "<h5>", "<h6>",
                            "<ul>", "</ul>", "<ol>", "</ol>", "<li>",
                            "<pre>", "</pre>", "<blockquote>", "<hr>"]
        
        func flushParagraph() {
            if !paragraphBuffer.isEmpty {
                let content = paragraphBuffer.joined(separator: " ").trimmingCharacters(in: .whitespaces)
                if !content.isEmpty {
                    result.append("<p>\(content)</p>")
                }
                paragraphBuffer.removeAll()
            }
        }
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty {
                flushParagraph()
                continue
            }
            
            let isBlock = blockElements.contains { trimmed.hasPrefix($0) }
            
            if isBlock {
                flushParagraph()
                result.append(line)
            } else {
                paragraphBuffer.append(trimmed)
            }
        }
        
        flushParagraph()
        
        return result.joined(separator: "\n")
    }
}

// MARK: - Preview Helpers

extension MarkdownRenderer {
    /// Sample Markdown for testing
    static let sampleMarkdown = """
    # Welcome to MD Edit
    
    This is a **sample document** to demonstrate the editor.
    
    ## Features
    
    - Create and edit Markdown
    - Preview rendered content
    - Sync across devices via iCloud
    
    ### Code Example
    
    ```swift
    print("Hello, MD Edit!")
    ```
    
    > MD Edit focuses on simplicity and speed.
    """
}

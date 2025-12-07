import Foundation
import SwiftUI

/// Utility for rendering Markdown to AttributedString and HTML.
/// Uses native Apple frameworks only - no third-party dependencies.
struct MarkdownRenderer {
    
    // MARK: - Markdown to AttributedString
    
    /// Renders Markdown text to an AttributedString for display
    /// - Parameter text: The Markdown source text
    /// - Returns: An AttributedString with Markdown formatting applied
    static func renderMarkdown(_ text: String) -> AttributedString {
        do {
            var options = AttributedString.MarkdownParsingOptions()
            options.interpretedSyntax = .inlineOnlyPreservingWhitespace
            
            // First try with full markdown parsing
            let fullOptions = AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            )
            
            var attributed = try AttributedString(markdown: text, options: fullOptions)
            
            // Apply custom styling for better visual appearance
            attributed = applyCustomStyling(to: attributed)
            
            return attributed
        } catch {
            // If parsing fails, return plain text
            return AttributedString(text)
        }
    }
    
    /// Applies custom styling to enhance the rendered Markdown
    private static func applyCustomStyling(to attributedString: AttributedString) -> AttributedString {
        // The AttributedString from Markdown already has proper formatting
        // We can enhance specific elements if needed
        return attributedString
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

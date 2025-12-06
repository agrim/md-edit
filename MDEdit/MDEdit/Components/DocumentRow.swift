import SwiftUI

/// Single document row for display in the document list.
/// Shows title, preview snippet, and metadata.
struct DocumentRow: View {
    let document: Document
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title with pin indicator
            HStack(spacing: 6) {
                if document.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                
                Text(document.title.isEmpty ? "Untitled" : document.title)
                    .font(.headline)
                    .lineLimit(1)
            }
            
            // Content preview
            if !document.content.isEmpty {
                Text(contentPreview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            // Metadata
            HStack(spacing: 8) {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                if !document.content.isEmpty {
                    Text("·")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    Text(wordCount)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    // MARK: - Computed Properties
    
    /// Preview of the content, stripped of Markdown syntax
    private var contentPreview: String {
        // Remove common Markdown syntax for preview
        var preview = document.content
        
        // Remove headers
        preview = preview.replacingOccurrences(of: "(?m)^#{1,6} ", with: "", options: .regularExpression)
        
        // Remove bold/italic markers
        preview = preview.replacingOccurrences(of: "\\*+", with: "", options: .regularExpression)
        preview = preview.replacingOccurrences(of: "_+", with: "", options: .regularExpression)
        
        // Remove code markers
        preview = preview.replacingOccurrences(of: "`+", with: "", options: .regularExpression)
        
        // Remove list markers  
        preview = preview.replacingOccurrences(of: "(?m)^[\\-\\*] ", with: "", options: .regularExpression)
        preview = preview.replacingOccurrences(of: "(?m)^\\d+\\. ", with: "", options: .regularExpression)
        
        // Remove blockquote markers
        preview = preview.replacingOccurrences(of: "(?m)^> ", with: "", options: .regularExpression)
        
        // Remove excessive whitespace
        preview = preview.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return preview.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Formatted date string
    private var formattedDate: String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(document.updatedAt) {
            return document.updatedAt.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(document.updatedAt) {
            return "Yesterday"
        } else if calendar.isDate(document.updatedAt, equalTo: now, toGranularity: .weekOfYear) {
            return document.updatedAt.formatted(.dateTime.weekday(.wide))
        } else if calendar.isDate(document.updatedAt, equalTo: now, toGranularity: .year) {
            return document.updatedAt.formatted(.dateTime.month().day())
        } else {
            return document.updatedAt.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    /// Word count string
    private var wordCount: String {
        let words = document.content.split { $0.isWhitespace || $0.isNewline }.count
        return "\(words) word\(words == 1 ? "" : "s")"
    }
    
    /// Accessibility description
    private var accessibilityDescription: String {
        var description = document.title.isEmpty ? "Untitled document" : document.title
        
        if document.isPinned {
            description += ", pinned"
        }
        
        description += ", modified \(formattedDate)"
        description += ", \(wordCount)"
        
        return description
    }
}

#Preview {
    List {
        DocumentRow(document: Document.preview)
        DocumentRow(document: Document(title: "Empty Note", content: ""))
        DocumentRow(document: Document(
            title: "Shopping List",
            content: "- Milk\n- Eggs\n- Bread\n- **Butter**",
            updatedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        ))
    }
}

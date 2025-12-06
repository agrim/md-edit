import SwiftData
import Foundation

/// Core data model for a Markdown document.
/// Uses SwiftData for local persistence and CloudKit for sync.
@Model
final class Document {
    /// Unique identifier for the document
    var id: UUID = UUID()
    
    /// Document title (displayed in list and as heading)
    var title: String = ""
    
    /// Markdown content of the document
    var content: String = ""
    
    /// When the document was first created
    var createdAt: Date = Date()
    
    /// When the document was last modified
    var updatedAt: Date = Date()
    
    /// Whether the document is pinned to the top of the list
    var isPinned: Bool = false
    
    /// Optional tags for organization (future use)
    var tags: [String] = []
    
    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPinned: Bool = false,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
        self.tags = tags
    }
    
    /// Updates the document content and modified timestamp
    func updateContent(_ newContent: String) {
        self.content = newContent
        self.updatedAt = Date()
    }
    
    /// Updates the document title and modified timestamp
    func updateTitle(_ newTitle: String) {
        self.title = newTitle
        self.updatedAt = Date()
    }
    
    /// Toggles the pinned state
    func togglePinned() {
        self.isPinned.toggle()
        self.updatedAt = Date()
    }
}

// MARK: - Preview Helpers

extension Document {
    /// Sample document for previews and testing
    static var preview: Document {
        Document(
            title: "Sample Note",
            content: """
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
            """,
            isPinned: true
        )
    }
    
    /// Empty document for new document creation
    static var empty: Document {
        Document(title: "Untitled", content: "")
    }
}

import AppIntents
import SwiftData
import SwiftUI

/// App shortcut for creating a new Markdown document.
struct NewDocumentIntent: AppIntent {
    static var title: LocalizedStringResource = "Create New Document"
    static var description = IntentDescription("Creates a new Markdown document in MD Edit.")
    
    @Parameter(title: "Title")
    var title: String?
    
    @Parameter(title: "Content")
    var content: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Create a new document") {
            \.$title
            \.$content
        }
    }
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Create the document
        let documentTitle = title ?? "Untitled"
        let documentContent = content ?? ""
        
        // Post notification to create document in the app
        NotificationCenter.default.post(
            name: .createNewDocument,
            object: ["title": documentTitle, "content": documentContent]
        )
        
        return .result(dialog: "Created '\(documentTitle)' in MD Edit.")
    }
}

/// App shortcut for opening the most recent document.
struct OpenRecentDocumentIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Recent Document"
    static var description = IntentDescription("Opens the most recently modified document in MD Edit.")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Get the most recent document
        if let recentDocument = DocumentStore.shared.fetchMostRecentDocument() {
            // Post notification to open the document
            NotificationCenter.default.post(
                name: .openDocument,
                object: recentDocument.id
            )
            return .result(dialog: "Opening '\(recentDocument.title.isEmpty ? "Untitled" : recentDocument.title)'.")
        } else {
            return .result(dialog: "No documents found. Create one first!")
        }
    }
}

/// App shortcut for searching documents.
struct SearchDocumentsIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Documents"
    static var description = IntentDescription("Searches for documents in MD Edit.")
    
    @Parameter(title: "Query")
    var query: String
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Post notification to trigger search
        NotificationCenter.default.post(
            name: .searchDocuments,
            object: query
        )
        
        return .result(dialog: "Searching for '\(query)' in MD Edit.")
    }
}

// MARK: - App Shortcuts Provider

struct MDEditShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NewDocumentIntent(),
            phrases: [
                "Create a new document in \(.applicationName)",
                "New \(.applicationName) document",
                "Start writing in \(.applicationName)"
            ],
            shortTitle: "New Document",
            systemImageName: "doc.badge.plus"
        )
        
        AppShortcut(
            intent: OpenRecentDocumentIntent(),
            phrases: [
                "Open my recent \(.applicationName) document",
                "Continue writing in \(.applicationName)",
                "Open last note in \(.applicationName)"
            ],
            shortTitle: "Open Recent",
            systemImageName: "clock"
        )
    }
}

// MARK: - Additional Notification Names

extension Notification.Name {
    static let openDocument = Notification.Name("openDocument")
    static let searchDocuments = Notification.Name("searchDocuments")
}

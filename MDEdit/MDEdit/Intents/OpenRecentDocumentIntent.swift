import AppIntents
import SwiftData
import SwiftUI

/// Entity representing a document for AppIntents.
struct DocumentEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Document"
    
    static var defaultQuery = DocumentQuery()
    
    var id: UUID
    var title: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title.isEmpty ? "Untitled" : title)")
    }
}

/// Query for fetching documents in AppIntents.
struct DocumentQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [DocumentEntity] {
        let documents = DocumentStore.shared.fetchAllDocuments()
        return documents
            .filter { identifiers.contains($0.id) }
            .map { DocumentEntity(id: $0.id, title: $0.title) }
    }
    
    @MainActor
    func suggestedEntities() async throws -> [DocumentEntity] {
        let documents = DocumentStore.shared.fetchAllDocuments()
        return documents.prefix(10).map { DocumentEntity(id: $0.id, title: $0.title) }
    }
}

/// Intent for opening a specific document.
struct OpenDocumentIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Document"
    static var description = IntentDescription("Opens a specific document in MD Edit.")
    
    @Parameter(title: "Document")
    var document: DocumentEntity
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Post notification to open the document
        NotificationCenter.default.post(
            name: .openDocument,
            object: document.id
        )
        
        return .result(dialog: "Opening '\(document.title.isEmpty ? "Untitled" : document.title)'.")
    }
}

/// Intent for getting document count.
struct GetDocumentCountIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Document Count"
    static var description = IntentDescription("Returns the number of documents in MD Edit.")
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<Int> & ProvidesDialog {
        let documents = DocumentStore.shared.fetchAllDocuments()
        let count = documents.count
        
        let message = count == 1 
            ? "You have 1 document in MD Edit."
            : "You have \(count) documents in MD Edit."
        
        return .result(value: count, dialog: IntentDialog(stringLiteral: message))
    }
}

/// Intent for quick capture - create a document with content.
struct QuickCaptureIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Capture"
    static var description = IntentDescription("Quickly capture text as a new Markdown document.")
    
    @Parameter(title: "Content")
    var content: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Save '\(\.$content)' as a new document")
    }
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Create a document with the captured content
        let title = generateTitle(from: content)
        
        if let _ = DocumentStore.shared.createDocument(title: title, content: content) {
            return .result(dialog: "Saved to MD Edit.")
        } else {
            return .result(dialog: "Could not save. Please try again.")
        }
    }
    
    private func generateTitle(from content: String) -> String {
        // Use first line or first few words as title
        let firstLine = content.components(separatedBy: .newlines).first ?? content
        let words = firstLine.components(separatedBy: .whitespaces).prefix(5)
        let title = words.joined(separator: " ")
        
        if title.count > 50 {
            return String(title.prefix(47)) + "..."
        }
        
        return title.isEmpty ? "Quick Note" : title
    }
}

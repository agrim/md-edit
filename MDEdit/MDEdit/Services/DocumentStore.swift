import SwiftData
import Foundation

/// Service layer for document operations.
/// Provides a clean API for CRUD operations on documents.
@Observable
final class DocumentStore {
    private var modelContext: ModelContext?
    
    /// Shared instance for app-wide use
    static let shared = DocumentStore()
    
    private init() {}
    
    /// Configure the store with a model context
    func configure(with context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Create
    
    /// Creates a new document with optional title and content
    @discardableResult
    func createDocument(title: String = "Untitled", content: String = "") -> Document? {
        guard let context = modelContext else { return nil }
        
        let document = Document(title: title, content: content)
        context.insert(document)
        
        do {
            try context.save()
            return document
        } catch {
            print("Error creating document: \(error)")
            return nil
        }
    }
    
    // MARK: - Update
    
    /// Updates a document's title
    func updateTitle(for document: Document, newTitle: String) {
        document.updateTitle(newTitle)
        save()
    }
    
    /// Updates a document's content
    func updateContent(for document: Document, newContent: String) {
        document.updateContent(newContent)
        save()
    }
    
    /// Toggles a document's pinned status
    func togglePinned(for document: Document) {
        document.togglePinned()
        save()
    }
    
    // MARK: - Delete
    
    /// Deletes a document
    func deleteDocument(_ document: Document) {
        guard let context = modelContext else { return }
        context.delete(document)
        save()
    }
    
    /// Deletes multiple documents
    func deleteDocuments(_ documents: [Document]) {
        guard let context = modelContext else { return }
        for document in documents {
            context.delete(document)
        }
        save()
    }
    
    // MARK: - Query Helpers
    
    /// Fetches the most recently modified document
    func fetchMostRecentDocument() -> Document? {
        guard let context = modelContext else { return nil }
        
        var descriptor = FetchDescriptor<Document>(
            sortBy: [SortDescriptor(\Document.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        do {
            let documents = try context.fetch(descriptor)
            return documents.first
        } catch {
            print("Error fetching most recent document: \(error)")
            return nil
        }
    }
    
    /// Fetches all documents
    func fetchAllDocuments() -> [Document] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<Document>(
            sortBy: [
                SortDescriptor(\Document.updatedAt, order: .reverse)
            ]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching documents: \(error)")
            return []
        }
    }
    
    // MARK: - Private
    
    private func save() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

// MARK: - Sort Options

/// Available sort options for document list
enum DocumentSortOption: String, CaseIterable, Identifiable {
    case dateModified = "Date Modified"
    case title = "Title"
    
    var id: String { rawValue }
    
    var sortDescriptors: [SortDescriptor<Document>] {
        switch self {
        case .dateModified:
            return [
                SortDescriptor(\Document.updatedAt, order: .reverse)
            ]
        case .title:
            return [
                SortDescriptor(\Document.title)
            ]
        }
    }
}

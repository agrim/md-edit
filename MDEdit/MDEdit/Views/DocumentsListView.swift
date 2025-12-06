import SwiftUI
import SwiftData
import TipKit

/// Main document library view showing all documents.
/// Supports search, sorting, pinning, and swipe-to-delete.
struct DocumentsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Query private var documents: [Document]
    
    @Binding var selectedDocument: Document?
    
    @State private var searchText = ""
    @State private var sortOption: DocumentSortOption = .dateModified
    @State private var showingSortMenu = false
    
    // Tips
    private let createDocumentTip = CreateDocumentTip()
    private let swipeToDeleteTip = SwipeToDeleteTip()
    
    init(selectedDocument: Binding<Document?>) {
        self._selectedDocument = selectedDocument
        
        // Default query - will be filtered/sorted in view
        let sortDescriptors = [
            SortDescriptor(\Document.updatedAt, order: .reverse)
        ]
        _documents = Query(sort: sortDescriptors)
    }
    
    var body: some View {
        Group {
            if documents.isEmpty && searchText.isEmpty {
                emptyStateView
            } else {
                documentListView
            }
        }
        .navigationTitle("Documents")
        .searchable(text: $searchText, prompt: "Search documents")
        .toolbar {
            toolbarContent
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            EmptyStateView(
                icon: "doc.text",
                title: "No Documents Yet",
                message: "Create your first Markdown document to get started."
            )
            
            Button(action: createNewDocument) {
                Label("Create Document", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            
            TipView(createDocumentTip)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var documentListView: some View {
        List(selection: $selectedDocument) {
            // Show tip if there are documents
            if !documents.isEmpty {
                TipView(swipeToDeleteTip)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            // Pinned section
            let pinnedDocs = filteredDocuments.filter { $0.isPinned }
            if !pinnedDocs.isEmpty {
                Section("Pinned") {
                    ForEach(pinnedDocs) { document in
                        documentRow(for: document)
                    }
                    .onDelete { indexSet in
                        deleteDocuments(pinnedDocs, at: indexSet)
                    }
                }
            }
            
            // Regular documents section
            let unpinnedDocs = filteredDocuments.filter { !$0.isPinned }
            if !unpinnedDocs.isEmpty {
                Section(pinnedDocs.isEmpty ? "" : "Documents") {
                    ForEach(unpinnedDocs) { document in
                        documentRow(for: document)
                    }
                    .onDelete { indexSet in
                        deleteDocuments(unpinnedDocs, at: indexSet)
                    }
                }
            }
        }
        #if os(macOS)
        .listStyle(.sidebar)
        #else
        .listStyle(.insetGrouped)
        #endif
    }
    
    @ViewBuilder
    private func documentRow(for document: Document) -> some View {
        Group {
            #if os(macOS)
            DocumentRow(document: document)
                .tag(document)
                .contextMenu {
                    documentContextMenu(for: document)
                }
            #else
            if horizontalSizeClass == .regular {
                // iPad - use selection
                DocumentRow(document: document)
                    .tag(document)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteDocument(document)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            togglePin(document)
                        } label: {
                            Label(
                                document.isPinned ? "Unpin" : "Pin",
                                systemImage: document.isPinned ? "pin.slash" : "pin"
                            )
                        }
                        .tint(.orange)
                    }
                    .contextMenu {
                        documentContextMenu(for: document)
                    }
            } else {
                // iPhone - use NavigationLink
                NavigationLink(value: document) {
                    DocumentRow(document: document)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteDocument(document)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        togglePin(document)
                    } label: {
                        Label(
                            document.isPinned ? "Unpin" : "Pin",
                            systemImage: document.isPinned ? "pin.slash" : "pin"
                        )
                    }
                    .tint(.orange)
                }
                .contextMenu {
                    documentContextMenu(for: document)
                }
            }
            #endif
        }
    }
    
    @ViewBuilder
    private func documentContextMenu(for document: Document) -> some View {
        Button {
            togglePin(document)
        } label: {
            Label(
                document.isPinned ? "Unpin" : "Pin",
                systemImage: document.isPinned ? "pin.slash" : "pin"
            )
        }
        
        Divider()
        
        Button {
            shareDocument(document)
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        
        Divider()
        
        Button(role: .destructive) {
            deleteDocument(document)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if os(macOS)
        ToolbarItem(placement: .primaryAction) {
            Button(action: createNewDocument) {
                Label("New Document", systemImage: "plus")
            }
            .keyboardShortcut("n", modifiers: .command)
        }
        
        ToolbarItem(placement: .secondaryAction) {
            Menu {
                Picker("Sort By", selection: $sortOption) {
                    ForEach(DocumentSortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
        #else
        ToolbarItem(placement: .primaryAction) {
            Button(action: createNewDocument) {
                Label("New Document", systemImage: "plus")
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Picker("Sort By", selection: $sortOption) {
                    ForEach(DocumentSortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
        #endif
    }
    
    // MARK: - Computed Properties
    
    private var filteredDocuments: [Document] {
        var result = documents
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { document in
                document.title.localizedCaseInsensitiveContains(searchText) ||
                document.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateModified:
            result.sort { ($0.isPinned ? 1 : 0, $0.updatedAt) > ($1.isPinned ? 1 : 0, $1.updatedAt) }
        case .title:
            result.sort { ($0.isPinned ? 1 : 0, $0.title.lowercased()) > ($1.isPinned ? 1 : 0, $1.title.lowercased()) }
        }
        
        return result
    }
    
    // MARK: - Actions
    
    private func createNewDocument() {
        let newDocument = Document(title: "Untitled", content: "")
        modelContext.insert(newDocument)
        
        do {
            try modelContext.save()
            selectedDocument = newDocument
            
            // Invalidate the tip after creating first document
            CreateDocumentTip.hasCreatedDocument = true
        } catch {
            print("Error creating document: \(error)")
        }
    }
    
    private func deleteDocument(_ document: Document) {
        if selectedDocument == document {
            selectedDocument = nil
        }
        modelContext.delete(document)
        try? modelContext.save()
        
        // Mark tip as shown after deletion
        SwipeToDeleteTip.hasDeletedDocument = true
    }
    
    private func deleteDocuments(_ documents: [Document], at offsets: IndexSet) {
        for index in offsets {
            let document = documents[index]
            deleteDocument(document)
        }
    }
    
    private func togglePin(_ document: Document) {
        document.togglePinned()
        try? modelContext.save()
    }
    
    private func shareDocument(_ document: Document) {
        // Create a temporary file for sharing
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(document.title.isEmpty ? "Untitled" : document.title)
            .appendingPathExtension("md")
        
        do {
            try document.content.write(to: tempURL, atomically: true, encoding: .utf8)
            
            #if os(macOS)
            NSWorkspace.shared.activateFileViewerSelecting([tempURL])
            #else
            // iOS sharing is handled via ShareLink in SwiftUI
            #endif
        } catch {
            print("Error sharing document: \(error)")
        }
    }
}

// MARK: - Navigation Destination

extension DocumentsListView {
    @ViewBuilder
    static func navigationDestination(for document: Document) -> some View {
        DocumentEditorView(document: document)
    }
}

#Preview {
    NavigationStack {
        DocumentsListView(selectedDocument: .constant(nil))
    }
    .modelContainer(for: Document.self, inMemory: true)
}

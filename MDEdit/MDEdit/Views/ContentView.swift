import SwiftUI
import SwiftData

/// Root content view that provides navigation structure.
/// Uses NavigationSplitView for iPad/Mac and NavigationStack for iPhone.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedDocument: Document?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView(columnVisibility: $columnVisibility) {
            DocumentsListView(selectedDocument: $selectedDocument)
                .navigationSplitViewColumnWidth(min: 200, ideal: 280, max: 400)
        } detail: {
            if let document = selectedDocument {
                DocumentEditorView(document: document)
            } else {
                EmptyEditorView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .createNewDocument)) { _ in
            createNewDocument()
        }
        #else
        if horizontalSizeClass == .regular {
            // iPad - Split View
            NavigationSplitView(columnVisibility: $columnVisibility) {
                DocumentsListView(selectedDocument: $selectedDocument)
            } detail: {
                if let document = selectedDocument {
                    DocumentEditorView(document: document)
                } else {
                    EmptyEditorView()
                }
            }
        } else {
            // iPhone - Navigation Stack
            NavigationStack {
                DocumentsListView(selectedDocument: $selectedDocument)
            }
        }
        #endif
    }
    
    private func createNewDocument() {
        let newDocument = Document(title: "Untitled", content: "")
        modelContext.insert(newDocument)
        
        do {
            try modelContext.save()
            selectedDocument = newDocument
        } catch {
            print("Error creating document: \(error)")
        }
    }
}

/// Empty state view shown when no document is selected
struct EmptyEditorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("No Document Selected")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("Select a document from the sidebar or create a new one.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(macOS)
        .background(Color(nsColor: .windowBackgroundColor))
        #else
        .background(Color(.systemBackground))
        #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Document.self, inMemory: true)
}

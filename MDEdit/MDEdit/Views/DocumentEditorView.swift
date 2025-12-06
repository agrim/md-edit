import SwiftUI
import SwiftData
import TipKit

/// Document editor view for writing and editing Markdown.
/// Supports editor-only, preview-only, and split view modes.
struct DocumentEditorView: View {
    @Bindable var document: Document
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var viewMode: EditorViewMode = .editor
    @State private var showingShareSheet = false
    @State private var showingExportMenu = false
    @FocusState private var isEditorFocused: Bool
    
    // Tips
    private let previewToggleTip = PreviewToggleTip()
    
    var body: some View {
        VStack(spacing: 0) {
            // Show tip inline
            if PreviewToggleTip.shouldShow {
                TipView(previewToggleTip)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            
            // Main content area
            Group {
                switch viewMode {
                case .editor:
                    editorView
                case .preview:
                    MarkdownPreviewView(content: document.content)
                case .split:
                    splitView
                }
            }
        }
        .navigationTitle(document.title.isEmpty ? "Untitled" : document.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            toolbarContent
        }
        .onReceive(NotificationCenter.default.publisher(for: .togglePreview)) { _ in
            togglePreview()
        }
        .onReceive(NotificationCenter.default.publisher(for: .insertMarkdown)) { notification in
            if let markdown = notification.object as? String {
                insertMarkdown(markdown)
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var editorView: some View {
        VStack(spacing: 0) {
            // Title field
            TextField("Title", text: $document.title)
                .font(.title.bold())
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .onChange(of: document.title) { _, _ in
                    document.updatedAt = Date()
                    saveDocument()
                }
            
            Divider()
                .padding(.horizontal)
            
            // Content editor
            TextEditor(text: $document.content)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .focused($isEditorFocused)
                .onChange(of: document.content) { _, _ in
                    document.updatedAt = Date()
                    saveDocument()
                }
            
            // Markdown toolbar (iOS only, shown above keyboard)
            #if os(iOS)
            if isEditorFocused {
                EditorToolbar { markdown in
                    insertMarkdown(markdown)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            #endif
        }
        .animation(.easeInOut(duration: 0.2), value: isEditorFocused)
    }
    
    @ViewBuilder
    private var splitView: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Editor side
                VStack(spacing: 0) {
                    TextField("Title", text: $document.title)
                        .font(.title2.bold())
                        .textFieldStyle(.plain)
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        .onChange(of: document.title) { _, _ in
                            document.updatedAt = Date()
                            saveDocument()
                        }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    TextEditor(text: $document.content)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .onChange(of: document.content) { _, _ in
                            document.updatedAt = Date()
                            saveDocument()
                        }
                }
                .frame(width: geometry.size.width / 2)
                
                Divider()
                
                // Preview side
                MarkdownPreviewView(content: document.content)
                    .frame(width: geometry.size.width / 2)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if os(macOS)
        ToolbarItemGroup(placement: .primaryAction) {
            // View mode picker
            Picker("View Mode", selection: $viewMode) {
                ForEach(EditorViewMode.allCases) { mode in
                    Label(mode.title, systemImage: mode.icon).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            
            Divider()
            
            // Share/Export
            Menu {
                Button {
                    shareAsMarkdown()
                } label: {
                    Label("Share as Markdown", systemImage: "doc.text")
                }
                
                Button {
                    exportAsHTML()
                } label: {
                    Label("Export as HTML", systemImage: "doc.richtext")
                }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        #else
        ToolbarItemGroup(placement: .primaryAction) {
            // View mode picker
            Menu {
                Picker("View Mode", selection: $viewMode) {
                    ForEach(availableViewModes) { mode in
                        Label(mode.title, systemImage: mode.icon).tag(mode)
                    }
                }
            } label: {
                Label(viewMode.title, systemImage: viewMode.icon)
            }
            
            // Share button
            ShareLink(item: document.content, subject: Text(document.title)) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        #endif
    }
    
    // MARK: - Computed Properties
    
    private var availableViewModes: [EditorViewMode] {
        #if os(macOS)
        return EditorViewMode.allCases
        #else
        // Only show split on iPad
        if horizontalSizeClass == .regular {
            return EditorViewMode.allCases
        } else {
            return [.editor, .preview]
        }
        #endif
    }
    
    // MARK: - Actions
    
    private func saveDocument() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving document: \(error)")
        }
    }
    
    private func togglePreview() {
        withAnimation {
            switch viewMode {
            case .editor:
                viewMode = .preview
            case .preview:
                viewMode = .editor
            case .split:
                viewMode = .editor
            }
        }
        
        // Invalidate tip after first toggle
        PreviewToggleTip.hasToggledPreview = true
    }
    
    private func insertMarkdown(_ markdown: String) {
        // Insert markdown at cursor position
        // For now, append to content (cursor position requires UITextView integration)
        document.content += markdown
        saveDocument()
    }
    
    private func shareAsMarkdown() {
        let filename = (document.title.isEmpty ? "Untitled" : document.title) + ".md"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try document.content.write(to: tempURL, atomically: true, encoding: .utf8)
            #if os(macOS)
            NSWorkspace.shared.activateFileViewerSelecting([tempURL])
            #endif
        } catch {
            print("Error sharing markdown: \(error)")
        }
    }
    
    private func exportAsHTML() {
        let html = MarkdownRenderer.htmlFromMarkdown(document.content)
        let filename = (document.title.isEmpty ? "Untitled" : document.title) + ".html"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try html.write(to: tempURL, atomically: true, encoding: .utf8)
            #if os(macOS)
            NSWorkspace.shared.activateFileViewerSelecting([tempURL])
            #endif
        } catch {
            print("Error exporting HTML: \(error)")
        }
    }
}

// MARK: - View Mode

enum EditorViewMode: String, CaseIterable, Identifiable {
    case editor
    case preview
    case split
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .editor: return "Editor"
        case .preview: return "Preview"
        case .split: return "Split"
        }
    }
    
    var icon: String {
        switch self {
        case .editor: return "square.and.pencil"
        case .preview: return "eye"
        case .split: return "rectangle.split.2x1"
        }
    }
}

#Preview {
    NavigationStack {
        DocumentEditorView(document: Document.preview)
    }
    .modelContainer(for: Document.self, inMemory: true)
}

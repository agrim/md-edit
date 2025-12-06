import SwiftUI

/// Renders Markdown content as formatted preview.
/// Uses native AttributedString Markdown parsing for fast rendering.
struct MarkdownPreviewView: View {
    let content: String
    
    @State private var renderedContent: AttributedString = AttributedString()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if content.isEmpty {
                    emptyPreview
                } else {
                    Text(renderedContent)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(macOS)
        .background(Color(nsColor: .textBackgroundColor))
        #else
        .background(Color(.systemBackground))
        #endif
        .onAppear {
            renderContent()
        }
        .onChange(of: content) { _, _ in
            renderContent()
        }
    }
    
    private var emptyPreview: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("No Content")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Start typing in the editor to see a preview here.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func renderContent() {
        // Render on a background thread for large documents
        Task {
            let rendered = MarkdownRenderer.renderMarkdown(content)
            await MainActor.run {
                self.renderedContent = rendered
            }
        }
    }
}

// MARK: - Preview Styles

extension MarkdownPreviewView {
    /// Creates a preview view with custom styling
    init(content: String, style: PreviewStyle = .default) {
        self.content = content
    }
}

enum PreviewStyle {
    case `default`
    case compact
    case presentation
}

#Preview("With Content") {
    MarkdownPreviewView(content: """
    # Welcome to MD Edit
    
    This is a **sample document** to demonstrate the preview.
    
    ## Features
    
    - Create and edit Markdown
    - Preview rendered content
    - Sync across devices via iCloud
    
    ### Code Example
    
    ```swift
    print("Hello, MD Edit!")
    ```
    
    > MD Edit focuses on simplicity and speed.
    
    Here's a [link to Apple](https://apple.com) for reference.
    """)
}

#Preview("Empty") {
    MarkdownPreviewView(content: "")
}

import SwiftUI

/// Reusable empty state view for displaying when content is not available.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preset Empty States

extension EmptyStateView {
    /// Empty state for when there are no documents
    static var noDocuments: EmptyStateView {
        EmptyStateView(
            icon: "doc.text",
            title: "No Documents Yet",
            message: "Create your first Markdown document to get started."
        )
    }
    
    /// Empty state for when search returns no results
    static var noSearchResults: EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results",
            message: "Try searching for something else."
        )
    }
    
    /// Empty state for preview with no content
    static var noContent: EmptyStateView {
        EmptyStateView(
            icon: "doc.text",
            title: "No Content",
            message: "Start typing in the editor to see a preview."
        )
    }
}

#Preview("No Documents") {
    EmptyStateView.noDocuments
}

#Preview("No Search Results") {
    EmptyStateView.noSearchResults
}

#Preview("No Content") {
    EmptyStateView.noContent
}

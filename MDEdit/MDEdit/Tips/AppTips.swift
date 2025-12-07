import TipKit

/// Tip shown to encourage creating the first document.
struct CreateDocumentTip: Tip {
    /// Tracks whether the user has created a document
    @Parameter
    static var hasCreatedDocument: Bool = false
    
    var title: Text {
        Text("Create Your First Document")
    }
    
    var message: Text? {
        Text("Tap the + button to create a new Markdown document.")
    }
    
    var image: Image? {
        Image(systemName: "doc.badge.plus")
    }
    
    var rules: [Rule] {
        #Rule(Self.$hasCreatedDocument) {
            $0 == false
        }
    }
}

/// Tip showing how to delete documents.
struct SwipeToDeleteTip: Tip {
    /// Tracks whether the user has deleted a document
    @Parameter
    static var hasDeletedDocument: Bool = false
    
    var title: Text {
        Text("Swipe to Delete")
    }
    
    var message: Text? {
        #if os(macOS)
        Text("Right-click a document or press Delete to remove it.")
        #else
        Text("Swipe left on a document to delete it.")
        #endif
    }
    
    var image: Image? {
        Image(systemName: "trash")
    }
    
    var rules: [Rule] {
        #Rule(Self.$hasDeletedDocument) {
            $0 == false
        }
    }
}

/// Tip showing how to toggle preview mode.
struct PreviewToggleTip: Tip {
    /// Tracks whether the user has toggled preview
    @Parameter
    static var hasToggledPreview: Bool = false
    
    /// Whether the tip should be shown based on state
    static var shouldShow: Bool {
        !hasToggledPreview
    }
    
    var title: Text {
        Text("Preview Your Markdown")
    }
    
    var message: Text? {
        #if os(macOS)
        Text("Use the view mode picker or press ⇧⌘P to toggle preview.")
        #else
        Text("Tap the view mode button to see your formatted Markdown.")
        #endif
    }
    
    var image: Image? {
        Image(systemName: "eye")
    }
    
    var rules: [Rule] {
        #Rule(Self.$hasToggledPreview) {
            $0 == false
        }
    }
}

/// Tip for pinning documents.
struct PinDocumentTip: Tip {
    @Parameter
    static var hasPinnedDocument: Bool = false
    
    var title: Text {
        Text("Pin Important Documents")
    }
    
    var message: Text? {
        #if os(macOS)
        Text("Right-click a document and select Pin to keep it at the top.")
        #else
        Text("Swipe right on a document to pin it to the top of your list.")
        #endif
    }
    
    var image: Image? {
        Image(systemName: "pin")
    }
    
    var rules: [Rule] {
        #Rule(Self.$hasPinnedDocument) {
            $0 == false
        }
    }
}

import SwiftUI
import SwiftData
import TipKit

/// Main entry point for MD Edit app.
/// Configures SwiftData with CloudKit sync and sets up the app structure.
@main
struct MDEditApp: App {
    /// Shared model container configured with CloudKit sync
    let modelContainer: ModelContainer
    
    init() {
        // Configure SwiftData for local storage
        let schema = Schema([Document.self])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            // Configure DocumentStore with the model context
            let context = modelContainer.mainContext
            DocumentStore.shared.configure(with: context)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
        
        // Configure TipKit
        configureTips()
    }
    
    var body: some Scene {
        #if os(macOS)
        // macOS: WindowGroup with commands and Settings scene
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
        .commands {
            // File menu commands
            CommandGroup(replacing: .newItem) {
                Button("New Document") {
                    NotificationCenter.default.post(
                        name: .createNewDocument,
                        object: nil
                    )
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            // Edit menu - Markdown formatting
            CommandMenu("Format") {
                Button("Heading 1") {
                    NotificationCenter.default.post(
                        name: .insertMarkdown,
                        object: "# "
                    )
                }
                .keyboardShortcut("1", modifiers: [.command, .control])
                
                Button("Heading 2") {
                    NotificationCenter.default.post(
                        name: .insertMarkdown,
                        object: "## "
                    )
                }
                .keyboardShortcut("2", modifiers: [.command, .control])
                
                Button("Heading 3") {
                    NotificationCenter.default.post(
                        name: .insertMarkdown,
                        object: "### "
                    )
                }
                .keyboardShortcut("3", modifiers: [.command, .control])
                
                Divider()
                
                Button("Bold") {
                    NotificationCenter.default.post(
                        name: .insertMarkdown,
                        object: "**bold**"
                    )
                }
                .keyboardShortcut("b", modifiers: .command)
                
                Button("Italic") {
                    NotificationCenter.default.post(
                        name: .insertMarkdown,
                        object: "*italic*"
                    )
                }
                .keyboardShortcut("i", modifiers: .command)
                
                Button("Code") {
                    NotificationCenter.default.post(
                        name: .insertMarkdown,
                        object: "`code`"
                    )
                }
                .keyboardShortcut("k", modifiers: .command)
                
                Divider()
                
                Button("Bullet List") {
                    NotificationCenter.default.post(
                        name: .insertMarkdown,
                        object: "- "
                    )
                }
                
                Button("Numbered List") {
                    NotificationCenter.default.post(
                        name: .insertMarkdown,
                        object: "1. "
                    )
                }
                
                Button("Quote") {
                    NotificationCenter.default.post(
                        name: .insertMarkdown,
                        object: "> "
                    )
                }
            }
            
            // View menu - preview toggle
            CommandGroup(after: .toolbar) {
                Button("Toggle Preview") {
                    NotificationCenter.default.post(
                        name: .togglePreview,
                        object: nil
                    )
                }
                .keyboardShortcut("p", modifiers: [.command, .shift])
            }
        }
        
        // Settings window for macOS
        Settings {
            SettingsView()
        }
        #else
        // iOS/iPadOS: Simple WindowGroup
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
        #endif
    }
    
    /// Configure TipKit for the app
    private func configureTips() {
        do {
            try Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        } catch {
            print("Error configuring tips: \(error)")
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let createNewDocument = Notification.Name("createNewDocument")
    static let insertMarkdown = Notification.Name("insertMarkdown")
    static let togglePreview = Notification.Name("togglePreview")
}

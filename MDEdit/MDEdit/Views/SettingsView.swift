import SwiftUI

/// Minimal settings view for app configuration.
struct SettingsView: View {
    @AppStorage("editorFontSize") private var editorFontSize: Double = 16
    @AppStorage("showLineNumbers") private var showLineNumbers: Bool = false
    @AppStorage("autoSaveInterval") private var autoSaveInterval: Double = 2
    
    var body: some View {
        Form {
            #if os(macOS)
            formContent
                .frame(minWidth: 400, maxWidth: 500)
                .padding()
            #else
            formContent
            #endif
        }
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    @ViewBuilder
    private var formContent: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Font Size")
                    Spacer()
                    Text("\(Int(editorFontSize)) pt")
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $editorFontSize, in: 12...24, step: 1) {
                    Text("Font Size")
                }
            }
        } header: {
            Text("Editor")
        }
        
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Auto-save Delay")
                    Spacer()
                    Text("\(String(format: "%.1f", autoSaveInterval))s")
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $autoSaveInterval, in: 0.5...5, step: 0.5) {
                    Text("Auto-save Delay")
                }
            }
        } header: {
            Text("Saving")
        } footer: {
            Text("Documents are automatically saved after you stop typing.")
        }
        
        Section {
            LabeledContent("Version", value: Bundle.main.appVersion)
            LabeledContent("Build", value: Bundle.main.buildNumber)
        } header: {
            Text("About")
        }
        
        Section {
            Link(destination: URL(string: "https://apple.com/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            
            Link(destination: URL(string: "https://apple.com/terms")!) {
                Label("Terms of Service", systemImage: "doc.text")
            }
        } header: {
            Text("Legal")
        }
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

import SwiftUI

/// Markdown formatting toolbar for quick syntax insertion.
/// Displayed above the keyboard on iOS or in the toolbar on macOS.
struct EditorToolbar: View {
    let onInsert: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(ToolbarAction.allCases) { action in
                    Button {
                        onInsert(action.markdown)
                    } label: {
                        Image(systemName: action.icon)
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 44, height: 36)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(action.accessibilityLabel)
                    .help(action.accessibilityLabel)
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 44)
        .background(.bar)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

// MARK: - Toolbar Actions

enum ToolbarAction: String, CaseIterable, Identifiable {
    case heading1
    case heading2
    case heading3
    case bold
    case italic
    case code
    case codeBlock
    case bulletList
    case numberedList
    case checklist
    case quote
    case link
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .heading1: return "h.square"
        case .heading2: return "h.square"
        case .heading3: return "h.square"
        case .bold: return "bold"
        case .italic: return "italic"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .codeBlock: return "text.alignleft"
        case .bulletList: return "list.bullet"
        case .numberedList: return "list.number"
        case .checklist: return "checklist"
        case .quote: return "text.quote"
        case .link: return "link"
        }
    }
    
    var markdown: String {
        switch self {
        case .heading1: return "# "
        case .heading2: return "## "
        case .heading3: return "### "
        case .bold: return "**text**"
        case .italic: return "*text*"
        case .code: return "`code`"
        case .codeBlock: return "```\ncode\n```"
        case .bulletList: return "- "
        case .numberedList: return "1. "
        case .checklist: return "- [ ] "
        case .quote: return "> "
        case .link: return "[title](url)"
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .heading1: return "Heading 1"
        case .heading2: return "Heading 2"
        case .heading3: return "Heading 3"
        case .bold: return "Bold"
        case .italic: return "Italic"
        case .code: return "Inline Code"
        case .codeBlock: return "Code Block"
        case .bulletList: return "Bullet List"
        case .numberedList: return "Numbered List"
        case .checklist: return "Checklist"
        case .quote: return "Quote"
        case .link: return "Link"
        }
    }
}

#Preview {
    VStack {
        Spacer()
        EditorToolbar { markdown in
            print("Insert: \(markdown)")
        }
    }
}

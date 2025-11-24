# MD Edit

**MD Edit** is a minimal, no-nonsense Markdown editor for iPhone, iPad, and Mac.

It focuses on one thing and doing it well:  
> Let you write and manage Markdown documents quickly, comfortably, and safely, across all your Apple devices.

MD Edit is built primarily with **SwiftUI**, uses **SwiftData** for local persistence, and leverages **CloudKit** for secure iCloud sync. It avoids third-party dependencies and leans entirely on the latest native Apple frameworks and design idioms.

---

## Table of Contents

1. [Product Philosophy](#product-philosophy)  
2. [Key Features](#key-features)  
   - [Markdown Editing](#markdown-editing)  
   - [Preview & Reading Modes](#preview--reading-modes)  
   - [Document Management](#document-management)  
   - [Search & Organization](#search--organization)  
   - [Sync & Offline Support](#sync--offline-support)  
   - [Sharing & Export](#sharing--export)  
   - [Tips & Shortcuts](#tips--shortcuts)  
3. [Platforms & Requirements](#platforms--requirements)  
4. [Using MD Edit](#using-md-edit)  
   - [Creating a New Document](#creating-a-new-document)  
   - [Editing Markdown](#editing-markdown)  
   - [Previewing Content](#previewing-content)  
   - [Managing Your Library](#managing-your-library)  
5. [Architecture Overview](#architecture-overview)  
   - [Data Model](#data-model)  
   - [Persistence & Sync](#persistence--sync)  
   - [UI Structure](#ui-structure)  
   - [Native Frameworks Used](#native-frameworks-used)  
6. [Agentic Development Model](#agentic-development-model)  
7. [Roadmap](#roadmap)  
8. [FAQ & Troubleshooting](#faq--troubleshooting)  
9. [Contributing](#contributing)  
10. [License](#license)

---

## Product Philosophy

MD Edit is designed for people who:

- Prefer **clean, distraction-free text editors**.
- Want **Markdown support** without a kitchen sink of extra features.
- Live in the **Apple ecosystem** and want seamless, native-feeling apps.
- Care about **reliability**, **offline work**, and **safe sync**.

Guiding principles:

1. **Minimalism**  
   Only features that directly help writing and managing Markdown documents make the cut. UI is kept deliberately simple so you can focus on your text.

2. **No-Nonsense UX**  
   MD Edit should “click” in under a minute. There are no complex modes, no heavy configuration pages, and no unusual metaphors.

3. **SwiftUI-First & Native-Only**  
   The app is implemented primarily in **SwiftUI** and **SwiftData**, with **CloudKit** for sync. No third-party libraries. This keeps the codebase small, modern, and aligned with Apple’s platform evolution.

4. **Offline-First, Sync-Second**  
   Your documents always live locally first. Sync is additive and opportunistic—loss of network or iCloud issues should never prevent you from writing.

5. **Safety & Trust**  
   Automatic saving and careful sync logic aim to make data loss extremely unlikely. Any sync issues are surfaced without blocking your work.

---

## Key Features

### Markdown Editing

- **Plain-text Markdown editing** using a clean SwiftUI editor.
- Supports core Markdown syntax:
  - Headings (`#`, `##`, `###`)
  - Bold, italic, inline code
  - Bullet lists, numbered lists, checklists
  - Block quotes and fenced code blocks
- Editor is tuned for responsiveness even with large documents.
- Autosave as you type, so you never have to worry about hitting “Save”.

### Preview & Reading Modes

MD Edit supports different ways of viewing your content:

- **Editor Only** – focus purely on writing.
- **Preview Only** – see a rendered version of your Markdown (great for reading or proofing).
- **(Optionally on iPad/macOS) Split View** – see editor and preview side-by-side.

The preview uses native rendering tools (e.g. `AttributedString` Markdown capabilities) to keep things fast and integrated.

### Document Management

- **Document library** showing all your notes at a glance.
- Each document has:
  - Title
  - Content
  - Timestamps (created & last updated)
  - Optional pinning flag
  - Optional tags (future/extended use)
- Quick actions:
  - Create new document
  - Pin/unpin important items
  - Delete with standard gestures (swipe/delete on iOS/iPadOS; context menu or keyboard shortcut on macOS)

### Search & Organization

- Instant search across:
  - Document titles
  - Document content (where supported by current implementation)
- Sorting options:
  - By last modified
  - By title (A→Z)
- Pinning:
  - Keep important documents at the top of your list.

### Sync & Offline Support

- **Local first**: All data is stored locally using **SwiftData**.
- **iCloud sync via CloudKit**:
  - When enabled, your documents are synced through your private CloudKit database.
  - Edits on one device appear on others logged into the same Apple ID.
- Sync model:
  - Edits are applied locally immediately.
  - Sync occurs in the background wherever possible.
  - Simple, deterministic conflict resolution (e.g. last modified wins), with room for future refinement.

### Sharing & Export

- **Share Markdown**:
  - Export your document as a `.md` file with the system share sheet.
- **Mac-specific export (planned / optional)**:
  - “Export as HTML” from a menu command, using a built-in Markdown → HTML transform.

### Tips & Shortcuts

- **TipKit-based hints** (subtle and rare):
  - “Create your first document”
  - “Swipe to delete” (or appropriate Mac hint)
  - “Toggle preview mode”
- **AppIntents / Shortcuts (where supported)**:
  - Quickly create a new Markdown document.
  - Jump into your most recent note from Shortcuts or Siri.

---

## Platforms & Requirements

- **iOS** – iPhone
- **iPadOS** – iPad, with multitasking/multiwindow support where possible
- **macOS** – Mac, with a document-style or window-based experience

Baseline OS targets (actual values may be adjusted in the project):

- **iOS / iPadOS**: 17+  
- **macOS**: Sonoma+

You’ll need **Xcode (current stable)** to build and run MD Edit from source.

---

## Using MD Edit

This section speaks to both end users and anyone running the app in development.

### Creating a New Document

1. Open MD Edit.
2. On iPhone/iPad:
   - Tap the **“+”** button in the navigation bar or toolbar.
3. On Mac:
   - Use the **“New Document”** toolbar button or **File → New** menu item / keyboard shortcut.
4. A new, empty document appears with:
   - Editable **title** at the top.
   - **Body** area below for Markdown content.

Documents are saved automatically as you type.

### Editing Markdown

- Use standard Markdown syntax:
  - `#` for headings, `*` or `-` for bullets, `1.` for numbered lists, etc.
- Optional editing helpers:
  - Toolbar buttons to insert heading markers, list prefixes, code blocks, etc.
- Keyboard shortcuts (macOS and external keyboards):
  - Common operations such as new document, toggle preview, etc.
  - Additional shortcuts may be added as the app matures.

### Previewing Content

- Toggle preview from the editor:
  - On iOS/iPadOS: via a toolbar button.
  - On Mac: via toolbar button or menu/shortcut.
- Modes:
  - **Editor** – raw Markdown only.
  - **Preview** – fully rendered Markdown.
  - **(Optional) Split** – editor and preview side by side (especially useful on iPad/Mac).

### Managing Your Library

- Library view:
  - Shows all documents sorted by last modified (default) or title.
  - Pin important notes; pinned docs float to the top.
- Search:
  - Pull down or tap the search field.
  - Type to filter by title, and (where supported) content.
- Delete:
  - On iOS/iPadOS: swipe left, tap delete.
  - On Mac: select a document and use context menu/Delete key.

---

## Architecture Overview

MD Edit’s internals are designed to be simple and idiomatic for SwiftUI + SwiftData.

### Data Model

At the heart of MD Edit is a single SwiftData model for documents:

```swift
import SwiftData
import Foundation

@Model
final class Document {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    var tags: [String]

    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPinned: Bool = false,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
        self.tags = tags
    }
}

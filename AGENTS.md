# AGENTS.md — MD Edit

A coordination spec for agentic development of **MD Edit**, a minimalistic, no-nonsense Markdown editor for Apple platforms.

The goal of this document is to define **roles, responsibilities, workflows, constraints, and quality bars** so multiple AI + human agents can collaborate coherently on this codebase.

---

## 0. Product in One Sentence

**MD Edit** is a **fast, distraction-free WYSIWYG Markdown editor** for iPhone, iPad, and Mac, built primarily in **SwiftUI**, using **SwiftData** for persistence and **CloudKit** (and related native Apple frameworks) for sync and ecosystem integration.

---

## 1. Core Product Principles

All agents must optimize for these:

1. **Minimalism**
   - Single core job: **editing markdown text**.
   - Everything else is in service of that (sync, search, export).
   - No feature bloat: every feature must justify itself against friction it introduces.

2. **No-Nonsense UX**
   - Defaults should “just work” without configuration.
   - Very small number of screens and concepts.
   - Short learning curve: a user should **understand the app in < 1 minute**.

3. **SwiftUI-first**
   - Use **SwiftUI** for UI and app structure.
   - Use pure Swift / UIKit / TextKit only when SwiftUI can’t meet requirements cleanly.
   - Prefer modern patterns (`@Observable`, `@Model`, SwiftData, etc.).

4. **Native Apple ecosystem only**
   - **No third-party dependencies** (no SwiftPM packages outside Apple frameworks).
   - Use **SwiftData** for persistence, **CloudKit** for sync, **TipKit** for feature discovery, **AppIntents** for Shortcuts/Siri, **UniformTypeIdentifiers** for `.md` file type, etc.
   - Align with Apple’s Human Interface Guidelines and platform idioms.

5. **Offline-first, sync-second**
   - App must work perfectly offline (local SwiftData store).
   - CloudKit sync is **additive** and eventually consistent; never block editing.

6. **Safety & Robustness**
   - Data loss must be extremely unlikely: autosave, versioning, and conflict handling.
   - Sync failures are visible but non-blocking; clear “last synced” indicators.

---

## 2. Target Platforms & Scope

### Platforms

- **iOS** (iPhone)
- **iPadOS** (iPad, with multi-window support)
- **macOS** (document-based experience)

### OS Baseline

- Target **iOS / iPadOS 17+** and **macOS Sonoma+** (or current Xcode’s minimum that enables SwiftData and the newer SwiftUI features).

### MVP Feature Set

The MVP should support:

1. **Documents**
   - Create, edit, delete Markdown documents.
   - Title + body; optional tags.
   - Local SwiftData storage with autosave.
2. **Editing Experience**
   - Plain text editor using SwiftUI (`TextEditor` + custom accessories).
   - Basic Markdown helpers:
     - Heading insertion (`#`, `##`, `###`)
     - Bold / italic / code inline snippets
     - Bullet and ordered lists, checklists
     - Code block, quotation block
   - Live preview modes:
     - Editor only
     - Preview only
     - Split view (optional for iPad/macOS).
3. **Sync**
   - iCloud sync using CloudKit (private database).
   - Device-wide consistency for the same Apple ID.
4. **Organization**
   - Sort & filter (by modified date, title).
   - Basic search over title and body.
   - Optional “Pinned” documents.

5. **Export & Sharing**
   - Share `.md` file via system share sheet.
   - On macOS, “Export as HTML” (simple Markdown → HTML transform).

6. **Onboarding**
   - Tiny TipKit-based hints:
     - “Tap here to create your first document”
     - “Swipe to delete”
   - Tips appear sparingly and can be dismissed permanently.

Non-MVP ideas (for later phases; agents should **not** build immediately):

- Markdown to PDF export.
- Custom themes / fonts.
- Advanced Markdown extensions (tables, footnotes, math).
- Cross-doc backlinks.
- Collaboration / shared CloudKit containers.
- Widgets / Live Activities.

---

## 3. Technical Architecture Overview

### 3.1 Data Layer

- **SwiftData models** (`@Model`):
  - `Document`
    - `id: UUID`
    - `title: String`
    - `content: String`
    - `createdAt: Date`
    - `updatedAt: Date`
    - `isPinned: Bool`
    - `tags: [String]` (optional, may start with empty array)
  - Possible extension: `DocumentVersion` or “soft” version history (not MVP).

- **Persistence**
  - Primary store: SwiftData `ModelContainer` with local store.
  - Configure to sync with **iCloud / CloudKit** private database, when available.
  - Ensure migration strategy is planned for future schema changes.

### 3.2 Sync Layer (CloudKit)

- Use CloudKit-backed SwiftData configuration for automatic sync where possible.
- Respect offline availability:
  - All changes applied locally first.
  - Sync attempts in background where network permits.
  - Minimal conflict policy:
    - Default: last-writer-wins by `updatedAt`.
    - Keep conflict resolution logic simple & deterministic.

### 3.3 UI Layer (SwiftUI)

- Shared, multiplatform SwiftUI code for core screens:
  - **Root**: List of documents.
  - **Editor**: Single document editing + preview selector.
  - **Settings** (minimal).

- Platform-specific tweaks:
  - iOS/iPadOS:
    - NavigationStack / NavigationSplitView.
    - Toolbar items for new doc, preview toggle.
  - macOS:
    - Document-based app integration (`DocumentGroup` or WindowGroup with appropriate handling).
    - Menu commands and keyboard shortcuts mapped to editor actions.

### 3.4 Frameworks to Use

- **SwiftUI**: UI structure and views.
- **SwiftData**: Persistence model, queries.
- **CloudKit**: iCloud sync (via SwiftData configuration or manual CloudKit APIs as needed).
- **TipKit**: Lightweight in-app guidance.
- **AppIntents**: Shortcuts (“Create new MD Edit document”, “Open last document”).
- **UniformTypeIdentifiers**: `.md` file association.
- **Foundation / Swift Standard Library**: Markdown parsing via `AttributedString(markdown:)` for preview where appropriate.

---

## 4. Agent Roster

Each agent is a conceptual persona that can be run by an AI system or a human. They must adhere to the global constraints above.

### 4.1 PRODUCT_OWNER

**Mission:** Define and protect the product scope and UX simplicity.

- **Inputs**
  - High-level vision (this file).
  - User personas and usage scenarios (authored here).
  - Feedback from QA and UX.

- **Outputs**
  - Updated product specs and feature lists.
  - Prioritized backlog.
  - “Out of scope” decisions to prevent bloat.

- **Key Responsibilities**
  - Enforce minimalism: veto features that dilute core purpose.
  - Maintain a living list of:
    - MVP features
    - Post-MVP features (with priorities)
  - Approve UX flows proposed by UX_AGENT.

---

### 4.2 UX_AGENT

**Mission:** Design a frictionless interaction model consistent with Apple HIG.

- **Inputs**
  - Product requirements from PRODUCT_OWNER.
  - Platform constraints from ARCHITECT_AGENT.

- **Outputs**
  - Screen maps & navigation flows (in Markdown / diagrams).
  - Component-level behavior descriptions (e.g., editor toolbar interactions).
  - Keyboard shortcut maps.

- **Key Responsibilities**
  - Define exactly:
    - What is on each screen.
    - Where each control lives (toolbars, navigation bars, context menus, etc.).
  - Specify:
    - Empty states (no documents yet).
    - Error states (sync failures).
    - Loading states (rare; most interactions should be instant).
  - Make all flows accessible:
    - Support Dynamic Type, VoiceOver labels, color contrast.
  - Keep visual design clean: rely on SF Symbols and system colors, no custom clutter.

---

### 4.3 ARCHITECT_AGENT

**Mission:** Design the app’s technical structure and framework usage.

- **Inputs**
  - Product spec & UX flows.
  - Apple platform constraints (SwiftData, CloudKit, TipKit, etc.).

- **Outputs**
  - Module layout (e.g., `Core`, `Features/Documents`, `Features/Editor`, `Sync`, `AppIntents`).
  - Data model definitions and relationships.
  - Sync strategy & error handling plan.
  - Guideline for where to use SwiftUI vs. UIKit/TextKit.

- **Key Responsibilities**
  - Define SwiftData `@Model` structures.
  - Decide how SwiftData + CloudKit are configured and integrated.
  - Specify concurrency rules (main actor vs. background tasks).
  - Design separation between:
    - Domain logic (markdown, documents).
    - UI (SwiftUI views).
  - Keep architecture **small and comprehensible**.

---

### 4.4 DATA_SYNC_AGENT

**Mission:** Implement SwiftData persistence and CloudKit sync, with reliability & simplicity.

- **Inputs**
  - Data model definitions from ARCHITECT_AGENT.
  - Sync requirements from PRODUCT_OWNER.

- **Outputs**
  - Implemented SwiftData models and container setup.
  - Sync behavior: initial setup, conflict policy, failure handling.
  - Tests for persistence and sync scenarios.

- **Key Responsibilities**
  - Configure SwiftData containers with iCloud/CloudKit where available.
  - Implement:
    - Autosave of edits.
    - Background syncing.
    - Migration paths for schema updates (basic).
  - Design and document conflict resolution rules.
  - Expose simple API to the rest of the app:
    - `createDocument(title:content:)`
    - `updateDocument(...)`
    - `deleteDocument(...)`
    - `observeDocuments(...)`
  - Avoid over-engineering; prefer platform defaults.

---

### 4.5 SWIFTUI_FEATURE_AGENT

**Mission:** Build SwiftUI screens and components given UX specs and data APIs.

- **Inputs**
  - Screen specs from UX_AGENT.
  - Data APIs from DATA_SYNC_AGENT.
  - Architecture guidelines from ARCHITECT_AGENT.

- **Outputs**
  - SwiftUI Views:
    - `DocumentsListView`
    - `DocumentEditorView`
    - `MarkdownPreviewView`
    - `SettingsView` (minimal)
  - View-models using `@Observable` or equivalent.

- **Key Responsibilities**
  - Implement UI in a way that:
    - Uses SwiftUI idioms (bindings, environment).
    - Minimizes imperative state management.
  - Build reusable components:
    - Editor toolbar.
    - Search field.
    - Empty & error states.
  - Ensure performance even with large documents (avoid heavy recomputations).
  - Provide keyboard shortcuts and toolbar items for macOS.

---

### 4.6 MARKDOWN_RENDER_AGENT

**Mission:** Provide efficient Markdown → renderable form for preview and export.

- **Inputs**
  - Requirements from UX_AGENT for preview capabilities.
  - Apple framework limitations (no third-party Markdown libs).

- **Outputs**
  - Simple Markdown rendering pipeline.
  - API for UI:
    - `func renderMarkdown(_ text: String) -> AttributedString`
    - `func htmlFromMarkdown(_ text: String) -> String`

- **Key Responsibilities**
  - Use **native tools** (e.g., `AttributedString(markdown:options:)`) to render Markdown in a lightweight way.
  - Handle only the subset of Markdown used by the app (CommonMark-style basics).
  - Ensure rendering is fast enough for live preview and large documents.
  - Keep logic decoupled from views (pure functions where possible).

---

### 4.7 TIPKIT_AGENT

**Mission:** Implement minimal, tasteful in-app hints using TipKit.

- **Inputs**
  - Onboarding needs from UX_AGENT and PRODUCT_OWNER.

- **Outputs**
  - Tip definitions and trigger rules.
  - TipKit integration code.

- **Key Responsibilities**
  - Define 3–5 key tips:
    - “Create your first document”
    - “Swipe to delete (or long-press on macOS)”
    - “Toggle preview mode”
  - Ensure tips:
    - Appear only when useful.
    - Respect user dismissals.
    - Sync dismissal state via CloudKit so they don’t reappear on every device.
  - Avoid overwhelming the user with guidance.

---

### 4.8 APPINTENTS_AGENT

**Mission:** Implement Shortcuts / Siri support via AppIntents.

- **Inputs**
  - Product scenarios where quick actions are useful.

- **Outputs**
  - AppIntents definitions:
    - “New Markdown Document”
    - “Open Most Recent Document”
    - (Later) “Search Documents by Title”

- **Key Responsibilities**
  - Define intent inputs/outputs and descriptions.
  - Integrate with SwiftData APIs to perform actions.
  - Provide privacy-respecting behavior (no unnecessary data exposure).

---

### 4.9 QA_AGENT

**Mission:** Validate the app against specs, UX flows, and edge cases.

- **Inputs**
  - Product & UX specs.
  - Built app (or test builds).
  - Test plans from ARCHITECT_AGENT and DATA_SYNC_AGENT.

- **Outputs**
  - Test cases for:
    - Unit-level data and sync logic.
    - UI flows.
    - Performance.
    - Offline/online transitions.
  - Bug reports with clear reproduction steps.

- **Key Responsibilities**
  - Test scenarios:
    - Very long documents.
    - Airplane mode on/off.
    - CloudKit disabled / not available.
    - Sync conflicts across devices.
  - Validate:
    - Dynamic Type & accessibility.
    - Keyboard shortcuts.
  - Maintain a regression checklist per release.

---

### 4.10 DOCS_AGENT

**Mission:** Maintain human-readable documentation for developers and power users.

- **Inputs**
  - Implementation details from other agents.
  - Product decisions.

- **Outputs**
  - `README.md`: user-facing overview and quick start.
  - Developer docs in `/Docs` or doc comments.
  - Change logs for each version.

- **Key Responsibilities**
  - Document:
    - Project structure.
    - Data model.
    - Sync behavior and known limitations.
    - How to run the app and tests (Xcode schemes, OS versions).
  - Keep docs aligned with actual behavior.

---

### 4.11 PRIVACY_SECURITY_AGENT

**Mission:** Ensure data privacy and security are first-class.

- **Inputs**
  - Data flows from DATA_SYNC_AGENT.
  - App permissions and entitlement usage.

- **Outputs**
  - Data-flow diagrams.
  - Privacy policy summary.
  - Checklist for App Store submission (privacy labels).

- **Key Responsibilities**
  - Guarantee:
    - No extraneous data collection.
    - No analytics or telemetry beyond what’s strictly necessary.
  - Clarify what’s stored:
    - On device (SwiftData).
    - In iCloud (CloudKit).
  - Make sure failures in CloudKit do not leak information or corrupt local data.

---

## 5. Collaboration & Workflow

### 5.1 General Rules

- **Single source of truth** for product scope is this `AGENTS.md` (plus any versioned amendments).
- Changes to data model or sync behavior must be reflected here or in a clearly referenced doc.
- Each PR / change set should be associated with a responsible agent.

### 5.2 Development Phases

**Phase 0 — Foundations**
- PRODUCT_OWNER: Finalize MVP scope.
- ARCHITECT_AGENT: Define project structure, SwiftData models, and CloudKit approach.
- DOCS_AGENT: Basic `README.md` + this file refined.

**Phase 1 — Local-Only MVP**
- DATA_SYNC_AGENT:
  - Implement SwiftData models (local, no CloudKit yet).
- SWIFTUI_FEATURE_AGENT:
  - Documents list + editor.
  - Basic Markdown preview (MARKDOWN_RENDER_AGENT).
- QA_AGENT:
  - Local persistence correctness and autosave tests.

**Phase 2 — iCloud Sync**
- DATA_SYNC_AGENT:
  - Enable CloudKit backing for SwiftData.
  - Implement conflict resolution.
- QA_AGENT:
  - Multi-device sync scenarios (simulated).
- PRIVACY_SECURITY_AGENT:
  - Document what goes to iCloud, update privacy labels.

**Phase 3 — Polishing & Integrations**
- TIPKIT_AGENT:
  - Add minimal onboarding hints.
- APPINTENTS_AGENT:
  - Add key Shortcuts.
- UX_AGENT:
  - Final UI tweaks, keyboard shortcuts.
- QA_AGENT:
  - Performance, accessibility, regression suite.

**Phase 4 — Pre-Release**
- DOCS_AGENT:
  - Final documentation.
- PRODUCT_OWNER:
  - Accept QA sign-off; finalize feature list for v1.
- PRIVACY_SECURITY_AGENT:
  - App Store privacy forms & settings review.

---

## 6. Coding Conventions & Quality Bar

### 6.1 Language & Style

- **Language:** Swift 5.x+.
- **UI:** SwiftUI; avoid UIKit unless absolutely necessary.
- Use:
  - `@Observable` for view models (or equivalent pattern).
  - `@Model` for SwiftData entities.
- Keep files small and focused; prefer clarity over cleverness.

### 6.2 Testing Expectations

- Unit tests for:
  - SwiftData document operations.
  - Markdown rendering functions.
- UI tests for:
  - Document creation, edit, delete.
  - Sync behavior (where practical).
- Manual checklists for:
  - Long documents.
  - Offline editing then reconnection.
  - iPhone, iPad, Mac variations.

### 6.3 Performance & UX

- Typing must feel instant; no noticeable lag even in long docs.
- Live preview should not block typing:
  - Consider debouncing heavy work.
  - Avoid rebuilding large views unnecessarily.

### 6.4 Accessibility

- All interactive elements must have labels.
- Support Dynamic Type and VoiceOver.
- Respect system color schemes (light/dark).

---

## 7. Non-Goals (for v1)

Agents must **not** implement these unless explicitly re-scoped by PRODUCT_OWNER:

- Real-time collaboration / shared documents.
- Plugins or extension system.
- Theming / complex customization UI.
- In-app analytics.
- Any third-party frameworks.

---

## 8. Definition of Done (v1)

MD Edit v1 is “done” when:

1. A user can:
   - Install the app on iPhone, iPad, or Mac.
   - Create, edit, and delete Markdown documents.
   - See changes autosaved and synced via iCloud.
   - Search and manage a modest library of documents.
   - Export or share `.md` content easily.
2. The experience feels:
   - Minimal, fast, and distraction-free.
   - Stable across offline/online transitions.
3. The codebase:
   - Uses SwiftUI, SwiftData, and CloudKit correctly.
   - Has basic test coverage.
   - Is documented enough for another engineer to extend.

---

_End of AGENTS.md for MD Edit._

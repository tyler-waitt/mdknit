# MDKnit Architecture

## Overview

MDKnit follows a simple, layered architecture with minimal abstraction:

```
┌─────────────────────────────┐
│      Cocoa UI Layer         │  (Objective-C++)
│  NSWindow, NSTextView, etc  │
├─────────────────────────────┤
│      Bridge Layer           │  (.mm files)
│   Objective-C++ Bridging    │
├─────────────────────────────┤
│      Core Logic             │  (C++)
│    Text Buffer, Parser      │
└─────────────────────────────┘
```

## Components

### Text Buffer (`text_buffer.cpp/h`)

The heart of the editor - a simple dynamic array that holds the document text.

**Data Structure:**
```cpp
struct TextBuffer {
    char* data;      // Contiguous memory block
    usize size;      // Current text size
    usize capacity;  // Allocated capacity
};
```

**Key Operations:**
- `insert(pos, text, len)` - Insert text at position
- `delete(pos, len)` - Delete text range
- `set_text(text, len)` - Replace entire content
- `get_text()` - Get raw text pointer

**Design Decisions:**
- Single contiguous buffer (not a rope or piece table)
- Always null-terminated for C compatibility
- Grows by doubling capacity when needed
- No undo/redo built-in (relies on NSTextView for now)

### Window Management (`editor_window.mm`)

Handles the main editor window and coordinates between Cocoa and our text buffer.

**Responsibilities:**
- Create and configure NSWindow
- Set up NSTextView for editing
- Handle file operations (open/save)
- Sync NSTextView changes with TextBuffer

**Key Methods:**
- `setupTextView()` - Configure text view properties
- `setupMenus()` - Build File menu
- `textDidChange:` - Sync edits to buffer

### Application Structure

**Entry Point (`main.mm`):**
- Minimal NSApplication setup
- Creates menu bar
- Launches app delegate

**App Delegate (`app_delegate.mm`):**
- Creates main window on launch
- Handles app lifecycle

## Data Flow

### Text Editing
1. User types in NSTextView
2. `textDidChange:` notification fired
3. Get string from NSTextView
4. Update TextBuffer with new content

### File Operations
1. User selects Open/Save
2. Show standard macOS file dialog
3. Read/write file using NSString
4. Update TextBuffer and NSTextView

## Memory Management

- **C++ Side**: Manual memory management with malloc/free
- **Objective-C Side**: ARC (Automatic Reference Counting)
- **Bridge**: Careful ownership transfer at boundaries

## Build System

Simple Makefile approach:
1. Compile C++ files to .o
2. Compile Objective-C++ files to .o
3. Link with Cocoa/AppKit frameworks
4. Bundle into .app structure

## Future Architecture Considerations

### Markdown Parsing
- Add `markdown_parser.cpp` for syntax analysis
- Keep parser separate from buffer
- Output simple token stream

### Preview Pane
- Split NSWindow into two views
- Left: NSTextView (editor)
- Right: WKWebView or custom NSView (preview)

### Custom Text Rendering
- Replace NSTextView with custom NSView
- Implement own text layout and drawing
- Full control over rendering pipeline
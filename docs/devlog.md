# MDKnit Development Log

## 2025-01-07: Initial Implementation

### What Was Built

Created the foundation of MDKnit - a simple Markdown editor for macOS following data-oriented design principles.

**Components implemented:**
- Basic text buffer using dynamic array
- Cocoa UI with NSWindow and NSTextView
- File operations (new, open, save, save as)
- Simple Makefile build system

### Key Decisions

1. **Started with NSTextView**: Rather than implementing custom text rendering from scratch, used Cocoa's text view to get a working editor quickly. This follows the principle of starting concrete and specific.

2. **Minimal abstraction**: No classes beyond what Cocoa requires. Text buffer is a simple struct with free functions.

3. **Manual memory management**: Text buffer uses malloc/realloc/free directly for clarity and control.

4. **No external dependencies**: Just system libraries (Cocoa/AppKit).

### Technical Notes

- Used Objective-C++ (.mm files) to bridge between Cocoa UI and C++ core
- Disabled C++ exceptions and RTTI for smaller binary and predictable behavior
- Text buffer always maintains null termination for C string compatibility
- Currently syncing the entire text buffer on every keystroke (room for optimization)

### Known Issues

- `setAllowedFileTypes` deprecation warning when building
- No error messages shown to user if file operations fail
- No undo/redo beyond what NSTextView provides
- No syntax highlighting yet

### Next Steps

Potential features to explore:
- Markdown preview pane
- Basic syntax highlighting
- Project sidebar for multiple files
- Performance profiling and optimization
- Custom text rendering (for ultimate control)

### Lessons Learned

- Cocoa + C++ via Objective-C++ is a powerful combination
- Starting simple and concrete makes progress fast
- NSTextView provides a lot of functionality for free
- Data-oriented thinking applies even to UI applications

---

## Future Entries

New development sessions should add entries here with:
- Date
- What was changed/added
- Why decisions were made
- Any issues encountered
- Performance measurements (if relevant)
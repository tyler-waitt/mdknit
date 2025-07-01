# Claude Development Notes

This file contains important information for AI assistants working on MDKnit.

## Project Philosophy

This project follows a specific programming style inspired by Casey Muratori, Brian Will, and Mike Acton:
- **Data-oriented design** - Structure code around data flow, not abstract models
- **Minimal abstraction** - No unnecessary layers, inheritance, or design patterns
- **Performance-aware** - Consider cache locality, memory layout, and CPU efficiency
- **Explicit over implicit** - Code should be traceable and debuggable

## Current Architecture

### Core Components

1. **Text Buffer** (`src/text_buffer.cpp/h`)
   - Simple dynamic array of bytes
   - Basic operations: insert, delete, set_text
   - No fancy data structures - just realloc when needed
   - Always null-terminated for C string compatibility

2. **Cocoa UI Layer** (`.mm` files)
   - `main.mm` - Entry point, sets up NSApplication
   - `app_delegate.mm` - Application lifecycle
   - `editor_window.mm` - Main window with NSTextView

3. **Build System**
   - Simple Makefile using clang/clang++
   - Objective-C++ (.mm) files bridge Cocoa and C++
   - No external build dependencies

## Key Design Decisions

1. **Why NSTextView**: For v1, using Cocoa's text view gives us proper text editing for free. Future versions might implement custom text rendering for more control.

2. **Why C++ for core logic**: Allows precise memory control and zero-overhead abstractions where needed.

3. **Why Objective-C++**: Best of both worlds - Cocoa UI with C++ logic, minimal bridging code.

## Development Guidelines

### When Adding Features

1. **Start concrete**: Implement for the specific use case first
2. **Avoid premature generalization**: Only abstract when you have 2-3 real use cases
3. **Keep data structures simple**: Arrays before lists, structs before classes
4. **Measure before optimizing**: Use Instruments or similar profiling tools

### Code Style

- No exceptions (`-fno-exceptions`)
- No RTTI (`-fno-rtti`)
- Prefer stack allocation
- Use C++ type aliases (u8, u32, etc.) from common.h
- Functions should do one thing clearly

### Testing Approach

Currently no formal test framework. Test by:
1. Building: `make clean && make`
2. Running: `make run`
3. Manual testing of file operations

### Known Issues

- File type filtering uses deprecated API (setAllowedFileTypes)
- No error handling UI for file operations yet
- Text buffer syncs on every keystroke (might want to batch)

## Future Considerations

### Potential Features
- Markdown preview pane (split view)
- Syntax highlighting (custom or NSTextView attributes)
- File tree sidebar
- Multiple tabs/windows
- Find/replace
- Undo/redo (currently relies on NSTextView's built-in)

### Performance Optimizations
- Rope data structure for large files
- Incremental parsing for syntax highlighting
- Custom text rendering for ultimate control

### Platform Considerations
- Currently macOS only
- Could port core logic to other platforms
- UI layer would need platform-specific implementation

## Useful Commands

```bash
# Build and run
make && make run

# Clean build
make clean

# Check binary size
ls -lh build/MDKnit

# Profile with Instruments
instruments -t "Time Profiler" build/MDKnit.app
```

## Resources

- [Handmade Hero](https://handmadehero.org/) - Casey Muratori's project
- [Data-Oriented Design](https://www.dataorienteddesign.com/dodbook/) - Mike Acton's philosophy
- [Brian Will's YouTube](https://www.youtube.com/user/briantwill) - Anti-OOP videos
# MDKnit

A simple, fast Markdown editor for macOS built with a data-oriented, low-abstraction programming approach.

C++ with Cocoa via Objective-C++

i am building a markdown editor using C++ with Cocoa via Objective-C++.  i would like to have the editor on the right. and then have a outliner pane on the left. i want the outline to be atomic markdown nodes. where you can reorganize and nest them, and it will be reflected in the editor. when you click on a node, it only shows the content of that node and sub-nodes.

## Overview

MDKnit is a native macOS text editor designed for editing Markdown files. It follows the programming philosophy of Casey Muratori, Brian Will, and Mike Acton - emphasizing performance, clarity, and minimal abstraction.

## Quick Start

```bash
make
make run
```

## Documentation

- [Architecture](docs/architecture.md) - System design and component overview
- [Coding Style](docs/coding-style.md) - Programming principles and guidelines
- [Stack](docs/stack.md) - Technology choices and rationale
- [Development Log](docs/devlog.md) - Progress notes and decisions

## Features

- Native macOS application with standard menu bar and keyboard shortcuts
- Fast, responsive text editing
- Open and save Markdown/text files
- Minimal dependencies - just system libraries

## Build Requirements

- macOS
- Xcode Command Line Tools (for clang/clang++)
- Make

## License

TBD
# Simple Makefile for MDKnit - Markdown Editor for macOS

APP_NAME = MDKnit
BUILD_DIR = build
SRC_DIR = src

# Compiler settings
CXX = clang++
OBJC = clang
CXXFLAGS = -std=c++11 -Wall -O2 -fno-exceptions -fno-rtti
OBJCFLAGS = -fobjc-arc -Wall -O2
LDFLAGS = -framework Cocoa -framework AppKit

# Source files
CPP_SOURCES = $(SRC_DIR)/text_buffer.cpp
MM_SOURCES = $(SRC_DIR)/main.mm $(SRC_DIR)/app_delegate.mm $(SRC_DIR)/editor_window.mm \
           $(SRC_DIR)/markdown_node.mm $(SRC_DIR)/node_card_view.mm $(SRC_DIR)/outliner_view_controller.mm \
           $(SRC_DIR)/settings_manager.mm $(SRC_DIR)/settings_window.mm $(SRC_DIR)/tree_outliner_view_controller.mm

# Object files
CPP_OBJECTS = $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/%.o,$(CPP_SOURCES))
MM_OBJECTS = $(patsubst $(SRC_DIR)/%.mm,$(BUILD_DIR)/%.o,$(MM_SOURCES))
ALL_OBJECTS = $(CPP_OBJECTS) $(MM_OBJECTS)

# Targets
all: $(BUILD_DIR)/$(APP_NAME).app

$(BUILD_DIR)/$(APP_NAME).app: $(BUILD_DIR)/$(APP_NAME)
	@mkdir -p $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS
	@mkdir -p $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources
	@cp $(BUILD_DIR)/$(APP_NAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '<plist version="1.0">' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '<dict>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '    <key>CFBundleExecutable</key>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '    <string>$(APP_NAME)</string>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '    <key>CFBundleIdentifier</key>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '    <string>com.mdknit.editor</string>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '    <key>CFBundleName</key>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '    <string>$(APP_NAME)</string>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '    <key>CFBundlePackageType</key>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '    <string>APPL</string>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '    <key>NSHighResolutionCapable</key>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '    <true/>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '</dict>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@echo '</plist>' >> $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist

$(BUILD_DIR)/$(APP_NAME): $(ALL_OBJECTS)
	$(CXX) $(LDFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.mm
	@mkdir -p $(BUILD_DIR)
	$(OBJC) $(OBJCFLAGS) -c -o $@ $<

run: $(BUILD_DIR)/$(APP_NAME).app
	open $(BUILD_DIR)/$(APP_NAME).app

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean
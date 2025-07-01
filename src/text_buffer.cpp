#include "text_buffer.h"
#include <stdlib.h>
#include <string.h>

static void ensure_capacity(TextBuffer* buffer, usize required_capacity) {
    if (buffer->capacity >= required_capacity) return;
    
    usize new_capacity = buffer->capacity * 2;
    if (new_capacity < required_capacity) {
        new_capacity = required_capacity;
    }
    if (new_capacity < 1024) {
        new_capacity = 1024;
    }
    
    buffer->data = (char*)realloc(buffer->data, new_capacity);
    buffer->capacity = new_capacity;
}

void text_buffer_init(TextBuffer* buffer) {
    buffer->data = nullptr;
    buffer->size = 0;
    buffer->capacity = 0;
}

void text_buffer_free(TextBuffer* buffer) {
    if (buffer->data) {
        free(buffer->data);
        buffer->data = nullptr;
    }
    buffer->size = 0;
    buffer->capacity = 0;
}

void text_buffer_clear(TextBuffer* buffer) {
    buffer->size = 0;
}

void text_buffer_insert(TextBuffer* buffer, usize pos, const char* text, usize len) {
    if (pos > buffer->size) pos = buffer->size;
    
    ensure_capacity(buffer, buffer->size + len + 1);
    
    if (pos < buffer->size) {
        memmove(buffer->data + pos + len, buffer->data + pos, buffer->size - pos);
    }
    
    memcpy(buffer->data + pos, text, len);
    buffer->size += len;
    buffer->data[buffer->size] = '\0';
}

void text_buffer_delete(TextBuffer* buffer, usize pos, usize len) {
    if (pos >= buffer->size) return;
    if (pos + len > buffer->size) {
        len = buffer->size - pos;
    }
    
    memmove(buffer->data + pos, buffer->data + pos + len, buffer->size - pos - len);
    buffer->size -= len;
    buffer->data[buffer->size] = '\0';
}

void text_buffer_set_text(TextBuffer* buffer, const char* text, usize len) {
    ensure_capacity(buffer, len + 1);
    memcpy(buffer->data, text, len);
    buffer->size = len;
    buffer->data[buffer->size] = '\0';
}

char* text_buffer_get_text(TextBuffer* buffer) {
    if (!buffer->data) return (char*)"";
    return buffer->data;
}

usize text_buffer_get_size(TextBuffer* buffer) {
    return buffer->size;
}
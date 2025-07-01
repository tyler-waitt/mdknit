#ifndef MDKNIT_TEXT_BUFFER_H
#define MDKNIT_TEXT_BUFFER_H

#include "common.h"

struct TextBuffer {
    char* data;
    usize size;
    usize capacity;
};

void text_buffer_init(TextBuffer* buffer);
void text_buffer_free(TextBuffer* buffer);
void text_buffer_clear(TextBuffer* buffer);

void text_buffer_insert(TextBuffer* buffer, usize pos, const char* text, usize len);
void text_buffer_delete(TextBuffer* buffer, usize pos, usize len);

void text_buffer_set_text(TextBuffer* buffer, const char* text, usize len);
char* text_buffer_get_text(TextBuffer* buffer);
usize text_buffer_get_size(TextBuffer* buffer);

#endif // MDKNIT_TEXT_BUFFER_H
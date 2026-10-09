package com.edututor.util;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

import org.junit.jupiter.api.Test;

class HtmlSanitizerTest {

    @Test
    void toPlainTextStripsTagsAndKeepsParagraphBreaks() {
        String text = HtmlSanitizer.toPlainText("<p><b>Bài 15.</b> Xác suất là</p><p>Chọn A &amp; B</p>");
        assertFalse(text.contains("<"));
        assertEquals("Bài 15. Xác suất là\nChọn A & B", text);
    }

    @Test
    void toPlainTextKeepsLatexComparisons() {
        assertEquals("Cho $a<b$ và $x \\geq 1$", HtmlSanitizer.toPlainText("<p>Cho $a<b$ và $x \\geq 1$</p>"));
    }

    @Test
    void toPlainTextDropsImagesAndScripts() {
        assertEquals("Hình", HtmlSanitizer.toPlainText("<p>Hình<img src=\"/static/img/a.png\"><script>x()</script></p>"));
    }

    @Test
    void toPlainTextHandlesNullAndEmpty() {
        assertEquals("", HtmlSanitizer.toPlainText(null));
        assertEquals("", HtmlSanitizer.toPlainText(""));
    }
}

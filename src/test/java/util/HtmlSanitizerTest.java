package util;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

import static org.junit.jupiter.api.Assertions.assertTrue;
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

    @Test
    void plainTextNewlinesBecomeLineBreaksOutsideMath() {
        String html = HtmlSanitizer.toSafeHtml("Cho hàm số:\na) $y=x^2$\nb) $$\\begin{array}{c}\n1\\\\2\n\\end{array}$$");
        assertEquals(2, html.split("<br>", -1).length - 1);
        assertTrue(html.contains("\\begin{array}{c}\n1"));
    }

    @Test
    void existingHtmlIsLeftAlone() {
        assertFalse(HtmlSanitizer.toSafeHtml("<p>Bài 1</p>\n<p>Bài 2</p>").contains("<br>"));
    }
}

package com.edututor.util;

import java.util.regex.Pattern;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.safety.Safelist;

/**
 * Làm sạch văn bản do AI sinh ra trước khi lưu/hiển thị (NFR-03).
 * Công thức toán thường chứa các ký tự < > (ví dụ $a<b$) nên chỉ can thiệp khi phát hiện thẻ HTML nguy hiểm.
 */
public final class HtmlSanitizer {

    private static final Pattern DANGEROUS = Pattern.compile(
            "<\\s*/?\\s*(script|iframe|object|embed|img|svg|style|link|meta|form|input|button|video|audio|base|body|html)\\b"
            + "|\\bon[a-z]+\\s*=|javascript\\s*:", Pattern.CASE_INSENSITIVE);

    private HtmlSanitizer() {
    }

    /**
     * Nếu phát hiện mã HTML nguy hiểm: loại bỏ toàn bộ thẻ và trả về văn bản đã escape an toàn;
     * ngược lại giữ nguyên (hiển thị luôn qua c:out hoặc escape phía client).
     */
    public static String clean(String text) {
        if (text == null || text.isEmpty()) {
            return text;
        }
        if (!DANGEROUS.matcher(text).find()) {
            return text;
        }
        Document.OutputSettings out = new Document.OutputSettings().prettyPrint(false);
        return Jsoup.clean(text, "", Safelist.none(), out);
    }
}

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

    private static final Safelist RICH = Safelist.none()
            .addTags("p", "br", "b", "i", "u", "strong", "em", "sub", "sup", "ul", "ol", "li", "div", "span",
                    "h1", "h2", "h3", "h4", "h5", "h6", "table", "thead", "tbody", "tr", "th", "td");

    /** Thẻ được giữ lại; mọi dấu '<' khác (vd. $a<b$) được escape trước khi parse. */
    private static final Pattern STRAY_LT = Pattern.compile(
            "<(?!/?(p|br|b|i|u|strong|em|sub|sup|ul|ol|li|div|span|h[1-6]|table|thead|tbody|tr|th|td)\\b)");

    /**
     * Dùng khi hiển thị nội dung có thể chứa HTML đơn giản (p, ul, b...) lẫn công thức LaTeX:
     * giữ thẻ định dạng an toàn, bỏ mọi thẻ/thuộc tính khác (script, onerror...).
     */
    public static String toSafeHtml(String text) {
        if (text == null || text.isEmpty()) {
            return "";
        }
        String protectedText = STRAY_LT.matcher(text).replaceAll("&lt;");
        Document.OutputSettings out = new Document.OutputSettings().prettyPrint(false);
        return Jsoup.clean(protectedText, "", RICH, out);
    }
}

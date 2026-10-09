package com.edututor.util;

import java.util.regex.Pattern;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.parser.Parser;
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
                    "h1", "h2", "h3", "h4", "h5", "h6", "table", "thead", "tbody", "tr", "th", "td", "img")
            .addAttributes("img", "src", "alt")
            .preserveRelativeLinks(true);

    /** Thẻ được giữ lại; mọi dấu '<' khác (vd. $a<b$) được escape trước khi parse. */
    private static final Pattern STRAY_LT = Pattern.compile(
            "<(?!/?(p|br|b|i|u|strong|em|sub|sup|ul|ol|li|div|span|h[1-6]|table|thead|tbody|tr|th|td|img)(?=[\\s/>]))");

    /**
     * Dùng khi hiển thị nội dung có thể chứa HTML đơn giản (p, ul, b...) lẫn công thức LaTeX:
     * giữ thẻ định dạng an toàn, bỏ mọi thẻ/thuộc tính khác (script, onerror...).
     */
    public static String toSafeHtml(String text) {
        return toSafeHtml(text, "");
    }

    private static final Pattern BLOCK_END = Pattern.compile("(?i)<br\\s*/?>|</(p|div|li|h[1-6]|tr)>");
    private static final Pattern CODE_BLOCK = Pattern.compile("(?is)<(script|style)\\b.*?</\\1\\s*>");
    private static final Pattern MANY_BLANK_LINES = Pattern.compile("\\n{3,}");

    /**
     * Chuyển nội dung HTML (vd. đề SGK "&lt;p&gt;&lt;b&gt;Bài 15.&lt;/b&gt; ...&lt;/p&gt;") thành văn bản thuần để đưa vào
     * hội thoại gia sư: bỏ mọi thẻ, giữ xuống dòng giữa các đoạn và giữ nguyên công thức LaTeX (kể cả '<', '>').
     */
    public static String toPlainText(String html) {
        if (html == null || html.isEmpty()) {
            return "";
        }
        String withoutCode = CODE_BLOCK.matcher(html).replaceAll("");
        String protectedText = STRAY_LT.matcher(withoutCode).replaceAll("&lt;");
        String withBreaks = BLOCK_END.matcher(protectedText).replaceAll("\n");
        Document.OutputSettings out = new Document.OutputSettings().prettyPrint(false);
        String stripped = Jsoup.clean(withBreaks, "", Safelist.none(), out);
        String text = Parser.unescapeEntities(stripped, false).replace(' ', ' ');
        return MANY_BLANK_LINES.matcher(text).replaceAll("\n\n").trim();
    }

    /** Ảnh minh họa chỉ được lấy từ thư mục tĩnh của ứng dụng (vd. hình vẽ trong SGK), không cho nguồn bên ngoài. */
    private static final Pattern LOCAL_IMG = Pattern.compile("^/static/img/[A-Za-z0-9_./-]+$");

    /**
     * Như {@link #toSafeHtml(String)}, và cho phép thẻ {@code <img src="/static/img/...">} (ảnh trong ứng dụng).
     * Ảnh có src khác (http, data:, ngoài thư mục ảnh, chứa "..") bị bỏ; src hợp lệ được nối thêm contextPath
     * (vd. "/edututor") để hiển thị đúng khi ứng dụng không chạy ở gốc.
     */
    public static String toSafeHtml(String text, String contextPath) {
        if (text == null || text.isEmpty()) {
            return "";
        }
        String protectedText = STRAY_LT.matcher(text).replaceAll("&lt;");
        Document.OutputSettings out = new Document.OutputSettings().prettyPrint(false);
        String cleaned = Jsoup.clean(protectedText, "", RICH, out);
        if (!cleaned.contains("<img")) {
            return cleaned;
        }
        Document doc = Jsoup.parseBodyFragment(cleaned);
        doc.outputSettings(out);
        String prefix = contextPath == null ? "" : contextPath;
        for (Element img : doc.select("img")) {
            String src = img.attr("src");
            if (LOCAL_IMG.matcher(src).matches() && !src.contains("..")) {
                img.attr("src", prefix + src);
                img.addClass("img-fluid").addClass("sgk-figure");
                img.attr("loading", "lazy");
            } else {
                img.remove();
            }
        }
        return doc.body().html();
    }
}

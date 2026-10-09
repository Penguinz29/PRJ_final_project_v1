package com.edututor.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Chuyển LaTeX "văn bản" (tabular, center) mà AI hay viết cho bảng biến thiên sang dạng KaTeX hiển thị được:
 * KaTeX chỉ hiểu môi trường toán, nên {@code \begin{tabular}} / {@code \begin{center}} bị in nguyên mã.
 * Bảng được đổi thành {@code $$\begin{array}{...}...\end{array}$$}; các ô toán {@code $...$} bên trong bị bỏ dấu $
 * (đã ở chế độ toán), mũi tên {@code $/$} và {@code $\setminus$} thành {@code \nearrow} / {@code \searrow}.
 */
public final class LatexNormalizer {

    private static final Pattern TABULAR = Pattern.compile(
            "\\\\begin\\{tabular\\}(\\{[^}]*\\})(.*?)\\\\end\\{tabular\\}", Pattern.DOTALL);
    private static final Pattern CENTER = Pattern.compile("\\\\begin\\{center\\}|\\\\end\\{center\\}|\\\\center(?![A-Za-z])");
    private static final Pattern UP_ARROW = Pattern.compile("\\$\\s*/\\s*\\$");
    private static final Pattern DOWN_ARROW = Pattern.compile("\\$\\s*\\\\(?:setminus|backslash|diagdown)\\s*\\$");

    private LatexNormalizer() {
    }

    /**
     * AI hay nhân đôi dấu \ của xuống dòng nên "\n" lọt vào văn bản dưới dạng hai ký tự. Đổi lại thành xuống dòng thật,
     * trừ khi đó là lệnh LaTeX bắt đầu bằng n (\neq, \nu, \not, \nabla ...) hoặc đứng sau dấu \ khác (ngắt dòng \\).
     */
    private static final Pattern LITERAL_NEWLINE = Pattern.compile(
            "(?<!\\\\)\\\\n(?!(?:eq|e|u|abla|otin|ot|eg|i|earrow|warrow|leq|geq|less|gtr|mid|subset|supset|parallel|exists"
                    + "|cong|sim|Leftarrow|Rightarrow|leftarrow|rightarrow|ewline|ewcommand|prec|succ|vdash|vDash)(?![A-Za-z]))");

    /** \left / \right bắt buộc có ký hiệu đi kèm; AI hay viết "\right$" nên KaTeX báo lỗi cả công thức. Thêm dấu chấm (ẩn). */
    private static final Pattern BARE_LEFT_RIGHT = Pattern.compile(
            "\\\\(left|right)(?![A-Za-z])(?!\\s*(?:[()\\[\\]|./<>]|\\\\[{}|]|\\\\(?:langle|rangle|lvert|rvert|lVert|rVert|lfloor"
                    + "|rfloor|lceil|rceil|vert|Vert|backslash|uparrow|downarrow|updownarrow|lbrace|rbrace|lbrack|rbrack"
                    + "|lgroup|rgroup|lmoustache|rmoustache|ulcorner|urcorner|llcorner|lrcorner)(?![A-Za-z])))");
    /** "\hliney'" (mất khoảng trắng / xuống dòng sau \hline) là lệnh không tồn tại; tách lại thành "\hline y'". */
    private static final Pattern GLUED_HLINE = Pattern.compile("\\\\hline(?=[A-Za-z])");

    /** Đoạn "giống toán": chỉ gồm ký tự ASCII của công thức; chữ Việt có dấu làm đứt đoạn nên lời văn không bị bọc nhầm. */
    private static final Pattern BARE_MATH_RUN = Pattern.compile(
            "(?<![\\p{L}\\p{M}])(?:\\\\[A-Za-z]+|[A-Za-z0-9^_{}()\\[\\];,.+\\-*=<>|'/ ])+(?![\\p{L}\\p{M}])");
    private static final Pattern HAS_LATEX_COMMAND = Pattern.compile("\\\\[A-Za-z]{2,}|[\\^_]\\{");

    /**
     * OCR / AI chấm bài hay trả LaTeX trần ("(-\infty;0) \cup (1;+\infty)") không có dấu $ nên KaTeX không render.
     * Với văn bản chưa có dấu $ nào, bọc từng đoạn chứa lệnh LaTeX bằng $...$; văn bản đã có $ giữ nguyên.
     */
    public static String wrapBareMath(String text) {
        if (text == null || text.indexOf('$') >= 0 || text.indexOf('\\') < 0) {
            return text;
        }
        Matcher m = BARE_MATH_RUN.matcher(text);
        StringBuilder out = new StringBuilder();
        int last = 0;
        while (m.find()) {
            String run = m.group();
            String core = run.strip();
            if (core.isEmpty() || !HAS_LATEX_COMMAND.matcher(core).find()) {
                continue;
            }
            int start = m.start() + run.indexOf(core);
            out.append(text, last, start).append('$').append(core).append('$');
            last = start + core.length();
        }
        return out.append(text, last, text.length()).toString();
    }

    public static String normalize(String text) {
        if (text == null) {
            return null;
        }
        String s = LITERAL_NEWLINE.matcher(text).replaceAll("\n");
        s = BARE_LEFT_RIGHT.matcher(s).replaceAll("\\\\$1.");
        s = GLUED_HLINE.matcher(s).replaceAll("\\\\hline ");
        return normalizeTables(s);
    }

    private static String normalizeTables(String text) {
        if (text.indexOf("\\begin{") < 0 && text.indexOf("\\center") < 0) {
            return text;
        }
        StringBuilder out = new StringBuilder();
        Matcher m = TABULAR.matcher(text);
        int last = 0;
        while (m.find()) {
            out.append(text, last, m.start());
            String body = m.group(2);
            body = UP_ARROW.matcher(body).replaceAll(Matcher.quoteReplacement("\\nearrow"));
            body = DOWN_ARROW.matcher(body).replaceAll(Matcher.quoteReplacement("\\searrow"));
            body = body.replace("$", "");
            String table = "\\begin{array}" + m.group(1) + body + "\\end{array}";
            boolean insideDisplayMath = countOccurrences(text.substring(0, m.start()), "$$") % 2 == 1;
            out.append(insideDisplayMath ? table : "$$" + table + "$$");
            last = m.end();
        }
        out.append(text, last, text.length());
        return CENTER.matcher(out).replaceAll("");
    }

    private static int countOccurrences(String s, String sub) {
        int count = 0;
        for (int i = s.indexOf(sub); i >= 0; i = s.indexOf(sub, i + sub.length())) {
            count++;
        }
        return count;
    }
}

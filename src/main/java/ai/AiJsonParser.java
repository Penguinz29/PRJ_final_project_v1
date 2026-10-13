package ai;

import java.util.regex.Pattern;

/** Bóc và vá JSON từ văn bản Gemini trả về (bỏ hàng rào markdown, phần dẫn thừa, sửa dấu \ của LaTeX). */
public final class AiJsonParser {

    /**
     * Lệnh LaTeX bắt đầu bằng b/f/n/r/t: nếu AI quên nhân đôi dấu \ thì JSON coi \frac là form-feed + "rac",
     * \times là tab + "imes"... (parse thành công nhưng công thức hỏng). Chỉ nhận khi lệnh không bị chữ cái nối tiếp.
     */
    private static final Pattern LATEX_AFTER_BACKSLASH = Pattern.compile(
            "(?:frac|flat|forall|beta|bar|begin|binom|boxed|bigcup|bigcap|bigoplus|bullet|"
                    + "text|textbf|textit|theta|tan|tau|to|top|times|tilde|triangle|therefore|"
                    + "neq|ne|nu|nabla|notin|neg|ni|not|nearrow|"
                    + "right|rightarrow|rho|rangle|rfloor|rceil)(?!\\p{L})");

    private AiJsonParser() {
    }

    /**
     * Sửa các dấu \ chưa nhân đôi bên trong chuỗi JSON (LaTeX do AI viết): \Leftrightarrow, \sqrt, \( ... thành
     * \\Leftrightarrow, \\sqrt; \frac, \times... (trùng escape hợp lệ) cũng được nhân đôi. Escape JSON thật
     * (\n, \", \\, \/, mã Unicode 4 số hex, \t không phải lệnh LaTeX) được giữ nguyên. Chỉ tác động bên trong chuỗi "...".
     */
    public static String repairLatexEscapes(String json) {
        if (json == null || json.indexOf('\\') < 0) {
            return json;
        }
        StringBuilder out = new StringBuilder(json.length() + 16);
        boolean inString = false;
        int n = json.length();
        for (int i = 0; i < n; i++) {
            char c = json.charAt(i);
            if (!inString) {
                out.append(c);
                if (c == '"') {
                    inString = true;
                }
                continue;
            }
            if (c == '"') {
                inString = false;
                out.append(c);
            } else if (c != '\\' || i + 1 >= n) {
                out.append(c);
            } else {
                char next = json.charAt(i + 1);
                if (next == '"' || next == '\\' || next == '/') {
                    out.append(c).append(next);   // escape hợp lệ, giữ cả cặp
                    i++;
                } else if (next == 'u' && isHex4(json, i + 2)) {
                    out.append(c);                // mã Unicode 4 số hex hợp lệ
                } else if ("bfnrt".indexOf(next) >= 0) {
                    boolean latex = LATEX_AFTER_BACKSLASH.matcher(json).region(i + 1, n).lookingAt();
                    out.append(c);
                    if (latex) {
                        out.append('\\');         // \frac -> \\frac
                    }
                } else {
                    out.append(c).append('\\');   // escape không hợp lệ (\L, \s, \( ...) -> nhân đôi
                }
            }
        }
        return out.toString();
    }

    private static boolean isHex4(String s, int from) {
        if (from + 4 > s.length()) {
            return false;
        }
        for (int k = from; k < from + 4; k++) {
            if (Character.digit(s.charAt(k), 16) < 0) {
                return false;
            }
        }
        return true;
    }

    /** Bỏ hàng rào markdown ``` và phần dẫn thừa, giữ lại đoạn JSON. */
    public static String extractJson(String raw) {
        String s = raw == null ? "" : raw.trim();
        if (s.startsWith("```")) {
            int nl = s.indexOf('\n');
            s = (nl >= 0) ? s.substring(nl + 1) : s.substring(3);
            int fence = s.lastIndexOf("```");
            if (fence >= 0) {
                s = s.substring(0, fence);
            }
            s = s.trim();
        }
        if (!s.startsWith("{") && !s.startsWith("[")) {
            int obj = s.indexOf('{');
            int arr = s.indexOf('[');
            int start = (obj < 0) ? arr : (arr < 0 ? obj : Math.min(obj, arr));
            int end = Math.max(s.lastIndexOf('}'), s.lastIndexOf(']'));
            if (start >= 0 && end > start) {
                s = s.substring(start, end + 1);
            }
        }
        return s;
    }
}

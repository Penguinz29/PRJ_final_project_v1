package com.edututor.ai;

/** Bóc JSON từ văn bản Gemini trả về (bỏ hàng rào markdown và phần dẫn thừa). */
public final class AiJsonParser {

    private AiJsonParser() {
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

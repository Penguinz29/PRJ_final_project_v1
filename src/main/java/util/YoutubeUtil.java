package util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class YoutubeUtil {

    private static final Pattern YOUTUBE = Pattern.compile(
            "(?:https?:\\/\\/)?(?:www\\.|m\\.)?(?:youtube\\.com\\/(?:[^\\/\\n\\s]+\\/\\S+\\/|(?:v|e(?:mbed)?|shorts)\\/|.*[?&]v=)"
                    + "|youtu\\.be\\/)([a-zA-Z0-9_-]{11})");

    /**
     * Lấy mã video 11 ký tự từ link {@code youtube.com/watch?v=…}, {@code youtu.be/…}, {@code youtube.com/embed/…}
     * hoặc {@code /shorts/…}. Trả về null nếu không phải link YouTube hợp lệ.
     */
    public static String extractId(String url) {
        if (url == null || url.trim().isEmpty()) {
            return null;
        }
        Matcher matcher = YOUTUBE.matcher(url.trim());
        return matcher.find() ? matcher.group(1) : null;
    }
}

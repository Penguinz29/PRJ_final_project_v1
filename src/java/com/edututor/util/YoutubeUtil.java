package com.edututor.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class YoutubeUtil {

    /**
     * Chuyển đổi url video (watch?v=xxx) thành dạng embed
     * Trả về null nếu không hợp lệ
     */
    public static String getEmbedUrl(String url) {
        if (url == null || url.trim().isEmpty())
            return null;

        String pattern = "(?:https?:\\/\\/)?(?:www\\.)?(?:youtube\\.com\\/(?:[^\\/\\n\\s]+\\/\\S+\\/|(?:v|e(?:mbed)?)\\/|.*[?&]v=)|youtu\\.be\\/)([a-zA-Z0-9_-]{11})";
        Pattern compiledPattern = Pattern.compile(pattern);
        Matcher matcher = compiledPattern.matcher(url);

        if (matcher.find()) {
            String videoId = matcher.group(1);
            return "https://www.youtube.com/embed/" + videoId;
        }
        return null; // Trả về url gốc ban đầu nếu bạn muốn, ở đây tôi chọn null
    }
}


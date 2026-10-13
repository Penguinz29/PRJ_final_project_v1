package util;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Iterator;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;

/**
 * Kiểm tra ảnh bài làm tự luận theo VAL-18: định dạng xác định bằng magic bytes (không tin đuôi tệp / MIME do
 * client gửi), đọc được và kích thước tối đa 4096×4096. JPEG / PNG đọc kích thước bằng ImageIO (chỉ đọc header,
 * không giải mã cả ảnh); WebP (JDK không hỗ trợ) đọc kích thước trực tiếp từ header RIFF (VP8 / VP8L / VP8X).
 */
public final class ImageValidator {

    public static final int MAX_DIMENSION = 4096;

    /** Kết quả kiểm tra: MIME, đuôi tệp lưu trữ và kích thước ảnh. */
    public record ImageInfo(String mimeType, String extension, int width, int height) {
    }

    private ImageValidator() {
    }

    /**
     * @throws IllegalArgumentException ảnh sai định dạng, hỏng hoặc vượt 4096×4096 (thông báo tiếng Việt)
     */
    public static ImageInfo validate(byte[] b) {
        ImageInfo info;
        if (isPng(b)) {
            info = readWithImageIo(b, "image/png", "png");
        } else if (isJpeg(b)) {
            info = readWithImageIo(b, "image/jpeg", "jpg");
        } else if (isWebp(b)) {
            info = readWebp(b);
        } else {
            throw new IllegalArgumentException("Chỉ chấp nhận ảnh định dạng JPG, PNG hoặc WebP.");
        }
        if (info.width() <= 0 || info.height() <= 0) {
            throw new IllegalArgumentException("Ảnh bị hỏng hoặc không đọc được.");
        }
        if (info.width() > MAX_DIMENSION || info.height() > MAX_DIMENSION) {
            throw new IllegalArgumentException("Ảnh quá lớn (" + info.width() + "×" + info.height()
                    + " px). Kích thước tối đa là " + MAX_DIMENSION + "×" + MAX_DIMENSION + " px.");
        }
        return info;
    }

    static boolean isPng(byte[] b) {
        return b.length > 8 && (b[0] & 0xFF) == 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G';
    }

    static boolean isJpeg(byte[] b) {
        return b.length > 3 && (b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF;
    }

    /** WebP: "RIFF" + 4 byte kích thước + "WEBP". */
    static boolean isWebp(byte[] b) {
        return b.length >= 30 && b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F'
                && b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P';
    }

    private static ImageInfo readWithImageIo(byte[] b, String mime, String ext) {
        try (ImageInputStream in = ImageIO.createImageInputStream(new ByteArrayInputStream(b))) {
            Iterator<ImageReader> readers = in == null ? null : ImageIO.getImageReaders(in);
            if (readers == null || !readers.hasNext()) {
                throw new IllegalArgumentException("Ảnh bị hỏng hoặc không đọc được.");
            }
            ImageReader reader = readers.next();
            try {
                reader.setInput(in, true, true);
                return new ImageInfo(mime, ext, reader.getWidth(0), reader.getHeight(0));
            } finally {
                reader.dispose();
            }
        } catch (IOException | RuntimeException e) {
            if (e instanceof IllegalArgumentException iae && iae.getMessage() != null
                    && iae.getMessage().startsWith("Ảnh")) {
                throw iae;
            }
            throw new IllegalArgumentException("Ảnh bị hỏng hoặc không đọc được.");
        }
    }

    /** Đọc kích thước từ chunk đầu tiên của WebP (định dạng theo đặc tả RIFF WebP của Google). */
    private static ImageInfo readWebp(byte[] b) {
        String chunk = new String(b, 12, 4, java.nio.charset.StandardCharsets.US_ASCII);
        int w;
        int h;
        switch (chunk) {
            case "VP8 " -> {
                // Lossy: frame tag (3 byte) + start code 9D 01 2A, rồi 2 byte rộng, 2 byte cao (14 bit thấp)
                if ((b[23] & 0xFF) != 0x9D || (b[24] & 0xFF) != 0x01 || (b[25] & 0xFF) != 0x2A) {
                    throw new IllegalArgumentException("Ảnh bị hỏng hoặc không đọc được.");
                }
                w = le16(b, 26) & 0x3FFF;
                h = le16(b, 28) & 0x3FFF;
            }
            case "VP8L" -> {
                // Lossless: chữ ký 0x2F, rồi 14 bit (rộng - 1) và 14 bit (cao - 1)
                if ((b[20] & 0xFF) != 0x2F) {
                    throw new IllegalArgumentException("Ảnh bị hỏng hoặc không đọc được.");
                }
                int bits = (b[21] & 0xFF) | (b[22] & 0xFF) << 8 | (b[23] & 0xFF) << 16 | (b[24] & 0xFF) << 24;
                w = (bits & 0x3FFF) + 1;
                h = ((bits >> 14) & 0x3FFF) + 1;
            }
            case "VP8X" -> {
                // Extended: 24 bit (rộng - 1) tại offset 24, 24 bit (cao - 1) tại offset 27
                w = le24(b, 24) + 1;
                h = le24(b, 27) + 1;
            }
            default -> throw new IllegalArgumentException("Ảnh bị hỏng hoặc không đọc được.");
        }
        return new ImageInfo("image/webp", "webp", w, h);
    }

    private static int le16(byte[] b, int off) {
        return (b[off] & 0xFF) | (b[off + 1] & 0xFF) << 8;
    }

    private static int le24(byte[] b, int off) {
        return (b[off] & 0xFF) | (b[off + 1] & 0xFF) << 8 | (b[off + 2] & 0xFF) << 16;
    }
}

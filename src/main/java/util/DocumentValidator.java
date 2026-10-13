package util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * Kiểm tra tệp đề bài / đáp án / bài làm do người dùng tải lên: ảnh (JPG, PNG, WebP), PDF hoặc Word (.docx).
 * Định dạng xác định bằng magic bytes, không tin đuôi tệp hay MIME do client gửi.
 * <ul>
 *   <li>Ảnh: kiểm tra bằng {@link ImageValidator}.</li>
 *   <li>PDF: chỉ kiểm tra chữ ký "%PDF-"; Gemini đọc trực tiếp PDF.</li>
 *   <li>DOCX: giải nén an toàn (giới hạn dung lượng), lấy văn bản + ảnh nhúng ({@code word/media}).
 *       Không hỗ trợ .doc cũ.</li>
 * </ul>
 */
public final class DocumentValidator {

    public enum Kind { IMAGE, PDF, DOCX }

    /** Ảnh nhúng trong tệp Word. */
    public record EmbeddedImage(String mimeType, byte[] data) {
    }

    /** Kết quả kiểm tra. {@code text} và {@code images} chỉ có ý nghĩa với DOCX. */
    public record Info(Kind kind, String mimeType, String extension, String text, List<EmbeddedImage> images) {
    }

    public static final String DOCX_MIME = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
    public static final String UNSUPPORTED_MESSAGE =
            "Chỉ chấp nhận tệp PDF, Word (.docx) hoặc ảnh JPG, PNG, WebP.";

    private static final int MAX_DOCUMENT_XML = 8 * 1024 * 1024;
    private static final int MAX_EMBEDDED_IMAGE = 3 * 1024 * 1024;
    private static final int MAX_EMBEDDED_IMAGES = 5;
    private static final int MAX_ZIP_ENTRIES = 2000;
    private static final int MAX_TEXT_LENGTH = 60_000;

    /** Nội dung chữ trong Word (w:t) và công thức (m:t), ngắt đoạn, tab, xuống dòng. */
    private static final Pattern DOCX_TOKEN = Pattern.compile(
            "<(?:w|m):t(?:\\s[^>]*)?>([^<]*)</(?:w|m):t>|</w:p>|<w:tab\\s*/>|<w:br\\s*/>");

    private DocumentValidator() {
    }

    /**
     * @throws IllegalArgumentException tệp sai định dạng, hỏng hoặc không có nội dung (thông báo tiếng Việt)
     */
    public static Info validate(byte[] b) {
        if (b == null || b.length == 0) {
            throw new IllegalArgumentException("Tệp tải lên bị rỗng.");
        }
        if (isPdf(b)) {
            return new Info(Kind.PDF, "application/pdf", "pdf", "", List.of());
        }
        if (isZip(b)) {
            return readDocx(b);
        }
        if (isOleCompound(b)) {
            throw new IllegalArgumentException(
                    "Chưa hỗ trợ Word định dạng cũ (.doc). Vui lòng lưu lại thành .docx hoặc PDF.");
        }
        try {
            ImageValidator.ImageInfo img = ImageValidator.validate(b);
            return new Info(Kind.IMAGE, img.mimeType(), img.extension(), "", List.of());
        } catch (IllegalArgumentException e) {
            // Ảnh sai định dạng: nhắc cả PDF/Word; ảnh hỏng hoặc quá lớn: giữ nguyên thông báo cụ thể
            if (e.getMessage() != null && e.getMessage().startsWith("Chỉ chấp nhận ảnh")) {
                throw new IllegalArgumentException(UNSUPPORTED_MESSAGE);
            }
            throw e;
        }
    }

    static boolean isPdf(byte[] b) {
        return b.length > 5 && b[0] == '%' && b[1] == 'P' && b[2] == 'D' && b[3] == 'F' && b[4] == '-';
    }

    static boolean isZip(byte[] b) {
        return b.length > 4 && b[0] == 'P' && b[1] == 'K' && b[2] == 3 && b[3] == 4;
    }

    private static boolean isOleCompound(byte[] b) {
        return b.length > 8 && (b[0] & 0xFF) == 0xD0 && (b[1] & 0xFF) == 0xCF && (b[2] & 0xFF) == 0x11
                && (b[3] & 0xFF) == 0xE0;
    }

    private static Info readDocx(byte[] b) {
        byte[] documentXml = null;
        List<EmbeddedImage> images = new ArrayList<>();
        try (ZipInputStream zip = new ZipInputStream(new ByteArrayInputStream(b), StandardCharsets.UTF_8)) {
            ZipEntry entry;
            int count = 0;
            while ((entry = zip.getNextEntry()) != null) {
                if (++count > MAX_ZIP_ENTRIES) {
                    throw new IllegalArgumentException("Tệp Word không hợp lệ.");
                }
                String name = entry.getName();
                if (name.equals("word/document.xml")) {
                    documentXml = readLimited(zip, MAX_DOCUMENT_XML);
                } else if (images.size() < MAX_EMBEDDED_IMAGES && name.startsWith("word/media/")) {
                    byte[] data = readLimited(zip, MAX_EMBEDDED_IMAGE);
                    addIfValidImage(images, data);
                }
            }
        } catch (IOException e) {
            throw new IllegalArgumentException("Không đọc được tệp. Tệp có thể bị hỏng.");
        }
        if (documentXml == null) {
            // ZIP nhưng không phải Word (ví dụ xlsx, pptx, zip thường)
            throw new IllegalArgumentException(UNSUPPORTED_MESSAGE);
        }
        String text = extractText(new String(documentXml, StandardCharsets.UTF_8));
        if (text.isBlank() && images.isEmpty()) {
            throw new IllegalArgumentException("Tệp Word không có nội dung chữ hoặc hình ảnh để đọc.");
        }
        return new Info(Kind.DOCX, DOCX_MIME, "docx", text, images);
    }

    private static void addIfValidImage(List<EmbeddedImage> images, byte[] data) {
        if (data == null) {
            return;
        }
        try {
            ImageValidator.ImageInfo info = ImageValidator.validate(data);
            images.add(new EmbeddedImage(info.mimeType(), data));
        } catch (IllegalArgumentException ignored) {
            // định dạng không hỗ trợ (emf, wmf, gif...) hoặc ảnh hỏng: bỏ qua
        }
    }

    /** Đọc tối đa {@code limit} byte của mục hiện tại; vượt giới hạn trả null (chống zip bomb). */
    private static byte[] readLimited(InputStream in, int limit) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] buf = new byte[8192];
        int n;
        while ((n = in.read(buf)) > 0) {
            if (out.size() + n > limit) {
                return null;
            }
            out.write(buf, 0, n);
        }
        return out.toByteArray();
    }

    static String extractText(String xml) {
        StringBuilder sb = new StringBuilder();
        Matcher m = DOCX_TOKEN.matcher(xml);
        while (m.find()) {
            String token = m.group();
            if (m.group(1) != null) {
                sb.append(unescapeXml(m.group(1)));
            } else if (token.startsWith("<w:tab")) {
                sb.append('\t');
            } else {
                sb.append('\n'); // </w:p> hoặc <w:br/>
            }
            if (sb.length() > MAX_TEXT_LENGTH) {
                sb.setLength(MAX_TEXT_LENGTH);
                break;
            }
        }
        return sb.toString().replaceAll("\\n{3,}", "\n\n").trim();
    }

    private static String unescapeXml(String s) {
        return s.replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", "\"")
                .replace("&apos;", "'").replace("&amp;", "&");
    }

    /** MIME để phục vụ lại tệp đã lưu (tên tệp do server sinh, đuôi lấy từ kết quả {@link #validate}). */
    public static String mimeForExtension(String filename) {
        String lower = filename.toLowerCase(Locale.ROOT);
        if (lower.endsWith(".png")) {
            return "image/png";
        } else if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
            return "image/jpeg";
        } else if (lower.endsWith(".webp")) {
            return "image/webp";
        } else if (lower.endsWith(".pdf")) {
            return "application/pdf";
        } else if (lower.endsWith(".docx")) {
            return DOCX_MIME;
        }
        return "application/octet-stream";
    }
}

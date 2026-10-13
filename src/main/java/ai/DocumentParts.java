package ai;

import ai.GeminiClient.Part;
import util.DocumentValidator;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

/** Chuyển tệp đã kiểm tra thành các Part gửi Gemini: ảnh/PDF gửi inline, Word gửi chữ + ảnh nhúng. */
public final class DocumentParts {

    private DocumentParts() {
    }

    public static List<Part> of(DocumentValidator.Info info, byte[] data) {
        List<Part> parts = new ArrayList<>();
        switch (info.kind()) {
            case IMAGE, PDF -> parts.add(Part.image(info.mimeType(), Base64.getEncoder().encodeToString(data)));
            case DOCX -> {
                if (!info.text().isBlank()) {
                    parts.add(Part.text("[Nội dung văn bản của tệp Word]\n" + info.text()));
                }
                for (DocumentValidator.EmbeddedImage img : info.images()) {
                    parts.add(Part.image(img.mimeType(), Base64.getEncoder().encodeToString(img.data())));
                }
            }
        }
        return parts;
    }
}

package controller;

import dto.view.SessionUser;
import exception.ForbiddenException;
import exception.NotFoundException;
import config.AuthInterceptor;
import service.FileStorageService;
import service.SubmissionService;
import util.DocumentValidator;
import java.nio.file.Path;
import java.util.Locale;
import java.util.concurrent.TimeUnit;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.SessionAttribute;

/**
 * Phục vụ tệp bài làm (ảnh / PDF / Word) tự luận lưu ngoài thư mục web. Ảnh chỉ được trả về cho chủ bài làm (học sinh),
 * giáo viên hoặc admin; học sinh khác nhận 403. Tên tệp do server sinh nên không có path traversal.
 */
@Controller
public class FileController {

    private final SubmissionService submissionService;
    private final FileStorageService storage;

    public FileController(SubmissionService submissionService, FileStorageService storage) {
        this.submissionService = submissionService;
        this.storage = storage;
    }

    /** Ảnh lưu theo thư mục học sinh: /uploads/essays/{studentId}/{uuid}.{ext} (SRS 6.3). */
    @GetMapping("/uploads/essays/{studentId:\\d+}/{filename:[A-Za-z0-9._-]+}")
    public ResponseEntity<Resource> essayImageByStudent(@PathVariable String studentId, @PathVariable String filename,
                                                        @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        return serve("essays/" + studentId + "/" + filename, user);
    }

    /** Ảnh cũ lưu phẳng trong thư mục upload (trước khi tách theo học sinh). */
    @GetMapping("/uploads/{filename:[A-Za-z0-9._-]+}")
    public ResponseEntity<Resource> essayImage(@PathVariable String filename,
                                               @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        return serve(filename, user);
    }

    private ResponseEntity<Resource> serve(String relative, SessionUser user) {
        String filename = relative.substring(relative.lastIndexOf('/') + 1);
        String urlPath = FileStorageService.URL_PREFIX + relative;
        Integer ownerId = submissionService.findEssayImageOwner(urlPath)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy ảnh bài làm."));
        if (user.isStudent() && ownerId != user.getUserId()) {
            throw new ForbiddenException("Bạn không có quyền xem ảnh bài làm này.");
        }
        Path file = storage.resolve(urlPath);
        if (file == null) {
            throw new NotFoundException("Không tìm thấy ảnh bài làm.");
        }
        MediaType type = MediaType.parseMediaType(DocumentValidator.mimeForExtension(filename));
        // Word không xem trực tiếp trên trình duyệt được: buộc tải về; ảnh và PDF xem tại chỗ
        String disposition = filename.toLowerCase(Locale.ROOT).endsWith(".docx") ? "attachment" : "inline";
        return ResponseEntity.ok()
                .contentType(type)
                .header("Content-Disposition", disposition + "; filename=\"bai-lam-" + filename + "\"")
                .cacheControl(CacheControl.maxAge(1, TimeUnit.HOURS).cachePrivate())
                .header("X-Content-Type-Options", "nosniff")
                .body(new FileSystemResource(file));
    }
}

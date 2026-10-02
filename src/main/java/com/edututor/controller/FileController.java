package com.edututor.controller;

import com.edututor.dto.SessionUser;
import com.edututor.exception.ForbiddenException;
import com.edututor.exception.NotFoundException;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.FileStorageService;
import com.edututor.service.SubmissionService;
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
 * Phục vụ ảnh bài làm tự luận lưu ngoài thư mục web. Ảnh chỉ được trả về cho chủ bài làm (học sinh),
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

    @GetMapping("/uploads/{filename:[A-Za-z0-9._-]+}")
    public ResponseEntity<Resource> essayImage(@PathVariable String filename,
                                               @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user) {
        String urlPath = FileStorageService.URL_PREFIX + filename;
        Integer ownerId = submissionService.findEssayImageOwner(urlPath)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy ảnh bài làm."));
        if (user.isStudent() && ownerId != user.getUserId()) {
            throw new ForbiddenException("Bạn không có quyền xem ảnh bài làm này.");
        }
        Path file = storage.resolve(urlPath);
        if (file == null) {
            throw new NotFoundException("Không tìm thấy ảnh bài làm.");
        }
        String lower = filename.toLowerCase(Locale.ROOT);
        MediaType type = lower.endsWith(".png") ? MediaType.IMAGE_PNG
                : (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) ? MediaType.IMAGE_JPEG
                : MediaType.APPLICATION_OCTET_STREAM;
        return ResponseEntity.ok()
                .contentType(type)
                .cacheControl(CacheControl.maxAge(1, TimeUnit.HOURS).cachePrivate())
                .header("X-Content-Type-Options", "nosniff")
                .body(new FileSystemResource(file));
    }
}

package com.edututor.service;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Lưu ảnh bài làm ngoài thư mục webapp (không mất khi redeploy). Tên tệp do server sinh (UUID),
 * không dùng tên người dùng gửi lên nên không có nguy cơ path traversal.
 * Ảnh chỉ được phục vụ lại qua controller có kiểm tra quyền (xem {@code FileController}).
 */
@Service
public class FileStorageService {

    public static final String URL_PREFIX = "/uploads/";

    private final Path root;

    public FileStorageService(@Value("${UPLOAD_DIR:${app.upload-dir}}") String uploadDir) {
        this.root = Paths.get(uploadDir).toAbsolutePath().normalize();
    }

    /** @return đường dẫn tương đối để lưu CSDL, ví dụ /uploads/3f2a....png */
    public String store(byte[] data, String extension) {
        try {
            Files.createDirectories(root);
            String name = UUID.randomUUID() + "." + extension;
            Files.write(root.resolve(name), data);
            return URL_PREFIX + name;
        } catch (IOException e) {
            throw new UncheckedIOException("Không thể lưu ảnh bài làm: " + e.getMessage(), e);
        }
    }

    /**
     * Phân giải đường dẫn tương đối thành tệp trong thư mục upload.
     *
     * @return null nếu đường dẫn thoát khỏi thư mục gốc (path traversal) hoặc tệp không tồn tại
     */
    public Path resolve(String urlPath) {
        if (urlPath == null || !urlPath.startsWith(URL_PREFIX)) {
            return null;
        }
        Path file = root.resolve(urlPath.substring(URL_PREFIX.length())).normalize();
        return file.startsWith(root) && Files.isRegularFile(file) ? file : null;
    }

    public void deleteQuietly(String urlPath) {
        if (urlPath == null || !urlPath.startsWith(URL_PREFIX)) {
            return;
        }
        try {
            Path file = root.resolve(urlPath.substring(URL_PREFIX.length())).normalize();
            if (file.startsWith(root)) {
                Files.deleteIfExists(file);
            }
        } catch (IOException ignored) {
            // không quan trọng
        }
    }
}

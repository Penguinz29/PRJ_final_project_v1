package com.mathtutor.util;

import jakarta.servlet.http.Part;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

public class FileUtil {

    // Helper folder outside webapp or inside upload folder
    private static final String UPLOAD_DIR = "uploads";

    public static String uploadFile(Part filePart, String appPath) throws Exception {
        if (filePart == null || filePart.getSize() == 0) return null;

        String fileName = extractFileName(filePart);
        if (fileName.isEmpty()) return null;

        String ext = fileName.substring(fileName.lastIndexOf("."));
        String newName = UUID.randomUUID().toString() + ext;

        // Xây dựng đường dẫn (Bạn có thể lưu ở ổ C:uploads hoặc thư mục app)
        String uploadPath = appPath + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        Path outPath = Paths.get(uploadPath + File.separator + newName);
        try (InputStream is = filePart.getInputStream()) {
            Files.copy(is, outPath, StandardCopyOption.REPLACE_EXISTING);
        }

        return UPLOAD_DIR + "/" + newName;
    }

    private static String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }
}

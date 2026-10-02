package com.edututor.controller.admin;

import com.edututor.dao.AiConfigDAO;
import com.edututor.model.AiConfig;
import com.edututor.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet(urlPatterns = {"/admin/ai-config", "/admin/ai-config/update", "/admin/ai-config/test-connection"})
public class AdminAiConfigController extends HttpServlet {
    private AiConfigDAO aiConfigDAO = new AiConfigDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<AiConfig> configs = aiConfigDAO.getAll();
        req.setAttribute("configs", configs);
        req.getRequestDispatcher("/WEB-INF/views/admin/ai-config.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        User currentUser = (User) req.getSession().getAttribute("LOGGED_IN_USER");

        if (uri.endsWith("/test-connection")) {
            handleTestConnection(req, resp);
        } else if (uri.endsWith("/update")) {
            handleUpdate(req, resp, currentUser);
        }
    }

    /**
     * FR-ADM-01: Cập nhật cấu hình AI
     */
    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws IOException {
        String[] keys = {"GEMINI_API_KEY", "DEFAULT_MODEL", "VISION_MODEL", "TUTOR_TEMPERATURE", "MAX_OUTPUT_TOKENS"};
        int uid = (currentUser != null) ? currentUser.getUserId() : 1;

        for (String key : keys) {
            String value = req.getParameter(key);
            if (value != null) {
                aiConfigDAO.update(key, value.trim(), uid);
            }
        }

        req.getSession().setAttribute("flash", "Cập nhật cấu hình AI thành công!");
        resp.sendRedirect(req.getContextPath() + "/admin/ai-config");
    }

    /**
     * FR-ADM-02: Test API Connection - Ping Gemini API
     */
    private void handleTestConnection(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String apiKey = req.getParameter("GEMINI_API_KEY");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            apiKey = aiConfigDAO.getValue("GEMINI_API_KEY");
        }

        String model = req.getParameter("DEFAULT_MODEL");
        if (model == null || model.trim().isEmpty()) {
            model = aiConfigDAO.getValue("DEFAULT_MODEL");
        }

        if (apiKey == null || apiKey.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"API Key chưa được cấu hình. Vui lòng nhập GEMINI_API_KEY.\"}");
            return;
        }

        if (model == null || model.trim().isEmpty()) {
            model = "gemini-1.5-flash";
        }

        try {
            // Gọi Gemini API với prompt đơn giản
            String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/"
                    + model + ":generateContent?key=" + apiKey;

            String payload = "{\"contents\":[{\"parts\":[{\"text\":\"Ping. Reply with: Pong\"}]}],"
                    + "\"generationConfig\":{\"maxOutputTokens\":50}}";

            URL url = new URL(endpoint);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(15000);
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(payload.getBytes(StandardCharsets.UTF_8));
            }

            int statusCode = conn.getResponseCode();

            if (statusCode == 200) {
                // Đọc response để xác nhận
                java.io.InputStream is = conn.getInputStream();
                String body = new String(is.readAllBytes(), StandardCharsets.UTF_8);
                is.close();
                out.print("{\"success\":true,\"message\":\"Kết nối Gemini API thành công! Model: " + model + "\",\"statusCode\":200}");
            } else {
                java.io.InputStream es = conn.getErrorStream();
                String errBody = (es != null) ? new String(es.readAllBytes(), StandardCharsets.UTF_8) : "Unknown error";
                if (es != null) es.close();

                // Trích xuất message ngắn gọn
                String shortErr = errBody.length() > 200 ? errBody.substring(0, 200) + "..." : errBody;
                shortErr = shortErr.replace("\"", "'").replace("\n", " ").replace("\r", "");
                out.print("{\"success\":false,\"message\":\"HTTP " + statusCode + ": " + shortErr + "\"}");
            }

            conn.disconnect();
        } catch (Exception e) {
            String errMsg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Lỗi không xác định";
            out.print("{\"success\":false,\"message\":\"Lỗi kết nối: " + errMsg + "\"}");
        }
    }
}


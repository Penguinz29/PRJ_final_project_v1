package com.mathtutor.controller.teacher;

import com.mathtutor.dao.LessonDAO;
import com.mathtutor.dao.QuestionDAO;
import com.mathtutor.dao.TopicDAO;
import com.mathtutor.model.Lesson;
import com.mathtutor.model.Question;
import com.mathtutor.model.QuestionOption;
import com.mathtutor.model.Topic;
import com.mathtutor.model.User;
import com.mathtutor.service.AiExamService;
import com.mathtutor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

/**
 * FR-TEA-03: Servlet sinh đề thi trắc nghiệm bằng Gemini AI (Smart Exam Generator)
 * Đáp ứng endpoint FRS 4.2: POST /api/teacher/generate-questions
 */
@WebServlet(urlPatterns = {
    "/api/teacher/generate-questions",
    "/teacher/questions/generate-ai",
    "/teacher/questions/save-ai",
    "/teacher/lessons-by-topic"
})
public class TeacherAiExamServlet extends HttpServlet {

    private AiExamService aiExamService = new AiExamService();
    private QuestionDAO questionDAO = new QuestionDAO();
    private LessonDAO lessonDAO = new LessonDAO();
    private TopicDAO topicDAO = new TopicDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        if (uri.endsWith("/lessons-by-topic")) {
            handleGetLessonsByTopic(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String uri = req.getRequestURI();
        if (uri.endsWith("/generate-questions") || uri.endsWith("/generate-ai")) {
            handleGenerateQuestions(req, resp);
        } else if (uri.endsWith("/save-ai")) {
            handleSaveAiQuestions(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * AJAX lấy danh sách bài học theo chuyên đề
     */
    private void handleGetLessonsByTopic(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        int topicId = Validator.getInt(req, "topicId", 0);

        List<Lesson> lessons = lessonDAO.getByTopicId(topicId);
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < lessons.size(); i++) {
            Lesson l = lessons.get(i);
            sb.append("{\"lessonId\":").append(l.getLessonId())
              .append(",\"title\":\"").append(escapeJson(l.getTitle())).append("\"}");
            if (i < lessons.size() - 1) sb.append(",");
        }
        sb.append("]");
        out.print(sb.toString());
    }

    /**
     * FR-TEA-03: Gọi Gemini AI sinh danh sách câu hỏi
     */
    private void handleGenerateQuestions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        int lessonId = Validator.getInt(req, "lessonId", 0);
        int level = Validator.getInt(req, "level", 1);
        int count = Validator.getInt(req, "count", 3);

        if (count < 1) count = 3;
        if (count > 10) count = 10;

        Lesson lesson = (lessonId > 0) ? lessonDAO.getById(lessonId) : null;
        String lessonName = (lesson != null) ? lesson.getTitle() : req.getParameter("lessonName");
        String topicName = (lesson != null && lesson.getTopicName() != null) ? lesson.getTopicName() : req.getParameter("topicName");

        try {
            String questionsJsonArray = aiExamService.generateQuestions(topicName, lessonName, level, count);
            out.print("{\"success\":true,\"lessonId\":" + lessonId + ",\"questions\":" + questionsJsonArray + "}");
        } catch (Exception e) {
            String msg = (e.getMessage() != null) ? escapeJson(e.getMessage()) : "Lỗi không xác định khi sinh câu hỏi từ AI";
            out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
    }

    /**
     * Lưu các câu hỏi do AI sinh vào Database với IsAiGenerated = 1
     */
    private void handleSaveAiQuestions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        User currentUser = (User) req.getSession().getAttribute("currentUser");

        int lessonId = Validator.getInt(req, "lessonId", 0);
        int count = Validator.getInt(req, "count", 0);

        if (lessonId <= 0 || count <= 0) {
            out.print("{\"success\":false,\"message\":\"Dữ liệu câu hỏi hoặc bài học không hợp lệ.\"}");
            return;
        }

        int savedCount = 0;
        String[] letters = {"A", "B", "C", "D"};

        for (int i = 0; i < count; i++) {
            String content = req.getParameter("q_" + i + "_content");
            if (content == null || content.trim().isEmpty()) {
                continue; // Bỏ qua câu hỏi không được chọn hoặc rỗng
            }

            int level = Validator.getInt(req, "q_" + i + "_level", 1);
            String explanation = req.getParameter("q_" + i + "_explanation");
            String correct = req.getParameter("q_" + i + "_correct");
            if (correct == null || correct.isEmpty()) correct = "A";

            // Gắn thêm lời giải vào nội dung nếu có
            String finalContent = content.trim();
            if (explanation != null && !explanation.trim().isEmpty()) {
                finalContent += "\n\n**Lời giải chi tiết:**\n" + explanation.trim();
            }

            Question q = new Question();
            q.setLessonId(lessonId);
            q.setQuestionType("MCQ");
            q.setContent(finalContent);
            q.setLevel(level);
            q.setAiGenerated(true); // Đánh dấu câu hỏi do AI sinh
            int teacherId = (currentUser != null) ? currentUser.getUserId() : 1;
            q.setTeacherId(teacherId);

            int qId = questionDAO.insert(q);
            if (qId > 0) {
                List<QuestionOption> options = new ArrayList<>();
                for (String l : letters) {
                    String optContent = req.getParameter("q_" + i + "_opt_" + l);
                    QuestionOption opt = new QuestionOption();
                    opt.setQuestionId(qId);
                    opt.setOptionLetter(l);
                    opt.setContent(optContent != null ? optContent.trim() : "");
                    opt.setCorrect(l.equalsIgnoreCase(correct));
                    options.add(opt);
                }
                questionDAO.insertOptions(qId, options);
                savedCount++;
            }
        }

        if (savedCount > 0) {
            req.getSession().setAttribute("flash", "Đã lưu thành công " + savedCount + " câu hỏi AI vào Ngân hàng đề!");
            out.print("{\"success\":true,\"savedCount\":" + savedCount + ",\"message\":\"Đã lưu " + savedCount + " câu hỏi vào ngân hàng đề thành công!\"}");
        } else {
            out.print("{\"success\":false,\"message\":\"Không có câu hỏi nào được lưu.\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}

package com.mathtutor.controller.teacher;

import com.mathtutor.dao.LessonDAO;
import com.mathtutor.dao.QuestionDAO;
import com.mathtutor.dao.TopicDAO;
import com.mathtutor.model.Topic;
import com.mathtutor.model.User;
import com.mathtutor.util.Validator;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = { "/teacher/questions", "/teacher/question/form" })
public class TeacherQuestionServlet extends HttpServlet {
    private QuestionDAO questionDAO = new QuestionDAO();
    private TopicDAO topicDAO = new TopicDAO();
    private LessonDAO lessonDAO = new LessonDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        String action = Validator.getString(req, "action", "");
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        List<Topic> topics = topicDAO.getByTeacherId(currentUser.getUserId());
        if (topics == null || topics.isEmpty()) {
            topics = topicDAO.getAll();
        }
        req.setAttribute("topics", topics);

        if (path.equals("/teacher/question/form") || "create".equals(action) || "edit".equals(action)) {
            if (topics != null && !topics.isEmpty()) {
                req.setAttribute("lessons", lessonDAO.getByTopicId(topics.get(0).getTopicId()));
            } else {
                req.setAttribute("lessons", lessonDAO.getAll());
            }
            if ("edit".equals(action)) {
                req.setAttribute("isEdit", true);
                req.setAttribute("question", questionDAO.getById(Validator.getInt(req, "id", 0)));
                req.setAttribute("optionsList", questionDAO.getOptions(Validator.getInt(req, "id", 0)));
            }
            req.getRequestDispatcher("/WEB-INF/views/teacher/question-form.jsp").forward(req, resp);
            return;
        }

        if (path.equals("/teacher/questions")) {
            int filterLessonId = Validator.getInt(req, "lessonId", 0);
            String questionType = Validator.getString(req, "questionType", "MCQ");

            if (topics != null && !topics.isEmpty()) {
                req.setAttribute("lessons", lessonDAO.getByTopicId(topics.get(0).getTopicId()));
            }
            if (filterLessonId > 0) {
                req.setAttribute("questions", questionDAO.getByLessonAndType(filterLessonId, questionType));
            } else {
                req.setAttribute("questions", questionDAO.getAll());
            }
            req.setAttribute("filterLessonId", filterLessonId);
            req.setAttribute("questionType", questionType);
            req.getRequestDispatcher("/WEB-INF/views/teacher/questions.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = Validator.getString(req, "action", "create");
        int lessonId = Validator.getInt(req, "lessonId", 0);
        String type = Validator.getString(req, "type", "MCQ");
        int level = Validator.getInt(req, "level", 1);
        String content = Validator.getString(req, "content", "");

        User currentUser = (User) req.getSession().getAttribute("currentUser");

        com.mathtutor.model.Question q = new com.mathtutor.model.Question();
        q.setLessonId(lessonId);
        q.setQuestionType(type);
        q.setContent(content);
        q.setLevel(level);
        q.setAiGenerated(false);
        q.setTeacherId(currentUser.getUserId());

        if ("create".equals(action)) {
            int qId = questionDAO.insert(q);
            if (qId > 0 && "MCQ".equals(type)) {
                String correct = Validator.getString(req, "correctOption", "A");
                java.util.List<com.mathtutor.model.QuestionOption> opts = new java.util.ArrayList<>();
                String[] letters = { "A", "B", "C", "D" };
                for (String l : letters) {
                    com.mathtutor.model.QuestionOption o = new com.mathtutor.model.QuestionOption();
                    o.setOptionLetter(l);
                    o.setContent(Validator.getString(req, "opt_" + l, ""));
                    o.setCorrect(l.equals(correct));
                    opts.add(o);
                }
                questionDAO.insertOptions(qId, opts);
            }
            req.getSession().setAttribute("success", "Thêm câu hỏi thành công.");
        }
        resp.sendRedirect(req.getContextPath() + "/teacher/questions?lessonId=" + lessonId + "&questionType=" + type);
    }
}

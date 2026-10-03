package com.edututor.controller.student;

import com.edututor.dto.SessionUser;
import com.edututor.dto.TutorMessageView;
import com.edututor.dto.TutorSessionView;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.AiTutorService;
import com.edututor.service.TopicService;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;

/**
 * Trang Gia sư AI: chọn bài học, xem lại phiên cũ. Tương tác từng bước đi qua POST /api/tutor/next-step.
 * Phiên của học sinh khác → 403 (BR-14), phiên không tồn tại → 404 (xử lý tập trung ở GlobalExceptionHandler).
 */
@Controller
public class StudentTutorController {

    private final AiTutorService tutorService;
    private final TopicService topicService;

    public StudentTutorController(AiTutorService tutorService, TopicService topicService) {
        this.tutorService = tutorService;
        this.topicService = topicService;
    }

    /**
     * @param mode       QUESTION | SUBMISSION: trang tự gọi POST /api/tutor/start để mở phiên từ câu trắc nghiệm
     *                   vừa làm sai (questionId) hoặc bài tự luận vừa chấm (submissionId). Quyền được kiểm tra ở API.
     */
    @GetMapping("/student/ai-tutor")
    public String tutor(@RequestParam(required = false) Integer sessionId,
                        @RequestParam(required = false) Integer lessonId,
                        @RequestParam(required = false) String mode,
                        @RequestParam(required = false) Integer questionId,
                        @RequestParam(required = false) Integer submissionId,
                        @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser user, Model model) {
        model.addAttribute("topics", topicService.getAllTopicsWithLessons());
        model.addAttribute("sessions", tutorService.getRecentSessions(user.getUserId()));
        model.addAttribute("lessonId", lessonId);
        if (sessionId != null) {
            TutorSessionView session = tutorService.getSession(user.getUserId(), sessionId);
            List<TutorMessageView> messages = tutorService.getMessages(user.getUserId(), sessionId);
            model.addAttribute("tutorSession", session);
            model.addAttribute("messages", messages);
            model.addAttribute("lessonId", session.getLessonId());
        } else if ("QUESTION".equals(mode) && questionId != null) {
            model.addAttribute("startMode", mode);
            model.addAttribute("startQuestionId", questionId);
        } else if ("SUBMISSION".equals(mode) && submissionId != null) {
            model.addAttribute("startMode", mode);
            model.addAttribute("startSubmissionId", submissionId);
        }
        return "student/ai-tutor";
    }
}

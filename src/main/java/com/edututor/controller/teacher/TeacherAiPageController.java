package com.edututor.controller.teacher;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/** Liên kết "Sinh câu hỏi bằng AI" trên sidebar: mở danh sách câu hỏi kèm modal sinh đề. */
@Controller
public class TeacherAiPageController {

    @GetMapping("/teacher/ai/generate")
    public String aiGeneratePage() {
        return "redirect:/teacher/questions?openAi=1";
    }
}

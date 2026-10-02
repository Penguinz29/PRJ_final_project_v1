package com.edututor.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/** Câu hỏi trắc nghiệm gửi tới trình duyệt khi làm bài: không có đáp án đúng, không có lời giải. */
public class QuizQuestionView implements Serializable {
    private static final long serialVersionUID = 1L;

    private final int questionId;
    private final String content;
    private final int level;
    private final boolean aiGenerated;
    private final List<QuizOptionView> options = new ArrayList<>();

    /** Hàm dựng dùng cho JPQL {@code select new ...} (kiểu bọc để Hibernate khớp tham số). */
    public QuizQuestionView(Integer questionId, String content, Integer level, Boolean aiGenerated) {
        this.questionId = questionId;
        this.content = content;
        this.level = level;
        this.aiGenerated = aiGenerated;
    }

    public int getQuestionId() { return questionId; }
    public String getContent() { return content; }
    public int getLevel() { return level; }
    public boolean isAiGenerated() { return aiGenerated; }
    public List<QuizOptionView> getOptions() { return options; }
}

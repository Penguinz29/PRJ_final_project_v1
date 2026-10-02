package com.edututor.dto;

import java.io.Serializable;

/** Phương án hiển thị khi làm bài: KHÔNG có cờ đúng/sai (BR-11, TC-SEC-08). */
public class QuizOptionView implements Serializable {
    private static final long serialVersionUID = 1L;

    private final int optionId;
    private final int questionId;
    private final String optionLetter;
    private final String content;

    /** Hàm dựng dùng cho JPQL {@code select new ...}. */
    public QuizOptionView(Integer optionId, Integer questionId, String optionLetter, String content) {
        this.optionId = optionId;
        this.questionId = questionId;
        this.optionLetter = optionLetter;
        this.content = content;
    }

    public int getOptionId() { return optionId; }
    public int getQuestionId() { return questionId; }
    public String getOptionLetter() { return optionLetter; }
    public String getContent() { return content; }
}

package dto.view;

import java.io.Serializable;

public class OptionView implements Serializable {
    private int optionId;
    private int questionId;
    private String optionLetter; // A, B, C, D
    private String content;
    private boolean correct;

    public OptionView() {}

    public int getOptionId() { return optionId; }
    public void setOptionId(int optionId) { this.optionId = optionId; }

    public int getQuestionId() { return questionId; }
    public void setQuestionId(int questionId) { this.questionId = questionId; }

    public String getOptionLetter() { return optionLetter; }
    public void setOptionLetter(String optionLetter) { this.optionLetter = optionLetter; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public boolean isCorrect() { return correct; }
    public void setCorrect(boolean correct) { this.correct = correct; }
}


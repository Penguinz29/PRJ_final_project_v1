package com.mathtutor.model;

import java.io.Serializable;
import java.util.List;

public class AttemptResult implements Serializable {
    private int correctCount;
    private int totalQuestions;
    private double score;
    private List<AttemptResultItem> items;

    public AttemptResult() {
    }

    public int getCorrectCount() {
        return correctCount;
    }

    public void setCorrectCount(int correctCount) {
        this.correctCount = correctCount;
    }

    public int getTotalQuestions() {
        return totalQuestions;
    }

    public void setTotalQuestions(int totalQuestions) {
        this.totalQuestions = totalQuestions;
    }

    public double getScore() {
        return score;
    }

    public void setScore(double score) {
        this.score = score;
    }

    public List<AttemptResultItem> getItems() {
        return items;
    }

    public void setItems(List<AttemptResultItem> items) {
        this.items = items;
    }

    public static class AttemptResultItem implements Serializable {
        private Question question;
        private List<QuestionOption> options;
        private String studentAnswer;
        private String correctAnswer;
        private boolean isCorrect;

        public Question getQuestion() {
            return question;
        }

        public void setQuestion(Question question) {
            this.question = question;
        }

        public List<QuestionOption> getOptions() {
            return options;
        }

        public void setOptions(List<QuestionOption> options) {
            this.options = options;
        }

        public String getStudentAnswer() {
            return studentAnswer;
        }

        public void setStudentAnswer(String studentAnswer) {
            this.studentAnswer = studentAnswer;
        }

        public String getCorrectAnswer() {
            return correctAnswer;
        }

        public void setCorrectAnswer(String correctAnswer) {
            this.correctAnswer = correctAnswer;
        }

        public boolean isCorrect() {
            return isCorrect;
        }

        public void setCorrect(boolean correct) {
            this.isCorrect = correct;
        }
    }
}

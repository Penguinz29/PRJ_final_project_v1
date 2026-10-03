package com.edututor.model;

/**
 * Trạng thái chấm bài (cột Submissions.Status): GRADED = trắc nghiệm tự chấm,
 * AI_GRADED = tự luận AI đã chấm, chờ giáo viên duyệt, REVIEWED = giáo viên đã duyệt.
 */
public enum SubmissionStatus {
    GRADED, AI_GRADED, REVIEWED
}

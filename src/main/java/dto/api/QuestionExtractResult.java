package dto.api;

import java.util.Map;

/**
 * Câu hỏi AI trích xuất từ tệp (đề bài + đáp án tùy chọn) để giáo viên xem lại trong form trước khi lưu.
 * {@code answerSource}: FILE nếu đáp án lấy từ tệp đáp án giáo viên tải lên, AI nếu AI tự giải.
 */
public record QuestionExtractResult(String type, String content, Map<String, String> options, String correctOption,
                                    String explanation, String answerSource) {
}

package com.edututor.repository;

import com.edututor.model.TutorMessage;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TutorMessageRepository extends JpaRepository<TutorMessage, Integer> {

    List<TutorMessage> findBySession_SessionIdOrderByMessageIdAsc(Integer sessionId);

    /** 20 tin nhắn gần nhất (mới nhất trước) để dựng ngữ cảnh gửi Gemini. */
    List<TutorMessage> findTop20BySession_SessionIdOrderByMessageIdDesc(Integer sessionId);
}

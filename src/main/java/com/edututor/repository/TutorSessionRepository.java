package com.edututor.repository;

import com.edututor.model.TutorSession;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TutorSessionRepository extends JpaRepository<TutorSession, Integer> {

    @EntityGraph(attributePaths = {"lesson"})
    List<TutorSession> findByStudent_UserId(Integer studentId, Pageable pageable);

    @EntityGraph(attributePaths = {"lesson", "student"})
    Optional<TutorSession> findWithLessonBySessionId(Integer sessionId);

    boolean existsByStudent_UserId(Integer studentId);
}

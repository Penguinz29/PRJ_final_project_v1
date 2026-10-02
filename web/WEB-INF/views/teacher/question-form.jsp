<%-- File: WEB-INF/views/teacher/question-form.jsp Servlet: TeacherQuestionServlet (GET ?action=create|edit) Attributes:
    question(Question - null if create), lessons(List<Lesson>),
    options(List<QuestionOption>), isEdit(boolean)
        POST fields: content, type(MCQ|ESSAY), level(1-3), lessonId, action, id,
        opt_A, opt_B, opt_C, opt_D, correctOption(A-D) [MCQ only]
        sampleAnswer [ESSAY only]
        --%>
        <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
            <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
                <jsp:include page="../common/head.jsp">
                    <jsp:param name="title" value="${isEdit ? 'Sửa câu hỏi' : 'Thêm câu hỏi'}" />
                </jsp:include>

                <body data-ctx="${pageContext.request.contextPath}">
                    <jsp:include page="../common/navbar.jsp" />
                    <div class="app-shell">
                        <jsp:include page="../common/sidebar.jsp">
                            <jsp:param name="active" value="teacher-questions" />
                        </jsp:include>
                        <main class="app-main">
                            <jsp:include page="../common/flash.jsp" />

                            <div class="page-header">
                                <h1><i class="bi bi-patch-question me-2 text-primary"></i>
                                    ${isEdit ? 'Sửa câu hỏi' : 'Thêm câu hỏi mới'}</h1>
                                <a href="${pageContext.request.contextPath}/teacher/questions"
                                    class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i>Quay
                                    lại</a>
                            </div>

                            <div class="row g-4">
                                <div class="col-lg-8">
                                    <form action="${pageContext.request.contextPath}/teacher/questions" method="post"
                                        class="needs-validation" novalidate>
                                        <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
                                        <c:if test="${isEdit}">
                                            <input type="hidden" name="id" value="${question.questionId}">
                                        </c:if>

                                        <div class="card mb-3">
                                            <div class="card-header"><i class="bi bi-info-circle me-2"></i>Thông tin câu
                                                hỏi</div>
                                            <div class="card-body">
                                                <div class="row g-3 mb-3">
                                                    <div class="col-sm-6">
                                                        <label class="form-label fw-semibold">Bài giảng <span
                                                                class="text-danger">*</span></label>
                                                        <select class="form-select" name="lessonId" required>
                                                            <option value="">-- Chọn bài giảng --</option>
                                                            <c:forEach var="l" items="${lessons}">
                                                                <option value="${l.lessonId}"
                                                                    ${question.lessonId==l.lessonId ? 'selected' : '' }>
                                                                    <c:out value="${l.title}" />
                                                                </option>
                                                            </c:forEach>
                                                        </select>
                                                        <div class="invalid-feedback">Chọn bài giảng.</div>
                                                    </div>
                                                    <div class="col-sm-3">
                                                        <label class="form-label fw-semibold">Loại <span
                                                                class="text-danger">*</span></label>
                                                        <div class="d-flex gap-2 mt-1">
                                                            <div class="form-check">
                                                                <input class="form-check-input" type="radio" name="type"
                                                                    id="typeMCQ" value="MCQ" ${empty question or
                                                                    question.type=='MCQ' ? 'checked' : '' }>
                                                                <label class="form-check-label" for="typeMCQ">Trắc
                                                                    nghiệm</label>
                                                            </div>
                                                            <div class="form-check">
                                                                <input class="form-check-input" type="radio" name="type"
                                                                    id="typeEssay" value="ESSAY"
                                                                    ${question.type=='ESSAY' ? 'checked' : '' }>
                                                                <label class="form-check-label" for="typeEssay">Tự
                                                                    luận</label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-3">
                                                        <label class="form-label fw-semibold" for="qLevel">Mức
                                                            độ</label>
                                                        <select class="form-select" id="qLevel" name="level">
                                                            <option value="1" ${question.level==1 ? 'selected' : '' }>1
                                                                - Dễ</option>
                                                            <option value="2" ${question.level==2 ? 'selected' : '' }>2
                                                                - Trung bình</option>
                                                            <option value="3" ${question.level==3 ? 'selected' : '' }>3
                                                                - Khó</option>
                                                        </select>
                                                    </div>
                                                </div>

                                                <div class="mb-0">
                                                    <label class="form-label fw-semibold" for="qContent">Nội dung câu
                                                        hỏi <span class="text-danger">*</span></label>
                                                    <small class="ms-2 text-muted">Hỗ trợ LaTeX:
                                                        <code>\$x^2\$</code></small>
                                                    <textarea class="form-control font-monospace" id="qContent"
                                                        name="content" rows="5" maxlength="2000" required
                                                        placeholder="Nhập nội dung câu hỏi, có thể dùng LaTeX..."
                                                        data-latex-preview="#previewContent"><c:out value="${question.content}"/></textarea>
                                                    <div class="invalid-feedback">Vui lòng nhập nội dung câu hỏi.</div>
                                                </div>
                                            </div>
                                        </div>

                                        <%-- MCQ Options --%>
                                            <div class="card mb-3" id="mcqBlock">
                                                <div class="card-header"><i class="bi bi-list-check me-2"></i>Đáp án
                                                    trắc nghiệm</div>
                                                <div class="card-body">
                                                    <c:set var="optMap" value="${optionMap}" />
                                                    <c:forEach var="letter" items="${'A,B,C,D'.split(',')}">
                                                        <div class="mb-3">
                                                            <label
                                                                class="form-label fw-semibold d-flex align-items-center gap-2">
                                                                <span class="option-label border-0"
                                                                    style="background:var(--primary);color:#fff;border:none;">${letter}</span>
                                                                Đáp án ${letter}
                                                            </label>
                                                            <input type="text" class="form-control font-monospace"
                                                                name="opt_${letter}" maxlength="500"
                                                                placeholder="Nhập đáp án ${letter}..."
                                                                value="<c:out value='${optionMap[letter]}'/>">
                                                        </div>
                                                    </c:forEach>
                                                    <div class="mb-0">
                                                        <label class="form-label fw-semibold">Đáp án đúng <span
                                                                class="text-danger">*</span></label>
                                                        <div class="d-flex gap-3">
                                                            <c:forEach var="letter" items="${'A,B,C,D'.split(',')}">
                                                                <div class="form-check">
                                                                    <input class="form-check-input" type="radio"
                                                                        name="correctOption" id="correct${letter}"
                                                                        value="${letter}"
                                                                        ${question.correctOption==letter ? 'checked'
                                                                        : '' }>
                                                                    <label class="form-check-label fw-semibold"
                                                                        for="correct${letter}">${letter}</label>
                                                                </div>
                                                            </c:forEach>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <%-- Essay sample answer --%>
                                                <div class="card mb-3">
                                                    <div class="card-header"><i class="bi bi-file-text me-2"></i>Gợi ý
                                                        đáp án (Tự luận)</div>
                                                    <div class="card-body">
                                                        <textarea class="form-control font-monospace"
                                                            name="sampleAnswer" rows="4" maxlength="3000"
                                                            placeholder="Nhập gợi ý đáp án / lời giải mẫu (dùng cho GV tham khảo khi chấm)..."><c:out value="${question.sampleAnswer}"/></textarea>
                                                    </div>
                                                </div>

                                                <div class="d-flex gap-2">
                                                    <button type="submit" class="btn btn-primary">
                                                        <i class="bi bi-check-lg me-1"></i>${isEdit ? 'Lưu thay đổi' :
                                                        'Tạo câu hỏi'}
                                                    </button>
                                                    <a href="${pageContext.request.contextPath}/teacher/questions"
                                                        class="btn btn-outline-secondary">Hủy</a>
                                                </div>
                                    </form>
                                </div>

                                <%-- Preview --%>
                                    <div class="col-lg-4">
                                        <div class="card" style="position:sticky;top:calc(var(--navbar-h) + 1rem);">
                                            <div class="card-header"><i class="bi bi-eye me-2"></i>Preview câu hỏi</div>
                                            <div class="card-body" id="previewContent"
                                                style="min-height:120px;font-size:.9rem;line-height:1.7;">
                                                <span class="text-muted">Nhập nội dung để xem preview...</span>
                                            </div>
                                        </div>
                                    </div>
                            </div>
                        </main>
                    </div>
                    <jsp:include page="../common/footer.jsp" />
                </body>

                </html>
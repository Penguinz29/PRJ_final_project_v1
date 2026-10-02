<%-- File: WEB-INF/views/teacher/submission-review.jsp
     Servlet: TeacherSubmissionServlet (/teacher/submissions?id=...)
     Attributes: sub (Submission)
     FR-TEA-04: Giáo viên xem xét, duyệt và điều chỉnh điểm số tự luận --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Chấm bài tự luận - ${sub.studentName}" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
<jsp:include page="../common/navbar.jsp" />

<div class="app-shell">
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="active" value="teacher-submissions" />
    </jsp:include>

    <main class="app-main">
        <ui:flash />

        <div class="page-header d-flex justify-content-between align-items-center mb-3">
            <div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-1" style="font-size: .85rem;">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/teacher/submissions">Chấm bài tự luận</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Bài làm #${sub.submissionId}</li>
                    </ol>
                </nav>
                <h1 class="h3 mb-0">
                    <i class="bi bi-pencil-square text-primary me-2"></i>Đánh giá bài làm tự luận
                </h1>
            </div>
            <a href="${pageContext.request.contextPath}/teacher/submissions?status=${sub.reviewed ? 'reviewed' : 'pending'}" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-left me-1"></i>Quay lại danh sách
            </a>
        </div>

        <div class="row g-3">
            <!-- Cột trái: Đề bài & Bài làm của học sinh -->
            <div class="col-lg-7">
                <!-- Thông tin học sinh & nộp bài -->
                <div class="card mb-3">
                    <div class="card-body py-2 px-3 bg-light rounded-top d-flex justify-content-between align-items-center">
                        <div>
                            <i class="bi bi-person-circle text-primary me-1"></i>
                            <strong><c:out value="${sub.studentName}" /></strong>
                            <span class="text-muted ms-1" style="font-size: .85rem;">(<c:out value="${sub.studentEmail}" />)</span>
                        </div>
                        <div class="text-muted" style="font-size: .85rem;">
                            <i class="bi bi-clock me-1"></i><fmt:formatDate value="${sub.submittedAt}" pattern="dd/MM/yyyy HH:mm" />
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="mb-2">
                            <span class="badge bg-secondary-subtle text-secondary me-2">
                                <c:out value="${not empty sub.lessonTitle ? sub.lessonTitle : 'Bài học'}" />
                            </span>
                            <c:if test="${sub.questionAiGenerated}">
                                <span class="badge bg-purple-subtle text-ai"><i class="bi bi-stars me-1"></i>Đề do AI sinh</span>
                            </c:if>
                        </div>
                        <h6 class="fw-bold text-muted mb-1" style="font-size: .85rem;">NỘI DUNG ĐỀ BÀI:</h6>
                        <div class="p-3 bg-light rounded border mb-3 latex-content" style="font-size: .95rem;">
                            <c:out value="${not empty sub.questionContent ? sub.questionContent : sub.questionTitle}" />
                        </div>

                        <h6 class="fw-bold text-muted mb-1" style="font-size: .85rem;">BÀI LÀM CỦA HỌC SINH:</h6>
                        
                        <!-- Nếu có ảnh bài làm tự luận viết tay (OCR) -->
                        <c:if test="${not empty sub.essayImagePath}">
                            <div class="mb-3 text-center p-2 border rounded bg-white">
                                <p class="text-muted small mb-2"><i class="bi bi-camera me-1"></i>Ảnh chụp bài làm viết tay của học sinh:</p>
                                <img src="${sub.essayImagePath.startsWith('http') ? sub.essayImagePath : pageContext.request.contextPath.concat(sub.essayImagePath)}"
                                     alt="Ảnh bài làm viết tay"
                                     class="img-fluid rounded border shadow-sm"
                                     style="max-height: 480px; object-fit: contain; cursor: pointer;"
                                     onclick="window.open(this.src, '_blank')"
                                     title="Nhấp để xem kích thước lớn" />
                                <div class="mt-1">
                                    <small class="text-muted">(Nhấp vào ảnh để mở xem toàn màn hình)</small>
                                </div>
                            </div>
                        </c:if>

                        <!-- Nội dung văn bản / Nhận dạng OCR -->
                        <div class="p-3 border rounded bg-white">
                            <p class="text-muted small mb-1 fw-bold">
                                <i class="bi bi-file-earmark-text me-1"></i>
                                ${not empty sub.essayImagePath ? 'Nội dung nhận dạng OCR từ nét chữ viết tay:' : 'Văn bản lời giải của học sinh:'}
                            </p>
                            <div class="latex-content" style="white-space: pre-wrap; font-size: .92rem;">
                                <c:choose>
                                    <c:when test="${not empty sub.studentAnswer}">
                                        <c:out value="${sub.studentAnswer}" />
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted italic">Học sinh chưa nhập văn bản lời giải.</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Nhận xét của AI OCR nếu có -->
                        <c:if test="${not empty sub.aiFeedback}">
                            <div class="mt-3 p-3 border border-primary-subtle bg-primary-subtle rounded">
                                <h6 class="text-primary fw-bold mb-1">
                                    <i class="bi bi-robot me-1"></i>Đánh giá đề xuất từ Gemini Vision AI:
                                </h6>
                                <div class="latex-content small" style="white-space: pre-wrap;">
                                    <c:out value="${sub.aiFeedback}" />
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Cột phải: Form chấm điểm & Nhận xét của giáo viên -->
            <div class="col-lg-5">
                <div class="card sticky-top" style="top: 1rem;">
                    <div class="card-header bg-white py-3">
                        <h5 class="card-title mb-0 fw-bold">
                            <i class="bi bi-check2-circle text-success me-2"></i>Chấm điểm & Nhận xét
                        </h5>
                    </div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/teacher/submissions" method="post">
<input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                            <input type="hidden" name="submissionId" value="${sub.submissionId}">

                            <!-- Trạng thái hiện tại -->
                            <div class="mb-3 p-2 rounded ${sub.reviewed ? 'bg-success-subtle text-success' : 'bg-warning-subtle text-warning-emphasis'}">
                                <i class="bi ${sub.reviewed ? 'bi-check-circle-fill' : 'bi-hourglass-split'} me-1"></i>
                                <strong>Trạng thái:</strong> ${sub.reviewed ? 'Đã chấm điểm' : 'Chưa được chấm'}
                            </div>

                            <!-- Điểm số (Thang điểm 10.0, bước 0.25) -->
                            <div class="mb-3">
                                <label for="scoreInput" class="form-label fw-bold">
                                    Điểm số (Thang điểm 10.0):
                                </label>
                                <div class="input-group">
                                    <input type="number" class="form-control form-control-lg fw-bold text-primary"
                                           id="scoreInput" name="score"
                                           min="0" max="10" step="0.25"
                                           value="${sub.score != null ? sub.score : ''}"
                                           placeholder="Ví dụ: 8.5">
                                    <span class="input-group-text fw-bold">/ 10</span>
                                </div>
                                <small class="text-muted">Nhập điểm từ 0.00 đến 10.00 (làm tròn tới 0.25 điểm theo quy chế thi THPT).</small>
                            </div>

                            <!-- Đánh giá kết quả -->
                            <div class="mb-3">
                                <label class="form-label fw-bold">Đánh giá chung:</label>
                                <div class="d-flex gap-4">
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="isCorrect" id="evalPass" value="true"
                                               ${sub.isCorrect != null && sub.isCorrect ? 'checked' : ''}>
                                        <label class="form-check-label text-success fw-semibold" for="evalPass">
                                            <i class="bi bi-check-circle me-1"></i>Đạt / Chính xác
                                        </label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="isCorrect" id="evalFail" value="false"
                                               ${sub.isCorrect != null && !sub.isCorrect ? 'checked' : ''}>
                                        <label class="form-check-label text-danger fw-semibold" for="evalFail">
                                            <i class="bi bi-x-circle me-1"></i>Chưa đạt / Sai sót
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <!-- Lời nhận xét sư phạm của giáo viên -->
                            <div class="mb-3">
                                <label for="teacherFeedback" class="form-label fw-bold">Nhận xét của Giáo viên:</label>
                                <textarea class="form-control" id="teacherFeedback" name="teacherFeedback" rows="5"
                                          placeholder="Chỉ rõ điểm mạnh, các bước biến đổi còn thiếu sót hoặc lưu ý sư phạm cho học sinh..."><c:out value="${sub.teacherFeedback}" /></textarea>
                            </div>

                            <hr>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="bi bi-check-lg me-1"></i>Lưu kết quả chấm điểm
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

    </main>
</div>

<jsp:include page="../common/footer.jsp" />

<script>
    document.addEventListener("DOMContentLoaded", function () {
        if (typeof renderMathInElement === "function") {
            renderMathInElement(document.body, {
                delimiters: [
                    { left: "$$", right: "$$", display: true },
                    { left: "$", right: "$", display: false }
                ],
                throwOnError: false
            });
        }
    });
</script>

</body>
</html>

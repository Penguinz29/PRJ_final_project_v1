<%-- File: WEB-INF/views/student/history-detail.jsp Controller: StudentHistoryController (/student/history/{id}) Attributes: sub(SubmissionView) --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Chi tiết bài làm" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
<jsp:include page="../common/navbar.jsp" />
<div class="app-shell">
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="active" value="student-history" />
    </jsp:include>
    <main class="app-main">
        <div class="page-header d-flex align-items-center">
            <h1><i class="bi bi-journal-check me-2 text-primary"></i>Chi tiết bài làm</h1>
            <a href="${pageContext.request.contextPath}/student/history" class="btn btn-outline-secondary btn-sm ms-auto">
                <i class="bi bi-arrow-left me-1"></i>Quay lại lịch sử</a>
        </div>

        <c:set var="isMcq" value="${sub.questionType == 'MCQ'}" />
        <div class="card mb-3">
            <div class="card-body">
                <div class="d-flex flex-wrap align-items-center gap-2 mb-3">
                    <span class="badge ${isMcq ? 'bg-primary-subtle text-primary' : 'bg-purple-subtle text-ai'}">${isMcq ? 'Trắc nghiệm' : 'Tự luận'}</span>
                    <span class="text-muted small"><i class="bi bi-book me-1"></i><c:out value="${sub.lessonTitle}" /></span>
                    <span class="text-muted small ms-auto"><i class="bi bi-clock me-1"></i>
                        <fmt:formatDate value="${sub.submittedAt}" pattern="dd/MM/yyyy HH:mm" /></span>
                </div>

                <h6 class="fw-bold text-muted mb-1" style="font-size:.85rem;">ĐỀ BÀI</h6>
                <div class="p-3 bg-light rounded border mb-4 latex-content">
                    <ui:rich-text value="${sub.questionContent}" />
                </div>

                <c:choose>
                    <%-- ===== Trắc nghiệm ===== --%>
                    <c:when test="${isMcq}">
                        <h6 class="fw-bold text-muted mb-2" style="font-size:.85rem;">BÀI LÀM CỦA BẠN</h6>
                        <div class="list-group mb-3">
                            <c:forEach var="o" items="${sub.options}">
                                <c:set var="chosen" value="${o.letter == sub.studentAnswer}" />
                                <div class="list-group-item d-flex align-items-start gap-2
                                    ${o.correct ? 'list-group-item-success' : (chosen ? 'list-group-item-danger' : '')}">
                                    <strong>${o.letter}.</strong>
                                    <div class="latex-content flex-grow-1"><ui:rich-text value="${o.content}" /></div>
                                    <c:if test="${chosen}"><span class="badge bg-dark">Bạn chọn</span></c:if>
                                    <c:if test="${o.correct}"><span class="badge bg-success"><i class="bi bi-check-lg"></i> Đáp án đúng</span></c:if>
                                </div>
                            </c:forEach>
                        </div>
                        <c:choose>
                            <c:when test="${sub.correct}">
                                <span class="badge bg-success-subtle text-success fw-bold px-2 py-1"><i class="bi bi-check-circle-fill me-1"></i>Kết quả: Đúng</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-danger-subtle text-danger fw-bold px-2 py-1"><i class="bi bi-x-circle-fill me-1"></i>Kết quả: Sai</span>
                            </c:otherwise>
                        </c:choose>
                    </c:when>

                    <%-- ===== Tự luận ===== --%>
                    <c:otherwise>
                        <h6 class="fw-bold text-muted mb-2" style="font-size:.85rem;">BÀI BẠN ĐÃ NỘP</h6>
                        <c:if test="${not empty sub.essayImagePath}">
                            <c:set var="fileUrl" value="${sub.essayImagePath.startsWith('http') ? sub.essayImagePath : pageContext.request.contextPath.concat(sub.essayImagePath)}" />
                            <c:choose>
                                <c:when test="${sub.essayImagePath.endsWith('.pdf')}">
                                    <div class="mb-3 p-2 border rounded bg-white">
                                        <p class="text-muted small mb-2"><i class="bi bi-file-earmark-pdf me-1"></i>Tệp PDF đã nộp:
                                            <a href="${fileUrl}" target="_blank" rel="noopener">Mở ở tab mới</a></p>
                                        <iframe src="${fileUrl}" title="Bài làm PDF" style="width:100%;height:480px;border:1px solid #dee2e6;"></iframe>
                                    </div>
                                </c:when>
                                <c:when test="${sub.essayImagePath.endsWith('.docx')}">
                                    <div class="mb-3 p-2 border rounded bg-white"><i class="bi bi-file-earmark-word me-1"></i>Tệp Word đã nộp:
                                        <a href="${fileUrl}">Tải về</a></div>
                                </c:when>
                                <c:otherwise>
                                    <div class="mb-3 text-center p-2 border rounded bg-white">
                                        <img src="${fileUrl}" alt="Ảnh bài làm" class="img-fluid rounded border"
                                             style="max-height:480px;object-fit:contain;cursor:pointer;"
                                             onclick="window.open(this.src,'_blank')" />
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                        <div class="p-3 border rounded bg-white mb-3">
                            <p class="text-muted small mb-1 fw-bold">${not empty sub.essayImagePath ? 'Nội dung đọc được từ tệp bài làm:' : 'Văn bản bài làm:'}</p>
                            <div class="latex-content" style="white-space:pre-wrap;"><c:choose><c:when test="${not empty sub.studentAnswer}"><c:out value="${sub.studentAnswer}" /></c:when><c:otherwise><span class="text-muted">Không có nội dung văn bản.</span></c:otherwise></c:choose></div>
                        </div>

                        <h6 class="fw-bold text-muted mb-2" style="font-size:.85rem;">KẾT QUẢ</h6>
                        <c:choose>
                            <c:when test="${sub.reviewed}">
                                <span class="badge bg-success-subtle text-success fw-bold px-2 py-1"><i class="bi bi-check2-circle me-1"></i>Đã chấm: ${sub.score}đ</span>
                                <c:if test="${not empty sub.reviewedByName}"><span class="small text-muted ms-2">bởi <c:out value="${sub.reviewedByName}" /></span></c:if>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-warning-subtle text-warning fw-bold px-2 py-1"><i class="bi bi-hourglass-split me-1"></i>Điểm tạm thời<c:if test="${sub.aiScore != null}">: ${sub.aiScore}đ</c:if> · chờ GV duyệt</span>
                            </c:otherwise>
                        </c:choose>
                        <c:if test="${not empty sub.teacherFeedback}">
                            <div class="mt-3 p-3 border border-success-subtle bg-success-subtle rounded">
                                <h6 class="text-success fw-bold mb-1"><i class="bi bi-person-check me-1"></i>Nhận xét của giáo viên</h6>
                                <div class="latex-content small" style="white-space:pre-wrap;"><c:out value="${sub.teacherFeedback}" /></div>
                            </div>
                        </c:if>
                        <c:if test="${not empty sub.aiFeedback}">
                            <div class="mt-3 p-3 border border-primary-subtle bg-primary-subtle rounded">
                                <h6 class="text-primary fw-bold mb-1"><i class="bi bi-robot me-1"></i>Nhận xét của AI</h6>
                                <div class="latex-content small" style="white-space:pre-wrap;"><c:out value="${sub.aiFeedback}" /></div>
                            </div>
                        </c:if>
                        <c:if test="${not empty sub.suggestedCorrection}">
                            <div class="mt-3 p-3 border rounded bg-white">
                                <h6 class="fw-bold mb-1"><i class="bi bi-lightbulb me-1"></i>Lời giải gợi ý</h6>
                                <div class="latex-content small" style="white-space:pre-wrap;"><c:out value="${sub.suggestedCorrection}" /></div>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>

                <c:if test="${not empty sub.explanation}">
                    <div class="mt-4 p-3 border rounded bg-light">
                        <h6 class="fw-bold mb-1"><i class="bi bi-lightbulb me-1"></i>Lời giải</h6>
                        <div class="latex-content"><ui:rich-text value="${sub.explanation}" /></div>
                    </div>
                </c:if>
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

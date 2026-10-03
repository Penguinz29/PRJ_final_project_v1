<%-- File: WEB-INF/views/student/history.jsp Servlet: StudentHistoryServlet (/student/history) Attributes:
    history(List<Submission>), page(int), totalPages(int), totalRecords(int), type(String)
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
                <jsp:include page="../common/head.jsp">
                    <jsp:param name="title" value="Lịch sử học tập" />
                </jsp:include>

                <body data-ctx="${pageContext.request.contextPath}">
                    <jsp:include page="../common/navbar.jsp" />
                    <div class="app-shell">
                        <jsp:include page="../common/sidebar.jsp">
                            <jsp:param name="active" value="student-history" />
                        </jsp:include>
                        <main class="app-main">
                            <ui:flash />
                            <div class="page-header">
                                <h1><i class="bi bi-clock-history me-2 text-primary"></i>Lịch sử làm bài
                                    <span class="badge bg-secondary ms-2">${totalRecords}</span>
                                </h1>
                            </div>

                            <%-- Tabs lọc --%>
                                <ul class="nav nav-tabs mb-4">
                                    <li class="nav-item">
                                        <a class="nav-link ${empty type or type == 'ALL' ? 'active fw-bold' : ''}"
                                            href="${pageContext.request.contextPath}/student/history?type=ALL">Tất
                                            cả</a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${type == 'MCQ' ? 'active fw-bold' : ''}"
                                            href="${pageContext.request.contextPath}/student/history?type=MCQ">Trắc
                                            nghiệm</a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${type == 'ESSAY' ? 'active fw-bold' : ''}"
                                            href="${pageContext.request.contextPath}/student/history?type=ESSAY">Tự
                                            luận</a>
                                    </li>
                                </ul>

                                <div class="card table-card border-top-0 rounded-top-0">
                                    <div class="table-responsive">
                                        <table class="table table-hover mb-0">
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Câu hỏi / Đề bài</th>
                                                    <th>Bài giảng</th>
                                                    <th>Loại</th>
                                                    <th>Kết quả / Trạng thái</th>
                                                    <th>Thời gian nộp</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:choose>
                                                    <c:when test="${empty history}">
                                                        <tr>
                                                            <td colspan="6">
                                                                <div class="empty-state">
                                                                    <i class="bi bi-clock empty-icon"></i>
                                                                    <p>Chưa có lịch sử làm bài.</p>
                                                                    <a href="${pageContext.request.contextPath}/student/topics"
                                                                        class="btn btn-primary btn-sm">Học ngay</a>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:forEach var="sub" items="${history}" varStatus="vs">
                                                            <tr>
                                                                <td class="text-muted">${(page-1)*10 + vs.count}</td>
                                                                <td>
                                                                    <div
                                                                        style="max-width:300px;text-overflow:ellipsis;overflow:hidden;white-space:nowrap;">
                                                                        <c:out value="${sub.questionTitle}" />
                                                                        <c:if test="${sub.questionAiGenerated}"><i
                                                                                class="bi bi-stars text-ai ms-1"
                                                                                title="Câu hỏi do AI sinh"></i></c:if>
                                                                    </div>
                                                                </td>
                                                                <td class="text-muted">
                                                                    <c:out value="${sub.lessonTitle}" />
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${sub.questionType == 'MCQ'}">
                                                                            <span
                                                                                class="badge bg-primary-subtle text-primary">Trắc
                                                                                nghiệm</span>
                                                                        </c:when>
                                                                        <c:otherwise><span
                                                                                class="badge bg-purple-subtle text-ai">Tự
                                                                                luận</span></c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${sub.questionType == 'MCQ'}">
                                                                            <c:choose>
                                                                                <c:when test="${sub.correct or sub.isCorrect}">
                                                                                    <span class="badge bg-success-subtle text-success fw-bold px-2 py-1">
                                                                                        <i class="bi bi-check-circle-fill me-1"></i>Đúng
                                                                                    </span>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span class="badge bg-danger-subtle text-danger fw-bold px-2 py-1">
                                                                                        <i class="bi bi-x-circle-fill me-1"></i>Sai
                                                                                    </span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                            <c:if test="${not empty sub.studentAnswer}">
                                                                                <div class="small text-muted mt-1">Đã chọn: <strong class="text-dark"><c:out value="${sub.studentAnswer}"/></strong></div>
                                                                            </c:if>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <c:choose>
                                                                                <c:when test="${sub.reviewed}">
                                                                                    <span class="badge bg-success-subtle text-success fw-bold px-2 py-1 tooltip-trigger"
                                                                                        data-bs-toggle="tooltip"
                                                                                        title="Nhận xét: <c:out value='${sub.teacherFeedback}'/>">
                                                                                        <i class="bi bi-check2-circle me-1"></i>Đã chấm: <strong>${sub.score}đ</strong>
                                                                                    </span>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <%-- FR-OCR-03: điểm AI chỉ là điểm tạm thời cho tới khi giáo viên duyệt --%>
                                                                                    <span class="badge bg-warning-subtle text-warning fw-bold px-2 py-1">
                                                                                        <i class="bi bi-hourglass-split me-1"></i>Điểm tạm thời<c:if test="${sub.aiScore != null}">: <strong>${sub.aiScore}đ</strong></c:if> · chờ GV duyệt
                                                                                    </span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td class="text-muted" style="font-size:.85rem;">
                                                                    <fmt:formatDate value="${sub.submittedAt}"
                                                                        pattern="dd/MM/yyyy HH:mm" />
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:otherwise>
                                                </c:choose>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <ui:pagination baseUrl="${pageContext.request.contextPath}/student/history${not empty type ? '?type='.concat(type) : ''}" page="${page}" totalPages="${totalPages}" />
                        </main>
                    </div>
                    <script>
                        // Activate tooltips for feedback
                        document.addEventListener("DOMContentLoaded", function () {
                            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
                            tooltipTriggerList.map(function (tooltipTriggerEl) {
                                return new bootstrap.Tooltip(tooltipTriggerEl);
                            });
                        });
                    </script>
                    <jsp:include page="../common/footer.jsp" />
                </body>

                </html>
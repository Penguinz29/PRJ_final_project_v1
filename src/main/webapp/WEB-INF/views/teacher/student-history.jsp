<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="Lịch sử học sinh" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="teacher-students" />
                    </jsp:include>
                    <main class="app-main">
                        <ui:flash />
                        <div class="page-header">
                            <h1><i class="bi bi-clock-history me-2 text-primary"></i>Lịch sử làm bài</h1>
                            <a href="${pageContext.request.contextPath}/teacher/students"
                                class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i>Quay
                                lại</a>
                        </div>

                        <div class="card table-card mb-3">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Bài - Câu hỏi</th>
                                            <th>Loại</th>
                                            <th>Trả lời</th>
                                            <th>Đúng/Sai</th>
                                            <th>Thời gian</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="sub" items="${submissions}" varStatus="vs">
                                            <tr>
                                                <td class="text-muted">
                                                    <c:out value="${(page-1)*10 + vs.count}" />
                                                </td>
                                                <td>
                                                    <div class="fw-semibold text-truncate" style="max-width:300px;">
                                                        <c:out value="${sub.lessonTitle}" />
                                                    </div>
                                                    <div class="text-muted text-truncate"
                                                        style="font-size:0.85rem;max-width:300px;">
                                                        <c:out value="${sub.questionTitle}" />
                                                    </div>
                                                </td>
                                                <td>
                                                    <span
                                                        class="badge ${sub.questionType=='MCQ'?'bg-primary':'bg-info'}">
                                                        <c:out value="${sub.questionType}" />
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:out value="${sub.studentAnswer}" />
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${sub.isCorrect == null}"><span
                                                                class="badge bg-secondary">Chưa chấm</span></c:when>
                                                        <c:when test="${sub.isCorrect}"><span
                                                                class="badge bg-success">Đúng</span></c:when>
                                                        <c:otherwise><span class="badge bg-danger">Sai</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-muted" style="font-size:0.85rem;">
                                                    <fmt:formatDate value="${sub.submittedAt}"
                                                        pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty submissions}">
                                            <tr>
                                                <td colspan="6" class="text-center py-4 text-muted">Chưa có lịch sử làm
                                                    bài.</td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <ui:pagination baseUrl="${pageContext.request.contextPath}/teacher/students/history?studentId=${studentId}" page="${page}" totalPages="${totalPages}" />
                    </main>
                </div>
                <jsp:include page="../common/footer.jsp" />
            </body>

            </html>
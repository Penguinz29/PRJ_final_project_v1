<%-- File: WEB-INF/views/teacher/submissions.jsp Servlet: TeacherSubmissionServlet (/teacher/submissions) Attributes:
    submissions(List<Submission>), page(int), totalPages(int), totalRecords(int),
    status(String) - "pending" or "reviewed"
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                <jsp:include page="../common/head.jsp">
                    <jsp:param name="title" value="Chấm bài tự luận" />
                </jsp:include>

                <body data-ctx="${pageContext.request.contextPath}">
                    <jsp:include page="../common/navbar.jsp" />
                    <div class="app-shell">
                        <jsp:include page="../common/sidebar.jsp">
                            <jsp:param name="active" value="teacher-submissions" />
                        </jsp:include>
                        <main class="app-main">
                            <jsp:include page="../common/flash.jsp" />
                            <div class="page-header">
                                <h1><i class="bi bi-pencil-square me-2 text-primary"></i>Chấm bài tự luận
                                    <span class="badge bg-secondary ms-2">${totalRecords}</span>
                                </h1>
                            </div>

                            <%-- Tabs lọc --%>
                                <ul class="nav nav-tabs mb-4">
                                    <li class="nav-item">
                                        <a class="nav-link ${empty status or status == 'pending' ? 'active fw-bold' : ''}"
                                            href="${pageContext.request.contextPath}/teacher/submissions?status=pending">
                                            <i class="bi bi-hourglass-split me-1 text-warning"></i>Cần chấm
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link ${status == 'reviewed' ? 'active fw-bold' : ''}"
                                            href="${pageContext.request.contextPath}/teacher/submissions?status=reviewed">
                                            <i class="bi bi-check2-circle me-1 text-success"></i>Đã chấm
                                        </a>
                                    </li>
                                </ul>

                                <div class="card table-card border-top-0 rounded-top-0">
                                    <div class="table-responsive">
                                        <table class="table table-hover mb-0">
                                            <thead>
                                                <tr>
                                                    <th>#</th>
                                                    <th>Học sinh</th>
                                                    <th>Bài làm</th>
                                                    <th>Câu hỏi</th>
                                                    <th>Nguồn</th>
                                                    <th>Nộp lúc</th>
                                                    <th>Thao tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:choose>
                                                    <c:when test="${empty submissions}">
                                                        <tr>
                                                            <td colspan="7">
                                                                <div class="empty-state">
                                                                    <i class="bi bi-clipboard-check empty-icon"></i>
                                                                    <p>Không có bài luận nào ${empty status or status ==
                                                                        'pending' ? 'cần chấm' : 'đã chấm'}.</p>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:forEach var="sub" items="${submissions}" varStatus="vs">
                                                            <tr>
                                                                <td class="text-muted">${(page-1)*10 + vs.count}</td>
                                                                <td class="fw-semibold">
                                                                    <c:out value="${sub.studentName}" />
                                                                </td>
                                                                <td>
                                                                    <div style="max-height:40px;overflow:hidden;font-size:.85rem;color:#444;"
                                                                        title="<c:out value='${sub.studentAnswer}'/>">
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${not empty sub.essayImagePath}">
                                                                                <i
                                                                                    class="bi bi-image text-primary me-1"></i>[Có
                                                                                hình ảnh đính kèm]
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <c:out value="${sub.studentAnswer}" />
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                </td>
                                                                <td class="text-muted"
                                                                    style="max-width:200px;text-overflow:ellipsis;overflow:hidden;white-space:nowrap;">
                                                                    <c:out value="${sub.questionTitle}" />
                                                                </td>
                                                                <td>
                                                                    <c:if test="${sub.questionAiGenerated}">
                                                                        <i class="bi bi-stars text-ai"
                                                                            title="Câu hỏi AI sinh"></i>
                                                                    </c:if>
                                                                </td>
                                                                <td class="text-muted" style="font-size:.85rem;">
                                                                    <fmt:formatDate value="${sub.submittedAt}"
                                                                        pattern="dd/MM/yyyy HH:mm" />
                                                                </td>
                                                                <td>
                                                                    <a href="${pageContext.request.contextPath}/teacher/submissions?id=${sub.submissionId}"
                                                                        class="btn btn-sm btn-outline-primary">
                                                                        ${empty status or status == 'pending' ? '<i
                                                                            class="bi bi-eyedropper me-1"></i>Chấm điểm'
                                                                        : '<i class="bi bi-eye me-1"></i>Xem lại'}
                                                                    </a>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:otherwise>
                                                </c:choose>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <jsp:include page="../common/pagination.jsp">
                                    <jsp:param name="baseUrl"
                                        value="${pageContext.request.contextPath}/teacher/submissions${not empty status ? '?status='.concat(status) : ''}" />
                                </jsp:include>
                        </main>
                    </div>
                    <jsp:include page="../common/footer.jsp" />
                </body>

                </html>
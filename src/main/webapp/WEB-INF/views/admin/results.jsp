<%-- File: WEB-INF/views/admin/results.jsp
     Controller: AdminResultController (GET /admin/results?topicId=&lessonId=&page=)
     Attributes: level (topics | lessons | submissions), topicId, topicName,
                 groups (List<ResultGroupRow>, level topics/lessons),
                 lesson (LessonView), submissions (List<SubmissionView>), page, totalPages, totalRecords (level submissions)
     Ba cấp: chủ đề → bài giảng → bài làm của học sinh thuộc bài giảng đó. --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Kết quả học sinh" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
<jsp:include page="../common/navbar.jsp" />

<div class="app-shell">
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="active" value="admin-results" />
    </jsp:include>

    <main class="app-main">
        <ui:flash />

        <div class="page-header">
            <h1><i class="bi bi-bar-chart-line me-2 text-primary"></i>
                <c:choose>
                    <c:when test="${level == 'topics'}">Kết quả học sinh theo chủ đề</c:when>
                    <c:when test="${level == 'lessons'}">Bài giảng: <c:out value="${topicName}" /></c:when>
                    <c:otherwise>Bài làm: <c:out value="${lesson.title}" /></c:otherwise>
                </c:choose>
            </h1>
            <c:if test="${level != 'topics'}">
                <a href="${pageContext.request.contextPath}/admin/results${level == 'submissions' ? '?topicId=' : ''}${level == 'submissions' ? topicId : ''}"
                   class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i>Quay lại
                </a>
            </c:if>
        </div>

        <c:choose>
            <%-- ═══ Cấp 1 & 2: bảng thống kê theo chủ đề / bài giảng ═══ --%>
            <c:when test="${level != 'submissions'}">
                <div class="card">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th><c:out value="${level == 'topics' ? 'Chủ đề' : 'Bài giảng'}" /></th>
                                <c:if test="${level == 'topics'}"><th class="text-center">Bài giảng</th></c:if>
                                <th class="text-center">Lượt làm</th>
                                <th class="text-center">Học sinh</th>
                                <th class="text-center">Điểm TB /10</th>
                                <th class="text-end">Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="g" items="${groups}">
                                <c:url var="drill" value="/admin/results">
                                    <c:param name="${level == 'topics' ? 'topicId' : 'lessonId'}" value="${g.id}" />
                                </c:url>
                                <tr>
                                    <td class="fw-semibold"><a href="${drill}" class="text-decoration-none"><c:out value="${g.name}" /></a></td>
                                    <c:if test="${level == 'topics'}"><td class="text-center">${g.lessons}</td></c:if>
                                    <td class="text-center">${g.attempts}</td>
                                    <td class="text-center">${g.students}</td>
                                    <td class="text-center fw-bold">
                                        <c:choose>
                                            <c:when test="${g.avgScore != null}"><fmt:formatNumber value="${g.avgScore}" pattern="0.0#" /></c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <a class="btn btn-sm btn-outline-primary" href="${drill}">
                                            <c:out value="${level == 'topics' ? 'Xem bài giảng' : 'Xem bài làm'}" /> <i class="bi bi-chevron-right"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty groups}">
                                <tr><td colspan="${level == 'topics' ? 6 : 5}" class="text-center text-muted py-4">
                                    <c:out value="${level == 'topics' ? 'Chưa có chủ đề nào.' : 'Chủ đề chưa có bài giảng nào.'}" />
                                </td></tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:when>

            <%-- ═══ Cấp 3: bài làm của học sinh thuộc bài giảng ═══ --%>
            <c:otherwise>
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span><i class="bi bi-list-ul me-1"></i>Bài làm của học sinh</span>
                        <span class="small text-muted">${totalRecords} bài làm</span>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>Học sinh</th>
                                <th style="width:36%">Câu hỏi</th>
                                <th class="text-center">Loại</th>
                                <th class="text-center">Kết quả</th>
                                <th class="text-center">Điểm</th>
                                <th>Thời gian</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="s" items="${submissions}">
                                <tr>
                                    <td>
                                        <div class="fw-semibold"><c:out value="${s.studentName}" /></div>
                                        <div class="small text-muted"><c:out value="${s.studentEmail}" /></div>
                                    </td>
                                    <td class="small"><c:out value="${fn:substring(s.questionTitle, 0, 120)}" /><c:if test="${fn:length(s.questionTitle) > 120}">…</c:if></td>
                                    <td class="text-center">
                                        <span class="badge ${s.questionType == 'MCQ' ? 'bg-info-subtle text-info' : 'bg-warning-subtle text-warning'}">
                                            <c:out value="${s.questionType == 'MCQ' ? 'Trắc nghiệm' : 'Tự luận'}" /></span>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${s.questionType == 'MCQ'}">
                                                <span class="${s.correct ? 'text-success' : 'text-danger'} fw-semibold">${s.correct ? 'Đúng' : 'Sai'}</span>
                                            </c:when>
                                            <c:when test="${s.status == 'REVIEWED'}"><span class="text-success small">Đã duyệt</span></c:when>
                                            <c:otherwise><span class="text-muted small">Chờ duyệt</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center fw-bold">
                                        <c:choose>
                                            <c:when test="${s.score != null}"><fmt:formatNumber value="${s.score}" pattern="0.0#" /></c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="small text-nowrap"><fmt:formatDate value="${s.submittedAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty submissions}">
                                <tr><td colspan="6" class="text-center text-muted py-4">Chưa có học sinh nào làm bài giảng này.</td></tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
                <ui:pagination baseUrl="${pageContext.request.contextPath}/admin/results?lessonId=${lesson.lessonId}"
                               page="${page}" totalPages="${totalPages}" />
            </c:otherwise>
        </c:choose>
    </main>
</div>

<jsp:include page="../common/footer.jsp" />
</body>
</html>

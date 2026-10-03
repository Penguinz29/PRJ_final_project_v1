<%-- File: WEB-INF/views/student/progress.jsp
     Controller: StudentController (GET /student/topics/{topicId}/progress)
     Attributes: topicName (String), lessonProgress (List<ProgressView>), overall (ProgressView tổng của chủ đề)
     FR-STU-06 / BR-10: tiến độ theo từng bài học, tính theo lần làm gần nhất của mỗi câu. --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Tiến độ chủ đề" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
<jsp:include page="../common/navbar.jsp" />

<div class="app-shell">
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="active" value="student-dashboard" />
    </jsp:include>

    <main class="app-main">
        <ui:flash />

        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/student/dashboard">Tổng quan</a></li>
                <li class="breadcrumb-item active" aria-current="page">Tiến độ: <c:out value="${topicName}" /></li>
            </ol>
        </nav>

        <div class="page-header">
            <h1><i class="bi bi-graph-up-arrow me-2 text-primary"></i><c:out value="${topicName}" /></h1>
            <a href="${pageContext.request.contextPath}/student/dashboard" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-left me-1"></i>Quay lại
            </a>
        </div>

        <div class="card card-body mb-3">
            <div class="d-flex flex-wrap gap-4">
                <div><div class="text-muted small">Đã làm</div><div class="fs-4 fw-bold">${overall.answered}/${overall.total} câu</div></div>
                <div><div class="text-muted small">Trả lời đúng (lần gần nhất)</div><div class="fs-4 fw-bold">${overall.correct}</div></div>
                <div><div class="text-muted small">Tỉ lệ đúng</div><div class="fs-4 fw-bold">
                    <c:choose><c:when test="${overall.correctPct != null}"><fmt:formatNumber value="${overall.correctPct}" maxFractionDigits="1" />%</c:when><c:otherwise>--</c:otherwise></c:choose>
                </div></div>
                <div><div class="text-muted small">Hoàn thành</div><div class="fs-4 fw-bold">${overall.completionPct}%</div></div>
            </div>
            <div class="small text-muted mt-2">Mỗi câu chỉ tính kết quả của <strong>lần làm gần nhất</strong>; làm lại câu sai và trả lời đúng sẽ nâng tiến độ.</div>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                    <tr>
                        <th>Bài học</th>
                        <th class="text-center">Đã làm</th>
                        <th class="text-center">Đúng</th>
                        <th style="min-width:180px">Tiến độ</th>
                        <th class="text-end">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="p" items="${lessonProgress}">
                        <tr>
                            <td class="fw-semibold"><c:out value="${p.name}" /></td>
                            <td class="text-center">${p.answered}/${p.total}</td>
                            <td class="text-center">
                                ${p.correct}
                                <c:if test="${p.correctPct != null}"><span class="small text-muted">(<fmt:formatNumber value="${p.correctPct}" maxFractionDigits="1" />%)</span></c:if>
                            </td>
                            <td>
                                <div class="progress" style="height:8px" title="Hoàn thành ${p.completionPct}%">
                                    <div class="progress-bar bg-success" style="width:${p.total == 0 ? 0 : p.correct * 100 / p.total}%"></div>
                                    <div class="progress-bar bg-danger" style="width:${p.total == 0 ? 0 : (p.answered - p.correct) * 100 / p.total}%"></div>
                                </div>
                                <div class="small text-muted mt-1">Hoàn thành ${p.completionPct}%</div>
                            </td>
                            <td class="text-end text-nowrap">
                                <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/student/quiz?lessonId=${p.id}">
                                    <i class="bi bi-play-fill"></i> Luyện</a>
                                <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/student/history?lessonId=${p.id}">
                                    <i class="bi bi-clock-history"></i> Lịch sử</a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty lessonProgress}">
                        <tr><td colspan="5" class="text-center text-muted py-4">Chủ đề chưa có bài học nào.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<jsp:include page="../common/footer.jsp" />
</body>
</html>

<%-- File: WEB-INF/views/teacher/results.jsp
     Controller: TeacherResultController (GET /teacher/results?lessonId=&page=&size=)
     Attributes: lessons (List<LessonView>), lesson (LessonView đang chọn), rows (List<QuestionResultView>),
                 summary (QuestionResultView tổng hợp cả bài), page, size, totalPages, totalRecords
     FR-TEA-08: hiển thị song song tỉ lệ đúng (correct_pct) và điểm trung bình thang 10 (avg_score = correct_pct / 10). --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Kết quả học sinh" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
<jsp:include page="../common/navbar.jsp" />

<div class="app-shell">
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="active" value="teacher-results" />
    </jsp:include>

    <main class="app-main">
        <ui:flash />

        <div class="page-header">
            <h1><i class="bi bi-bar-chart-line me-2 text-primary"></i>Kết quả học sinh theo câu hỏi</h1>
        </div>

        <form class="card card-body mb-3" method="get" action="${pageContext.request.contextPath}/teacher/results">
            <div class="row g-2 align-items-end">
                <div class="col-md-7">
                    <label for="lessonId" class="form-label fw-semibold mb-1">Bài học</label>
                    <select id="lessonId" name="lessonId" class="form-select" onchange="this.form.submit()">
                        <c:forEach var="l" items="${lessons}">
                            <option value="${l.lessonId}" ${l.lessonId == lesson.lessonId ? 'selected' : ''}>
                                <c:out value="${l.topicName}" /> — <c:out value="${l.title}" />
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="size" class="form-label fw-semibold mb-1">Số dòng / trang</label>
                    <select id="size" name="size" class="form-select" onchange="this.form.submit()">
                        <c:forEach var="n" items="10,20,50">
                            <option value="${n}" ${n == size ? 'selected' : ''}>${n}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100"><i class="bi bi-funnel me-1"></i>Xem</button>
                </div>
            </div>
        </form>

        <c:choose>
            <c:when test="${empty lesson}">
                <div class="alert alert-info">Chưa có bài học nào.</div>
            </c:when>
            <c:otherwise>
                <%-- Tổng hợp cả bài học --%>
                <div class="row g-3 mb-3">
                    <div class="col-6 col-md-3"><div class="card card-body text-center">
                        <div class="text-muted small">Câu trắc nghiệm</div><div class="fs-4 fw-bold">${totalRecords}</div></div></div>
                    <div class="col-6 col-md-3"><div class="card card-body text-center">
                        <div class="text-muted small">Lượt làm / Học sinh</div>
                        <div class="fs-4 fw-bold">${summary.attempts} / ${summary.students}</div></div></div>
                    <div class="col-6 col-md-3"><div class="card card-body text-center">
                        <div class="text-muted small">Tỉ lệ đúng chung</div>
                        <div class="fs-4 fw-bold">
                            <c:choose><c:when test="${summary.correctPct != null}"><fmt:formatNumber value="${summary.correctPct}" pattern="0.#" />%</c:when><c:otherwise>—</c:otherwise></c:choose>
                        </div></div></div>
                    <div class="col-6 col-md-3"><div class="card card-body text-center">
                        <div class="text-muted small">Điểm TB (thang 10)</div>
                        <div class="fs-4 fw-bold">
                            <c:choose><c:when test="${summary.avgScore != null}"><fmt:formatNumber value="${summary.avgScore}" pattern="0.0#" /></c:when><c:otherwise>—</c:otherwise></c:choose>
                        </div></div></div>
                </div>

                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <span><i class="bi bi-list-ol me-1"></i>Theo từng câu (tỉ lệ đúng thấp nhất trước)</span>
                        <span class="small text-muted">Điểm TB = tỉ lệ đúng / 10 (đúng 10 điểm, sai 0)</span>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                            <tr>
                                <th style="width:50%">Câu hỏi</th>
                                <th class="text-center">Mức độ</th>
                                <th class="text-center">Lượt làm</th>
                                <th class="text-center">Học sinh</th>
                                <th class="text-center">Tỉ lệ đúng</th>
                                <th class="text-center">Điểm TB /10</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="r" items="${rows}">
                                <tr>
                                    <td class="latex-content small"><ui:rich-text value="${r.content}" /></td>
                                    <td class="text-center">${r.level}</td>
                                    <td class="text-center">${r.attempts}</td>
                                    <td class="text-center">${r.students}</td>
                                    <td class="text-center" style="min-width:140px">
                                        <c:choose>
                                            <c:when test="${r.correctPct != null}">
                                                <div class="small fw-semibold"><fmt:formatNumber value="${r.correctPct}" pattern="0.#" />%</div>
                                                <div class="progress" style="height:6px">
                                                    <div class="progress-bar ${r.correctPct < 50 ? 'bg-danger' : (r.correctPct < 80 ? 'bg-warning' : 'bg-success')}"
                                                         style="width:${r.correctPct}%"></div>
                                                </div>
                                            </c:when>
                                            <c:otherwise><span class="text-muted small">Chưa có lượt làm</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center fw-bold">
                                        <c:choose>
                                            <c:when test="${r.avgScore != null}"><fmt:formatNumber value="${r.avgScore}" pattern="0.0#" /></c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty rows}">
                                <tr><td colspan="6" class="text-center text-muted py-4">Bài học chưa có câu trắc nghiệm nào.</td></tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
                <ui:pagination baseUrl="${pageContext.request.contextPath}/teacher/results?lessonId=${lesson.lessonId}&size=${size}"
                               page="${page}" totalPages="${totalPages}" />
            </c:otherwise>
        </c:choose>
    </main>
</div>

<jsp:include page="../common/footer.jsp" />
</body>
</html>

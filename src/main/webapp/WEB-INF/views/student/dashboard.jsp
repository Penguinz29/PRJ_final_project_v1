<%-- File: WEB-INF/views/student/dashboard.jsp Controller: StudentController (GET /student/dashboard)
    Attributes: totalTopics(int), topicProgress(List<ProgressView>), overall(ProgressView), essayAverage(Double),
                recentAttempts(List<SubmissionView>)
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
                <jsp:include page="../common/head.jsp">
                    <jsp:param name="title" value="Tổng quan Học sinh" />
                </jsp:include>

                <body data-ctx="${pageContext.request.contextPath}">

                    <jsp:include page="../common/navbar.jsp" />

                    <div class="app-shell">
                        <jsp:include page="../common/sidebar.jsp">
                            <jsp:param name="active" value="student-dashboard" />
                        </jsp:include>

                        <main class="app-main">
                            <ui:flash />

                            <div class="page-header">
                                <h1><i class="bi bi-speedometer2 me-2 text-primary"></i>Tổng quan học tập</h1>
                                <span class="text-muted" style="font-size:.85rem;">
                                    Xin chào, <strong>
                                        <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />
                                    </strong>!
                                </span>
                            </div>

                            <%-- Stat cards: tính theo lần làm gần nhất của mỗi câu (BR-10) --%>
                                <div class="row g-3 mb-4">
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon blue"><i class="bi bi-book"></i></div>
                                            <div>
                                                <div class="stat-number">${totalTopics}</div>
                                                <div class="stat-label">Chủ đề có thể học</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon green"><i class="bi bi-check2-circle"></i></div>
                                            <div>
                                                <div class="stat-number">${overall.answered}/${overall.total}</div>
                                                <div class="stat-label">Câu trắc nghiệm đã làm</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon orange"><i class="bi bi-bullseye"></i></div>
                                            <div>
                                                <div class="stat-number">
                                                    <c:choose>
                                                        <c:when test="${overall.correctPct != null}"><fmt:formatNumber value="${overall.correctPct}" maxFractionDigits="1" />%</c:when>
                                                        <c:otherwise>--</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="stat-label">Tỉ lệ đúng trắc nghiệm</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon purple"><i class="bi bi-star-fill"></i></div>
                                            <div>
                                                <div class="stat-number">
                                                    <c:choose>
                                                        <c:when test="${essayAverage != null}"><fmt:formatNumber value="${essayAverage}" maxFractionDigits="2" />/10</c:when>
                                                        <c:otherwise>--</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="stat-label">Điểm TB tự luận</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <%-- FR-STU-06: tiến độ theo chủ đề; bấm để xem theo từng bài học --%>
                                <div class="card mb-4">
                                    <div class="card-header">
                                        <i class="bi bi-graph-up-arrow me-2 text-primary"></i>Tiến độ theo chủ đề
                                        <span class="small text-muted ms-2">(tính theo lần làm gần nhất của mỗi câu)</span>
                                    </div>
                                    <div class="list-group list-group-flush">
                                        <c:forEach var="p" items="${topicProgress}">
                                            <a class="list-group-item list-group-item-action py-3"
                                               href="${pageContext.request.contextPath}/student/topics/${p.id}/progress">
                                                <div class="d-flex justify-content-between align-items-center mb-1">
                                                    <span class="fw-semibold"><c:out value="${p.name}" /></span>
                                                    <span class="small text-muted">
                                                        Đã làm ${p.answered}/${p.total} câu
                                                        <c:if test="${p.correctPct != null}"> · đúng ${p.correct} (<fmt:formatNumber value="${p.correctPct}" maxFractionDigits="1" />%)</c:if>
                                                        <i class="bi bi-chevron-right ms-1"></i>
                                                    </span>
                                                </div>
                                                <div class="progress" style="height:8px" title="Hoàn thành ${p.completionPct}%">
                                                    <div class="progress-bar bg-success" style="width:${p.answered == 0 ? 0 : p.correct * 100 / (p.total == 0 ? 1 : p.total)}%"></div>
                                                    <div class="progress-bar bg-danger" style="width:${p.answered == 0 ? 0 : (p.answered - p.correct) * 100 / (p.total == 0 ? 1 : p.total)}%"></div>
                                                </div>
                                            </a>
                                        </c:forEach>
                                        <c:if test="${empty topicProgress}">
                                            <div class="list-group-item text-muted">Chưa có chủ đề nào.</div>
                                        </c:if>
                                    </div>
                                </div>

                                <%-- Nhanh học ngay --%>
                                    <div class="card mb-4">
                                        <div class="card-body d-flex flex-wrap align-items-center gap-3">
                                            <div>
                                                <div class="fw-bold fs-5">Sẵn sàng học chưa?</div>
                                                <div class="text-muted" style="font-size:.88rem;">Chọn bài giảng và làm
                                                    bài trắc nghiệm hoặc tự luận.</div>
                                            </div>
                                            <div class="ms-auto d-flex gap-2 flex-wrap">
                                                <a href="${pageContext.request.contextPath}/student/topics"
                                                    class="btn btn-primary">
                                                    <i class="bi bi-book me-1"></i>Học ngay
                                                </a>
                                                <a href="${pageContext.request.contextPath}/student/ai-tutor"
                                                    class="btn btn-ai">
                                                    <i class="bi bi-chat-dots me-1"></i>Hỏi AI
                                                </a>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Lịch sử làm bài gần đây --%>
                                        <div class="card">
                                            <div class="card-header">
                                                <i class="bi bi-clock-history me-2 text-primary"></i>Kết quả gần đây
                                                <a href="${pageContext.request.contextPath}/student/history"
                                                    class="btn btn-sm btn-outline-primary ms-auto">Xem tất cả</a>
                                            </div>
                                            <div class="table-responsive">
                                                <table class="table table-hover table-card mb-0">
                                                    <thead>
                                                        <tr>
                                                            <th>Câu hỏi</th>
                                                            <th>Loại</th>
                                                            <th>Điểm / Kết quả</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:choose>
                                                            <c:when test="${empty recentAttempts}">
                                                                <tr>
                                                                    <td colspan="3" class="text-center text-muted py-4">
                                                                        <i
                                                                            class="bi bi-inbox d-block fs-1 mb-2 opacity-25"></i>
                                                                        Bạn chưa làm bài nào. <a
                                                                            href="${pageContext.request.contextPath}/student/topics">Bắt
                                                                            đầu học ngay!</a>
                                                                    </td>
                                                                </tr>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:forEach var="sub" items="${recentAttempts}">
                                                                    <tr>
                                                                        <td>
                                                                            <c:out value="${sub.questionTitle}" />
                                                                        </td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${sub.questionType == 'MCQ'}">
                                                                                    <span
                                                                                        class="badge bg-primary-subtle text-primary">Trắc
                                                                                        nghiệm</span>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span
                                                                                        class="badge bg-purple-subtle text-ai">Tự
                                                                                        luận</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                        <td>
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${sub.questionType == 'MCQ'}">
                                                                                    <c:choose>
                                                                                        <c:when test="${sub.correct}">
                                                                                            <span
                                                                                                class="text-success fw-bold"><i
                                                                                                    class="bi bi-check-lg"></i>
                                                                                                Đúng</span>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span
                                                                                                class="text-danger fw-bold"><i
                                                                                                    class="bi bi-x-lg"></i>
                                                                                                Sai</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <c:choose>
                                                                                        <c:when test="${sub.reviewed}">
                                                                                            <span
                                                                                                class="text-success"><i
                                                                                                    class="bi bi-check2-circle"></i>
                                                                                                Đã chấm</span>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <span
                                                                                                class="text-warning"><i
                                                                                                    class="bi bi-hourglass-split"></i>
                                                                                                Chờ chấm</span>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                        </main>
                    </div>

                    <jsp:include page="../common/footer.jsp" />
                </body>

                </html>
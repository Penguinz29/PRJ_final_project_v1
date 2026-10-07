<%-- File: WEB-INF/views/student/essay-topics.jsp. Controller: StudentEssayController (GET /student/essay, không có lessonId).
    Attributes: topics (chủ đề kèm lessons), essayCounts (Map lessonId -> số câu tự luận). Bấm bài học → /student/essay?lessonId=... --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Làm tự luận" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
    <jsp:include page="../common/navbar.jsp" />
    <div class="app-shell">
        <jsp:include page="../common/sidebar.jsp">
            <jsp:param name="active" value="student-essay" />
        </jsp:include>
        <main class="app-main">
            <ui:flash />

            <div class="page-header mb-4 border-bottom-0 pb-0">
                <div>
                    <h1><i class="bi bi-camera me-2 text-primary"></i>Làm tự luận</h1>
                    <p class="st-subtitle text-muted mb-0">Chọn chủ đề, rồi chọn bài học để làm bài tập tự luận</p>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty topics}">
                    <div class="card border-0 shadow-sm text-center py-5">
                        <i class="bi bi-inbox d-block display-1 text-muted opacity-25 mb-3"></i>
                        <h5 class="text-muted">Chưa có chủ đề nào được công bố.</h5>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="accordion st-accordion" id="essayTopicsAccordion">
                        <c:forEach var="t" items="${topics}" varStatus="tVs">
                            <div class="accordion-item border-0 st-topic-card mb-3">
                                <h2 class="accordion-header">
                                    <button class="accordion-button st-topic-btn shadow-none ${tVs.first ? '' : 'collapsed'}"
                                        type="button" data-bs-toggle="collapse" data-bs-target="#essayCollapse${t.topicId}">
                                        <div class="d-flex align-items-center gap-3 w-100">
                                            <div class="st-topic-num"><c:out value="${tVs.count}" /></div>
                                            <div class="flex-grow-1 min-w-0">
                                                <div class="st-topic-title"><c:out value="${t.topicName}" /></div>
                                                <span class="st-lesson-count">${empty t.lessons ? 0 : t.lessons.size()} bài học</span>
                                            </div>
                                            <i class="bi bi-chevron-down st-chevron"></i>
                                        </div>
                                    </button>
                                </h2>
                                <div id="essayCollapse${t.topicId}"
                                    class="accordion-collapse collapse ${tVs.first ? 'show' : ''}"
                                    data-bs-parent="#essayTopicsAccordion">
                                    <div class="accordion-body p-0 border-top">
                                        <c:choose>
                                            <c:when test="${empty t.lessons}">
                                                <div class="p-4 text-center text-muted">Chủ đề này chưa có bài học.</div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="list-group list-group-flush">
                                                    <c:forEach var="l" items="${t.lessons}">
                                                        <c:set var="n" value="${empty essayCounts[l.lessonId] ? 0 : essayCounts[l.lessonId]}" />
                                                        <c:choose>
                                                            <c:when test="${n > 0}">
                                                                <a href="${pageContext.request.contextPath}/student/essay?lessonId=${l.lessonId}"
                                                                    class="list-group-item list-group-item-action st-lesson-row d-flex align-items-center gap-3 py-3 px-4"
                                                                    style="padding-left: 5rem !important;">
                                                                    <div class="st-lesson-icon"><i class="bi bi-pencil-square"></i></div>
                                                                    <div class="flex-grow-1 min-w-0">
                                                                        <div class="st-lesson-title"><c:out value="${l.title}" /></div>
                                                                        <div class="st-lesson-summary"><c:out value="${l.summary}" /></div>
                                                                    </div>
                                                                    <span class="badge bg-primary-subtle text-primary">${n} câu</span>
                                                                    <i class="bi bi-chevron-right st-lesson-arrow"></i>
                                                                </a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="list-group-item d-flex align-items-center gap-3 py-3 px-4 text-muted"
                                                                    style="padding-left: 5rem !important;">
                                                                    <div class="st-lesson-icon"><i class="bi bi-pencil-square"></i></div>
                                                                    <div class="flex-grow-1 min-w-0">
                                                                        <div class="st-lesson-title"><c:out value="${l.title}" /></div>
                                                                    </div>
                                                                    <span class="small">Chưa có câu tự luận</span>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:forEach>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>
    </div>
    <jsp:include page="../common/footer.jsp" />
</body>

</html>

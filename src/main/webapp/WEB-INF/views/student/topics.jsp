<%-- File: WEB-INF/views/student/topics.jsp Servlet: StudentTopicServlet (/student/topics) Attributes:
    topics(List<Topic>)
    Note: Mỗi topic sẽ có lessons (List<Lesson>) kèm theo
        --%>
        <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
            <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
                <jsp:include page="../common/head.jsp">
                    <jsp:param name="title" value="Chủ đề học tập" />
                </jsp:include>

                <body data-ctx="${pageContext.request.contextPath}">
                    <jsp:include page="../common/navbar.jsp" />
                    <div class="app-shell">
                        <jsp:include page="../common/sidebar.jsp">
                            <jsp:param name="active" value="student-topics" />
                        </jsp:include>
                        <main class="app-main">
                            <ui:flash />

                            <div class="page-header mb-4 border-bottom-0 pb-0">
                                <h1><i class="bi bi-book me-2 text-primary"></i>Danh sách Chủ đề</h1>
                                <p class="text-muted mb-0">Chọn bài giảng để bắt đầu học và làm bài tập</p>
                            </div>

                            <c:choose>
                                <c:when test="${empty topics}">
                                    <div class="card border-0 shadow-sm text-center py-5">
                                        <i class="bi bi-inbox d-block display-1 text-muted opacity-25 mb-3"></i>
                                        <h5 class="text-muted">Chưa có chủ đề nào được công bố.</h5>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="accordion" id="topicsAccordion">
                                        <c:forEach var="t" items="${topics}" varStatus="tVs">
                                            <div class="accordion-item border-0 card mb-3 shadow-sm"
                                                style="overflow:hidden;">
                                                <h2 class="accordion-header">
                                                    <button
                                                        class="accordion-button fw-bold fs-5 shadow-none ${tVs.first ? '' : 'collapsed'}"
                                                        type="button" data-bs-toggle="collapse"
                                                        data-bs-target="#collapse${t.topicId}">
                                                        <div class="d-flex align-items-center w-100">
                                                            <div class="stat-icon blue me-3"
                                                                style="width:40px;height:40px;font-size:1.1rem;flex-shrink:0;">
                                                                <c:out value="${tVs.count}" />
                                                            </div>
                                                            <div>
                                                                <div class="mb-1">
                                                                    <c:out value="${t.topicName}" />
                                                                </div>
                                                                <span
                                                                    class="badge bg-secondary-subtle text-secondary fw-normal">
                                                                    ${empty t.lessons ? 0 : t.lessons.size()} bài giảng
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </button>
                                                </h2>
                                                <div id="collapse${t.topicId}"
                                                    class="accordion-collapse collapse ${tVs.first ? 'show' : ''}"
                                                    data-bs-parent="#topicsAccordion">
                                                    <div class="accordion-body p-0 border-top">
                                                        <c:choose>
                                                            <c:when test="${empty t.lessons}">
                                                                <div class="p-4 text-center text-muted">Chủ đề này chưa
                                                                    có bài giảng.</div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="list-group list-group-flush">
                                                                    <c:forEach var="l" items="${t.lessons}"
                                                                        varStatus="lVs">
                                                                        <a href="${pageContext.request.contextPath}/student/lesson?id=${l.lessonId}"
                                                                            class="list-group-item list-group-item-action d-flex justify-content-between align-items-center p-3">
                                                                            <div>
                                                                                <h6
                                                                                    class="mb-1 fw-semibold text-primary">
                                                                                    <i
                                                                                        class="bi bi-file-earmark-text me-2"></i>Bài
                                                                                    ${lVs.count}:
                                                                                    <c:out value="${l.title}" />
                                                                                </h6>
                                                                                <div class="text-muted"
                                                                                    style="font-size:0.85rem;">
                                                                                    <c:out value="${l.summary}" />
                                                                                </div>
                                                                            </div>
                                                                            <i
                                                                                class="bi bi-chevron-right text-muted opacity-50"></i>
                                                                        </a>
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
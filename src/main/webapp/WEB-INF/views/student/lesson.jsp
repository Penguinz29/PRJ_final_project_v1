<%-- File: WEB-INF/views/student/lesson.jsp Servlet: StudentLessonServlet (/student/lesson) Attributes: lesson(Lesson)
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="${lesson.title}" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="student-topics" />
                    </jsp:include>
                    <main class="app-main">
                        <ui:flash />

                        <div class="page-header mb-3">
                            <div>
                                <nav aria-label="breadcrumb">
                                    <ol class="breadcrumb mb-1" style="font-size:.85rem;">
                                        <li class="breadcrumb-item"><a
                                                href="${pageContext.request.contextPath}/student/topics"
                                                class="text-decoration-none">Chủ đề</a></li>
                                        <li class="breadcrumb-item active" aria-current="page">
                                            <c:out value="${lesson.topicName}" />
                                        </li>
                                    </ol>
                                </nav>
                                <h1 class="mb-2">
                                    <c:out value="${lesson.title}" />
                                </h1>
                                <p class="text-muted">
                                    <c:out value="${lesson.summary}" />
                                </p>
                            </div>

                            <div class="d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/student/quiz?lessonId=${lesson.lessonId}"
                                    class="btn btn-primary d-flex align-items-center">
                                    <i class="bi bi-joystick me-2"></i>Làm trắc nghiệm
                                </a>
                                <a href="${pageContext.request.contextPath}/student/essay?lessonId=${lesson.lessonId}"
                                    class="btn btn-outline-primary d-flex align-items-center">
                                    <i class="bi bi-pencil-square me-2"></i>Làm tự luận
                                </a>
                            </div>
                        </div>

                        <div class="row g-4">
                            <div class="col-12 col-xl-10">
                                <div class="card shadow-sm border-0 mb-4">
                                    <div class="card-header bg-white py-3">
                                        <i class="bi bi-book-half me-2 text-primary"></i>Nội dung lý thuyết
                                    </div>
                                    <div class="card-body p-4 latex-content" style="font-size:1rem;line-height:1.7;">
                                        <c:out value="${lesson.content}" />
                                    </div>
                                </div>
                                <%-- Bài giảng: YouTube / video / liên kết / văn bản (lesson_materials) --%>
                                <c:if test="${not empty materials}">
                                    <div class="card shadow-sm border-0 mb-4">
                                        <div class="card-header bg-white py-3">
                                            <i class="bi bi-collection-play me-2 text-primary"></i>Bài giảng
                                        </div>
                                        <div class="card-body p-4">
                                            <c:forEach var="m" items="${materials}" varStatus="vs">
                                                <div class="${vs.last ? '' : 'mb-4 pb-4 border-bottom'}">
                                                    <h6 class="fw-bold mb-3"><c:out value="${m.title}" /></h6>
                                                    <c:choose>
                                                        <c:when test="${m.materialType == 'YOUTUBE' and not empty m.youtubeEmbedUrl}">
                                                            <div class="ratio ratio-16x9">
                                                                <iframe src="${m.youtubeEmbedUrl}" title="<c:out value='${m.title}'/>"
                                                                    allow="accelerometer; encrypted-media; gyroscope; picture-in-picture; web-share"
                                                                    referrerpolicy="strict-origin-when-cross-origin" loading="lazy"
                                                                    allowfullscreen class="rounded"></iframe>
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${m.materialType == 'VIDEO'}">
                                                            <video controls preload="metadata" class="w-100 rounded"
                                                                src="<c:out value='${m.url}'/>">
                                                                Trình duyệt không hỗ trợ phát video.
                                                            </video>
                                                        </c:when>
                                                        <c:when test="${m.materialType == 'LINK'}">
                                                            <a href="<c:out value='${m.url}'/>" target="_blank"
                                                                rel="noopener noreferrer" class="btn btn-outline-primary">
                                                                <i class="bi bi-box-arrow-up-right me-2"></i>Mở liên kết
                                                            </a>
                                                            <div class="small text-muted mt-1 text-break"><c:out value="${m.url}" /></div>
                                                        </c:when>
                                                        <c:when test="${m.materialType == 'TEXT'}">
                                                            <div class="latex-content" style="white-space:pre-wrap;line-height:1.7;"><c:out value="${m.contentText}" /></div>
                                                        </c:when>
                                                    </c:choose>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </main>
                </div>
                <jsp:include page="../common/footer.jsp" />
            </body>

            </html>
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
                            <div class="col-lg-8">
                                <div class="card shadow-sm border-0 mb-4">
                                    <div class="card-header bg-white py-3">
                                        <i class="bi bi-book-half me-2 text-primary"></i>Nội dung lý thuyết
                                    </div>
                                    <div class="card-body p-4 latex-content" style="font-size:1rem;line-height:1.7;">
                                        <c:out value="${lesson.content}" />
                                    </div>
                                </div>
                            </div>

                            <div class="col-lg-4">
                                <c:if test="${not empty lesson.embedUrl}">
                                    <div class="card shadow-sm border-0 mb-4"
                                        style="position:sticky;top:calc(var(--navbar-h) + 1rem);">
                                        <div class="card-header bg-white py-3">
                                            <i class="bi bi-youtube me-2 text-danger"></i>Video hướng dẫn
                                        </div>
                                        <div class="card-body p-2">
                                            <%-- Assuming lesson.youtubeUrl contains the embed URL here via FileUtil
                                                mapping --%>
                                                <div class="ratio ratio-16x9">
                                                    <iframe src="${lesson.embedUrl}" allowfullscreen
                                                        class="rounded"></iframe>
                                                </div>
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
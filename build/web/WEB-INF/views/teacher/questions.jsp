<%-- File: WEB-INF/views/teacher/questions.jsp Servlet: TeacherQuestionServlet (/teacher/questions) Attributes:
    questions(List<Question>), lessons(List<Lesson>), topics(List<Topic>),
            page(int), totalPages(int), totalRecords(int),
            selectedLessonId(Integer), selectedType(String)
            Actions: delete (POST)
            --%>
            <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
                <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
                    <jsp:include page="../common/head.jsp">
                        <jsp:param name="title" value="Câu hỏi" />
                    </jsp:include>

                    <body data-ctx="${pageContext.request.contextPath}">
                        <jsp:include page="../common/navbar.jsp" />
                        <div class="app-shell">
                            <jsp:include page="../common/sidebar.jsp">
                                <jsp:param name="active" value="teacher-questions" />
                            </jsp:include>
                            <main class="app-main">
                                <jsp:include page="../common/flash.jsp" />
                                <div class="page-header">
                                    <h1><i class="bi bi-patch-question me-2 text-primary"></i>Câu hỏi
                                        <span class="badge bg-secondary ms-2">${totalRecords}</span>
                                    </h1>
                                    <a href="${pageContext.request.contextPath}/teacher/questions?action=create"
                                        class="btn btn-primary btn-sm">
                                        <i class="bi bi-plus-lg me-1"></i>Thêm câu hỏi
                                    </a>
                                </div>

                                <%-- Lọc --%>
                                    <div class="card mb-3">
                                        <div class="card-body py-2">
                                            <form class="row g-2"
                                                action="${pageContext.request.contextPath}/teacher/questions"
                                                method="get">
                                                <div class="col-sm-5">
                                                    <select class="form-select form-select-sm" name="lessonId">
                                                        <option value="">-- Lọc theo bài giảng --</option>
                                                        <c:forEach var="l" items="${lessons}">
                                                            <option value="${l.lessonId}" ${selectedLessonId==l.lessonId
                                                                ? 'selected' : '' }>
                                                                <c:out value="${l.title}" />
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-sm-3">
                                                    <select class="form-select form-select-sm" name="type">
                                                        <option value="">-- Loại --</option>
                                                        <option value="MCQ" ${selectedType=='MCQ' ? 'selected' : '' }>
                                                            Trắc nghiệm</option>
                                                        <option value="ESSAY" ${selectedType=='ESSAY' ? 'selected' : ''
                                                            }>Tự luận</option>
                                                    </select>
                                                </div>
                                                <div class="col-sm-2">
                                                    <button class="btn btn-sm btn-primary w-100"><i
                                                            class="bi bi-search"></i></button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>

                                    <div class="card table-card">
                                        <div class="table-responsive">
                                            <table class="table table-hover mb-0">
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <th>Nội dung (tóm tắt)</th>
                                                        <th>Loại</th>
                                                        <th>Mức độ</th>
                                                        <th>Bài giảng</th>
                                                        <th>Nguồn</th>
                                                        <th style="width:100px">Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:choose>
                                                        <c:when test="${empty questions}">
                                                            <tr>
                                                                <td colspan="7">
                                                                    <div class="empty-state">
                                                                        <i class="bi bi-patch-question empty-icon"></i>
                                                                        <p>Chưa có câu hỏi nào.</p>
                                                                        <a href="${pageContext.request.contextPath}/teacher/questions?action=create"
                                                                            class="btn btn-primary btn-sm">Thêm câu
                                                                            hỏi</a>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:forEach var="q" items="${questions}" varStatus="vs">
                                                                <tr>
                                                                    <td class="text-muted">${(page-1)*10 + vs.count}
                                                                    </td>
                                                                    <td style="max-width:280px;">
                                                                        <div class="text-truncate">
                                                                            <c:out value="${q.content}" />
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${q.type == 'MCQ'}">
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
                                                                            <c:when test="${q.level == 1}"><span
                                                                                    class="badge-level-1">Dễ</span>
                                                                            </c:when>
                                                                            <c:when test="${q.level == 2}"><span
                                                                                    class="badge-level-2">TB</span>
                                                                            </c:when>
                                                                            <c:when test="${q.level == 3}"><span
                                                                                    class="badge-level-3">Khó</span>
                                                                            </c:when>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td class="text-muted" style="font-size:.8rem;">
                                                                        <c:out value="${q.lessonTitle}" />
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${q.aiGenerated}">
                                                                                <span class="badge-ai"><i
                                                                                        class="bi bi-stars me-1"></i>AI</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span
                                                                                    class="badge bg-secondary-subtle text-secondary">Thủ
                                                                                    công</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>
                                                                        <a href="${pageContext.request.contextPath}/teacher/questions?action=edit&id=${q.questionId}"
                                                                            class="btn btn-sm btn-outline-primary me-1"><i
                                                                                class="bi bi-pencil"></i></a>
                                                                        <form class="d-inline" id="delQ${q.questionId}"
                                                                            action="${pageContext.request.contextPath}/teacher/questions"
                                                                            method="post">
                                                                            <input type="hidden" name="action"
                                                                                value="delete">
                                                                            <input type="hidden" name="id"
                                                                                value="${q.questionId}">
                                                                        </form>
                                                                        <button class="btn btn-sm btn-outline-danger"
                                                                            data-confirm="true"
                                                                            data-form="#delQ${q.questionId}"
                                                                            data-confirm-message="Xóa câu hỏi này?">
                                                                            <i class="bi bi-trash3"></i>
                                                                        </button>
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
                                            value="${pageContext.request.contextPath}/teacher/questions${not empty selectedLessonId ? '?lessonId='.concat(selectedLessonId) : ''}" />
                                    </jsp:include>
                            </main>
                        </div>
                        <jsp:include page="../common/confirm-modal.jsp" />
                        <jsp:include page="../common/footer.jsp" />
                    </body>

                    </html>
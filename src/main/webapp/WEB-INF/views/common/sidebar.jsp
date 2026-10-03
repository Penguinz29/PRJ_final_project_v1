<%-- sidebar.jsp: menu theo role, param active --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <aside class="app-sidebar">
                <c:choose>
                    <%--=====ADMIN=====--%>
                        <c:when test="${sessionScope.LOGGED_IN_USER.role == 'ADMIN'}">
                            <div class="sidebar-group-label">Tổng quan</div>
                            <a href="${pageContext.request.contextPath}/admin/dashboard"
                                class="sidebar-link ${param.active == 'admin-dashboard' ? 'active' : ''}">
                                <i class="bi bi-speedometer2"></i> Tổng quan
                            </a>

                            <div class="sidebar-group-label">Người dùng</div>
                            <a href="${pageContext.request.contextPath}/admin/users"
                                class="sidebar-link ${param.active == 'admin-users' ? 'active' : ''}">
                                <i class="bi bi-people"></i> Quản lý người dùng
                            </a>

                            <div class="sidebar-group-label">Nội dung</div>
                            <a href="${pageContext.request.contextPath}/admin/topics"
                                class="sidebar-link ${param.active == 'admin-topics' ? 'active' : ''}">
                                <i class="bi bi-folder2"></i> Chủ đề
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/lessons"
                                class="sidebar-link ${param.active == 'admin-lessons' ? 'active' : ''}">
                                <i class="bi bi-journal-text"></i> Bài giảng
                            </a>
                            <a href="${pageContext.request.contextPath}/admin/questions"
                                class="sidebar-link ${param.active == 'admin-questions' ? 'active' : ''}">
                                <i class="bi bi-patch-question"></i> Câu hỏi
                            </a>

                            <div class="sidebar-group-label">Hệ thống</div>
                            <a href="${pageContext.request.contextPath}/admin/ai-config"
                                class="sidebar-link ${param.active == 'admin-ai-config' ? 'active' : ''}">
                                <i class="bi bi-gear-wide-connected"></i> Cấu hình AI
                            </a>
                        </c:when>

                        <%--=====TEACHER=====--%>
                            <c:when test="${sessionScope.LOGGED_IN_USER.role == 'TEACHER'}">
                                <div class="sidebar-group-label">Tổng quan</div>
                                <a href="${pageContext.request.contextPath}/teacher/dashboard"
                                    class="sidebar-link ${param.active == 'teacher-dashboard' ? 'active' : ''}">
                                    <i class="bi bi-speedometer2"></i> Tổng quan
                                </a>

                                <div class="sidebar-group-label">Nội dung</div>
                                <a href="${pageContext.request.contextPath}/teacher/topics"
                                    class="sidebar-link ${param.active == 'teacher-topics' ? 'active' : ''}">
                                    <i class="bi bi-folder2"></i> Chủ đề
                                </a>
                                <a href="${pageContext.request.contextPath}/teacher/lessons"
                                    class="sidebar-link ${param.active == 'teacher-lessons' ? 'active' : ''}">
                                    <i class="bi bi-journal-text"></i> Bài giảng
                                </a>
                                <a href="${pageContext.request.contextPath}/teacher/questions"
                                    class="sidebar-link ${param.active == 'teacher-questions' ? 'active' : ''}">
                                    <i class="bi bi-patch-question"></i> Câu hỏi
                                </a>
                                <a href="${pageContext.request.contextPath}/teacher/ai/generate"
                                    class="sidebar-link ${param.active == 'teacher-ai' ? 'active' : ''}">
                                    <i class="bi bi-stars"></i> AI sinh câu hỏi
                                </a>

                                <div class="sidebar-group-label">Lớp học</div>
                                <a href="${pageContext.request.contextPath}/teacher/students"
                                    class="sidebar-link ${param.active == 'teacher-students' ? 'active' : ''}">
                                    <i class="bi bi-people"></i> Học sinh của tôi
                                </a>
                                <a href="${pageContext.request.contextPath}/teacher/results"
                                    class="sidebar-link ${param.active == 'teacher-results' ? 'active' : ''}">
                                    <i class="bi bi-bar-chart-line"></i> Kết quả học sinh
                                </a>
                                <a href="${pageContext.request.contextPath}/teacher/submissions"
                                    class="sidebar-link ${param.active == 'teacher-submissions' ? 'active' : ''}">
                                    <i class="bi bi-pencil-square"></i> Bài tự luận
                                </a>
                            </c:when>

                            <%--=====STUDENT=====--%>
                                <c:otherwise>
                                    <div class="sidebar-group-label">Tổng quan</div>
                                    <a href="${pageContext.request.contextPath}/student/dashboard"
                                        class="sidebar-link ${param.active == 'student-dashboard' ? 'active' : ''}">
                                        <i class="bi bi-speedometer2"></i> Tổng quan
                                    </a>

                                    <div class="sidebar-group-label">Học tập</div>
                                    <a href="${pageContext.request.contextPath}/student/topics"
                                        class="sidebar-link ${param.active == 'student-topics' ? 'active' : ''}">
                                        <i class="bi bi-book"></i> Bài giảng
                                    </a>
                                    <a href="${pageContext.request.contextPath}/student/essay"
                                        class="sidebar-link ${param.active == 'student-essay' ? 'active' : ''}">
                                        <i class="bi bi-camera"></i> Làm tự luận
                                    </a>
                                    <a href="${pageContext.request.contextPath}/student/ai-tutor"
                                        class="sidebar-link ${param.active == 'student-ai' ? 'active' : ''}">
                                        <i class="bi bi-chat-dots"></i> Hỏi AI từng bước
                                    </a>
                                    <a href="${pageContext.request.contextPath}/student/history"
                                        class="sidebar-link ${param.active == 'student-history' ? 'active' : ''}">
                                        <i class="bi bi-clock-history"></i> Lịch sử làm bài
                                    </a>
                                </c:otherwise>
                </c:choose>
            </aside>
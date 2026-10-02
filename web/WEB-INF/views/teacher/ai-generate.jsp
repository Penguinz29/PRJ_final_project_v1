<%-- File: WEB-INF/views/teacher/ai-generate.jsp Servlet: TeacherAiGenerateServlet (/teacher/ai/generate) Attributes:
    topics(List<Topic>)
    POST Fields: topicId, difficulty(1,2,3), quantity(int), prompt, questionType(MCQ|ESSAY)
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="AI Tạo Câu Hỏi" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="teacher-ai-gen" />
                    </jsp:include>
                    <main class="app-main">
                        <jsp:include page="../common/flash.jsp" />

                        <div class="page-header">
                            <h1><i class="bi bi-stars me-2 text-ai"></i>Sinh câu hỏi bằng AI</h1>
                            <p class="text-muted mb-0">Hệ thống sẽ sử dụng Gemini AI để sinh danh sách câu hỏi dựa trên
                                yêu cầu của bạn, sau đó bạn có thể duyệt, chỉnh sửa và phân bổ vào bài giảng cụ thể.</p>
                        </div>

                        <div class="row g-4 justify-content-center">
                            <div class="col-lg-8 col-xl-7">
                                <div class="card shadow-sm border-0 ai-glow">
                                    <div class="card-body p-4 p-md-5">
                                        <form action="${pageContext.request.contextPath}/teacher/ai/generate"
                                            method="post" class="needs-validation" novalidate id="aiGenForm">

                                            <div class="mb-4 text-center">
                                                <div class="stat-icon purple mx-auto mb-3"
                                                    style="width:64px;height:64px;font-size:1.8rem"><i
                                                        class="bi bi-robot"></i></div>
                                                <h5>Cấu hình sinh câu hỏi</h5>
                                            </div>

                                            <div class="mb-3">
                                                <label class="form-label fw-semibold">Loại câu hỏi <span
                                                        class="text-danger">*</span></label>
                                                <div class="d-flex gap-4">
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" name="questionType"
                                                            id="qt1" value="MCQ" checked>
                                                        <label class="form-check-label" for="qt1">Trắc nghiệm
                                                            (MCQ)</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" name="questionType"
                                                            id="qt2" value="ESSAY">
                                                        <label class="form-check-label" for="qt2">Tự luận
                                                            (Essay)</label>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row g-3 mb-3">
                                                <div class="col-sm-6">
                                                    <label class="form-label fw-semibold" for="gTopicId">Chủ đề tạo
                                                        <span class="text-danger">*</span></label>
                                                    <select class="form-select" id="gTopicId" name="topicId" required>
                                                        <option value="">-- Chọn chủ đề --</option>
                                                        <c:forEach var="t" items="${topics}">
                                                            <option value="${t.topicId}">
                                                                <c:out value="${t.topicName}" />
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-sm-3">
                                                    <label class="form-label fw-semibold" for="gDiff">Độ khó</label>
                                                    <select class="form-select" id="gDiff" name="difficulty">
                                                        <option value="1">Dễ</option>
                                                        <option value="2" selected>Trung bình</option>
                                                        <option value="3">Khó</option>
                                                    </select>
                                                </div>
                                                <div class="col-sm-3">
                                                    <label class="form-label fw-semibold" for="gQty">Số lượng <span
                                                            class="text-danger">*</span></label>
                                                    <input type="number" class="form-control" id="gQty" name="quantity"
                                                        value="5" min="1" max="20" required>
                                                    <div class="invalid-feedback">1-20 câu.</div>
                                                </div>
                                            </div>

                                            <div class="mb-4 mt-4">
                                                <label class="form-label fw-semibold" for="gPrompt">Yêu cầu thêm (tùy
                                                    chọn)</label>
                                                <textarea class="form-control" id="gPrompt" name="prompt" rows="3"
                                                    placeholder="Đưa thêm ngữ cảnh, ví dụ: 'Tập trung tính diện tích hình chóp', 'Sử dụng ví dụ thực tế'"></textarea>
                                            </div>

                                            <div class="text-center mt-5">
                                                <button type="submit" class="btn btn-ai btn-lg w-100" id="btnGen">
                                                    <i class="bi bi-magic me-2"></i>Bắt đầu Generate
                                                </button>
                                                <div id="genLoading" style="display:none;" class="mt-3 text-muted">
                                                    <div class="spinner-border spinner-border-sm text-ai me-2"
                                                        role="status"></div>
                                                    AI đang xử lý, vui lòng chờ trong giây lát (có thể mất 10-30s)...
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </main>
                </div>
                <script>
                    document.getElementById('aiGenForm').addEventListener('submit', function (e) {
                        if (this.checkValidity()) {
                            document.getElementById('btnGen').disabled = true;
                            document.getElementById('genLoading').style.display = 'block';
                        }
                    });
                </script>
                <jsp:include page="../common/footer.jsp" />
            </body>

            </html>
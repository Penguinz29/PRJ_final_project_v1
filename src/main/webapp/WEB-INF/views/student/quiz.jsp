<%-- File: WEB-INF/views/student/quiz.jsp Servlet: StudentQuizServlet (/student/quiz) Attributes: lesson(Lesson),
    questions(List<QuizQuestionView>: mỗi câu có options, KHÔNG có đáp án đúng)
        POST /student/quizSubmit: array of question_X values
        --%>
        <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
            <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
                <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                    <jsp:include page="../common/head.jsp">
                        <jsp:param name="title" value="Bài Quiz" />
                    </jsp:include>

                    <body class="quiz-mode" data-ctx="${pageContext.request.contextPath}">

                        <nav class="navbar navbar-expand bg-white fixed-top shadow-sm border-bottom">
                            <div class="container-fluid px-4">
                                <a class="navbar-brand fw-bold text-primary" href="#">
                                    <i class="bi bi-joystick me-2"></i>Luyện tập Trắc nghiệm
                                </a>
                                <div class="ms-auto d-flex align-items-center gap-4">
                                    <div class="d-none d-md-block text-muted">Bài: <strong>
                                            <c:out value="${lesson.title}" />
                                        </strong></div>
                                    <button class="btn btn-danger btn-sm" id="btnSubmitQuiz" type="button">Nộp bài
                                        ngay</button>
                                    <a href="${pageContext.request.contextPath}/student/lesson?id=${lesson.lessonId}"
                                        class="btn btn-outline-secondary btn-sm" data-confirm="true"
                                        data-confirm-message="Thoát sẽ hủy bài làm hiện tại?">
                                        <i class="bi bi-x-lg"></i> Thoát
                                    </a>
                                </div>
                            </div>
                        </nav>

                        <div class="container-fluid"
                            style="padding-top: calc(var(--navbar-h) + 1rem); padding-bottom: 2rem;">
                            <ui:flash />

                            <div class="row g-4">
                                <%-- Khung câu hỏi (Carousel) --%>
                                    <div class="col-lg-8 col-xl-9">
                                        <form id="quizForm"
                                            action="${pageContext.request.contextPath}/student/quizSubmit"
                                            method="post">
<input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                            <input type="hidden" name="lessonId" value="${lesson.lessonId}">

                                            <c:choose>
                                                <c:when test="${empty questions}">
                                                    <div class="card border-0 shadow-sm text-center py-5">
                                                        <i class="bi bi-inbox display-3 text-muted mb-3 opacity-25"></i>
                                                        <h5 class="text-muted">Bài giảng này chưa có câu hỏi trắc
                                                            nghiệm.</h5>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div id="quizCarousel" class="carousel slide" data-bs-ride="false"
                                                        data-bs-touch="false">
                                                        <div class="carousel-inner">
                                                            <c:forEach var="q" items="${questions}" varStatus="vs">
                                                                <div class="carousel-item ${vs.first ? 'active' : ''}"
                                                                    data-qindex="${vs.count}">
                                                                    <div
                                                                        class="card shadow-sm border-0 question-card h-100">
                                                                        <div
                                                                            class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                                                            <h5 class="mb-0 text-primary fw-bold">Câu
                                                                                ${vs.count}</h5>
                                                                            <div>
                                                                                <c:if test="${q.aiGenerated}"><span
                                                                                        class="badge-ai me-2"><i
                                                                                            class="bi bi-stars"></i></span>
                                                                                </c:if>
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
                                                                            </div>
                                                                        </div>
                                                                        <div class="card-body p-md-4">
                                                                            <div
                                                                                class="question-text mb-4 latex-content fs-5">
                                                                                <c:out value="${q.content}" />
                                                                            </div>

                                                                            <div class="options-grid">
                                                                                <c:forEach var="opt"
                                                                                    items="${q.options}">
                                                                                    <label class="option-item w-100"
                                                                                        for="opt_${opt.optionId}">
                                                                                        <input type="radio"
                                                                                            class="d-none q-radio"
                                                                                            name="question_${q.questionId}"
                                                                                            id="opt_${opt.optionId}"
                                                                                            value="${opt.optionLetter}"
                                                                                            data-qindex="${vs.count}">
                                                                                        <div
                                                                                            class="d-flex align-items-center p-3 border rounded mb-3 option-box cursor-pointer">
                                                                                            <span
                                                                                                class="option-label">${opt.optionLetter}</span>
                                                                                            <div class="ms-3 latex-content"
                                                                                                style="flex:1">
                                                                                                <c:out
                                                                                                    value="${opt.content}" />
                                                                                            </div>
                                                                                        </div>
                                                                                    </label>
                                                                                </c:forEach>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </c:forEach>
                                                        </div>

                                                        <%-- Điều hướng --%>
                                                            <div class="d-flex justify-content-between mt-4">
                                                                <button class="btn btn-outline-primary" type="button"
                                                                    data-bs-target="#quizCarousel" data-bs-slide="prev">
                                                                    <i class="bi bi-chevron-left me-1"></i>Câu trước
                                                                </button>
                                                                <button class="btn btn-primary" type="button"
                                                                    data-bs-target="#quizCarousel" data-bs-slide="next">
                                                                    Câu sau<i class="bi bi-chevron-right ms-1"></i>
                                                                </button>
                                                            </div>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </form>
                                    </div>

                                    <%-- Bảng điều khiển (Nav panel) --%>
                                        <div class="col-lg-4 col-xl-3">
                                            <div class="card shadow-sm border-0"
                                                style="position:sticky;top:calc(var(--navbar-h) + 1rem);">
                                                <div class="card-header bg-white py-3">
                                                    <h5 class="mb-0 fw-bold"><i class="bi bi-grid me-2"></i>Bảng câu hỏi
                                                    </h5>
                                                </div>
                                                <div class="card-body">
                                                    <div class="quiz-progress-grid d-flex flex-wrap gap-2 mb-4">
                                                        <c:forEach var="q" items="${questions}" varStatus="vs">
                                                            <button type="button"
                                                                class="btn btn-outline-secondary quiz-nav-btn"
                                                                id="navBtn_${vs.count}"
                                                                onclick="document.activeElement.blur();
                                             bootstrap.Carousel.getOrCreateInstance(document.getElementById('quizCarousel')).to(${vs.index})">
                                                                ${vs.count}
                                                            </button>
                                                        </c:forEach>
                                                    </div>

                                                    <div
                                                        class="d-flex justify-content-between align-items-center border-top pt-3">
                                                        <span class="text-muted" style="font-size:.9rem;">Đã làm:
                                                            <strong id="doneCount"
                                                                class="text-primary">0</strong>/${fn:length(questions)}</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                            </div>
                        </div>

                        <jsp:include page="../common/confirm-modal.jsp" />
                        <jsp:include page="../common/footer.jsp" />

                        <style>
                            body.quiz-mode {
                                background-color: #f3f6f9;
                            }

                            .option-box {
                                transition: all 0.2s;
                                background: #fff;
                            }

                            .option-box:hover {
                                border-color: var(--primary) !important;
                                background: rgba(79, 70, 229, 0.03);
                            }

                            .q-radio:checked+.option-box {
                                border-color: var(--primary) !important;
                                background: rgba(79, 70, 229, 0.1);
                                box-shadow: inset 0 0 0 1px var(--primary);
                            }

                            .q-radio:checked+.option-box .option-label {
                                background: var(--primary);
                                color: #fff;
                                border-color: var(--primary);
                            }

                            .quiz-nav-btn {
                                width: 40px;
                                height: 40px;
                                padding: 0;
                                font-weight: 500;
                                border-radius: 8px;
                            }

                            .quiz-nav-btn.answered {
                                background-color: var(--primary);
                                color: white;
                                border-color: var(--primary);
                            }
                        </style>

                        <script>
                            // Logic cập nhật state Quiz
                            document.addEventListener('DOMContentLoaded', () => {
                                const radios = document.querySelectorAll('.q-radio');
                                const doneCount = document.getElementById('doneCount');
                                const btnSubmit = document.getElementById('btnSubmitQuiz');
                                const total = ${fn:length(questions)};

                            radios.forEach(r => {
                                r.addEventListener('change', (e) => {
                                    const idx = e.target.getAttribute('data-qindex');
                                    const navBtn = document.getElementById('navBtn_' + idx);
                                    if (navBtn) navBtn.classList.add('answered');

                                    // Đếm số lượng làm
                                    const answered = document.querySelectorAll('.q-radio:checked').length;
                                    doneCount.innerText = answered;
                                });
                            });

                            btnSubmit.addEventListener('click', () => {
                                const answered = document.querySelectorAll('.q-radio:checked').length;
                                let msg = 'Bạn chắc chắn muốn nộp bài?';
                                if (answered < total) {
                                    msg = 'Bạn còn ' + (total - answered) + ' câu chưa làm. Vẫn nộp bài?';
                                }
                                if (confirm(msg)) {
                                    document.getElementById('quizForm').submit();
                                }
                            });
    });
                        </script>
                    </body>

                    </html>
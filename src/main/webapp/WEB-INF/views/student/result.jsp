<%-- File: WEB-INF/views/student/result.jsp Servlet: StudentQuizSubmitServlet (forward to result.jsp) Attributes:
    result(AttemptResult - DTO holds details), lesson(Lesson), score(double) --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
                <jsp:include page="../common/head.jsp">
                    <jsp:param name="title" value="Kết quả bài làm" />
                </jsp:include>

                <body data-ctx="${pageContext.request.contextPath}">
                    <jsp:include page="../common/navbar.jsp" />
                    <div class="container py-5 mt-4">
                        <ui:flash />

                        <div class="row justify-content-center">
                            <div class="col-lg-10">
                                <%-- Thẻ điểm số tổng quan --%>
                                    <div class="card border-0 shadow-lg mb-5 overflow-hidden text-center text-white"
                                        style="background: linear-gradient(135deg, ${score >= 50 ? 'var(--success)' : 'var(--danger)'}, ${score >= 50 ? '#047857' : '#991b1b'});">
                                        <div class="card-body p-5">
                                            <h2 class="fw-bold mb-1">Kết quả Trắc nghiệm</h2>
                                            <p class="mb-4 opacity-75 fs-5">
                                                <c:out value="${lesson.title}" />
                                            </p>

                                            <div class="d-flex justify-content-center gap-4 mb-4">
                                                <div class="bg-white bg-opacity-25 rounded-4 p-4 text-center d-flex flex-column"
                                                    style="min-width:180px;">
                                                    <span class="fs-1 fw-bold">
                                                        <fmt:formatNumber value="${score}" maxFractionDigits="1" />%
                                                    </span>
                                                    <span class="opacity-75">Điểm số</span>
                                                </div>
                                                <div class="bg-white bg-opacity-25 rounded-4 p-4 text-center d-flex flex-column"
                                                    style="min-width:180px;">
                                                    <span
                                                        class="fs-1 fw-bold">${result.correctCount}/${result.totalQuestions}</span>
                                                    <span class="opacity-75">Số câu đúng</span>
                                                </div>
                                            </div>

                                            <div>
                                                <c:choose>
                                                    <c:when test="${score >= 80}">
                                                        <h4 class="mb-0"><i
                                                                class="bi bi-star-fill text-warning me-2"></i>Tuyệt vời!
                                                            Bạn nắm bài rất tốt.</h4>
                                                    </c:when>
                                                    <c:when test="${score >= 50}">
                                                        <h4 class="mb-0"><i
                                                                class="bi bi-hand-thumbs-up-fill text-white me-2"></i>Đạt
                                                            yêu cầu! Tiếp tục cố gắng nhé.</h4>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <h4 class="mb-0"><i
                                                                class="bi bi-emoji-frown-fill text-white me-2"></i>Chưa
                                                            đạt. Bạn cần ôn lại bài giảng.</h4>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Chi tiết từng câu --%>
                                        <h4 class="mb-3 fw-bold"><i class="bi bi-list-check me-2 text-primary"></i>Chi
                                            tiết đáp án</h4>

                                        <div class="accordion" id="answersAccordion">
                                            <c:forEach var="item" items="${result.items}" varStatus="vs">
                                                <div
                                                    class="accordion-item shadow-sm border-0 mb-3 rounded overflow-hidden">
                                                    <h2 class="accordion-header">
                                                        <button class="accordion-button collapsed px-4" type="button"
                                                            data-bs-toggle="collapse" data-bs-target="#ans_${vs.count}">
                                                            <div class="d-flex align-items-center w-100">
                                                                <div class="me-3 fs-5">
                                                                    <c:choose>
                                                                        <c:when test="${item.isCorrect}"><i
                                                                                class="bi bi-check-circle-fill text-success"></i>
                                                                        </c:when>
                                                                        <c:otherwise><i
                                                                                class="bi bi-x-circle-fill text-danger"></i>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                                <div class="fw-semibold">Câu ${vs.count}</div>
                                                                <div class="ms-auto me-3 d-flex gap-3 text-muted"
                                                                    style="font-size:.85rem;">
                                                                    <span>Bạn chọn: <strong
                                                                            class="${item.isCorrect ? 'text-success' : 'text-danger'}">${empty
                                                                            item.studentAnswer ? 'Bỏ trống' :
                                                                            item.studentAnswer}</strong></span>
                                                                    <span>Đáp án: <strong
                                                                            class="text-success">${item.correctAnswer}</strong></span>
                                                                </div>
                                                            </div>
                                                        </button>
                                                    </h2>
                                                    <div id="ans_${vs.count}" class="accordion-collapse collapse"
                                                        data-bs-parent="#answersAccordion">
                                                        <div class="accordion-body bg-light">
                                                            <div
                                                                class="mb-3 p-3 bg-white border rounded latex-content fs-5">
                                                                <c:out value="${item.question.content}" />
                                                            </div>
                                                            <div class="row g-2">
                                                                <c:forEach var="opt" items="${item.options}">
                                                                    <div class="col-md-6">
                                                                        <div
                                                                            class="p-2 px-3 border rounded h-100 d-flex align-items-center
                                                        ${opt.optionLetter == item.correctAnswer ? 'bg-success-subtle border-success' : 
                                                          (opt.optionLetter == item.studentAnswer and not item.isCorrect ? 'bg-danger-subtle border-danger' : 'bg-white')}">
                                                                            <span
                                                                                class="fw-bold me-2 ${opt.optionLetter == item.correctAnswer ? 'text-success' : (opt.optionLetter == item.studentAnswer and not item.isCorrect ? 'text-danger' : '')}">
                                                                                ${opt.optionLetter}.
                                                                            </span>
                                                                            <span class="latex-content" style="flex:1;">
                                                                                <c:out value="${opt.content}" />
                                                                            </span>
                                                                            <c:if
                                                                                test="${opt.optionLetter == item.correctAnswer}">
                                                                                <i
                                                                                    class="bi bi-check-lg text-success ms-2 fs-5"></i>
                                                                            </c:if>
                                                                            <c:if
                                                                                test="${opt.optionLetter == item.studentAnswer and not item.isCorrect}">
                                                                                <i
                                                                                    class="bi bi-x-lg text-danger ms-2 fs-5"></i>
                                                                            </c:if>
                                                                        </div>
                                                                    </div>
                                                                </c:forEach>
                                                            </div>
                                                            <%-- FR-STU-02: giải thích chi tiết khi chọn sai hoặc bỏ trống --%>
                                                            <c:if test="${not item.isCorrect and not empty item.question.explanation}">
                                                                <div class="mt-3 p-3 bg-white border border-warning rounded">
                                                                    <div class="fw-semibold mb-1"><i class="bi bi-lightbulb text-warning me-1"></i>Lời giải chi tiết</div>
                                                                    <div class="latex-content" style="white-space:pre-line;">
                                                                        <c:out value="${item.question.explanation}" />
                                                                    </div>
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>

                                        <div class="text-center mt-5">
                                            <a href="${pageContext.request.contextPath}/student/topics"
                                                class="btn btn-primary px-4 py-2 me-2">
                                                <i class="bi bi-book me-2"></i>Học bài khác
                                            </a>
                                            <a href="${pageContext.request.contextPath}/student/history"
                                                class="btn btn-outline-secondary px-4 py-2">
                                                Lịch sử làm bài
                                            </a>
                                        </div>

                            </div>
                        </div>
                    </div>
                    <jsp:include page="../common/footer.jsp" />
                    <script>
                        // Trigger MathJax/KaTeX re-render when accordion opens (if needed by dynamic display)
                        const accordionEls = document.querySelectorAll('.accordion-collapse');
                        accordionEls.forEach(el => {
                            el.addEventListener('shown.bs.collapse', () => {
                                if (window.renderMathInElement) {
                                    renderMathInElement(el, {
                                        delimiters: [
                                            { left: "$$", right: "$$", display: true },
                                            { left: "$", right: "$", display: false }
                                        ]
                                    });
                                }
                            });
                        });
                    </script>
                </body>

                </html>
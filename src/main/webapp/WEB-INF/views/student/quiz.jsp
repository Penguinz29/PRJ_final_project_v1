<%-- File: WEB-INF/views/student/quiz.jsp
     Controller: StudentQuizController (GET /student/quiz?lessonId=&difficulty=&limit=)
     Attributes: lesson (LessonView), questions (List<QuizQuestionView>: mỗi câu có options, KHÔNG có đáp án đúng / lời giải),
                 level (0 = mọi mức độ), limit (5–30)
     UC-STU-04: mỗi câu được chấm NGAY qua POST /api/student/submit-quiz-answer {questionId, selectedOptionId};
     đáp án đúng và lời giải chỉ được gửi về SAU khi nộp câu đó (BR-11). --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Luyện trắc nghiệm" />
</jsp:include>

<body class="quiz-mode" data-ctx="${pageContext.request.contextPath}">

<nav class="navbar navbar-expand bg-white fixed-top shadow-sm border-bottom">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold text-primary" href="#"><i class="bi bi-joystick me-2"></i>Luyện tập Trắc nghiệm</a>
        <div class="ms-auto d-flex align-items-center gap-3">
            <div class="d-none d-md-block text-muted">Bài: <strong><c:out value="${lesson.title}" /></strong></div>
            <a href="${pageContext.request.contextPath}/student/lesson?id=${lesson.lessonId}" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-x-lg"></i> Thoát
            </a>
        </div>
    </div>
</nav>

<div class="container-fluid" style="padding-top: calc(var(--navbar-h) + 1rem); padding-bottom: 2rem;">
    <ui:flash />

    <%-- UC-STU-03: lọc mức độ, số câu; mỗi lần "Đề mới" chọn ngẫu nhiên lại --%>
    <form class="card card-body mb-3 py-2" method="get" action="${pageContext.request.contextPath}/student/quiz">
        <input type="hidden" name="lessonId" value="${lesson.lessonId}">
        <div class="row g-2 align-items-end">
            <div class="col-6 col-md-3">
                <label for="difficulty" class="form-label small mb-1">Mức độ</label>
                <select id="difficulty" name="difficulty" class="form-select form-select-sm">
                    <option value="" ${level == 0 ? 'selected' : ''}>Tất cả</option>
                    <option value="1" ${level == 1 ? 'selected' : ''}>Dễ</option>
                    <option value="2" ${level == 2 ? 'selected' : ''}>Trung bình</option>
                    <option value="3" ${level == 3 ? 'selected' : ''}>Khó</option>
                </select>
            </div>
            <div class="col-6 col-md-3">
                <label for="limit" class="form-label small mb-1">Số câu</label>
                <select id="limit" name="limit" class="form-select form-select-sm">
                    <c:forEach var="n" items="5,10,15,20,30">
                        <option value="${n}" ${n == limit ? 'selected' : ''}>${n}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-12 col-md-3">
                <button type="submit" class="btn btn-primary btn-sm w-100"><i class="bi bi-shuffle me-1"></i>Đề mới</button>
            </div>
            <div class="col-12 col-md-3 small text-muted">Câu hỏi được chọn ngẫu nhiên; mỗi câu chấm ngay khi bạn chọn đáp án.</div>
        </div>
    </form>

    <div class="row g-4">
        <div class="col-lg-8 col-xl-9">
            <c:choose>
                <c:when test="${empty questions}">
                    <div class="card border-0 shadow-sm text-center py-5">
                        <i class="bi bi-inbox display-3 text-muted mb-3 opacity-25"></i>
                        <h5 class="text-muted">Bài này chưa có câu hỏi trắc nghiệm${level > 0 ? ' ở mức độ đã chọn' : ''}.</h5>
                    </div>
                </c:when>
                <c:otherwise>
                    <div id="quizCarousel" class="carousel slide" data-bs-ride="false" data-bs-touch="false" data-bs-keyboard="false">
                        <div class="carousel-inner">
                            <c:forEach var="q" items="${questions}" varStatus="vs">
                                <div class="carousel-item ${vs.first ? 'active' : ''}">
                                    <div class="card shadow-sm border-0 question-card h-100" data-qid="${q.questionId}" data-qindex="${vs.count}">
                                        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                            <h5 class="mb-0 text-primary fw-bold">Câu ${vs.count}/${fn:length(questions)}</h5>
                                            <div>
                                                <c:if test="${q.aiGenerated}"><span class="badge-ai me-2"><i class="bi bi-stars"></i></span></c:if>
                                                <c:choose>
                                                    <c:when test="${q.level == 1}"><span class="badge-level-1">Dễ</span></c:when>
                                                    <c:when test="${q.level == 2}"><span class="badge-level-2">TB</span></c:when>
                                                    <c:when test="${q.level == 3}"><span class="badge-level-3">Khó</span></c:when>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div class="card-body p-md-4">
                                            <div class="question-text mb-4 latex-content fs-5"><ui:rich-text value="${q.content}" /></div>
                                            <div class="options-grid">
                                                <c:forEach var="opt" items="${q.options}">
                                                    <button type="button" class="option-box w-100 d-flex align-items-center p-3 border rounded mb-3 text-start"
                                                            data-option-id="${opt.optionId}">
                                                        <span class="option-label">${opt.optionLetter}</span>
                                                        <span class="ms-3 latex-content" style="flex:1"><ui:rich-text value="${opt.content}" /></span>
                                                        <i class="bi option-mark ms-2 fs-5"></i>
                                                    </button>
                                                </c:forEach>
                                            </div>
                                            <%-- Phản hồi tức thì (điền bằng textContent sau khi chấm) --%>
                                            <div class="feedback d-none mt-2 p-3 rounded border" role="status" aria-live="polite">
                                                <div class="fw-bold feedback-title mb-1"></div>
                                                <div class="feedback-explanation latex-content small" style="white-space:pre-line;"></div>
                                                <div class="d-flex flex-wrap gap-2 mt-3">
                                                    <a class="btn btn-ai btn-sm d-none btn-ask-tutor"
                                                       href="${pageContext.request.contextPath}/student/ai-tutor?mode=QUESTION&questionId=${q.questionId}">
                                                        <i class="bi bi-robot me-1"></i>Hỏi gia sư AI
                                                    </a>
                                                    <c:if test="${not vs.last}">
                                                        <button type="button" class="btn btn-primary btn-sm btn-next">Câu tiếp <i class="bi bi-chevron-right"></i></button>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="d-flex justify-content-between mt-4">
                            <button class="btn btn-outline-primary" type="button" data-bs-target="#quizCarousel" data-bs-slide="prev">
                                <i class="bi bi-chevron-left me-1"></i>Câu trước
                            </button>
                            <button class="btn btn-outline-primary" type="button" data-bs-target="#quizCarousel" data-bs-slide="next">
                                Câu sau<i class="bi bi-chevron-right ms-1"></i>
                            </button>
                        </div>
                    </div>

                    <%-- Tổng kết khi đã làm hết đề --%>
                    <div id="quizSummary" class="card border-0 shadow-sm mt-4 d-none">
                        <div class="card-body text-center py-4">
                            <h4 class="fw-bold mb-1">Hoàn thành đề!</h4>
                            <p class="fs-5 mb-3">Đúng <strong id="summaryCorrect">0</strong>/${fn:length(questions)} câu</p>
                            <div class="d-flex flex-wrap justify-content-center gap-2">
                                <a class="btn btn-primary" href="${pageContext.request.contextPath}/student/quiz?lessonId=${lesson.lessonId}&difficulty=${level == 0 ? '' : level}&limit=${limit}">
                                    <i class="bi bi-shuffle me-1"></i>Làm đề mới</a>
                                <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/student/history?type=MCQ&lessonId=${lesson.lessonId}">
                                    <i class="bi bi-clock-history me-1"></i>Lịch sử bài này</a>
                                <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/student/lesson?id=${lesson.lessonId}">
                                    <i class="bi bi-book me-1"></i>Về bài học</a>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- Bảng câu hỏi --%>
        <div class="col-lg-4 col-xl-3">
            <div class="card shadow-sm border-0" style="position:sticky;top:calc(var(--navbar-h) + 1rem);">
                <div class="card-header bg-white py-3"><h5 class="mb-0 fw-bold"><i class="bi bi-grid me-2"></i>Bảng câu hỏi</h5></div>
                <div class="card-body">
                    <div class="d-flex flex-wrap gap-2 mb-3">
                        <c:forEach var="q" items="${questions}" varStatus="vs">
                            <button type="button" class="btn btn-outline-secondary quiz-nav-btn" id="navBtn_${vs.count}"
                                    data-slide-to="${vs.index}" aria-label="Câu ${vs.count}">${vs.count}</button>
                        </c:forEach>
                    </div>
                    <div class="border-top pt-3 small text-muted">
                        Đã làm: <strong id="doneCount" class="text-primary">0</strong>/${fn:length(questions)}
                        · Đúng: <strong id="correctCount" class="text-success">0</strong>
                    </div>
                    <div class="small text-muted mt-2">
                        <span class="badge bg-success">&nbsp;</span> đúng
                        <span class="badge bg-danger ms-2">&nbsp;</span> sai
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />

<style>
    body.quiz-mode { background-color: #f3f6f9; }
    .option-box { transition: all 0.2s; background: #fff; }
    .option-box:not(:disabled):hover { border-color: var(--primary) !important; background: rgba(79, 70, 229, 0.03); }
    .option-box:disabled { opacity: 1; cursor: default; }
    .option-box.is-correct { border-color: var(--success, #16a34a) !important; background: #f0fdf4; }
    .option-box.is-correct .option-mark { color: var(--success, #16a34a); }
    .option-box.is-wrong { border-color: var(--danger, #dc2626) !important; background: #fef2f2; }
    .option-box.is-wrong .option-mark { color: var(--danger, #dc2626); }
    .feedback.ok { background: #f0fdf4; border-color: #86efac !important; }
    .feedback.ko { background: #fef2f2; border-color: #fca5a5 !important; }
    .quiz-nav-btn { width: 40px; height: 40px; padding: 0; font-weight: 500; border-radius: 8px; }
    .quiz-nav-btn.answered-ok { background-color: var(--success, #16a34a); border-color: var(--success, #16a34a); color: #fff; }
    .quiz-nav-btn.answered-ko { background-color: var(--danger, #dc2626); border-color: var(--danger, #dc2626); color: #fff; }
</style>

<script>
document.addEventListener('DOMContentLoaded', () => {
    const ctx = document.body.dataset.ctx;
    const carouselEl = document.getElementById('quizCarousel');
    if (!carouselEl) return;
    const carousel = bootstrap.Carousel.getOrCreateInstance(carouselEl);
    const cards = Array.from(document.querySelectorAll('.question-card'));
    const total = cards.length;
    let done = 0;
    let correct = 0;

    function renderMath(el) {
        if (window.renderMathInElement) {
            renderMathInElement(el, { delimiters: [{ left: '$$', right: '$$', display: true }, { left: '$', right: '$', display: false }], throwOnError: false });
        }
    }

    // Lời giải lưu dạng HTML từ trình soạn thảo: chuyển sang văn bản thuần (DOMParser không chạy script),
    // giữ xuống dòng giữa các đoạn, rồi vẫn chèn bằng textContent để an toàn XSS.
    function htmlToText(html) {
        if (!html) return '';
        const withBreaks = String(html)
            .replace(/<br\s*\/?>/gi, '\n')
            .replace(/<\/(p|div|li|h[1-6])\s*>/gi, '\n');
        const doc = new DOMParser().parseFromString(withBreaks, 'text/html');
        return (doc.body.textContent || '').replace(/\n{3,}/g, '\n\n').trim();
    }

    document.querySelectorAll('.quiz-nav-btn').forEach(btn => {
        btn.addEventListener('click', () => carousel.to(parseInt(btn.dataset.slideTo, 10)));
    });
    document.querySelectorAll('.btn-next').forEach(btn => btn.addEventListener('click', () => carousel.next()));

    cards.forEach(card => {
        const qid = parseInt(card.dataset.qid, 10);
        const options = Array.from(card.querySelectorAll('.option-box'));
        const feedback = card.querySelector('.feedback');
        options.forEach(opt => opt.addEventListener('click', async () => {
            if (card.dataset.answered) return;
            card.dataset.answered = 'pending';
            options.forEach(o => o.disabled = true);   // khóa câu: không gửi trùng
            try {
                const res = await csrfFetch(ctx + '/api/student/submit-quiz-answer', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                    body: JSON.stringify({ questionId: qid, selectedOptionId: parseInt(opt.dataset.optionId, 10) })
                });
                const body = await res.json().catch(() => ({}));
                if (!res.ok || !body.success) throw new Error(body.message || 'Không chấm được câu này.');
                const d = body.data;
                card.dataset.answered = 'yes';
                options.forEach(o => {
                    if (parseInt(o.dataset.optionId, 10) === d.correctOptionId) {
                        o.classList.add('is-correct');
                        o.querySelector('.option-mark').classList.add('bi-check-lg');
                    }
                });
                if (!d.isCorrect) {
                    opt.classList.add('is-wrong');
                    opt.querySelector('.option-mark').classList.add('bi-x-lg');
                }

                // Phản hồi: chèn bằng textContent (an toàn XSS) rồi render KaTeX
                feedback.classList.remove('d-none');
                feedback.classList.add(d.isCorrect ? 'ok' : 'ko');
                feedback.querySelector('.feedback-title').textContent = d.isCorrect
                    ? 'Chính xác! +10 điểm'
                    : 'Chưa đúng. Đáp án đúng là ' + (d.correctOptionLabel || '') + '.';
                const explanation = htmlToText(d.explanationLatex);
                feedback.querySelector('.feedback-explanation').textContent = explanation
                    ? 'Lời giải: ' + explanation : '';
                card.querySelector('.btn-ask-tutor').classList.toggle('d-none', !d.canAskTutor);
                renderMath(feedback);

                done++;
                if (d.isCorrect) correct++;
                const nav = document.getElementById('navBtn_' + card.dataset.qindex);
                if (nav) nav.classList.add(d.isCorrect ? 'answered-ok' : 'answered-ko');
                document.getElementById('doneCount').textContent = done;
                document.getElementById('correctCount').textContent = correct;
                if (done === total) {
                    document.getElementById('summaryCorrect').textContent = correct;
                    document.getElementById('quizSummary').classList.remove('d-none');
                }
            } catch (e) {
                delete card.dataset.answered;
                options.forEach(o => o.disabled = false);   // cho chọn lại khi lỗi mạng / máy chủ
                const msg = e.message || 'Có lỗi xảy ra, vui lòng thử lại.';
                if (typeof showToast === 'function') showToast(msg, 'danger'); else alert(msg);
            }
        }));
    });
});
</script>
</body>
</html>

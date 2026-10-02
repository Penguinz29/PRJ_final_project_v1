<%-- File: WEB-INF/views/student/ai-tutor.jsp
    Controller: StudentTutorController (GET /student/ai-tutor[?sessionId=&lessonId=])
    Attributes: topics(List<Topic> kèm lessons), sessions(List<TutorSession>), lessonId(Integer),
                tutorSession(TutorSession), messages(List<TutorMessage>), currentStep(int)
    API: POST /api/tutor/next-step {sessionId, lessonId, studentInput, currentStep} --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="../common/head.jsp">
    <jsp:param name="title" value="Gia sư AI" />
</jsp:include>

<body data-ctx="${pageContext.request.contextPath}">
    <jsp:include page="../common/navbar.jsp" />
    <div class="app-shell">
        <jsp:include page="../common/sidebar.jsp">
            <jsp:param name="active" value="student-ai" />
        </jsp:include>
        <main class="app-main">
            <ui:flash />

            <div class="page-header py-2 d-flex flex-wrap justify-content-between align-items-center gap-2">
                <div>
                    <h2 class="mb-0 fs-3"><i class="bi bi-robot me-2 text-ai"></i>Gia sư Toán AI</h2>
                    <p class="text-muted mb-0" style="font-size:0.9rem;">
                        Nêu bài toán, AI sẽ dẫn dắt bạn giải từng bước (3-6 bước) bằng câu hỏi gợi mở.</p>
                </div>
                <a href="${pageContext.request.contextPath}/student/ai-tutor" class="btn btn-outline-primary btn-sm">
                    <i class="bi bi-plus-lg me-1"></i>Bài toán mới
                </a>
            </div>

            <div class="row g-3">
                <%-- Danh sách phiên gần đây --%>
                <div class="col-lg-3 order-lg-2">
                    <div class="card">
                        <div class="card-header"><i class="bi bi-clock-history me-2"></i>Phiên gần đây</div>
                        <div class="list-group list-group-flush" style="max-height:60vh;overflow-y:auto;">
                            <c:forEach var="s" items="${sessions}">
                                <a class="list-group-item list-group-item-action ${s.sessionId == tutorSession.sessionId ? 'active' : ''}"
                                    href="${pageContext.request.contextPath}/student/ai-tutor?sessionId=${s.sessionId}">
                                    <div class="small fw-semibold text-truncate"><c:out value="${s.title}" /></div>
                                    <div class="d-flex justify-content-between small opacity-75">
                                        <span>
                                            <c:choose>
                                                <c:when test="${s.status == 'COMPLETED'}">Hoàn thành</c:when>
                                                <c:when test="${s.status == 'ABANDONED'}">Bỏ dở</c:when>
                                                <c:otherwise>Đang học</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <fmt:formatDate value="${s.createdAt}" pattern="dd/MM HH:mm" />
                                    </div>
                                </a>
                            </c:forEach>
                            <c:if test="${empty sessions}">
                                <div class="list-group-item text-muted small">Chưa có phiên nào.</div>
                            </c:if>
                        </div>
                    </div>
                </div>

                <div class="col-lg-9 order-lg-1">
                    <div class="card border-0 shadow-sm overflow-hidden">
                        <%-- Chọn bài học (chỉ khi bắt đầu phiên mới) + tiến độ --%>
                        <div class="card-header bg-white d-flex flex-wrap align-items-center gap-3">
                            <c:choose>
                                <c:when test="${empty tutorSession}">
                                    <label class="mb-0 fw-semibold" for="lessonSelect">Bài học:</label>
                                    <select class="form-select form-select-sm w-auto" id="lessonSelect">
                                        <option value="">-- Không chọn --</option>
                                        <c:forEach var="t" items="${topics}">
                                            <optgroup label="${fn:escapeXml(t.topicName)}">
                                                <c:forEach var="l" items="${t.lessons}">
                                                    <option value="${l.lessonId}" ${lessonId == l.lessonId ? 'selected' : ''}>
                                                        <c:out value="${l.title}" />
                                                    </option>
                                                </c:forEach>
                                            </optgroup>
                                        </c:forEach>
                                    </select>
                                </c:when>
                                <c:otherwise>
                                    <span class="fw-semibold"><i class="bi bi-journal-text me-1"></i>
                                        <c:out value="${empty tutorSession.lessonTitle ? 'Bài toán tự do' : tutorSession.lessonTitle}" />
                                    </span>
                                </c:otherwise>
                            </c:choose>
                            <div class="ms-auto d-flex align-items-center gap-2" style="min-width:180px;">
                                <span class="small text-muted" id="stepLabel">Chưa bắt đầu</span>
                                <div class="progress flex-grow-1" style="height:8px;">
                                    <div class="progress-bar bg-success" id="stepBar" style="width:0%"></div>
                                </div>
                            </div>
                        </div>

                        <div class="chat-box p-3" id="chatContainer"
                            style="height:52vh;min-height:320px;overflow-y:auto;background-color:#f8f9fa;">
                            <div class="chat-message bot">
                                <div class="avatar"><i class="bi bi-robot"></i></div>
                                <div class="content shadow-sm">
                                    Chào <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />! Hãy gõ bài toán bạn cần
                                    giải (có thể dùng LaTeX, ví dụ <code>$\int_0^1 x^2\,dx$</code>). Mình sẽ không đưa đáp
                                    án ngay mà dẫn bạn đi từng bước nhé.
                                </div>
                            </div>
                            <c:forEach var="m" items="${messages}">
                                <div class="chat-message ${m.senderType == 'USER' ? 'user' : 'bot'}">
                                    <c:if test="${m.senderType == 'AI'}">
                                        <div class="avatar"><i class="bi bi-robot"></i></div>
                                    </c:if>
                                    <div class="content shadow-sm latex-content" style="white-space:pre-wrap;"><c:out value="${m.contentText}" /></div>
                                </div>
                            </c:forEach>
                            <div class="chat-loading" id="chatLoading" style="display:none;">
                                <div class="typing-indicator"><span></span><span></span><span></span></div>
                            </div>
                        </div>

                        <div class="chat-input-area p-3 bg-white border-top">
                            <div id="tutorError" class="alert alert-danger py-2 d-none" role="alert"></div>
                            <form id="chatForm">
                                <div class="input-group">
                                    <textarea class="form-control" id="chatInput" rows="2" maxlength="4000"
                                        placeholder="Nhập bài toán của bạn (Enter để gửi, Shift+Enter xuống dòng)..."></textarea>
                                    <button class="btn btn-ai px-4 d-flex align-items-center" type="submit" id="btnSendChat">
                                        <i class="bi bi-send-fill fs-5"></i>
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
    <jsp:include page="../common/footer.jsp" />
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const ctx = document.body.dataset.ctx;
            const chatForm = document.getElementById('chatForm');
            const chatInput = document.getElementById('chatInput');
            const chatContainer = document.getElementById('chatContainer');
            const chatLoading = document.getElementById('chatLoading');
            const errorBox = document.getElementById('tutorError');
            const lessonSelect = document.getElementById('lessonSelect');
            const btnSend = document.getElementById('btnSendChat');
            const stepLabel = document.getElementById('stepLabel');
            const stepBar = document.getElementById('stepBar');

            const state = {
                sessionId: ${empty tutorSession ? 'null' : tutorSession.sessionId},
                currentStep: ${empty currentStep ? 0 : currentStep},
                totalSteps: 0,
                completed: ${not empty tutorSession and tutorSession.status != 'ACTIVE' ? 'true' : 'false'}
            };
            const MATH = {
                delimiters: [
                    { left: '$$', right: '$$', display: true },
                    { left: '$', right: '$', display: false },
                    { left: '\\[', right: '\\]', display: true },
                    { left: '\\(', right: '\\)', display: false }
                ],
                throwOnError: false
            };

            function scrollToBottom() { chatContainer.scrollTop = chatContainer.scrollHeight; }
            function renderMath(el) { if (window.renderMathInElement) renderMathInElement(el, MATH); }

            // Chèn văn bản an toàn (textContent), chỉ hỗ trợ **in đậm** đơn giản
            function setRichText(el, text) {
                el.textContent = '';
                String(text || '').split(/(\*\*[^*]+\*\*)/g).forEach(part => {
                    if (/^\*\*[^*]+\*\*$/.test(part)) {
                        const b = document.createElement('strong');
                        b.textContent = part.slice(2, -2);
                        el.appendChild(b);
                    } else if (part) {
                        el.appendChild(document.createTextNode(part));
                    }
                });
            }

            function addMessage(kind, text, extraClass) {
                const wrap = document.createElement('div');
                wrap.className = 'chat-message ' + kind;
                if (kind === 'bot') {
                    wrap.innerHTML = '<div class="avatar"><i class="bi bi-robot"></i></div>';
                }
                const content = document.createElement('div');
                content.className = 'content shadow-sm latex-content ' + (extraClass || '');
                content.style.whiteSpace = 'pre-wrap';
                setRichText(content, text);
                wrap.appendChild(content);
                chatContainer.insertBefore(wrap, chatLoading);
                renderMath(wrap);
                scrollToBottom();
            }

            function updateProgress() {
                if (state.completed) {
                    stepLabel.textContent = 'Hoàn thành';
                    stepBar.style.width = '100%';
                } else if (state.currentStep > 0) {
                    stepLabel.textContent = state.totalSteps > 0
                        ? 'Bước ' + state.currentStep + ' / ' + state.totalSteps : 'Bước ' + state.currentStep;
                    stepBar.style.width = state.totalSteps > 0
                        ? Math.round((state.currentStep - 1) / state.totalSteps * 100) + '%' : '10%';
                }
                if (state.sessionId !== null) {
                    chatInput.placeholder = state.completed
                        ? 'Phiên đã hoàn thành. Bấm "Bài toán mới" để tiếp tục.'
                        : 'Nhập câu trả lời cho bước ' + state.currentStep + '...';
                }
                chatInput.disabled = state.completed;
                btnSend.disabled = state.completed;
            }

            function showError(msg) {
                errorBox.textContent = msg;
                errorBox.classList.remove('d-none');
            }

            // Render công thức cho lịch sử đã có sẵn
            renderMath(chatContainer);
            updateProgress();
            scrollToBottom();

            chatInput.addEventListener('keydown', e => {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    chatForm.requestSubmit();
                }
            });

            chatForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                const text = chatInput.value.trim();
                if (!text || state.completed) return;

                errorBox.classList.add('d-none');
                chatInput.value = '';
                addMessage('user', text);
                chatLoading.style.display = 'flex';
                scrollToBottom();
                chatInput.disabled = true;
                btnSend.disabled = true;

                const payload = {
                    sessionId: state.sessionId,
                    lessonId: (state.sessionId === null && lessonSelect && lessonSelect.value)
                        ? parseInt(lessonSelect.value, 10) : null,
                    studentInput: text,
                    currentStep: state.currentStep
                };

                try {
                    const res = await csrfFetch(ctx + '/api/tutor/next-step', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                        body: JSON.stringify(payload)
                    });
                    const data = await res.json().catch(() => ({ message: 'Phản hồi không hợp lệ (HTTP ' + res.status + ').' }));
                    chatLoading.style.display = 'none';
                    if (!res.ok) {
                        showError(data.message || 'Có lỗi xảy ra, vui lòng thử lại.');
                        chatInput.value = text; // cho phép gửi lại
                    } else {
                        const d = data.data;
                        const firstTurn = state.sessionId === null;
                        state.sessionId = d.sessionId;
                        state.currentStep = d.currentStep;
                        state.totalSteps = d.totalSteps;
                        state.completed = d.isSessionCompleted;
                        if (lessonSelect) lessonSelect.disabled = true;

                        const parts = [];
                        if (d.feedbackToStudent) parts.push(d.feedbackToStudent);
                        if (d.nextPromptOrQuestion) parts.push(d.nextPromptOrQuestion);
                        const cls = (!firstTurn && !d.isStepCorrect) ? 'border border-warning' : '';
                        addMessage('bot', parts.join('\n\n'), cls);
                        if (d.isSessionCompleted) {
                            addMessage('bot', 'Chúc mừng bạn đã hoàn thành bài toán! Bấm "Bài toán mới" để luyện tiếp.');
                        }
                    }
                } catch (err) {
                    chatLoading.style.display = 'none';
                    showError('Mất kết nối mạng hoặc lỗi hệ thống. Vui lòng thử lại.');
                    chatInput.value = text;
                } finally {
                    updateProgress();
                    if (!state.completed) {
                        chatInput.disabled = false;
                        btnSend.disabled = false;
                        chatInput.focus();
                    }
                }
            });
        });
    </script>
</body>

</html>

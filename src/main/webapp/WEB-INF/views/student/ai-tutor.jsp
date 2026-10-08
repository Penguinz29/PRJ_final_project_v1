<%-- File: WEB-INF/views/student/ai-tutor.jsp
    Controller: StudentTutorController (GET /student/ai-tutor[?sessionId=|lessonId=|mode=QUESTION&questionId=|mode=SUBMISSION&submissionId=])
    Attributes: topics, sessions(List<TutorSessionView>), lessonId, tutorSession(TutorSessionView),
                messages(List<TutorMessageView>), startMode/startQuestionId/startSubmissionId (mở phiên tự động)
    API: POST /api/tutor/start {mode, problemText, lessonId, questionId, submissionId}
         POST /api/tutor/next-step {sessionId, studentInput}   POST /api/tutor/{id}/abandon --%>
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
            <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/ai-tutor.css?v=1.0">

            <div class="tutor-page">

                <header class="tt-header">
                    <div class="tt-title">
                        <span class="tt-title-icon"><i class="bi bi-robot"></i></span>
                        <div>
                            <h1>Gia sư Toán AI</h1>
                            <p>Nêu bài toán, AI sẽ dẫn dắt bạn giải từng bước bằng câu hỏi gợi mở.</p>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/student/ai-tutor" class="btn btn-outline-primary btn-sm">
                        <i class="bi bi-plus-lg me-1"></i>Bài toán mới
                    </a>
                </header>

                <div class="tt-grid">

                    <section class="tt-chat">
                        <%-- Chọn bài học (chỉ khi bắt đầu phiên mới) + tiến độ --%>
                        <div class="tt-chat-head">
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
                            <span class="tt-badge tt-badge--abandoned ms-auto" id="stepLabel">Chưa bắt đầu</span>
                            <div class="tt-progress">
                                <div id="stepBar" style="width:0%"></div>
                            </div>
                            <c:if test="${not empty tutorSession and tutorSession.status == 'ACTIVE'}">
                                <button type="button" class="btn btn-outline-secondary btn-sm" id="btnAbandon"
                                    title="Kết thúc phiên này">
                                    <i class="bi bi-stop-circle me-1"></i>Kết thúc
                                </button>
                            </c:if>
                        </div>

                        <%-- Vùng tin nhắn: duy nhất phần này cuộn. Markup bong bóng PHẢI trùng với addMessage() bên dưới --%>
                        <div class="chat-box" id="chatContainer">
                            <div class="chat-message bot">
                                <div class="avatar"><i class="bi bi-robot"></i></div>
                                <div class="bubble">
                                    <div class="bubble-text latex-content">Chào <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />! Hãy gõ bài toán bạn cần giải (có thể dùng LaTeX, ví dụ $\int_0^1 x^2\,dx$). Mình sẽ không đưa đáp án ngay mà dẫn bạn đi từng bước nhé.</div>
                                    <button type="button" class="bubble-copy" title="Sao chép" aria-label="Sao chép"><i class="bi bi-clipboard"></i></button>
                                </div>
                            </div>
                            <c:forEach var="m" items="${messages}">
                                <div class="chat-message ${m.senderType == 'USER' ? 'user' : 'bot'}">
                                    <c:if test="${m.senderType == 'AI'}">
                                        <div class="avatar"><i class="bi bi-robot"></i></div>
                                    </c:if>
                                    <div class="bubble">
                                        <div class="bubble-text latex-content"><c:out value="${m.contentText}" /></div>
                                        <c:if test="${m.senderType == 'AI'}">
                                            <button type="button" class="bubble-copy" title="Sao chép" aria-label="Sao chép"><i class="bi bi-clipboard"></i></button>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                            <div class="chat-message bot chat-loading" id="chatLoading" style="display:none;">
                                <div class="avatar"><i class="bi bi-robot"></i></div>
                                <div class="bubble">
                                    <span class="typing-indicator"><span></span><span></span><span></span></span>
                                    <span class="small text-muted ms-2">Gia sư AI đang suy nghĩ...</span>
                                </div>
                            </div>
                        </div>

                        <div class="tt-composer-wrap">
                            <div id="tutorError" class="visually-hidden" role="alert"></div>
                            <%-- BR-15: AI đang dừng chờ học sinh nhập số liệu (trạng thái lưu ở CSDL nên mở lại phiên vẫn đúng) --%>
                            <div id="inputHintBox" class="alert alert-warning py-2 mb-2 d-flex align-items-start gap-2 ${tutorSession.awaitingInput ? '' : 'd-none'}" role="status">
                                <i class="bi bi-pencil-square fs-5"></i>
                                <div><strong>Gia sư cần bạn cung cấp dữ liệu:</strong>
                                    <span id="inputHintText" class="latex-content"><c:out value="${tutorSession.inputHint}" /></span></div>
                            </div>

                            <div class="tt-math-bar" role="toolbar" aria-label="Ký hiệu toán">
                                <button type="button" class="tt-math-btn" data-tex="x^{2}" data-back="0" title="Bình phương">x²</button>
                                <button type="button" class="tt-math-btn" data-tex="\sqrt{}" data-back="2" title="Căn bậc hai">√</button>
                                <button type="button" class="tt-math-btn" data-tex="\frac{}{}" data-back="4" title="Phân số">a⁄b</button>
                                <button type="button" class="tt-math-btn" data-tex="\int_{}^{}" data-back="5" title="Tích phân">∫</button>
                                <button type="button" class="tt-math-btn" data-tex="\pi" data-back="0" title="Pi">π</button>
                                <button type="button" class="tt-math-btn" data-tex="\leq" data-back="0" title="Nhỏ hơn hoặc bằng">≤</button>
                                <button type="button" class="tt-math-btn" data-tex="\geq" data-back="0" title="Lớn hơn hoặc bằng">≥</button>
                            </div>
                            <div id="mathPreview" class="tt-preview latex-content" hidden></div>

                            <form id="chatForm">
                                <div class="tt-composer" id="composerBox">
                                    <textarea id="chatInput" rows="1" maxlength="2000"
                                        placeholder="${empty tutorSession ? 'Nhập bài toán của bạn...' : 'Nhập bước làm của bạn...'}"></textarea>
                                    <button class="tt-send" type="submit" id="btnSendChat" aria-label="Gửi">
                                        <i class="bi bi-send-fill"></i>
                                    </button>
                                </div>
                            </form>
                            <div class="tt-hint">Enter để gửi · Shift+Enter xuống dòng</div>
                        </div>
                    </section>

                    <%-- Danh sách phiên gần đây (đặt sau khung chat trong DOM: tự xuống dưới khi < 992px) --%>
                    <aside class="tt-side">
                        <div class="tt-side-card">
                            <h2 class="tt-side-title"><i class="bi bi-clock-history"></i> Phiên gần đây</h2>
                            <c:forEach var="s" items="${sessions}">
                                <a class="tt-session ${s.sessionId == tutorSession.sessionId ? 'bg-light border' : ''}"
                                    href="${pageContext.request.contextPath}/student/ai-tutor?sessionId=${s.sessionId}">
                                    <div class="tt-session-title latex-content"><c:out value="${s.title}" /></div>
                                    <div class="tt-session-meta">
                                        <c:choose>
                                            <c:when test="${s.status == 'COMPLETED'}"><span class="tt-badge tt-badge--done">Hoàn thành</span></c:when>
                                            <c:when test="${s.status == 'ABANDONED'}"><span class="tt-badge tt-badge--abandoned">Bỏ dở</span></c:when>
                                            <c:otherwise><span class="tt-badge tt-badge--active">Đang học<c:if test="${s.totalSteps > 0}"> · Bước ${s.currentStep}/${s.totalSteps}</c:if></span></c:otherwise>
                                        </c:choose>
                                        <time><fmt:formatDate value="${s.createdAt}" pattern="dd/MM HH:mm" /></time>
                                    </div>
                                </a>
                            </c:forEach>
                            <c:if test="${empty sessions}">
                                <div class="text-muted small px-2 py-1">Chưa có phiên nào.</div>
                            </c:if>
                        </div>
                    </aside>

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
            const hintBox = document.getElementById('inputHintBox');
            const hintText = document.getElementById('inputHintText');
            const btnAbandon = document.getElementById('btnAbandon');
            const composerBox = document.getElementById('composerBox');
            const mathPreview = document.getElementById('mathPreview');
            const mathKeys = document.querySelectorAll('.tt-math-btn');

            // Trạng thái lấy từ server (TutorSessions); client chỉ hiển thị, không quyết định bước
            const state = {
                sessionId: ${empty tutorSession ? 'null' : tutorSession.sessionId},
                currentStep: ${empty tutorSession ? 0 : tutorSession.currentStep},
                totalSteps: ${empty tutorSession ? 0 : tutorSession.totalSteps},
                awaiting: ${not empty tutorSession and tutorSession.awaitingInput ? 'true' : 'false'},
                status: '${empty tutorSession ? 'NEW' : tutorSession.status}'
            };
            <c:choose>
                <c:when test="${not empty startMode}">
            const pendingStart = {
                mode: '${startMode}',
                questionId: ${empty startQuestionId ? 'null' : startQuestionId},
                submissionId: ${empty startSubmissionId ? 'null' : startSubmissionId}
            };
                </c:when>
                <c:otherwise>
            const pendingStart = null;
                </c:otherwise>
            </c:choose>
            const MATH = {
                delimiters: [
                    { left: '$$', right: '$$', display: true },
                    { left: '$', right: '$', display: false },
                    { left: '\\[', right: '\\]', display: true },
                    { left: '\\(', right: '\\)', display: false }
                ],
                throwOnError: false
            };

            const rawText = new WeakMap(); // văn bản gốc của từng bong bóng (để sao chép)

            function scrollToBottom() { chatContainer.scrollTop = chatContainer.scrollHeight; }
            function renderMath(el) { if (window.renderMathInElement) renderMathInElement(el, MATH); }

            // Lấy lại văn bản gốc của một phần tử, kể cả khi KaTeX đã render sẵn (footer.jsp render toàn trang
            // trước DOMContentLoaded): thay mỗi công thức bằng mã TeX trong <annotation> + dấu $ / $$.
            function extractRaw(el) {
                if (!el.querySelector('.katex')) return el.textContent;
                const c = el.cloneNode(true);
                const tex = n => {
                    const a = n.querySelector('annotation[encoding="application/x-tex"]');
                    return a ? a.textContent : '';
                };
                c.querySelectorAll('.katex-display').forEach(n => n.replaceWith(document.createTextNode('$$' + tex(n) + '$$')));
                c.querySelectorAll('.katex').forEach(n => n.replaceWith(document.createTextNode('$' + tex(n) + '$')));
                return c.textContent;
            }

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

            // Tách câu hỏi ("ask") của AI: đoạn cuối kết thúc bằng ? hoặc :
            function splitAsk(raw) {
                const full = String(raw || '');
                const paras = full.split(/\n{2,}/);
                const last = paras.length > 1 ? paras[paras.length - 1].trim() : '';
                if (last && /[?？:]\s*$/.test(last)) {
                    return { main: paras.slice(0, -1).join('\n\n'), ask: last };
                }
                return { main: full, ask: '' };
            }

            function makeAsk(text) {
                const ask = document.createElement('div');
                ask.className = 'bubble-ask latex-content';
                setRichText(ask, text);
                return ask;
            }

            function makeCopyButton() {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'bubble-copy';
                btn.title = 'Sao chép';
                btn.setAttribute('aria-label', 'Sao chép');
                btn.innerHTML = '<i class="bi bi-clipboard"></i>';
                return btn;
            }

            // Nâng cấp bong bóng lịch sử do JSP render: tách ask + in đậm, kết quả trùng markup addMessage()
            function upgradeBubble(wrap) {
                const bubble = wrap.querySelector('.bubble');
                const textEl = bubble && bubble.querySelector('.bubble-text');
                if (!textEl) return;
                const raw = extractRaw(textEl);
                rawText.set(bubble, raw);
                const p = wrap.classList.contains('bot') ? splitAsk(raw) : { main: raw, ask: '' };
                setRichText(textEl, p.main);
                if (p.ask) textEl.after(makeAsk(p.ask));
            }

            // Markup bong bóng: giữ đồng nhất với phần JSP render lịch sử ở trên
            function addMessage(kind, text, extraClass) {
                const isError = extraClass === 'bubble--error';
                const wrap = document.createElement('div');
                wrap.className = 'chat-message ' + kind;
                if (kind === 'bot') {
                    wrap.innerHTML = '<div class="avatar"><i class="bi bi-robot"></i></div>';
                }
                const bubble = document.createElement('div');
                bubble.className = 'bubble' + (extraClass ? ' ' + extraClass : '');
                const p = (kind === 'bot' && !isError) ? splitAsk(text) : { main: String(text || ''), ask: '' };
                const textEl = document.createElement('div');
                textEl.className = 'bubble-text latex-content';
                setRichText(textEl, p.main);
                bubble.appendChild(textEl);
                if (p.ask) bubble.appendChild(makeAsk(p.ask));
                if (kind === 'bot' && !isError) bubble.appendChild(makeCopyButton());
                rawText.set(bubble, String(text || ''));
                wrap.appendChild(bubble);
                chatContainer.insertBefore(wrap, chatLoading);
                renderMath(wrap);
                scrollToBottom();
            }

            function copyText(text) {
                if (navigator.clipboard && navigator.clipboard.writeText) {
                    return navigator.clipboard.writeText(text);
                }
                return new Promise((resolve, reject) => {
                    const ta = document.createElement('textarea');
                    ta.value = text;
                    ta.style.position = 'fixed';
                    ta.style.opacity = '0';
                    document.body.appendChild(ta);
                    ta.select();
                    try { document.execCommand('copy') ? resolve() : reject(); } catch (e) { reject(e); }
                    document.body.removeChild(ta);
                });
            }

            chatContainer.addEventListener('click', e => {
                const btn = e.target.closest('.bubble-copy');
                if (!btn) return;
                const bubble = btn.closest('.bubble');
                copyText(rawText.get(bubble) || bubble.textContent).then(() => {
                    const icon = btn.querySelector('i');
                    icon.className = 'bi bi-check2';
                    setTimeout(() => { icon.className = 'bi bi-clipboard'; }, 1500);
                }).catch(() => {});
            });

            // ── Ô nhập: tự giãn + xem trước công thức ──
            let previewTimer = null;
            function autosize() {
                chatInput.style.height = 'auto';
                chatInput.style.height = chatInput.scrollHeight + 'px';
            }
            function schedulePreview() {
                clearTimeout(previewTimer);
                if (!chatInput.value.trim()) {
                    mathPreview.hidden = true;
                    mathPreview.textContent = '';
                    return;
                }
                previewTimer = setTimeout(() => {
                    const v = chatInput.value;
                    if (!v.trim()) { mathPreview.hidden = true; return; }
                    mathPreview.textContent = v;
                    mathPreview.hidden = false;
                    renderMath(mathPreview);
                }, 300);
            }
            function syncInput() { autosize(); schedulePreview(); }
            chatInput.addEventListener('input', syncInput);

            // ── Thanh ký hiệu toán: chèn $...$ tại vị trí con trỏ ──
            mathKeys.forEach(btn => btn.addEventListener('click', () => {
                if (chatInput.disabled) return;
                const snippet = '$' + btn.dataset.tex + '$';
                const back = parseInt(btn.dataset.back || '0', 10);
                const s = chatInput.selectionStart;
                const e = chatInput.selectionEnd;
                const v = chatInput.value;
                chatInput.value = v.slice(0, s) + snippet + v.slice(e);
                const pos = s + snippet.length - back;
                chatInput.focus();
                chatInput.setSelectionRange(pos, pos);
                syncInput();
            }));

            function isClosed() {
                return state.status === 'COMPLETED' || state.status === 'ABANDONED' || state.status === 'DONE';
            }

            function updateProgress() {
                if (state.status === 'COMPLETED') {
                    stepLabel.textContent = 'Hoàn thành';
                    stepBar.style.width = '100%';
                } else if (state.status === 'ABANDONED') {
                    stepLabel.textContent = 'Đã kết thúc';
                } else if (state.currentStep > 0) {
                    stepLabel.textContent = state.totalSteps > 0
                        ? 'Bước ' + state.currentStep + ' / ' + state.totalSteps : 'Bước ' + state.currentStep;
                    stepBar.style.width = state.totalSteps > 0
                        ? Math.round((state.currentStep - 1) / state.totalSteps * 100) + '%' : '10%';
                }
                stepLabel.className = 'tt-badge ms-auto ' + (state.status === 'COMPLETED' ? 'tt-badge--done'
                    : (state.status === 'ABANDONED' || state.currentStep === 0) ? 'tt-badge--abandoned' : 'tt-badge--active');
                chatInput.placeholder = isClosed()
                    ? 'Phiên đã kết thúc. Bấm "Bài toán mới" để tiếp tục.'
                    : (state.sessionId === null ? 'Nhập bài toán của bạn...' : 'Nhập bước làm của bạn...');
                hintBox.classList.toggle('d-none', !state.awaiting || isClosed());
                composerBox.classList.toggle('border-warning', state.awaiting && !isClosed());
                chatInput.disabled = isClosed();
                btnSend.disabled = isClosed();
                mathKeys.forEach(k => { k.disabled = isClosed(); });
                if (btnAbandon) btnAbandon.classList.toggle('d-none', isClosed());
            }

            // Lỗi hiển thị bằng bong bóng đỏ trong khung chat (errorBox chỉ để đọc màn hình)
            function showError(msg) {
                errorBox.textContent = msg;
                addMessage('bot', msg, 'bubble--error');
            }

            /** Áp kết quả TutorStepResponse của server vào giao diện. */
            function applyStep(d, firstTurn) {
                state.sessionId = d.sessionId;
                state.currentStep = d.currentStep;
                state.totalSteps = d.totalSteps;
                state.awaiting = d.needsStudentInput;
                state.status = d.status;
                hintText.textContent = d.inputRequestHint || '';
                renderMath(hintBox);
                if (lessonSelect) lessonSelect.disabled = true;

                const parts = [];
                if (d.feedbackToStudent) parts.push(d.feedbackToStudent);
                if (d.nextPromptOrQuestion) parts.push(d.nextPromptOrQuestion);
                if (d.finalSummary) parts.push(d.finalSummary);
                const cls = (!firstTurn && d.isStepCorrect === false) ? 'bubble--warn' : '';
                addMessage('bot', parts.join('\n\n'), cls);
                if (d.status === 'COMPLETED') {
                    addMessage('bot', 'Chúc mừng bạn đã hoàn thành bài toán! Bấm "Bài toán mới" để luyện tiếp.');
                }
            }

            async function postJson(url, payload) {
                const res = await csrfFetch(ctx + url, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                    body: JSON.stringify(payload)
                });
                const data = await res.json().catch(() => ({ message: 'Phản hồi không hợp lệ (HTTP ' + res.status + ').' }));
                return { ok: res.ok, data: data };
            }

            // Lịch sử đã có sẵn: chuẩn hóa bong bóng rồi render công thức
            chatContainer.querySelectorAll('.chat-message').forEach(upgradeBubble);
            renderMath(chatContainer);
            updateProgress();
            autosize();
            scrollToBottom();

            chatInput.addEventListener('keydown', e => {
                if (e.key === 'Enter' && !e.shiftKey && !e.isComposing) {
                    e.preventDefault();
                    chatForm.requestSubmit();
                }
            });

            chatForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                const text = chatInput.value.trim();
                if (!text || isClosed()) return;

                errorBox.textContent = '';
                chatInput.value = '';
                syncInput();
                addMessage('user', text);
                chatLoading.style.display = 'flex';
                scrollToBottom();
                chatInput.disabled = true;
                btnSend.disabled = true;

                const firstTurn = state.sessionId === null;
                const lessonId = (firstTurn && lessonSelect && lessonSelect.value) ? parseInt(lessonSelect.value, 10) : null;
                try {
                    const r = firstTurn
                        ? await postJson('/api/tutor/start', { mode: lessonId ? 'LESSON' : 'FREE', problemText: text, lessonId: lessonId })
                        : await postJson('/api/tutor/next-step', { sessionId: state.sessionId, studentInput: text });
                    chatLoading.style.display = 'none';
                    if (!r.ok) {
                        showError(r.data.message || 'Có lỗi xảy ra, vui lòng thử lại.');
                        chatInput.value = text; // cho phép gửi lại
                        syncInput();
                    } else {
                        applyStep(r.data.data, firstTurn);
                        if (firstTurn) history.replaceState(null, '', ctx + '/student/ai-tutor?sessionId=' + state.sessionId);
                    }
                } catch (err) {
                    chatLoading.style.display = 'none';
                    showError('Mất kết nối mạng hoặc lỗi hệ thống. Vui lòng thử lại.');
                    chatInput.value = text;
                    syncInput();
                } finally {
                    updateProgress();
                    if (!isClosed()) {
                        chatInput.disabled = false;
                        btnSend.disabled = false;
                        chatInput.focus();
                    }
                }
            });

            // UC-TUT-04: kết thúc phiên sớm
            if (btnAbandon) {
                btnAbandon.addEventListener('click', async () => {
                    btnAbandon.disabled = true;
                    try {
                        const r = await postJson('/api/tutor/' + state.sessionId + '/abandon', {});
                        if (r.ok) {
                            state.status = 'ABANDONED';
                            state.awaiting = false;
                            addMessage('bot', 'Đã kết thúc phiên. Bạn có thể xem lại hoặc bắt đầu bài toán mới.');
                        } else {
                            showError(r.data.message || 'Không kết thúc được phiên.');
                        }
                    } catch (err) {
                        showError('Mất kết nối mạng hoặc lỗi hệ thống. Vui lòng thử lại.');
                    } finally {
                        btnAbandon.disabled = false;
                        updateProgress();
                    }
                });
            }

            // FR-STU-05 / FR-OCR-04: mở phiên từ câu trắc nghiệm vừa sai hoặc bài tự luận vừa chấm
            if (pendingStart) {
                addMessage('user', pendingStart.mode === 'QUESTION'
                    ? 'Em vừa làm sai một câu trắc nghiệm, hãy hướng dẫn em.'
                    : 'Em muốn hiểu lỗi sai trong bài tự luận vừa chấm.');
                chatLoading.style.display = 'flex';
                scrollToBottom();
                chatInput.disabled = true;
                btnSend.disabled = true;
                postJson('/api/tutor/start', pendingStart).then(r => {
                    chatLoading.style.display = 'none';
                    if (r.ok) {
                        // Tải lại trang theo sessionId để hiện đầy đủ hội thoại do server lưu
                        window.location.replace(ctx + '/student/ai-tutor?sessionId=' + r.data.data.sessionId);
                    } else {
                        showError(r.data.message || 'Không mở được phiên gia sư.');
                        chatInput.disabled = false;
                        btnSend.disabled = false;
                    }
                }).catch(() => {
                    chatLoading.style.display = 'none';
                    showError('Mất kết nối mạng hoặc lỗi hệ thống. Vui lòng tải lại trang.');
                    chatInput.disabled = false;
                    btnSend.disabled = false;
                });
            }
        });
    </script>
</body>

</html>

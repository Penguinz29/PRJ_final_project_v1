<%-- File: WEB-INF/views/student/ai-tutor.jsp Servlet: StudentAiTutorServlet (/student/ai-tutor) Attributes:
    messages(List<ChatMessage - from session>)
    Context: Uses fetch in JS (app.js) to POST /student/ai-tutor-api
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="Gia sư AI" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}" style="overflow:hidden;">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell pb-0">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="student-ai" />
                    </jsp:include>
                    <main class="app-main h-100 pb-0"
                        style="padding-bottom:0 !important; max-height: calc(100vh - var(--navbar-h)); display:flex; flex-direction:column;">

                        <div class="page-header py-3 flex-shrink-0">
                            <h2 class="mb-0 fs-3"><i class="bi bi-robot me-2 text-ai"></i>Gia sư Toán AI</h2>
                            <p class="text-muted mb-0 mx-2" style="font-size:0.9rem;">Hỏi bất cứ bài toán nào, AI sẽ gợi
                                ý từng bước giải.</p>
                        </div>

                        <%-- Chat UI Container --%>
                            <div class="card flex-grow-1 border-0 shadow-sm overflow-hidden mb-3"
                                style="display:flex; flex-direction:column;">

                                <%-- Messages History --%>
                                    <div class="chat-box p-4" id="chatContainer"
                                        style="flex:1; overflow-y:auto; background-color:#f8f9fa;">

                                        <%-- Bot Greeting --%>
                                            <div class="chat-message bot">
                                                <div class="avatar"><i class="bi bi-robot"></i></div>
                                                <div class="content shadow-sm">
                                                    Chào
                                                    <c:out value="${sessionScope.currentUser.fullName}" />! Tôi là Gia
                                                    sư toán Gemini. Bạn có bài toán nào cần tôi hỗ trợ giải đáp không?
                                                    <br>Bạn có thể đưa ra dạng toán, ví dụ: <i>"Làm thế nào để tính giới
                                                        hạn hàm số 1/x khi x tiến tới vô cùng?"</i>
                                                    <br>Hoặc nhập công thức LaTeX để hỗ trợ hiển thị:
                                                    <code>$\lim_{x \to \infty} \frac{1}{x}$</code>.
                                                </div>
                                            </div>

                                            <%-- Load session history if exists --%>
                                                <c:if test="${not empty messages}">
                                                    <c:forEach var="msg" items="${messages}">
                                                        <div
                                                            class="chat-message ${msg.sender == 'USER' ? 'user' : 'bot'}">
                                                            <c:if test="${msg.sender == 'BOT'}">
                                                                <div class="avatar"><i class="bi bi-robot"></i></div>
                                                            </c:if>
                                                            <div class="content shadow-sm latex-content">
                                                                <c:out value="${msg.content}" />
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </c:if>

                                                <div class="chat-loading" id="chatLoading" style="display:none;">
                                                    <div class="typing-indicator">
                                                        <span></span><span></span><span></span></div>
                                                </div>
                                    </div>

                                    <%-- Input Box --%>
                                        <div class="chat-input-area p-3 bg-white border-top flex-shrink-0">
                                            <form id="chatForm">
                                                <div class="input-group">
                                                    <textarea class="form-control" id="chatInput" rows="2"
                                                        placeholder="Nhập câu hỏi của bạn (Nhấn Enter để gửi, Shift+Enter để xuống dòng)..."></textarea>
                                                    <button class="btn btn-ai px-4 d-flex align-items-center"
                                                        type="submit" id="btnSendChat">
                                                        <i class="bi bi-send-fill fs-5"></i>
                                                    </button>
                                                </div>
                                            </form>
                                        </div>
                            </div>
                    </main>
                </div>
                <jsp:include page="../common/footer.jsp" />
                <script>
                    document.addEventListener('DOMContentLoaded', () => {
                        const chatForm = document.getElementById('chatForm');
                        const chatInput = document.getElementById('chatInput');
                        const chatContainer = document.getElementById('chatContainer');
                        const chatLoading = document.getElementById('chatLoading');

                        // Auto scroll to bottom
                        function scrollToBottom() {
                            chatContainer.scrollTop = chatContainer.scrollHeight;
                        }
                        scrollToBottom();

                        // Enter to send
                        chatInput.addEventListener('keydown', function (e) {
                            if (e.key === 'Enter' && !e.shiftKey) {
                                e.preventDefault();
                                chatForm.dispatchEvent(new Event('submit'));
                            }
                        });

                        chatForm.addEventListener('submit', async (e) => {
                            e.preventDefault();
                            const text = chatInput.value.trim();
                            if (!text) return;

                            chatInput.value = '';

                            // Render user message
                            const userMsg = document.createElement('div');
                            userMsg.className = 'chat-message user';
                            userMsg.innerHTML = '<div class="content shadow-sm latex-content"></div>';
                            userMsg.querySelector('.content').textContent = text;
                            chatContainer.insertBefore(userMsg, chatLoading);

                            // Xử lý render latex cho nội dung user
                            if (window.renderMathInElement) {
                                renderMathInElement(userMsg, {
                                    delimiters: [
                                        { left: "$$", right: "$$", display: true },
                                        { left: "$", right: "$", display: false }
                                    ]
                                });
                            }
                            scrollToBottom();

                            chatLoading.style.display = 'flex';
                            scrollToBottom();
                            chatInput.disabled = true;

                            try {
                                const API_URL = document.body.dataset.ctx + '/student/ai-tutor-api';
                                const fd = new URLSearchParams();
                                fd.append('message', text);

                                const response = await fetch(API_URL, {
                                    method: 'POST',
                                    body: fd,
                                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
                                });

                                chatLoading.style.display = 'none';

                                if (response.ok) {
                                    const data = await response.json();
                                    if (data.success) {
                                        appendBotMessage(data.reply);
                                    } else {
                                        appendBotMessage("Xin lỗi, có lỗi xảy ra: " + data.error);
                                    }
                                } else {
                                    appendBotMessage("Lỗi kết nối tới server (HTTP " + response.status + ")");
                                }
                            } catch (err) {
                                chatLoading.style.display = 'none';
                                appendBotMessage("Mất kết nối mạng hoặc lỗi hệ thống. Vui lòng thử lại.");
                            } finally {
                                chatInput.disabled = false;
                                chatInput.focus();
                            }
                        });

                        function appendBotMessage(markdownText) {
                            const botMsg = document.createElement('div');
                            botMsg.className = 'chat-message bot';
                            // Dùng DOM implementation an toàn, nhưng vì trả về markdown/text thô có LaTeX
                            botMsg.innerHTML = '<div class="avatar"><i class="bi bi-robot"></i></div><div class="content shadow-sm latex-content"></div>';
                            // Parse "\n" to <br> for simple HTML display before KaTeX rendering
                            let formattedValue = markdownText.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
                            formattedValue = formattedValue.replace(/\n/g, '<br/>');

                            botMsg.querySelector('.content').innerHTML = formattedValue;

                            chatContainer.insertBefore(botMsg, chatLoading);

                            // Gọi hàm render latex của layout
                            if (window.renderMathInElement) {
                                renderMathInElement(botMsg, {
                                    delimiters: [
                                        { left: "$$", right: "$$", display: true },
                                        { left: "$", right: "$", display: false },
                                        { left: "\\[", right: "\\]", display: true },
                                        { left: "\\(", right: "\\)", display: false }
                                    ]
                                });
                            }
                            scrollToBottom();
                        }
                    });
                </script>
            </body>

            </html>
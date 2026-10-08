<%-- File: WEB-INF/views/teacher/questions.jsp Controller: TeacherQuestionController (/teacher/questions) Attributes:
    questions(List<Question>), lessons(List<Lesson>), topics(List<Topic>),
            page(int), totalPages(int), totalRecords(int),
            selectedLessonId(Integer), selectedType(String)
            Actions: delete (POST)
            --%>
            <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
                <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
                                <ui:flash />
                                <div class="page-header">
                                    <h1><i class="bi bi-patch-question me-2 text-primary"></i>Câu hỏi
                                        <span class="badge bg-secondary ms-2">${totalRecords}</span>
                                    </h1>
                                    <div class="d-flex gap-2">
                                        <button type="button" class="btn btn-outline-primary btn-sm" data-bs-toggle="modal" data-bs-target="#aiGeneratorModal">
                                            <i class="bi bi-stars me-1 text-primary"></i>Sinh câu hỏi bằng AI
                                        </button>
                                        <a href="${pageContext.request.contextPath}/teacher/questions?action=create"
                                            class="btn btn-primary btn-sm">
                                            <i class="bi bi-plus-lg me-1"></i>Thêm câu hỏi
                                        </a>
                                    </div>
                                </div>

                                <%-- Lọc --%>
                                    <div class="card mb-3">
                                        <div class="card-body py-2">
                                            <form class="row g-2"
                                                action="${pageContext.request.contextPath}/teacher/questions"
                                                method="get">
                                                <div class="col-sm-3">
                                                    <select class="form-select form-select-sm" name="topicId">
                                                        <option value="">-- Chuyên đề --</option>
                                                        <c:forEach var="t" items="${topics}">
                                                            <option value="${t.topicId}" ${selectedTopicId==t.topicId
                                                                ? 'selected' : '' }>
                                                                <c:out value="${t.topicName}" />
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-sm-3">
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
                                                <div class="col-sm-2">
                                                    <select class="form-select form-select-sm" name="type">
                                                        <option value="">-- Loại --</option>
                                                        <option value="MCQ" ${selectedType=='MCQ' ? 'selected' : '' }>
                                                            Trắc nghiệm</option>
                                                        <option value="ESSAY" ${selectedType=='ESSAY' ? 'selected' : ''
                                                            }>Tự luận</option>
                                                    </select>
                                                </div>
                                                <div class="col-sm-2">
                                                    <select class="form-select form-select-sm" name="level">
                                                        <option value="">-- Mức độ --</option>
                                                        <option value="1" ${selectedLevel==1 ? 'selected' : '' }>Dễ</option>
                                                        <option value="2" ${selectedLevel==2 ? 'selected' : '' }>Trung bình</option>
                                                        <option value="3" ${selectedLevel==3 ? 'selected' : '' }>Khó</option>
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
                                                                            <ui:rich-text value="${q.content}" />
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
<input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                                                            <input type="hidden" name="action"
                                                                                value="delete">
                                                                            <input type="hidden" name="id"
                                                                                value="${q.questionId}">
                                                                        </form>
                                                                        <ui:delete-button form="#delQ${q.questionId}" mode="${q.deleteMode}"
                                                                            question="Xóa câu hỏi này?"
                                                                            softNote="Câu hỏi đã có học sinh làm nên chỉ được ẩn khỏi trang quản lý (xóa mềm); học sinh vẫn ôn tập được, lịch sử giữ nguyên." />
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                    <ui:pagination baseUrl="${pageContext.request.contextPath}/teacher/questions?topicId=${selectedTopicId}&lessonId=${selectedLessonId}&type=${selectedType}&level=${selectedLevel}" page="${page}" totalPages="${totalPages}" />
                            </main>
                        </div>
                         <jsp:include page="../common/confirm-modal.jsp" />

                        <!-- Modal Sinh câu hỏi bằng AI (FR-TEA-03) -->
                        <div class="modal fade" id="aiGeneratorModal" tabindex="-1" aria-labelledby="aiGeneratorModalLabel" aria-hidden="true">
                            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title" id="aiGeneratorModalLabel">
                                            <i class="bi bi-stars text-primary me-2"></i>Sinh câu hỏi trắc nghiệm bằng Gemini AI
                                        </h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        <!-- Form tham số sinh đề -->
                                        <div class="card mb-3 border-0 bg-light">
                                            <div class="card-body">
                                                <div class="row g-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold">Chuyên đề Toán 12</label>
                                                        <select class="form-select form-select-sm" id="aiTopicSelect">
                                                            <c:forEach var="t" items="${topics}">
                                                                <option value="${t.topicId}"><c:out value="${t.topicName}" /></option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold">Bài học mục tiêu</label>
                                                        <select class="form-select form-select-sm" id="aiLessonSelect">
                                                            <c:forEach var="l" items="${lessons}">
                                                                <option value="${l.lessonId}"><c:out value="${l.title}" /></option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold">Mức độ nhận thức (GDPT 2018)</label>
                                                        <select class="form-select form-select-sm" id="aiLevelSelect">
                                                            <option value="1">Mức 1: Nhận biết / Thông hiểu (Dễ)</option>
                                                            <option value="2">Mức 2: Vận dụng (Trung bình)</option>
                                                            <option value="3">Mức 3: Vận dụng cao (Khó)</option>
                                                        </select>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold">Số lượng câu hỏi</label>
                                                        <select class="form-select form-select-sm" id="aiCountSelect">
                                                            <option value="3">3 câu hỏi</option>
                                                            <option value="5" selected>5 câu hỏi</option>
                                                            <option value="10">10 câu hỏi</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="mt-3 text-end">
                                                    <button type="button" class="btn btn-primary btn-sm" id="btnRunAiGenerate">
                                                        <i class="bi bi-magic me-1"></i> Bắt đầu sinh câu hỏi
                                                    </button>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Trạng thái loading / Thông báo -->
                                        <div id="aiLoading" class="text-center py-4 d-none">
                                            <div class="spinner-border text-primary" role="status" style="width: 2.5rem; height: 2.5rem;"></div>
                                            <p class="mt-2 text-muted fw-semibold">Gemini AI đang biên soạn câu hỏi chuẩn GDPT 2018 và kết xuất LaTeX...</p>
                                            <small class="text-muted">Quá trình này mất khoảng 3 - 6 giây</small>
                                        </div>

                                        <div id="aiAlert" class="alert d-none" role="alert"></div>

                                        <!-- Vùng xem trước kết quả sinh -->
                                        <div id="aiPreviewArea" class="d-none">
                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                <h6 class="fw-bold mb-0 text-success">
                                                    <i class="bi bi-check2-circle me-1"></i>Kết quả sinh câu hỏi (<span id="aiCountBadge">0</span> câu)
                                                </h6>
                                                <div>
                                                    <button type="button" class="btn btn-link btn-sm text-decoration-none p-0 me-2" id="btnSelectAllAi">Chọn tất cả</button>
                                                    <button type="button" class="btn btn-link btn-sm text-decoration-none p-0 text-muted" id="btnDeselectAllAi">Bỏ chọn</button>
                                                </div>
                                            </div>
                                            <div id="aiQuestionsContainer" class="d-flex flex-column gap-3"></div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
                                        <button type="button" class="btn btn-success btn-sm d-none" id="btnSaveAiQuestions">
                                            <i class="bi bi-cloud-arrow-up me-1"></i> Lưu vào Ngân hàng câu hỏi
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <jsp:include page="../common/footer.jsp" />

                        <script>
                            (function() {
                                const ctx = document.body.dataset.ctx || '';
                                // Escape trước khi đưa vào innerHTML (nội dung do AI sinh là dữ liệu không tin cậy)
                                const esc = (v) => String(v == null ? '' : v).replace(/&/g, '&amp;').replace(/</g, '&lt;')
                                    .replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
                                const topicSelect = document.getElementById('aiTopicSelect');
                                const lessonSelect = document.getElementById('aiLessonSelect');
                                const levelSelect = document.getElementById('aiLevelSelect');
                                const countSelect = document.getElementById('aiCountSelect');
                                const btnRun = document.getElementById('btnRunAiGenerate');
                                const loading = document.getElementById('aiLoading');
                                const alertBox = document.getElementById('aiAlert');
                                const previewArea = document.getElementById('aiPreviewArea');
                                const container = document.getElementById('aiQuestionsContainer');
                                const countBadge = document.getElementById('aiCountBadge');
                                const btnSave = document.getElementById('btnSaveAiQuestions');

                                let generatedList = [];

                                // Khi đổi Chuyên đề -> nạp bài học tương ứng
                                if (topicSelect) {
                                    topicSelect.addEventListener('change', function() {
                                        csrfFetch(ctx + '/api/teacher/lessons-by-topic?topicId=' + this.value)
                                            .then(res => res.json())
                                            .then(body => {
                                                const lessons = body.data || [];
                                                lessonSelect.innerHTML = '';
                                                lessons.forEach(l => {
                                                    const opt = document.createElement('option');
                                                    opt.value = l.lessonId;
                                                    opt.textContent = l.title;
                                                    lessonSelect.appendChild(opt);
                                                });
                                            })
                                            .catch(err => console.error('Lỗi nạp bài học:', err));
                                    });
                                }

                                const aiModalEl = document.getElementById('aiGeneratorModal');
                                if (aiModalEl && topicSelect) {
                                    aiModalEl.addEventListener('show.bs.modal', function() {
                                        topicSelect.dispatchEvent(new Event('change'));
                                    });
                                    if (new URLSearchParams(window.location.search).get('openAi') === '1') {
                                        window.addEventListener('load', function() {
                                            bootstrap.Modal.getOrCreateInstance(aiModalEl).show();
                                        });
                                    }
                                }

                                // Bấm nút sinh câu hỏi
                                if (btnRun) {
                                    btnRun.addEventListener('click', function() {
                                        const lessonId = lessonSelect ? lessonSelect.value : '';
                                        const level = levelSelect ? levelSelect.value : '1';
                                        const count = countSelect ? countSelect.value : '5';

                                        if (!lessonId) {
                                            showAlert('Vui lòng chọn bài học mục tiêu!', 'warning');
                                            return;
                                        }

                                        btnRun.disabled = true;
                                        loading.classList.remove('d-none');
                                        previewArea.classList.add('d-none');
                                        btnSave.classList.add('d-none');
                                        alertBox.classList.add('d-none');

                                        csrfFetch(ctx + '/api/teacher/generate-questions', {
                                            method: 'POST',
                                            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                                            body: JSON.stringify({
                                                lessonId: parseInt(lessonId, 10),
                                                difficultyLevel: parseInt(level, 10),
                                                count: parseInt(count, 10)
                                            })
                                        })
                                        .then(res => res.json().catch(() => ({ success: false, message: 'Phản hồi không hợp lệ (HTTP ' + res.status + ').' })))
                                        .then(data => {
                                            loading.classList.add('d-none');
                                            btnRun.disabled = false;

                                            if (!data.success) {
                                                showAlert(data.message || 'Lỗi khi gọi AI.', 'danger');
                                                return;
                                            }

                                            generatedList = data.data || [];
                                            if (generatedList.length === 0) {
                                                showAlert('Không có câu hỏi nào được trả về.', 'warning');
                                                return;
                                            }

                                            renderPreviewQuestions(generatedList);
                                            if (data.message && data.message !== 'OK') {
                                                showAlert(data.message, 'warning');
                                            }
                                        })
                                        .catch(err => {
                                            loading.classList.add('d-none');
                                            btnRun.disabled = false;
                                            showAlert('Lỗi kết nối máy chủ: ' + err.message, 'danger');
                                        });
                                    });
                                }

                                function renderPreviewQuestions(questions) {
                                    container.innerHTML = '';
                                    countBadge.textContent = questions.length;

                                    questions.forEach((q, idx) => {
                                        const card = document.createElement('div');
                                        card.className = 'card border';
                                        let optionsHtml = '';
                                        if (q.options && Array.isArray(q.options)) {
                                            optionsHtml = '<div class="row g-2 mt-1">';
                                            q.options.forEach(opt => {
                                                const isCorrect = opt.isCorrect === true || opt.isCorrect === 'true';
                                                const badgeClass = isCorrect ? 'border-success bg-success-subtle fw-semibold' : 'border-light-subtle bg-white';
                                                const checkIcon = isCorrect ? '<i class="bi bi-check-circle-fill text-success ms-1"></i>' : '';
                                                optionsHtml += '<div class="col-md-6">' +
                                                    '<div class="p-2 border rounded ' + badgeClass + '" style="font-size: .88rem;">' +
                                                        '<strong>' + esc(opt.letter) + '.</strong> ' + EduRich.toSafeHtml(opt.content) + ' ' + checkIcon +
                                                    '</div>' +
                                                '</div>';
                                            });
                                            optionsHtml += '</div>';
                                        }

                                        let explanationHtml = '';
                                        if (q.explanation) {
                                            explanationHtml = '<div class="mt-2 p-2 bg-light rounded text-muted" style="font-size: .83rem;">' +
                                                '<i class="bi bi-lightbulb text-warning me-1"></i><strong>Lời giải:</strong> ' + EduRich.toSafeHtml(q.explanation) +
                                            '</div>';
                                        }

                                        card.innerHTML = '<div class="card-body p-3">' +
                                            '<div class="d-flex align-items-start gap-2">' +
                                                '<input class="form-check-input mt-1 ai-q-check" type="checkbox" checked data-idx="' + idx + '" id="chk_ai_' + idx + '">' +
                                                '<div class="flex-grow-1">' +
                                                    '<label class="form-check-label fw-bold mb-1" for="chk_ai_' + idx + '">' +
                                                        'Câu ' + (idx + 1) +
                                                        ' <span class="badge bg-primary-subtle text-primary ms-1" style="font-size: .75rem;">Mức ' + esc(q.level || 1) + '</span>' +
                                                    '</label>' +
                                                    '<div class="latex-content mb-2">' + EduRich.toSafeHtml(q.content) + '</div>' +
                                                    optionsHtml +
                                                    explanationHtml +
                                                '</div>' +
                                            '</div>' +
                                        '</div>';
                                        container.appendChild(card);
                                    });

                                    previewArea.classList.remove('d-none');
                                    btnSave.classList.remove('d-none');

                                    // Render KaTeX cho toàn bộ công thức toán trong container
                                    if (typeof renderMathInElement === 'function') {
                                        renderMathInElement(container, {
                                            delimiters: [
                                                { left: '$$', right: '$$', display: true },
                                                { left: '$', right: '$', display: false }
                                            ],
                                            throwOnError: false
                                        });
                                    }
                                }

                                // Chọn tất cả / Bỏ chọn
                                const btnSelectAll = document.getElementById('btnSelectAllAi');
                                const btnDeselectAll = document.getElementById('btnDeselectAllAi');
                                if (btnSelectAll) {
                                    btnSelectAll.addEventListener('click', () => {
                                        document.querySelectorAll('.ai-q-check').forEach(c => c.checked = true);
                                    });
                                }
                                if (btnDeselectAll) {
                                    btnDeselectAll.addEventListener('click', () => {
                                        document.querySelectorAll('.ai-q-check').forEach(c => c.checked = false);
                                    });
                                }

                                // Lưu các câu hỏi đã chọn vào CSDL
                                if (btnSave) {
                                    btnSave.addEventListener('click', function() {
                                        const checkboxes = document.querySelectorAll('.ai-q-check:checked');
                                        if (checkboxes.length === 0) {
                                            showAlert('Vui lòng chọn ít nhất một câu hỏi để lưu.', 'warning');
                                            return;
                                        }

                                        btnSave.disabled = true;
                                        btnSave.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Đang lưu...';

                                        const selected = [];
                                        checkboxes.forEach(chk => {
                                            selected.push(generatedList[parseInt(chk.dataset.idx, 10)]);
                                        });

                                        csrfFetch(ctx + '/api/teacher/questions/batch-save', {
                                            method: 'POST',
                                            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                                            body: JSON.stringify({
                                                lessonId: parseInt(lessonSelect.value, 10),
                                                questions: selected
                                            })
                                        })
                                        .then(res => res.json().catch(() => ({ success: false, message: 'Phản hồi không hợp lệ (HTTP ' + res.status + ').' })))
                                        .then(data => {
                                            if (data.success) {
                                                window.location.href = ctx + '/teacher/questions?lessonId=' + lessonSelect.value;
                                            } else {
                                                btnSave.disabled = false;
                                                btnSave.innerHTML = '<i class="bi bi-cloud-arrow-up me-1"></i> Lưu vào Ngân hàng câu hỏi';
                                                showAlert(data.message || 'Lỗi khi lưu câu hỏi.', 'danger');
                                            }
                                        })
                                        .catch(err => {
                                            btnSave.disabled = false;
                                            btnSave.innerHTML = '<i class="bi bi-cloud-arrow-up me-1"></i> Lưu vào Ngân hàng câu hỏi';
                                            showAlert('Lỗi khi gửi yêu cầu lưu: ' + err.message, 'danger');
                                        });
                                    });
                                }

                                function showAlert(msg, type) {
                                    alertBox.className = 'alert alert-' + type;
                                    alertBox.textContent = msg;
                                    alertBox.classList.remove('d-none');
                                }
                            })();
                        </script>
                    </body>

                    </html>
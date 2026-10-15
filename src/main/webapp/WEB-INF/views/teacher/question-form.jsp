<%-- File: WEB-INF/views/teacher/question-form.jsp Controller: TeacherQuestionController (GET ?action=create|edit) Attributes:
    question(Question - null if create), lessons(List<Lesson>),
    options(List<QuestionOption>), isEdit(boolean)
        POST fields: content, type(MCQ|ESSAY), level(1-3), lessonId, action, id,
        opt_A, opt_B, opt_C, opt_D, correctOption(A-D) [MCQ only]
        sampleAnswer [ESSAY only]
        --%>
        <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
            <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
                <jsp:include page="../common/head.jsp">
                    <jsp:param name="title" value="${isEdit ? 'Sửa câu hỏi' : 'Thêm câu hỏi'}" />
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
                                <h1><i class="bi bi-patch-question me-2 text-primary"></i>
                                    ${isEdit ? 'Sửa câu hỏi' : 'Thêm câu hỏi mới'}</h1>
                                <a href="${pageContext.request.contextPath}${base}/questions"
                                    class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i>Quay
                                    lại</a>
                            </div>

                            <div class="row g-4">
                                <div class="col-lg-8">
                                    <form action="${pageContext.request.contextPath}${base}/questions" method="post"
                                        class="needs-validation" novalidate>
<input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
                                        <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
                                        <c:if test="${isEdit}">
                                            <input type="hidden" name="id" value="${question.questionId}">
                                        </c:if>

                                        <%-- Nhập nhanh từ tệp: AI đọc đề (+ đáp án nếu có) rồi điền vào form để giáo viên xem lại --%>
                                        <div class="card mb-3 border-primary-subtle" id="importCard">
                                            <div class="card-header"><i class="bi bi-file-earmark-arrow-up me-2"></i>Nhập nhanh từ tệp (AI)</div>
                                            <div class="card-body">
                                                <p class="text-muted small mb-3">
                                                    Tải tệp <strong>PDF, Word (.docx) hoặc ảnh</strong> chứa đề bài thay vì nhập tay. Mỗi tệp một câu hỏi, tối đa 5MB.
                                                    Tệp đáp án là <strong>không bắt buộc</strong>: nếu bỏ trống, AI sẽ tự giải và sinh đáp án + lời giải.
                                                    Bạn vẫn xem lại và chỉnh sửa trước khi bấm lưu.
                                                </p>
                                                <div class="row g-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold" for="importQuestionFile">Tệp đề bài <span class="text-danger">*</span></label>
                                                        <input type="file" class="form-control" id="importQuestionFile"
                                                            accept="image/jpeg,image/png,image/webp,application/pdf,.pdf,.docx">
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold" for="importAnswerFile">Tệp đáp án <span class="text-muted fw-normal">(tùy chọn)</span></label>
                                                        <input type="file" class="form-control" id="importAnswerFile"
                                                            accept="image/jpeg,image/png,image/webp,application/pdf,.pdf,.docx">
                                                    </div>
                                                </div>
                                                <div class="d-flex align-items-center gap-3 mt-3">
                                                    <button type="button" class="btn btn-outline-primary" id="btnImportFile">
                                                        <i class="bi bi-stars me-1"></i>Trích xuất bằng AI
                                                    </button>
                                                    <span class="spinner-border spinner-border-sm text-primary d-none" id="importSpinner"></span>
                                                    <span class="small" id="importStatus"></span>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="card mb-3">
                                            <div class="card-header"><i class="bi bi-info-circle me-2"></i>Thông tin câu
                                                hỏi</div>
                                            <div class="card-body">
                                                <div class="row g-3 mb-3">
                                                    <div class="col-sm-6">
                                                        <label class="form-label fw-semibold">Bài giảng <span
                                                                class="text-danger">*</span></label>
                                                        <select class="form-select" name="lessonId" required>
                                                            <option value="">-- Chọn bài giảng --</option>
                                                            <c:forEach var="l" items="${lessons}">
                                                                <option value="${l.lessonId}"
                                                                    ${question.lessonId==l.lessonId ? 'selected' : '' }>
                                                                    <c:out value="${l.title}" />
                                                                </option>
                                                            </c:forEach>
                                                        </select>
                                                        <div class="invalid-feedback">Chọn bài giảng.</div>
                                                    </div>
                                                    <div class="col-sm-3">
                                                        <label class="form-label fw-semibold">Loại <span
                                                                class="text-danger">*</span></label>
                                                        <div class="d-flex gap-2 mt-1">
                                                            <div class="form-check">
                                                                <input class="form-check-input" type="radio" name="type"
                                                                    id="typeMCQ" value="MCQ" ${empty question or
                                                                    question.type=='MCQ' ? 'checked' : '' }>
                                                                <label class="form-check-label" for="typeMCQ">Trắc
                                                                    nghiệm</label>
                                                            </div>
                                                            <div class="form-check">
                                                                <input class="form-check-input" type="radio" name="type"
                                                                    id="typeEssay" value="ESSAY"
                                                                    ${question.type=='ESSAY' ? 'checked' : '' }>
                                                                <label class="form-check-label" for="typeEssay">Tự
                                                                    luận</label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-3">
                                                        <label class="form-label fw-semibold" for="qLevel">Mức
                                                            độ</label>
                                                        <select class="form-select" id="qLevel" name="level">
                                                            <option value="1" ${question.level==1 ? 'selected' : '' }>1
                                                                - Dễ</option>
                                                            <option value="2" ${question.level==2 ? 'selected' : '' }>2
                                                                - Trung bình</option>
                                                            <option value="3" ${question.level==3 ? 'selected' : '' }>3
                                                                - Khó</option>
                                                        </select>
                                                    </div>
                                                </div>

                                                <div class="mb-0">
                                                    <label class="form-label fw-semibold" for="qContent">Nội dung câu
                                                        hỏi <span class="text-danger">*</span></label>
                                                    <small class="ms-2 text-muted">Hỗ trợ LaTeX:
                                                        <code>\$x^2\$</code></small>
                                                    <textarea class="form-control font-monospace" id="qContent"
                                                        name="content" rows="5" maxlength="2000" required
                                                        placeholder="Nhập nội dung câu hỏi, có thể dùng LaTeX..."
                                                        data-latex-preview="#previewContent"><c:out value="${question.content}"/></textarea>
                                                    <div class="invalid-feedback">Vui lòng nhập nội dung câu hỏi.</div>
                                                </div>
                                            </div>
                                        </div>

                                        <%-- MCQ Options --%>
                                            <div class="card mb-3" id="mcqBlock">
                                                <div class="card-header"><i class="bi bi-list-check me-2"></i>Đáp án
                                                    trắc nghiệm</div>
                                                <div class="card-body">
                                                    <c:set var="optMap" value="${optionMap}" />
                                                    <c:forEach var="letter" items="${'A,B,C,D'.split(',')}">
                                                        <div class="mb-3">
                                                            <label
                                                                class="form-label fw-semibold d-flex align-items-center gap-2">
                                                                <span class="option-label border-0"
                                                                    style="background:var(--primary);color:#fff;border:none;">${letter}</span>
                                                                Đáp án ${letter}
                                                            </label>
                                                            <input type="text" class="form-control font-monospace"
                                                                name="opt_${letter}" maxlength="500"
                                                                data-latex-preview="#previewOpt_${letter}"
                                                                placeholder="Nhập đáp án ${letter}..."
                                                                value="<c:out value='${optionMap[letter]}'/>">
                                                        </div>
                                                    </c:forEach>
                                                    <div class="mb-0">
                                                        <label class="form-label fw-semibold">Đáp án đúng <span
                                                                class="text-danger">*</span></label>
                                                        <div class="d-flex gap-3">
                                                            <c:forEach var="letter" items="${'A,B,C,D'.split(',')}">
                                                                <div class="form-check">
                                                                    <input class="form-check-input" type="radio"
                                                                        name="correctOption" id="correct${letter}"
                                                                        value="${letter}"
                                                                        ${correctOption==letter ? 'checked'
                                                                        : '' }>
                                                                    <label class="form-check-label fw-semibold"
                                                                        for="correct${letter}">${letter}</label>
                                                                </div>
                                                            </c:forEach>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <%-- Essay sample answer --%>
                                                <div class="card mb-3">
                                                    <div class="card-header"><i class="bi bi-file-text me-2"></i>Lời giải chi tiết
                                                        (LaTeX, hiển thị cho học sinh; với tự luận là đáp án mẫu để tham khảo)</div>
                                                    <div class="card-body">
                                                        <textarea class="form-control font-monospace"
                                                            name="explanation" rows="4" maxlength="3000"
                                                            data-latex-preview="#previewExplanation"
                                                            placeholder="Nhập lời giải chi tiết, có thể dùng LaTeX $...$ ..."><c:out value="${question.explanation}"/></textarea>
                                                    </div>
                                                </div>

                                                <div class="d-flex gap-2">
                                                    <button type="submit" class="btn btn-primary">
                                                        <i class="bi bi-check-lg me-1"></i>${isEdit ? 'Lưu thay đổi' :
                                                        'Tạo câu hỏi'}
                                                    </button>
                                                    <a href="${pageContext.request.contextPath}${base}/questions"
                                                        class="btn btn-outline-secondary">Hủy</a>
                                                </div>
                                    </form>
                                </div>

                                <%-- Preview --%>
                                    <div class="col-lg-4">
                                        <div style="position:sticky;top:calc(var(--navbar-h) + 1rem);">
                                        <div class="card mb-3">
                                            <div class="card-header"><i class="bi bi-eye me-2"></i>Preview câu hỏi</div>
                                            <div class="card-body latex-content" id="previewContent"
                                                style="min-height:120px;font-size:.9rem;line-height:1.7;">
                                                <span class="text-muted">Nhập nội dung để xem preview...</span>
                                            </div>
                                        </div>
                                        <div class="card mb-3" id="mcqPreview">
                                            <div class="card-header"><i class="bi bi-list-check me-2"></i>Preview đáp án</div>
                                            <div class="card-body" style="font-size:.9rem;line-height:1.7;">
                                                <c:forEach var="letter" items="${'A,B,C,D'.split(',')}">
                                                    <div class="d-flex align-items-baseline gap-2 mb-2">
                                                        <span class="option-label border-0" style="background:var(--primary);color:#fff;">${letter}</span>
                                                        <div class="latex-content flex-grow-1" id="previewOpt_${letter}"><span class="text-muted">—</span></div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                        <div class="card">
                                            <div class="card-header"><i class="bi bi-lightbulb me-2"></i>Preview lời giải</div>
                                            <div class="card-body latex-content" id="previewExplanation"
                                                style="min-height:80px;font-size:.9rem;line-height:1.7;">
                                                <span class="text-muted">Nhập lời giải để xem preview...</span>
                                            </div>
                                        </div>
                                        </div>
                                    </div>
                            </div>
                        </main>
                    </div>
                    <script>
                        // Nhập nhanh từ tệp: gửi tệp lên /api/teacher/extract-question rồi điền kết quả vào form
                        document.addEventListener('DOMContentLoaded', function () {
                            var btn = document.getElementById('btnImportFile');
                            if (!btn) return;
                            var qFile = document.getElementById('importQuestionFile');
                            var aFile = document.getElementById('importAnswerFile');
                            var spinner = document.getElementById('importSpinner');
                            var status = document.getElementById('importStatus');
                            var MAX = 5 * 1024 * 1024;

                            function say(msg, cls) { status.textContent = msg; status.className = 'small ' + (cls || ''); }
                            function setField(el, value) {
                                if (!el) return;
                                el.value = value || '';
                                el.dispatchEvent(new Event('input', { bubbles: true })); // cập nhật preview LaTeX
                            }

                            btn.addEventListener('click', async function () {
                                var form = document.querySelector('form.needs-validation');
                                var type = form.querySelector('input[name=type]:checked');
                                type = type ? type.value : 'MCQ';
                                if (!qFile.files.length) { say('Vui lòng chọn tệp đề bài.', 'text-danger'); return; }
                                var files = [qFile.files[0]].concat(aFile.files.length ? [aFile.files[0]] : []);
                                for (var i = 0; i < files.length; i++) {
                                    if (files[i].size > MAX) { say('Tệp "' + files[i].name + '" vượt quá 5MB.', 'text-danger'); return; }
                                }
                                var fd = new FormData();
                                fd.append('type', type);
                                fd.append('questionFile', qFile.files[0]);
                                if (aFile.files.length) fd.append('answerFile', aFile.files[0]);

                                btn.disabled = true;
                                spinner.classList.remove('d-none');
                                say('AI đang đọc tệp, vui lòng chờ (có thể mất vài chục giây)...', 'text-muted');
                                try {
                                    var res = await csrfFetch(document.body.dataset.ctx + '/api/teacher/extract-question', {
                                        method: 'POST', headers: { 'Accept': 'application/json' }, body: fd
                                    });
                                    var data = await res.json().catch(function () {
                                        return { success: false, message: 'Phản hồi không hợp lệ (HTTP ' + res.status + ').' };
                                    });
                                    if (!res.ok || !data.success) {
                                        say(data.message || 'Không trích xuất được câu hỏi.', 'text-danger');
                                        return;
                                    }
                                    var r = data.data;
                                    setField(form.querySelector('[name=content]'), r.content);
                                    setField(form.querySelector('[name=explanation]'), r.explanation);
                                    if (r.type === 'MCQ') {
                                        ['A', 'B', 'C', 'D'].forEach(function (l) {
                                            setField(form.querySelector('[name=opt_' + l + ']'), (r.options || {})[l]);
                                        });
                                        var radio = form.querySelector('input[name=correctOption][value=' + r.correctOption + ']');
                                        if (radio) radio.checked = true;
                                    }
                                    say(r.answerSource === 'FILE'
                                        ? 'Đã điền form: đáp án lấy từ tệp đáp án. Hãy kiểm tra lại rồi bấm lưu.'
                                        : 'Đã điền form: đáp án và lời giải do AI tự sinh (không có tệp đáp án). Hãy kiểm tra kỹ rồi bấm lưu.',
                                        'text-success');
                                } catch (err) {
                                    say('Mất kết nối tới máy chủ hoặc quá thời gian chờ: ' + err.message, 'text-danger');
                                } finally {
                                    btn.disabled = false;
                                    spinner.classList.add('d-none');
                                }
                            });
                        });
                    </script>
                    <jsp:include page="../common/footer.jsp" />

                </body>

                </html>
<%-- File: WEB-INF/views/student/essay.jsp. Controller: StudentEssayController (GET /student/essay). Attributes: lesson, question, questions.
    Nop bai qua AJAX: POST /api/student/submit-essay-ocr (multipart: questionId, essayImage, studentAnswer) --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="Bài tập Tự luận" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />

                <nav class="navbar navbar-expand bg-white fixed-top shadow-sm border-bottom">
                    <div class="container-fluid px-4">
                        <a class="navbar-brand fw-bold text-primary" href="#">
                            <i class="bi bi-pencil-square me-2"></i>Luyện tập Tự luận
                        </a>
                        <div class="ms-auto d-flex align-items-center gap-4">
                            <div class="d-none d-md-block text-muted">Bài: <strong>
                                    <c:out value="${lesson.title}" />
                                </strong></div>
                            <a href="${pageContext.request.contextPath}/student/lesson?id=${lesson.lessonId}"
                                class="btn btn-outline-secondary btn-sm" data-confirm="true"
                                data-confirm-message="Thoát sẽ hủy bài làm hiện tại?">
                                <i class="bi bi-x-lg"></i> Thoát
                            </a>
                        </div>
                    </div>
                </nav>

                <div class="container" style="padding-top: calc(var(--navbar-h) + 2rem); padding-bottom: 2rem;">
                    <ui:flash />

                    <c:choose>
                        <c:when test="${empty question}">
                            <div class="card border-0 shadow-sm text-center py-5 mt-4">
                                <i class="bi bi-inbox display-3 text-muted mb-3 opacity-25"></i>
                                <h5 class="text-muted">Bài giảng này chưa có câu bài tập tự luận.</h5>
                                <div class="mt-3">
                                    <a href="${pageContext.request.contextPath}/student/lesson?id=${lesson.lessonId}"
                                        class="btn btn-primary">Quay lại bài giảng</a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:if test="${questions.size() > 1}">
                                <div class="d-flex flex-wrap gap-2 justify-content-center mt-2">
                                    <c:forEach var="qq" items="${questions}" varStatus="vs">
                                        <a class="btn btn-sm ${qq.questionId == question.questionId ? 'btn-primary' : 'btn-outline-primary'}"
                                            href="${pageContext.request.contextPath}/student/essay?lessonId=${lesson.lessonId}&questionId=${qq.questionId}">Câu ${vs.count}</a>
                                    </c:forEach>
                                </div>
                            </c:if>
                            <div class="row g-4 justify-content-center mt-2">
                                <%-- Đề bài --%>
                                    <div class="col-lg-10">
                                        <div class="card shadow-sm border-0 mb-4 position-relative">
                                            <c:if test="${question.aiGenerated}">
                                                <span class="position-absolute top-0 end-0 badge-ai mt-3 me-3"
                                                    style="font-size:.8rem;">
                                                    <i class="bi bi-stars"></i> Đề sinh bởi AI
                                                </span>
                                            </c:if>
                                            <div class="card-header bg-white py-3">
                                                <h5 class="mb-0 fw-bold"><i
                                                        class="bi bi-question-circle me-2 text-primary"></i>Đề bài</h5>
                                            </div>
                                            <div class="card-body p-4 latex-content fs-5" style="line-height:1.7;">
                                                <ui:rich-text value="${question.content}" />
                                            </div>
                                        </div>

                                        <%-- Form nộp bài --%>
                                            <div class="card shadow-sm border-0">
                                                <div class="card-header bg-white py-3">
                                                    <h5 class="mb-0 fw-bold"><i
                                                            class="bi bi-journal-text me-2 text-primary"></i>Nộp bài làm
                                                    </h5>
                                                </div>
                                                <div class="card-body p-4">
                                                    <form enctype="multipart/form-data" novalidate id="essayForm">
                                                        <input type="hidden" name="questionId"
                                                            value="${question.questionId}">
                                                        <input type="hidden" name="lessonId" value="${lesson.lessonId}">

                                                        <div class="mb-4">
                                                            <label class="form-label fw-semibold">Cách 1: Nhập lời giải
                                                                trực tiếp</label>
                                                            <div class="essay-math-bar" role="toolbar" aria-label="Ký hiệu toán">
                                                                <button type="button" class="essay-math-btn" data-tex="x^{2}" data-back="0" title="Bình phương">x²</button>
                                                                <button type="button" class="essay-math-btn" data-tex="x_{1}" data-back="0" title="Chỉ số dưới">xₙ</button>
                                                                <button type="button" class="essay-math-btn" data-tex="\sqrt{}" data-back="2" title="Căn bậc hai">√</button>
                                                                <button type="button" class="essay-math-btn" data-tex="\frac{}{}" data-back="4" title="Phân số">a⁄b</button>
                                                                <button type="button" class="essay-math-btn" data-tex="\int_{}^{}" data-back="5" title="Tích phân">∫</button>
                                                                <button type="button" class="essay-math-btn" data-tex="\lim_{x \to }" data-back="2" title="Giới hạn">lim</button>
                                                                <button type="button" class="essay-math-btn" data-tex="\pi" data-back="0" title="Pi">π</button>
                                                                <button type="button" class="essay-math-btn" data-tex="\leq" data-back="0" title="Nhỏ hơn hoặc bằng">≤</button>
                                                                <button type="button" class="essay-math-btn" data-tex="\geq" data-back="0" title="Lớn hơn hoặc bằng">≥</button>
                                                                <button type="button" class="essay-math-btn" data-tex="\neq" data-back="0" title="Khác">≠</button>
                                                                <button type="button" class="essay-math-btn" data-tex="\infty" data-back="0" title="Vô cực">∞</button>
                                                            </div>
                                                            <textarea class="form-control" name="studentAnswer" id="essayAnswer" rows="8"
                                                                placeholder="Trình bày lời giải của bạn tại đây. Có thể dùng LaTeX, ví dụ $x^2$..."></textarea>
                                                            <div class="form-text">Công thức đặt giữa hai dấu <code>$</code>, ví dụ <code>$x^2$</code> (dùng <code>$$</code> để căn giữa dòng).</div>
                                                            <div id="essayMathPreview" class="essay-math-preview latex-content" style="white-space:pre-wrap;" hidden></div>
                                                        </div>

                                                        <div class="mb-4">
                                                            <label class="form-label fw-semibold">Cách 2: Chụp ảnh bài
                                                                làm (Chỉ 1 ảnh PNG/JPG, tối đa 5MB)</label>
                                                            <div class="dropzone" id="essayDropzone">
                                                                <i
                                                                    class="bi bi-cloud-arrow-up display-4 text-muted mb-2"></i>
                                                                <p class="mb-1 fw-bold fs-5 text-muted">Kéo thả ảnh vào
                                                                    đây</p>
                                                                <p class="text-muted small">hoặc click để chọn file</p>
                                                                <%-- VAL-18: JPG / PNG / WebP ≤ 5MB, ≤ 4096×4096; capture mở camera sau trên điện thoại --%>
                                                                <input type="file" name="essayImage" id="essayImageFile"
                                                                    accept="image/jpeg,image/png,image/webp" capture="environment"
                                                                    style="display:none;" />
                                                                <div id="imagePreview" style="display:none;"
                                                                    class="mt-3">
                                                                    <img src="" class="img-thumbnail"
                                                                        style="max-height:200px;" alt="Preview">
                                                                    <button type="button"
                                                                        class="btn btn-sm btn-outline-danger mt-2 d-block mx-auto"
                                                                        id="btnRemoveImg">
                                                                        Xóa ảnh
                                                                    </button>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="alert alert-info py-2" style="font-size:0.9rem;">
                                                            <i class="bi bi-info-circle me-1"></i> Gemini AI sẽ nhận diện chữ viết tay và
                                                            chấm điểm ngay (thang 10); giáo viên có thể điều chỉnh sau.
                                                        </div>

                                                        <div class="text-end">
                                                            <button type="submit" class="btn btn-primary btn-lg px-5" id="btnSubmitEssay">
                                                                <i class="bi bi-send me-2"></i>Nộp bài
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>

                                        <%-- Ket qua cham AI --%>
                                            <div id="essayLoading" class="card border-0 shadow-sm mt-4 d-none">
                                                <div class="card-body text-center py-5">
                                                    <div class="spinner-border text-primary" role="status"
                                                        style="width:2.5rem;height:2.5rem;"></div>
                                                    <p class="mt-3 mb-0 fw-semibold text-muted">Gemini AI đang đọc và chấm bài của bạn...</p>
                                                    <small class="text-muted">Quá trình này mất khoảng 5 - 15 giây</small>
                                                </div>
                                            </div>
                                            <div id="essayError" class="alert alert-danger mt-4 d-none" role="alert"></div>
                                            <div id="essayResult" class="card border-0 shadow-sm mt-4 d-none">
                                                <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                                    <h5 class="mb-0 fw-bold"><i class="bi bi-robot me-2 text-ai"></i>Kết quả chấm AI</h5>
                                                    <span class="badge bg-primary fs-6" id="essayScore"></span>
                                                </div>
                                                <div class="card-body p-4">
                                                    <%-- BR-09: điểm AI chỉ là điểm tạm thời --%>
                                                    <div class="alert alert-warning py-2 small">
                                                        <i class="bi bi-hourglass-split me-1"></i><strong>Điểm tạm thời</strong> — chờ giáo viên xác nhận.
                                                    </div>
                                                    <h6 class="fw-bold">Nội dung nhận diện</h6>
                                                    <div class="p-3 bg-light rounded latex-content mb-4" id="essayExtracted" style="white-space:pre-wrap;"></div>
                                                    <h6 class="fw-bold">Nhận xét chi tiết</h6>
                                                    <div class="p-3 bg-light rounded latex-content mb-3" id="essayFeedback" style="white-space:pre-wrap;"></div>
                                                    <div id="essayErrorsWrap" class="mb-4 d-none">
                                                        <h6 class="fw-bold text-danger">Các lỗi sai</h6>
                                                        <ul class="list-group latex-content" id="essayErrors"></ul>
                                                    </div>
                                                    <h6 class="fw-bold">Lời giải đúng gợi ý</h6>
                                                    <div class="p-3 bg-light rounded latex-content mb-3" id="essayCorrection" style="white-space:pre-wrap;"></div>
                                                    <%-- FR-OCR-04: mở gia sư AI từ bài tự luận vừa chấm (href gán sau khi chấm xong) --%>
                                                    <a href="#" id="btnAskTutor" class="btn btn-ai btn-sm me-2">
                                                        <i class="bi bi-robot me-1"></i>Hỏi gia sư AI về lỗi sai</a>
                                                    <a href="${pageContext.request.contextPath}/student/history?type=ESSAY"
                                                        class="btn btn-outline-primary btn-sm">Xem lịch sử bài tự luận</a>
                                                </div>
                                            </div>
                                    </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <jsp:include page="../common/footer.jsp" />
                <style>
                    .essay-math-bar { display:flex; gap:.4rem; flex-wrap:wrap; margin-bottom:.5rem; }
                    .essay-math-btn { padding:.2rem .65rem; border:0; border-radius:8px; cursor:pointer; background:#f1f5f9; color:#334155; font-size:.9rem; line-height:1.5; transition:background .15s,color .15s; }
                    .essay-math-btn:hover { background:#e0e7ff; color:#4338ca; }
                    .essay-math-preview { margin-top:.5rem; padding:.5rem .8rem; border-radius:10px; background:#f8fafc; border:1px dashed #cbd5e1; overflow-x:auto; }
                    .essay-math-preview[hidden] { display:none; }
                </style>
                <script>
                    // Thanh ký hiệu toán + xem trước LaTeX cho ô nhập lời giải
                    document.addEventListener('DOMContentLoaded', () => {
                        const ta = document.getElementById('essayAnswer');
                        const preview = document.getElementById('essayMathPreview');
                        if (!ta || !preview) return;
                        const MATH = {
                            delimiters: [
                                { left: '$$', right: '$$', display: true },
                                { left: '$', right: '$', display: false },
                                { left: '\\[', right: '\\]', display: true },
                                { left: '\\(', right: '\\)', display: false }
                            ],
                            throwOnError: false
                        };
                        let timer = null;
                        function update() {
                            clearTimeout(timer);
                            if (!ta.value.trim()) { preview.hidden = true; preview.textContent = ''; return; }
                            timer = setTimeout(() => {
                                preview.textContent = ta.value;
                                preview.hidden = false;
                                if (window.renderMathInElement) renderMathInElement(preview, MATH);
                            }, 300);
                        }
                        ta.addEventListener('input', update);
                        document.querySelectorAll('.essay-math-btn').forEach(btn => btn.addEventListener('click', () => {
                            const snippet = '$' + btn.dataset.tex + '$';
                            const back = parseInt(btn.dataset.back || '0', 10);
                            const s = ta.selectionStart, e = ta.selectionEnd;
                            ta.value = ta.value.slice(0, s) + snippet + ta.value.slice(e);
                            const pos = s + snippet.length - back;
                            ta.focus();
                            ta.setSelectionRange(pos, pos);
                            update();
                        }));
                    });
                </script>
                <script>
                    // Xử lý Custom Dropzone cho dạng tải ảnh
                    document.addEventListener('DOMContentLoaded', () => {
                        const dropzone = document.getElementById('essayDropzone');
                        const fileInput = document.getElementById('essayImageFile');
                        const previewWrap = document.getElementById('imagePreview');
                        const img = previewWrap?.querySelector('img');
                        const btnRemove = document.getElementById('btnRemoveImg');
                        const form = document.getElementById('essayForm');

                        if (dropzone && fileInput) {
                            dropzone.addEventListener('click', (e) => {
                                if (e.target !== btnRemove) {
                                    fileInput.click();
                                }
                            });

                            dropzone.addEventListener('dragover', (e) => {
                                e.preventDefault();
                                dropzone.classList.add('dragover');
                            });

                            dropzone.addEventListener('dragleave', () => {
                                dropzone.classList.remove('dragover');
                            });

                            dropzone.addEventListener('drop', (e) => {
                                e.preventDefault();
                                dropzone.classList.remove('dragover');
                                if (e.dataTransfer.files.length) {
                                    fileInput.files = e.dataTransfer.files;
                                    handlePreview();
                                }
                            });

                            fileInput.addEventListener('change', handlePreview);

                            btnRemove?.addEventListener('click', (e) => {
                                e.stopPropagation();
                                fileInput.value = '';
                                previewWrap.style.display = 'none';
                            });

                            function handlePreview() {
                                if (fileInput.files && fileInput.files[0]) {
                                    const file = fileInput.files[0];
                                    if (file.size > 5 * 1024 * 1024) {
                                        alert('Kích thước ảnh vượt quá 5MB.');
                                        fileInput.value = '';
                                        return;
                                    }
                                    const reader = new FileReader();
                                    reader.onload = (e) => {
                                        img.src = e.target.result;
                                        previewWrap.style.display = 'block';
                                    };
                                    reader.readAsDataURL(file);
                                }
                            }

                            // Thu nhỏ ảnh (cạnh dài <= 1600px, JPEG) trước khi gửi để upload + AI xử lý nhanh hơn
                            async function shrinkImage(file) {
                                const MAX = 1600;
                                try {
                                    const bmp = await createImageBitmap(file);
                                    const ratio = Math.min(1, MAX / Math.max(bmp.width, bmp.height));
                                    if (ratio === 1 && file.size < 800 * 1024) return file;
                                    const canvas = document.createElement('canvas');
                                    canvas.width = Math.round(bmp.width * ratio);
                                    canvas.height = Math.round(bmp.height * ratio);
                                    const ctx = canvas.getContext('2d');
                                    ctx.fillStyle = '#fff';
                                    ctx.fillRect(0, 0, canvas.width, canvas.height);
                                    ctx.drawImage(bmp, 0, 0, canvas.width, canvas.height);
                                    const blob = await new Promise(r => canvas.toBlob(r, 'image/jpeg', 0.85));
                                    if (!blob || blob.size >= file.size) return file;
                                    return new File([blob], file.name.replace(/\.\w+$/, '') + '.jpg', { type: 'image/jpeg' });
                                } catch (err) {
                                    return file;
                                }
                            }

                            form.addEventListener('submit', async (e) => {
                                e.preventDefault();
                                const text = form.querySelector('textarea').value.trim();
                                const hasFile = fileInput.files.length > 0;
                                if (text === '' && !hasFile) {
                                    alert('Vui lòng nhập lời giải hoặc tải ảnh lên.');
                                    return;
                                }
                                const btn = document.getElementById('btnSubmitEssay');
                                const loading = document.getElementById('essayLoading');
                                const errBox = document.getElementById('essayError');
                                const resultBox = document.getElementById('essayResult');
                                errBox.classList.add('d-none');
                                resultBox.classList.add('d-none');
                                loading.classList.remove('d-none');
                                btn.disabled = true;

                                const fd = new FormData();
                                fd.append('questionId', form.querySelector('[name=questionId]').value);
                                if (text) fd.append('studentAnswer', text);
                                if (hasFile) {
                                    const small = await shrinkImage(fileInput.files[0]);
                                    fd.append('essayImage', small, small.name || fileInput.files[0].name);
                                }

                                try {
                                    const res = await csrfFetch(document.body.dataset.ctx + '/api/student/submit-essay-ocr', {
                                        method: 'POST',
                                        headers: { 'Accept': 'application/json' },
                                        body: fd
                                    });
                                    const data = await res.json().catch(() => ({ success: false, message: 'Phản hồi không hợp lệ (HTTP ' + res.status + ').' }));
                                    loading.classList.add('d-none');
                                    if (!res.ok || !data.success) {
                                        errBox.textContent = data.message || 'Không thể chấm bài. Vui lòng thử lại.';
                                        errBox.classList.remove('d-none');
                                    } else {
                                        document.getElementById('essayScore').textContent = data.data.score + ' / 10';
                                        document.getElementById('essayExtracted').textContent = data.data.extractedText || '(không có)';
                                        document.getElementById('essayFeedback').textContent = data.data.detailedFeedback || '';
                                        document.getElementById('essayCorrection').textContent = data.data.suggestedCorrection || '';
                                        // Danh sách lỗi sai (chèn bằng textContent, không dùng innerHTML)
                                        const errList = document.getElementById('essayErrors');
                                        errList.textContent = '';
                                        (data.data.errors || []).forEach(e => {
                                            const li = document.createElement('li');
                                            li.className = 'list-group-item';
                                            if (e.location) {
                                                const loc = document.createElement('strong');
                                                loc.textContent = e.location + ': ';
                                                li.appendChild(loc);
                                            }
                                            li.appendChild(document.createTextNode(e.description || ''));
                                            errList.appendChild(li);
                                        });
                                        document.getElementById('essayErrorsWrap').classList.toggle('d-none', !(data.data.errors || []).length);
                                        document.getElementById('btnAskTutor').classList.toggle('d-none', !data.data.canAskTutor);
                                        document.getElementById('btnAskTutor').href = document.body.dataset.ctx
                                            + '/student/ai-tutor?mode=SUBMISSION&submissionId=' + encodeURIComponent(data.data.submissionId);
                                        resultBox.classList.remove('d-none');
                                        if (window.renderMathInElement) {
                                            renderMathInElement(resultBox, {
                                                delimiters: [
                                                    { left: '$$', right: '$$', display: true },
                                                    { left: '$', right: '$', display: false }
                                                ],
                                                throwOnError: false
                                            });
                                        }
                                        resultBox.scrollIntoView({ behavior: 'smooth', block: 'start' });
                                    }
                                } catch (err) {
                                    loading.classList.add('d-none');
                                    errBox.textContent = 'Mất kết nối tới máy chủ: ' + err.message;
                                    errBox.classList.remove('d-none');
                                } finally {
                                    btn.disabled = false;
                                }
                            });
                        }
                    });
                </script>
                <style>
                    body {
                        background-color: #f3f6f9;
                    }
                </style>
            </body>

            </html>
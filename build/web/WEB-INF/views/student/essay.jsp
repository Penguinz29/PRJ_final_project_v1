<%-- File: WEB-INF/views/student/essay.jsp Servlet: StudentEssayServlet (/student/essay) Attributes: lesson(Lesson),
    question(Question) - 1 câu tự luận ngẫu nhiên/hoặc theo ID POST action: /student/essaySubmit (text answer + image
    upload) --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
                    <jsp:include page="../common/flash.jsp" />

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
                                                <c:out value="${question.content}" />
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
                                                    <form
                                                        action="${pageContext.request.contextPath}/student/essaySubmit"
                                                        method="post" enctype="multipart/form-data"
                                                        class="needs-validation" novalidate id="essayForm">
                                                        <input type="hidden" name="questionId"
                                                            value="${question.questionId}">
                                                        <input type="hidden" name="lessonId" value="${lesson.lessonId}">

                                                        <div class="mb-4">
                                                            <label class="form-label fw-semibold">Cách 1: Nhập lời giải
                                                                trực tiếp</label>
                                                            <textarea class="form-control" name="studentAnswer" rows="8"
                                                                placeholder="Trình bày lời giải của bạn tại đây..."></textarea>
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
                                                                <input type="file" name="essayImage" id="essayImageFile"
                                                                    accept="image/jpeg, image/png"
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
                                                            <i class="bi bi-info-circle me-1"></i> Sau khi nộp, giáo
                                                            viên sẽ chấm điểm và phản hồi.
                                                        </div>

                                                        <div class="text-end">
                                                            <button type="submit" class="btn btn-primary btn-lg px-5">
                                                                <i class="bi bi-send me-2"></i>Nộp bài
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                    </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <jsp:include page="../common/footer.jsp" />
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

                            form.addEventListener('submit', (e) => {
                                const text = form.querySelector('textarea').value.trim();
                                const file = fileInput.files.length;
                                if (text === '' && file === 0) {
                                    e.preventDefault();
                                    alert('Vui lòng nhập lời giải hoặc tải ảnh lên báo cáo.');
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
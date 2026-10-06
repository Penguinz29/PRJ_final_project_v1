<%-- File: WEB-INF/views/student/lesson.jsp Servlet: StudentLessonServlet (/student/lesson) Attributes: lesson(Lesson)
    --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <jsp:include page="../common/head.jsp">
                <jsp:param name="title" value="${lesson.title}" />
            </jsp:include>

            <body data-ctx="${pageContext.request.contextPath}">
                <jsp:include page="../common/navbar.jsp" />
                <div class="app-shell">
                    <jsp:include page="../common/sidebar.jsp">
                        <jsp:param name="active" value="student-topics" />
                    </jsp:include>
                    <main class="app-main">
                        <ui:flash />

                        <div class="page-header mb-3">
                            <div>
                                <nav aria-label="breadcrumb">
                                    <ol class="breadcrumb mb-1" style="font-size:.85rem;">
                                        <li class="breadcrumb-item"><a
                                                href="${pageContext.request.contextPath}/student/topics"
                                                class="text-decoration-none">Chủ đề</a></li>
                                        <li class="breadcrumb-item active" aria-current="page">
                                            <c:out value="${lesson.topicName}" />
                                        </li>
                                    </ol>
                                </nav>
                                <h1 class="mb-2">
                                    <c:out value="${lesson.title}" />
                                </h1>
                                <p class="text-muted">
                                    <c:out value="${lesson.summary}" />
                                </p>
                            </div>

                            <div class="d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/student/quiz?lessonId=${lesson.lessonId}"
                                    class="btn btn-primary d-flex align-items-center">
                                    <i class="bi bi-joystick me-2"></i>Làm trắc nghiệm
                                </a>
                                <a href="${pageContext.request.contextPath}/student/essay?lessonId=${lesson.lessonId}"
                                    class="btn btn-outline-primary d-flex align-items-center">
                                    <i class="bi bi-pencil-square me-2"></i>Làm tự luận
                                </a>
                            </div>
                        </div>

                        <c:set var="hasMaterials" value="${not empty materials}" />
                        <c:set var="materialsFirst" value="${hasMaterials and empty lesson.content}" />

                        <div class="row g-4">
                            <div class="${hasMaterials ? 'col-lg-9' : 'col-12 col-xl-10'}">
                                <%-- Hai tab: Lý thuyết / Bài giảng, để lý thuyết dài không đẩy video xuống tận cuối trang --%>
                                <c:if test="${hasMaterials}">
                                    <ul class="nav nav-tabs mb-3" id="lessonTabs" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link ${materialsFirst ? '' : 'active'}" id="tab-theory"
                                                data-bs-toggle="tab" data-bs-target="#pane-theory" type="button"
                                                role="tab" aria-controls="pane-theory"
                                                aria-selected="${materialsFirst ? 'false' : 'true'}">
                                                <i class="bi bi-book-half me-1"></i>Lý thuyết
                                            </button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link ${materialsFirst ? 'active' : ''}" id="tab-materials"
                                                data-bs-toggle="tab" data-bs-target="#pane-materials" type="button"
                                                role="tab" aria-controls="pane-materials"
                                                aria-selected="${materialsFirst ? 'true' : 'false'}">
                                                <i class="bi bi-collection-play me-1"></i>Bài giảng
                                                <span class="badge bg-primary ms-1">${materials.size()}</span>
                                            </button>
                                        </li>
                                    </ul>
                                </c:if>

                                <div class="tab-content">
                                    <%-- Tab Lý thuyết --%>
                                    <div class="tab-pane fade ${materialsFirst ? '' : 'show active'}" id="pane-theory"
                                        role="tabpanel" aria-labelledby="tab-theory" tabindex="0">
                                        <div class="card shadow-sm border-0 mb-4">
                                            <div class="card-header bg-white py-3">
                                                <i class="bi bi-book-half me-2 text-primary"></i>Nội dung lý thuyết
                                            </div>
                                            <div class="card-body p-4 latex-content" style="font-size:1rem;line-height:1.7;">
                                                <ui:rich-text value="${lesson.content}" />
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Tab Bài giảng: YouTube / video / liên kết / văn bản (lesson_materials) --%>
                                    <c:if test="${hasMaterials}">
                                        <div class="tab-pane fade ${materialsFirst ? 'show active' : ''}" id="pane-materials"
                                            role="tabpanel" aria-labelledby="tab-materials" tabindex="0">
                                            <c:forEach var="m" items="${materials}" varStatus="vs">
                                                <div class="card shadow-sm border-0 mb-4" id="material-${m.materialId}"
                                                    style="scroll-margin-top:calc(var(--navbar-h) + 1rem);">
                                                    <div class="card-header bg-white py-3 fw-semibold">
                                                        <span class="text-muted me-1">${vs.count}.</span>
                                                        <c:out value="${m.title}" />
                                                    </div>
                                                    <div class="card-body p-4">
                                                        <c:choose>
                                                            <c:when test="${m.materialType == 'YOUTUBE' and not empty m.youtubeEmbedUrl}">
                                                                <div class="ratio ratio-16x9">
                                                                    <iframe src="${m.youtubeEmbedUrl}" title="<c:out value='${m.title}'/>"
                                                                        allow="accelerometer; encrypted-media; gyroscope; picture-in-picture; web-share"
                                                                        referrerpolicy="strict-origin-when-cross-origin" loading="lazy"
                                                                        allowfullscreen class="rounded"></iframe>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${m.materialType == 'VIDEO'}">
                                                                <video controls preload="metadata" class="w-100 rounded"
                                                                    src="<c:out value='${m.url}'/>">
                                                                    Trình duyệt không hỗ trợ phát video.
                                                                </video>
                                                            </c:when>
                                                            <c:when test="${m.materialType == 'LINK'}">
                                                                <a href="<c:out value='${m.url}'/>" target="_blank"
                                                                    rel="noopener noreferrer" class="btn btn-outline-primary">
                                                                    <i class="bi bi-box-arrow-up-right me-2"></i>Mở liên kết
                                                                </a>
                                                                <div class="small text-muted mt-1 text-break"><c:out value="${m.url}" /></div>
                                                            </c:when>
                                                            <c:when test="${m.materialType == 'TEXT'}">
                                                                <div class="latex-content" style="white-space:pre-wrap;line-height:1.7;"><ui:rich-text value="${m.contentText}" /></div>
                                                            </c:when>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:if>
                                </div>
                            </div>

                            <%-- Mục lục dính bên phải (chỉ trên màn hình lớn): bấm để nhảy tới đúng bài giảng --%>
                            <c:if test="${hasMaterials}">
                                <div class="col-lg-3 d-none d-lg-block">
                                    <div class="card shadow-sm border-0"
                                        style="position:sticky;top:calc(var(--navbar-h) + 1rem);max-height:calc(100vh - var(--navbar-h) - 2rem);overflow:auto;">
                                        <div class="card-header bg-white py-3 fw-semibold">
                                            <i class="bi bi-list-ul me-2 text-primary"></i>Mục lục
                                        </div>
                                        <div class="list-group list-group-flush" id="lessonToc">
                                            <a href="#pane-theory" class="list-group-item list-group-item-action"
                                                data-tab="#tab-theory" data-target="#pane-theory">
                                                <i class="bi bi-book-half me-2 text-primary"></i>Lý thuyết
                                            </a>
                                            <c:forEach var="m" items="${materials}" varStatus="vs">
                                                <a href="#material-${m.materialId}" class="list-group-item list-group-item-action"
                                                    data-tab="#tab-materials" data-target="#material-${m.materialId}">
                                                    <c:choose>
                                                        <c:when test="${m.materialType == 'YOUTUBE'}"><i class="bi bi-youtube me-2 text-danger"></i></c:when>
                                                        <c:when test="${m.materialType == 'VIDEO'}"><i class="bi bi-film me-2"></i></c:when>
                                                        <c:when test="${m.materialType == 'LINK'}"><i class="bi bi-link-45deg me-2 text-info"></i></c:when>
                                                        <c:otherwise><i class="bi bi-text-paragraph me-2 text-success"></i></c:otherwise>
                                                    </c:choose>
                                                    <c:out value="${m.title}" />
                                                </a>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </main>
                </div>
                <jsp:include page="../common/footer.jsp" />
                <script>
                    document.addEventListener('DOMContentLoaded', function () {
                        var toc = document.getElementById('lessonToc');
                        if (!toc || !window.bootstrap) return;

                        // Mở tab chứa phần tử rồi cuộn tới đó
                        function go(tabSel, targetSel) {
                            var tabBtn = document.querySelector(tabSel);
                            var target = document.querySelector(targetSel);
                            function scroll() {
                                if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                            }
                            if (tabBtn && !tabBtn.classList.contains('active')) {
                                tabBtn.addEventListener('shown.bs.tab', scroll, { once: true });
                                bootstrap.Tab.getOrCreateInstance(tabBtn).show();
                            } else {
                                scroll();
                            }
                        }

                        toc.querySelectorAll('a[data-tab]').forEach(function (a) {
                            a.addEventListener('click', function (e) {
                                e.preventDefault();
                                history.replaceState(null, '', a.getAttribute('href'));
                                go(a.dataset.tab, a.dataset.target);
                            });
                        });

                        // Mở thẳng bài giảng khi URL có #material-xx hoặc #pane-materials
                        var hash = window.location.hash;
                        if (hash.indexOf('#material-') === 0 || hash === '#pane-materials') {
                            go('#tab-materials', hash);
                        }
                    });
                </script>
            </body>

            </html>
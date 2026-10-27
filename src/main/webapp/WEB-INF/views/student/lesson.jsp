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
                                    <a href="${pageContext.request.contextPath}/student/topics"
                                        class="btn btn-outline-secondary d-flex align-items-center">
                                        <i class="bi bi-arrow-left me-2"></i>Quay lại
                                    </a>
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
                                    <%-- Hai tab: Lý thuyết / Bài giảng, để lý thuyết dài không đẩy video xuống tận cuối
                                        trang --%>
                                        <c:if test="${hasMaterials}">
                                            <ul class="nav nav-tabs mb-3" id="lessonTabs" role="tablist">
                                                <li class="nav-item" role="presentation">
                                                    <button class="nav-link ${materialsFirst ? '' : 'active'}"
                                                        id="tab-theory" data-bs-toggle="tab"
                                                        data-bs-target="#pane-theory" type="button" role="tab"
                                                        aria-controls="pane-theory"
                                                        aria-selected="${materialsFirst ? 'false' : 'true'}">
                                                        <i class="bi bi-book-half me-1"></i>Lý thuyết
                                                    </button>
                                                </li>
                                                <li class="nav-item" role="presentation">
                                                    <button class="nav-link ${materialsFirst ? 'active' : ''}"
                                                        id="tab-materials" data-bs-toggle="tab"
                                                        data-bs-target="#pane-materials" type="button" role="tab"
                                                        aria-controls="pane-materials"
                                                        aria-selected="${materialsFirst ? 'true' : 'false'}">
                                                        <i class="bi bi-collection-play me-1"></i>Bài giảng
                                                        <span class="badge bg-primary ms-1">${materials.size()}</span>
                                                    </button>
                                                </li>
                                            </ul>
                                        </c:if>

                                        <div class="tab-content">
                                            <%-- Tab Lý thuyết --%>
                                                <div class="tab-pane fade ${materialsFirst ? '' : 'show active'}"
                                                    id="pane-theory" role="tabpanel" aria-labelledby="tab-theory"
                                                    tabindex="0">
                                                    <div class="card shadow-sm border-0 mb-4">
                                                        <div class="card-header bg-white py-3">
                                                            <i class="bi bi-book-half me-2 text-primary"></i>Nội dung lý
                                                            thuyết
                                                        </div>
                                                        <div class="card-body p-4 latex-content"
                                                            style="font-size:1rem;line-height:1.7;">
                                                            <ui:rich-text value="${lesson.content}" />
                                                        </div>
                                                    </div>
                                                </div>

                                                <%-- Tab Bài giảng: YouTube / video / liên kết / văn bản
                                                    (lesson_materials) --%>
                                                    <c:if test="${hasMaterials}">
                                                        <div class="tab-pane fade ${materialsFirst ? 'show active' : ''}"
                                                            id="pane-materials" role="tabpanel"
                                                            aria-labelledby="tab-materials" tabindex="0">
                                                            <c:forEach var="m" items="${materials}" varStatus="vs">
                                                                <div class="card shadow-sm border-0 mb-4"
                                                                    id="material-${m.materialId}"
                                                                    style="scroll-margin-top:calc(var(--navbar-h) + 1rem);">
                                                                    <div class="card-header bg-white py-3 fw-semibold">
                                                                        <span
                                                                            class="text-muted me-1">${vs.count}.</span>
                                                                        <c:out value="${m.title}" />
                                                                    </div>
                                                                    <div class="card-body p-4">
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${m.materialType == 'YOUTUBE'}">
                                                                                <div class="youtube-player-container"
                                                                                    data-url="<c:out value='${not empty m.youtubeEmbedUrl ? m.youtubeEmbedUrl : m.url}'/>"
                                                                                    data-title="<c:out value='${m.title}'/>">
                                                                                    <div
                                                                                        class="ratio ratio-16x9 rounded-3 shadow-sm overflow-hidden youtube-player-wrapper border">
                                                                                        <iframe
                                                                                            src="${not empty m.youtubeEmbedUrl ? m.youtubeEmbedUrl : ''}"
                                                                                            title="<c:out value='${m.title}'/>"
                                                                                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                                                                                            referrerpolicy="strict-origin-when-cross-origin"
                                                                                            loading="lazy"
                                                                                            allowfullscreen
                                                                                            class="w-100 h-100 border-0 rounded-3"></iframe>
                                                                                    </div>
                                                                                    <c:if test="${not empty m.url}">
                                                                                        <div
                                                                                            class="youtube-player-meta mt-2 pt-1 d-flex align-items-center justify-content-between flex-wrap gap-2">
                                                                                            <a href="<c:out value='${m.url}'/>"
                                                                                                target="_blank"
                                                                                                rel="noopener noreferrer"
                                                                                                class="btn btn-sm btn-outline-danger d-inline-flex align-items-center">
                                                                                                <i
                                                                                                    class="bi bi-youtube me-1"></i>Xem
                                                                                                trên YouTube
                                                                                            </a>
                                                                                        </div>
                                                                                    </c:if>
                                                                                </div>
                                                                            </c:when>
                                                                            <c:when test="${m.materialType == 'VIDEO'}">
                                                                                <video controls preload="metadata"
                                                                                    class="w-100 rounded-3 shadow-sm border"
                                                                                    src="<c:out value='${m.url}'/>">
                                                                                    Trình duyệt không hỗ trợ phát video.
                                                                                </video>
                                                                            </c:when>
                                                                            <c:when test="${m.materialType == 'LINK'}">
                                                                                <div class="material-link-container"
                                                                                    data-url="<c:out value='${m.url}'/>"
                                                                                    data-title="<c:out value='${m.title}'/>">
                                                                                    <div class="link-standard-view">
                                                                                        <a href="<c:out value='${m.url}'/>"
                                                                                            target="_blank"
                                                                                            rel="noopener noreferrer"
                                                                                            class="btn btn-outline-primary">
                                                                                            <i
                                                                                                class="bi bi-box-arrow-up-right me-2"></i>Mở
                                                                                            liên kết
                                                                                        </a>
                                                                                        <div
                                                                                            class="small text-muted mt-2 text-break">
                                                                                            <c:out value="${m.url}" />
                                                                                        </div>
                                                                                    </div>
                                                                                </div>
                                                                            </c:when>
                                                                            <c:when test="${m.materialType == 'TEXT'}">
                                                                                <div class="latex-content" style="white-space:pre-line;line-height:1.8;"><ui:rich-text value="${m.contentText}" /></div>
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
                                                    <a href="#pane-theory"
                                                        class="list-group-item list-group-item-action"
                                                        data-tab="#tab-theory" data-target="#pane-theory">
                                                        <i class="bi bi-book-half me-2 text-primary"></i>Lý thuyết
                                                    </a>
                                                    <c:forEach var="m" items="${materials}" varStatus="vs">
                                                        <a href="#material-${m.materialId}"
                                                            class="list-group-item list-group-item-action"
                                                            data-tab="#tab-materials"
                                                            data-target="#material-${m.materialId}">
                                                            <c:choose>
                                                                <c:when test="${m.materialType == 'YOUTUBE'}"><i
                                                                        class="bi bi-youtube me-2 text-danger"></i>
                                                                </c:when>
                                                                <c:when test="${m.materialType == 'VIDEO'}"><i
                                                                        class="bi bi-film me-2"></i></c:when>
                                                                <c:when test="${m.materialType == 'LINK'}"><i
                                                                        class="bi bi-link-45deg me-2 text-info"></i>
                                                                </c:when>
                                                                <c:otherwise><i
                                                                        class="bi bi-text-paragraph me-2 text-success"></i>
                                                                </c:otherwise>
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
                            // 1. YouTube Video Embed Player Refactoring
                            function extractYouTubeVideoId(url) {
                                if (!url || typeof url !== 'string') return null;
                                var trimmed = url.trim();
                                var match = trimmed.match(/(?:https?:)?(?:\/\/)?(?:www\.|m\.)?(?:youtube\.com\/(?:watch\?(?:.*&)?v=|embed\/|v\/|shorts\/|live\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/i);
                                if (match && match[1]) return match[1];
                                try {
                                    var parsed = new URL(trimmed.indexOf('://') === -1 ? 'https://' + trimmed : trimmed);
                                    var v = parsed.searchParams.get('v');
                                    if (v && /^[a-zA-Z0-9_-]{11}$/.test(v)) return v;
                                } catch (e) { }
                                return null;
                            }

                            function buildYouTubeEmbedUrl(url, videoId) {
                                var embedUrl = 'https://www.youtube.com/embed/' + videoId + '?rel=0';
                                try {
                                    var parsed = new URL(url.indexOf('://') === -1 ? 'https://' + url : url);
                                    var t = parsed.searchParams.get('t') || parsed.searchParams.get('start');
                                    if (t) {
                                        var seconds = parseInt(t, 10);
                                        if (!isNaN(seconds) && seconds > 0) {
                                            embedUrl += '&start=' + seconds;
                                        }
                                    }
                                } catch (e) { }
                                return embedUrl;
                            }

                            function escapeHtml(str) {
                                if (!str) return '';
                                return str.replace(/&/g, '&amp;')
                                    .replace(/</g, '&lt;')
                                    .replace(/>/g, '&gt;')
                                    .replace(/"/g, '&quot;')
                                    .replace(/'/g, '&#39;');
                            }

                            function initYouTubeEmbeds() {
                                var containers = document.querySelectorAll('.youtube-player-container, .material-link-container');
                                containers.forEach(function (container) {
                                    var rawUrl = container.getAttribute('data-url');
                                    if (!rawUrl) return;

                                    var videoId = extractYouTubeVideoId(rawUrl);
                                    if (!videoId) return;

                                    var embedUrl = buildYouTubeEmbedUrl(rawUrl, videoId);
                                    var title = container.getAttribute('data-title') || 'Video bài giảng';

                                    var existingIframe = container.querySelector('iframe');
                                    if (existingIframe) {
                                        var src = existingIframe.getAttribute('src');
                                        if (!src || src.indexOf('youtube.com/embed/') === -1) {
                                            existingIframe.setAttribute('src', embedUrl);
                                        }
                                    } else {
                                        container.innerHTML =
                                            '<div class="ratio ratio-16x9 rounded-3 shadow-sm overflow-hidden youtube-player-wrapper border">' +
                                            '<iframe src="' + embedUrl + '" title="' + escapeHtml(title) + '" ' +
                                            'allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" ' +
                                            'referrerpolicy="strict-origin-when-cross-origin" loading="lazy" ' +
                                            'allowfullscreen class="w-100 h-100 border-0 rounded-3"></iframe>' +
                                            '</div>' +
                                            '<div class="youtube-player-meta mt-2 pt-1 d-flex align-items-center justify-content-between flex-wrap gap-2">' +
                                            '<a href="' + escapeHtml(rawUrl) + '" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-outline-danger d-inline-flex align-items-center">' +
                                            '<i class="bi bi-youtube me-1"></i>Xem trên YouTube' +
                                            '</a>' +
                                            '</div>';
                                    }

                                    // Cập nhật icon YouTube trong Mục lục (TOC) nếu ban đầu được xếp vào mục liên kết
                                    var card = container.closest('[id^="material-"]');
                                    if (card && card.id) {
                                        var tocLink = document.querySelector('#lessonToc a[href="#' + card.id + '"]');
                                        if (tocLink) {
                                            var icon = tocLink.querySelector('i');
                                            if (icon && !icon.classList.contains('bi-youtube')) {
                                                icon.className = 'bi bi-youtube me-2 text-danger';
                                            }
                                        }
                                    }
                                });
                            }

                            // Khởi chạy YouTube Embed Parser
                            initYouTubeEmbeds();

                            // 2. KaTeX Math Render & Preprocessing
                            var MATH_CONFIG = {
                                delimiters: [
                                    { left: '$$', right: '$$', display: true },
                                    { left: '$', right: '$', display: false },
                                    { left: '\\[', right: '\\]', display: true },
                                    { left: '\\(', right: '\\)', display: false }
                                ],
                                ignoredClasses: ['katex', 'katex-html', 'katex-mathml', 'katex-display'],
                                throwOnError: false
                            };

                            function processTextNodes(node, callback) {
                                if (node.nodeType === Node.TEXT_NODE) {
                                    callback(node);
                                } else if (node.nodeType === Node.ELEMENT_NODE) {
                                    if (node.tagName === 'SCRIPT' || node.tagName === 'STYLE' || node.classList.contains('katex') || node.classList.contains('katex-error')) {
                                        return;
                                    }
                                    var children = Array.from(node.childNodes);
                                    children.forEach(function (child) {
                                        processTextNodes(child, callback);
                                    });
                                }
                            }

                            function preprocessMathText(text) {
                                if (!text || typeof text !== 'string') return text;

                                function transformNonMath(str, fn) {
                                    var tokens = str.split(/(\$\$[\s\S]*?\$\$|\$[^$\n]*?\$|\\\[[\s\S]*?\\\]|\\\([\s\S]*?\\\))/g);
                                    for (var i = 0; i < tokens.length; i += 2) {
                                        if (tokens[i]) {
                                            tokens[i] = fn(tokens[i]);
                                        }
                                    }
                                    return tokens.join('');
                                }

                                text = text.replace(/&gt;/g, '>').replace(/&lt;/g, '<');

                                text = transformNonMath(text, function(chunk) {
                                    // Distance formulas in plain text: d(M, (P)) = |...| / căn(...) or \sqrt(...)
                                    chunk = chunk.replace(/d\s*\(\s*([A-Z])\s*,\s*\(([A-Z])\)\s*\)\s*=\s*\|([^|]+)\|\s*\/\s*(?:căn|\\sqrt)\s*\(([^)]+)\)\.?/gi, function(match, pt, pl, num, den) {
                                        var n = num.replace(/([A-Z])([xyz])0\b/g, '$1$2_0').trim();
                                        var d = den.replace(/([a-zA-Z])\^2/g, '$1^2').trim();
                                        return '$d(' + pt + ', (' + pl + ')) = \\dfrac{|' + n + '|}{\\sqrt{' + d + '}}$';
                                    });

                                    // Vecto phap tuyen / chi phuong: vecto phap tuyen n = (A; B; C)
                                    chunk = chunk.replace(/(vectơ\s+(?:pháp tuyến|chỉ phương)\s+)([a-zA-Z])(\s*=\s*\([^)]+\))/gi, function(match, p1, p2, p3) {
                                        return p1 + '$\\vec{' + p2 + '}' + p3 + '$';
                                    });

                                    // Diem toa do: M(x0; y0; z0), I(a; b; c)
                                    chunk = chunk.replace(/\b([A-Z])\s*\(\s*([a-zA-Z0-9_\-]+)\s*;\s*([a-zA-Z0-9_\-]+)(?:\s*;\s*([a-zA-Z0-9_\-]+))?\s*\)/g, function(match, p1, p2, p3, p4) {
                                        var c1 = p2.replace(/([xyz])0\b/g, '$1_0');
                                        var c2 = p3.replace(/([xyz])0\b/g, '$1_0');
                                        var c3 = p4 ? p4.replace(/([xyz])0\b/g, '$1_0') : '';
                                        return '$' + p1 + '(' + c1 + '; ' + c2 + (c3 ? '; ' + c3 : '') + ')$';
                                    });

                                    // Angle formulas in plain text: cos(d1,d2) = |u1.u2|/(|u1||u2|); sin(d,(P)) = |u.n|/(|u||n|); cos((P),(Q)) = |n1.n2|/(|n1||n2|)
                                    chunk = chunk.replace(/\b(cos|sin|tan)\s*\((.*?)\)\s*=\s*\|([^|]+)\|\s*\/\s*(?:\(?\s*\|([^|]+)\|\s*\|([^|]+)\|\s*\)?)/gi, function(m, fn, arg, num, d1, d2) {
                                        function formatVec(v) {
                                            var trimmed = v.trim();
                                            return trimmed.replace(/^([un])(\d?)$/, function(x, a, b) {
                                                return '\\vec{' + a + '}' + (b ? '_{' + b + '}' : '');
                                            });
                                        }
                                        var cleanNum = num.trim().replace(/^([un])(\d?)\.([un])(\d?)$/, function(x, a1, b1, a2, b2) {
                                            return '\\vec{' + a1 + '}' + (b1 ? '_{' + b1 + '}' : '') + ' \\cdot \\vec{' + a2 + '}' + (b2 ? '_{' + b2 + '}' : '');
                                        });
                                        var cleanD1 = formatVec(d1);
                                        var cleanD2 = formatVec(d2);
                                        var cleanArg = arg.replace(/\b([dP])(\d)\b/g, '$1_{$2}');
                                        return '$\\' + fn + '(' + cleanArg + ') = \\dfrac{|' + cleanNum + '|}{|' + cleanD1 + '||' + cleanD2 + '|}$';
                                    });

                                    // Vectors like a.b = a1b1 + a2b2 + a3b3; |a| = căn(a1^2 + a2^2 + a3^2); cos(a,b) = a.b / (|a||b|)
                                    chunk = chunk.replace(/\ba\.b\s*=\s*a1b1\s*\+\s*a2b2\s*\+\s*a3b3/gi, '$\\vec{a} \\cdot \\vec{b} = a_1b_1 + a_2b_2 + a_3b_3$');
                                    chunk = chunk.replace(/\|a\|\s*=\s*(?:căn|\\sqrt)\s*\((a1\^2\s*\+\s*a2\^2\s*\+\s*a3\^2)\)/gi, '$|\\vec{a}| = \\sqrt{a_1^2 + a_2^2 + a_3^2}$');
                                    chunk = chunk.replace(/cos\(a,b\)\s*=\s*a\.b\s*\/\s*\(\|a\|\|b\|\)/gi, '$\\cos(\\vec{a},\\vec{b}) = \\dfrac{\\vec{a}\\cdot\\vec{b}}{|\\vec{a}||\\vec{b}|}$');
                                    chunk = chunk.replace(/\ba\s+vuông góc\s+b\s+khi\s+a\.b\s*=\s*0/gi, '$\\vec{a} \\perp \\vec{b} \\Leftrightarrow \\vec{a} \\cdot \\vec{b} = 0$');

                                    // Plain text sphere eq: (x-a)^2 + (y-b)^2 + (z-c)^2 = R^2
                                    chunk = chunk.replace(/\(x\s*-\s*[a-z]\)\^2\s*\+\s*\(y\s*-\s*[a-z]\)\^2\s*\+\s*\(z\s*-\s*[a-z]\)\^2\s*=\s*[A-Z]\^2/gi, function(m) {
                                        return '$' + m.trim() + '$';
                                    });

                                    // Plain text condition: a^2 + b^2 + c^2 - d > 0
                                    chunk = chunk.replace(/[a-z]\^2\s*\+\s*[a-z]\^2\s*\+\s*[a-z]\^2\s*-\s*[a-z]\s*(?:>|>=)\s*0/gi, function(m) {
                                        return '$' + m.trim() + '$';
                                    });

                                    // Parametric eq: x = x0 + at, y = y0 + bt, z = z0 + ct
                                    chunk = chunk.replace(/\b([xyz])\s*=\s*([xyz])0\s*([+-]\s*[a-z0-9]+t)\b/g, function(match, v1, v2, v3) {
                                        return '$' + v1 + ' = ' + v2 + '_0 ' + v3 + '$';
                                    });

                                    // Plane eq in plain text: Ax + By + Cz + D = 0
                                    chunk = chunk.replace(/\b([A-Z]x\s*[+-]\s*[A-Z]y\s*[+-]\s*[A-Z]z\s*[+-]\s*[A-Z]\s*=\s*0)\b/g, function(m, eq) {
                                        return '$' + eq.trim() + '$';
                                    });

                                    // Ban kinh R:, tam I:
                                    chunk = chunk.replace(/(bán kính\s+)([A-Za-z])(\s*[:=])/gi, '$1$$$2$$$3');
                                    chunk = chunk.replace(/(tâm\s+)([A-Za-z])(\s*[:=])/gi, '$1$$$2$$$3');

                                    // Vector rules: AB + BC = AC, GA + GB + GC = 0
                                    chunk = chunk.replace(/\b([A-Z]{2})\s*\+\s*([A-Z]{2})\s*=\s*([A-Z]{2})\b/g, '$\\overrightarrow{$1} + \\overrightarrow{$2} = \\overrightarrow{$3}$');
                                    chunk = chunk.replace(/\b([A-Z]{2})\s*\+\s*([A-Z]{2})\s*\+\s*([A-Z]{2}['’]?)\s*=\s*([A-Z]{2}['’]?)(?=[^\w'’]|$)/g, '$\\overrightarrow{$1} + \\overrightarrow{$2} + \\overrightarrow{$3} = \\overrightarrow{$4}$');
                                    chunk = chunk.replace(/\bGA\s*\+\s*GB\s*\+\s*GC\s*=\s*0\b/g, '$\\overrightarrow{GA} + \\overrightarrow{GB} + \\overrightarrow{GC} = \\vec{0}$');

                                    return chunk;
                                });

                                return text;
                            }

                            function renderMathAll() {
                                var targets = document.querySelectorAll('.latex-content');
                                targets.forEach(function (el) {
                                    if (el.dataset.mathRendered === 'true') return;
                                    // Xóa bỏ text node trống hoặc ký tự xuống dòng dư thừa ở đầu/cuối khối
                                    while (el.firstChild && el.firstChild.nodeType === Node.TEXT_NODE && !el.firstChild.nodeValue.trim()) {
                                        el.removeChild(el.firstChild);
                                    }
                                    while (el.lastChild && el.lastChild.nodeType === Node.TEXT_NODE && !el.lastChild.nodeValue.trim()) {
                                        el.removeChild(el.lastChild);
                                    }
                                    if (el.firstChild && el.firstChild.nodeType === Node.TEXT_NODE) {
                                        el.firstChild.nodeValue = el.firstChild.nodeValue.replace(/^\s*\n+/, '');
                                    }
                                    processTextNodes(el, function (node) {
                                        var original = node.nodeValue;
                                        var formatted = preprocessMathText(original);
                                        if (formatted !== original) {
                                            node.nodeValue = formatted;
                                        }
                                    });
                                    if (window.renderMathInElement) {
                                        try {
                                            window.renderMathInElement(el, MATH_CONFIG);
                                            el.dataset.mathRendered = 'true';
                                        } catch (e) {
                                            console.warn('KaTeX render warning:', e);
                                        }
                                    }
                                });
                            }

                            function executeWhenKaTeXReady(callback) {
                                if (window.renderMathInElement) {
                                    callback();
                                } else {
                                    var retries = 0;
                                    var timer = setInterval(function () {
                                        retries++;
                                        if (window.renderMathInElement) {
                                            clearInterval(timer);
                                            callback();
                                        } else if (retries > 60) {
                                            clearInterval(timer);
                                        }
                                    }, 50);
                                }
                            }

                            executeWhenKaTeXReady(renderMathAll);

                            // Render lại KaTeX khi chuyển đổi tabs
                            document.querySelectorAll('#lessonTabs button[data-bs-toggle="tab"]').forEach(function (btn) {
                                btn.addEventListener('shown.bs.tab', function () {
                                    executeWhenKaTeXReady(renderMathAll);
                                });
                            });

                            // 3. Xử lý Mục lục (TOC)
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
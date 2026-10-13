<%-- File: WEB-INF/views/student/dashboard.jsp Controller: StudentController (GET /student/dashboard) Attributes:
    totalTopics(int), topicProgress(List<ProgressView>), overall(ProgressView),
    essayAverage(Double), recentLesson(LessonView), recentVideo(MaterialView)
        --%>
        <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
            <%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
                <%@ taglib prefix="c" uri="jakarta.tags.core" %>
                    <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

                        <jsp:include page="../common/head.jsp">
                            <jsp:param name="title" value="Tổng quan Học sinh" />
                        </jsp:include>

                        <body data-ctx="${pageContext.request.contextPath}">

                            <jsp:include page="../common/navbar.jsp" />

                            <div class="app-shell">
                                <jsp:include page="../common/sidebar.jsp">
                                    <jsp:param name="active" value="student-dashboard" />
                                </jsp:include>

                                <main class="app-main">
                                    <ui:flash />

                                    <%-- Page header --%>
                                        <div class="page-header">
                                            <h1><i class="bi bi-speedometer2 me-2 text-primary"></i>Tổng quan học tập
                                            </h1>
                                        </div>

                                        <div class="row g-4">

                                            <%-- ════ LEFT COL (col-lg-8) ════ --%>
                                                <div class="col-lg-9">

                                                    <%-- Hero banner --%>
                                                        <div class="hero-banner mb-4">
                                                            <div class="hero-banner-content">
                                                                <div class="hero-label">Chào mừng trở lại</div>
                                                                <h2>Xin chào,
                                                                    <c:out
                                                                        value="${sessionScope.LOGGED_IN_USER.fullName}" />!
                                                                </h2>
                                                                <p>Tiếp tục hành trình học Toán 12 của bạn ngay hôm nay.</p>
                                                                <div class="d-flex flex-wrap gap-2">
                                                                    <a href="${pageContext.request.contextPath}/student/topics"
                                                                        class="btn-hero-primary btn">
                                                                        <i class="bi bi-book me-1"></i>Học ngay
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/student/ai-tutor"
                                                                        class="btn-hero-outline btn">
                                                                        <i class="bi bi-chat-dots me-1"></i>Hỏi AI
                                                                    </a>
                                                                </div>
                                                            </div>
                                                            <img src="${pageContext.request.contextPath}/static/img/mascot.png" alt="Mascot" class="welcome-mascot-img" />
                                                        </div>

                                                        <%-- Stat cards 2×2 --%>
                                                            <div class="row g-3 mb-4">
                                                                <div class="col-6">
                                                                    <div class="stat-card">
                                                                        <div class="stat-icon blue"><i
                                                                                class="bi bi-book"></i></div>
                                                                        <div>
                                                                            <div class="stat-number">${totalTopics}
                                                                            </div>
                                                                            <div class="stat-label">Chủ đề có thể học
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="col-6">
                                                                    <div class="stat-card">
                                                                        <div class="stat-icon green"><i
                                                                                class="bi bi-check2-circle"></i></div>
                                                                        <div>
                                                                            <div class="stat-number">
                                                                                ${overall.answered}/${overall.total}
                                                                            </div>
                                                                            <div class="stat-label">Câu trắc nghiệm đã
                                                                                làm</div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="col-6">
                                                                    <div class="stat-card">
                                                                        <div class="stat-icon orange"><i
                                                                                class="bi bi-bullseye"></i></div>
                                                                        <div>
                                                                            <div class="stat-number">
                                                                                <c:choose>
                                                                                    <c:when
                                                                                        test="${overall.correctPct != null}">
                                                                                        <fmt:formatNumber
                                                                                            value="${overall.correctPct}"
                                                                                            maxFractionDigits="1" />%
                                                                                    </c:when>
                                                                                    <c:otherwise>--</c:otherwise>
                                                                                </c:choose>
                                                                            </div>
                                                                            <div class="stat-label">Tỉ lệ đúng trắc
                                                                                nghiệm</div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="col-6">
                                                                    <div class="stat-card">
                                                                        <div class="stat-icon purple"><i
                                                                                class="bi bi-star-fill"></i></div>
                                                                        <div>
                                                                            <div class="stat-number">
                                                                                <c:choose>
                                                                                    <c:when
                                                                                        test="${essayAverage != null}">
                                                                                        <fmt:formatNumber
                                                                                            value="${essayAverage}"
                                                                                            maxFractionDigits="2" />/10
                                                                                    </c:when>
                                                                                    <c:otherwise>--</c:otherwise>
                                                                                </c:choose>
                                                                            </div>
                                                                            <div class="stat-label">Điểm TB tự luận
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <%-- Tiến độ theo chủ đề --%>
                                                                <div class="card mb-4">
                                                                    <div class="card-header">
                                                                        <i
                                                                            class="bi bi-graph-up-arrow text-primary"></i>
                                                                        Tiến độ theo chủ đề
                                                                        <span class="ms-auto text-muted fw-normal"
                                                                            style="font-size:.78rem;">tính theo lần làm
                                                                            gần nhất</span>
                                                                    </div>
                                                                    <div>
                                                                        <c:forEach var="p" items="${topicProgress}">
                                                                            <a class="topic-progress-item"
                                                                                href="${pageContext.request.contextPath}/student/topics/${p.id}/progress">
                                                                                <div
                                                                                    class="d-flex justify-content-between align-items-center mb-2">
                                                                                    <span class="fw-semibold"
                                                                                        style="font-size:.9rem;">
                                                                                        <c:out value="${p.name}" />
                                                                                    </span>
                                                                                    <span class="text-muted"
                                                                                        style="font-size:.78rem;">
                                                                                        ${p.answered}/${p.total} câu
                                                                                        <c:if
                                                                                            test="${p.correctPct != null}">
                                                                                            · đúng ${p.correct}
                                                                                            (
                                                                                            <fmt:formatNumber
                                                                                                value="${p.correctPct}"
                                                                                                maxFractionDigits="1" />
                                                                                            %)
                                                                                        </c:if>
                                                                                        <i
                                                                                            class="bi bi-chevron-right ms-1"></i>
                                                                                    </span>
                                                                                </div>
                                                                                <div class="progress"
                                                                                    style="height:6px;">
                                                                                    <div class="progress-bar-gradient"
                                                                                        style="width:${p.answered == 0 ? 0 : p.correct * 100 / (p.total == 0 ? 1 : p.total)}%;display:block;height:100%;"
                                                                                        title="Đúng ${p.correctPct}%">
                                                                                    </div>
                                                                                    <div class="progress-bar bg-danger"
                                                                                        style="width:${p.answered == 0 ? 0 : (p.answered - p.correct) * 100 / (p.total == 0 ? 1 : p.total)}%;"
                                                                                        title="Sai"></div>
                                                                                </div>
                                                                            </a>
                                                                        </c:forEach>
                                                                        <c:if test="${empty topicProgress}">
                                                                            <div class="empty-state py-4">
                                                                                <i class="bi bi-inbox empty-icon"></i>
                                                                                <p class="mb-0">Chưa có chủ đề nào.</p>
                                                                            </div>
                                                                        </c:if>
                                                                    </div>
                                                                </div>

<%-- Bài học gần đây + video gần nhất --%>
<div class="card">
    <div class="card-header">
        <i class="bi bi-journal-bookmark text-primary"></i>
        Bài học gần đây
        <a href="${pageContext.request.contextPath}/student/history" class="btn btn-sm btn-outline-primary ms-auto">Lịch sử làm bài</a>
    </div>
    <div class="card-body">
        <c:choose>
            <c:when test="${empty recentLesson}">
                <div class="text-center py-4">
                    <i class="bi bi-inbox d-block fs-1 mb-2 opacity-25"></i>
                    Bạn chưa học bài nào.
                    <a href="${pageContext.request.contextPath}/student/topics">Bắt đầu học ngay!</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="d-flex flex-wrap align-items-center gap-2 mb-3">
                    <div>
                        <div class="fw-semibold fs-5"><c:out value="${recentLesson.title}" /></div>
                        <div class="text-muted small"><c:out value="${recentLesson.topicName}" /></div>
                    </div>
                    <a href="${pageContext.request.contextPath}/student/lesson?id=${recentLesson.lessonId}"
                        class="btn btn-primary btn-sm ms-auto"><i class="bi bi-play-circle me-1"></i>Tiếp tục học</a>
                </div>
                <c:choose>
                    <c:when test="${not empty recentVideo and recentVideo.materialType == 'YOUTUBE' and not empty recentVideo.youtubeEmbedUrl}">
                        <div class="fw-semibold small mb-2"><i class="bi bi-youtube text-danger me-1"></i><c:out value="${recentVideo.title}" /></div>
                        <div class="ratio ratio-16x9 rounded-3 overflow-hidden border">
                            <iframe src="${recentVideo.youtubeEmbedUrl}" title="<c:out value='${recentVideo.title}'/>"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                                referrerpolicy="strict-origin-when-cross-origin" loading="lazy" allowfullscreen
                                class="w-100 h-100 border-0"></iframe>
                        </div>
                    </c:when>
                    <c:when test="${not empty recentVideo and recentVideo.materialType == 'VIDEO'}">
                        <div class="fw-semibold small mb-2"><i class="bi bi-camera-video me-1"></i><c:out value="${recentVideo.title}" /></div>
                        <video controls preload="metadata" class="w-100 rounded-3 border" src="<c:out value='${recentVideo.url}'/>"></video>
                    </c:when>
                    <c:otherwise>
                        <div class="text-muted small">Bài học này chưa có video.</div>
                    </c:otherwise>
                </c:choose>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</div><%-- /col-lg-8 --%>

                                                    <%-- ════ RIGHT COL (col-lg-4) ════ --%>
                                                        <div class="col-lg-3">

                                                            <%-- ── WIDGET: Mini Calendar Streak (Light Purple Theme) ──
                                                                --%>
                                                                <div class="streak-cal-card">
                                                                    <%-- Header --%>
                                                                        <div class="streak-cal-header">
                                                                            <div class="streak-cal-top-row">
                                                                                <span class="streak-cal-label">
                                                                                    <span
                                                                                        class="streak-cal-flame">🔥</span>
                                                                                    CHUỖI HỌC TẬP
                                                                                </span>
                                                                                <span
                                                                                    class="streak-cal-count">${streakData.currentStreak}
                                                                                    NGÀY</span>
                                                                            </div>
                                                                            <div class="streak-cal-month-row">
                                                                                <span class="streak-cal-month">Tháng
                                                                                    ${streakData.month},
                                                                                    ${streakData.year}</span>
                                                                            </div>
                                                                        </div>

                                                                        <%-- Weekday Headers --%>
                                                                            <div class="streak-cal-grid">
                                                                                <div class="streak-cal-weekday">T2</div>
                                                                                <div class="streak-cal-weekday">T3</div>
                                                                                <div class="streak-cal-weekday">T4</div>
                                                                                <div class="streak-cal-weekday">T5</div>
                                                                                <div class="streak-cal-weekday">T6</div>
                                                                                <div class="streak-cal-weekday">T7</div>
                                                                                <div
                                                                                    class="streak-cal-weekday streak-cal-weekday--sun">
                                                                                    CN</div>

                                                                                <%-- Offset empty cells for the first
                                                                                    day of the month --%>
                                                                                    <c:forEach begin="1"
                                                                                        end="${streakData.emptyOffsetCells}">
                                                                                        <div class="streak-cal-empty">
                                                                                        </div>
                                                                                    </c:forEach>

                                                                                    <%-- Loop through the days of the
                                                                                        month --%>
                                                                                        <c:forEach var="day" begin="1"
                                                                                            end="${streakData.daysInMonth}">
                                                                                            <c:choose>
                                                                                                <c:when
                                                                                                    test="${streakData.activeDaysInMonth.contains(day)}">
                                                                                                    <c:set
                                                                                                        var="dayClass"
                                                                                                        value="active" />
                                                                                                    <c:set
                                                                                                        var="dayTitle"
                                                                                                        value="Đã học" />
                                                                                                </c:when>
                                                                                                <c:when
                                                                                                    test="${day > streakData.todayDayOfMonth}">
                                                                                                    <c:set
                                                                                                        var="dayClass"
                                                                                                        value="future" />
                                                                                                    <c:set
                                                                                                        var="dayTitle"
                                                                                                        value="Sắp tới" />
                                                                                                </c:when>
                                                                                                <c:otherwise>
                                                                                                    <c:set
                                                                                                        var="dayClass"
                                                                                                        value="" />
                                                                                                    <c:set
                                                                                                        var="dayTitle"
                                                                                                        value="Chưa học" />
                                                                                                </c:otherwise>
                                                                                            </c:choose>

                                                                                            <c:if
                                                                                                test="${day == streakData.todayDayOfMonth}">
                                                                                                <c:set var="dayClass"
                                                                                                    value="${dayClass} today" />
                                                                                                <c:set var="dayTitle"
                                                                                                    value="${streakData.activeDaysInMonth.contains(day) ? 'Hôm nay - Đã học' : 'Hôm nay - Chưa học'}" />
                                                                                            </c:if>

                                                                                            <div class="streak-cal-day ${dayClass}"
                                                                                                title="${day}/${streakData.month} - ${dayTitle}">
                                                                                                ${day}</div>
                                                                                        </c:forEach>
                                                                            </div>

                                                                            <%-- Legend --%>
                                                                                <div class="streak-cal-legend">
                                                                                    <div class="streak-cal-legend-item">
                                                                                        <span
                                                                                            class="streak-cal-dot streak-cal-dot--active"></span>
                                                                                        <span>Có học</span>
                                                                                    </div>
                                                                                    <div class="streak-cal-legend-item">
                                                                                        <span
                                                                                            class="streak-cal-dot streak-cal-dot--miss"></span>
                                                                                        <span>Nghỉ</span>
                                                                                    </div>
                                                                                    <div class="streak-cal-legend-item">
                                                                                        <span
                                                                                            class="streak-cal-dot streak-cal-dot--today"></span>
                                                                                        <span>Hôm nay</span>
                                                                                    </div>
                                                                                    <div class="streak-cal-legend-item">
                                                                                        <span
                                                                                            class="streak-cal-dot streak-cal-dot--future"></span>
                                                                                        <span>Sắp tới</span>
                                                                                    </div>
                                                                                </div>
                                                                </div><%-- /streak-cal-card --%>

                                                        </div><%-- /col-lg-4 --%>


                                        </div><%-- /row --%>
                                </main>
                            </div>

                            <jsp:include page="../common/footer.jsp" />
                        </body>

                        </html>
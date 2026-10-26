<%-- navbar.jsp: thanh trên cố định, logo, avatar user, dropdown đăng xuất --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

                <nav class="app-navbar">

                    <%-- Hamburger (mobile) --%>
                        <button id="sidebarToggle" class="btn d-lg-none me-1" type="button" aria-label="Mở menu">
                            <i class="bi bi-list fs-4"></i>
                        </button>

                        <%-- Brand --%>
                            <a href="${pageContext.request.contextPath}/" class="brand text-decoration-none">
                                <i class="bi bi-calculator-fill"></i> MathTutor 9
                            </a>

                            <%-- Right side --%>
                                <div class="ms-auto d-flex align-items-center gap-2">
                                    <div class="dropdown">
                                        <%-- Trigger button --%>
                                            <button class="nav-user-btn border-0" type="button"
                                                data-bs-toggle="dropdown" aria-expanded="false">

                                                <%-- Avatar chữ cái đầu --%>
                                                    <span class="nav-avatar">
                                                        <c:choose>
                                                            <c:when
                                                                test="${not empty sessionScope.LOGGED_IN_USER.fullName}">
                                                                <c:set var="uParts" value="${fn:split(fn:trim(sessionScope.LOGGED_IN_USER.fullName), ' ')}" />
                                                                <c:set var="lastUPartIdx" value="${fn:length(uParts) - 1}" />
                                                                <c:out
                                                                    value="${fn:substring(uParts[lastUPartIdx], 0, 1)}" />
                                                            </c:when>
                                                            <c:otherwise>U</c:otherwise>
                                                        </c:choose>
                                                    </span>

                                                    <%-- Full name (ẩn trên xs) --%>
                                                        <span class="d-none d-sm-inline fw-semibold"
                                                            style="font-size:.875rem; color:var(--text);">
                                                            <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />
                                                        </span>

                                                        <%-- Badge role --%>
                                                            <c:choose>
                                                                <c:when
                                                                    test="${sessionScope.LOGGED_IN_USER.role == 'ADMIN'}">
                                                                    <span class="role-badge admin">ADMIN</span>
                                                                </c:when>
                                                                <c:when
                                                                    test="${sessionScope.LOGGED_IN_USER.role == 'TEACHER'}">
                                                                    <span class="role-badge teacher">GV</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="role-badge student">HS</span>
                                                                </c:otherwise>
                                                            </c:choose>

                                                            <i class="bi bi-chevron-down d-none d-sm-inline"
                                                                style="font-size:.7rem; color:var(--muted);"></i>
                                            </button>

                                            <%-- Dropdown menu --%>
                                                <ul class="dropdown-menu dropdown-menu-end">
                                                    <li>
                                                        <a class="dropdown-item"
                                                            href="${pageContext.request.contextPath}/profile">
                                                            <i class="bi bi-person-circle me-2"></i>Hồ sơ cá nhân
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <a class="dropdown-item"
                                                            href="${pageContext.request.contextPath}/profile/password">
                                                            <i class="bi bi-key me-2"></i>Đổi mật khẩu
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <hr class="dropdown-divider">
                                                    </li>
                                                    <li>
                                                        <form action="${pageContext.request.contextPath}/logout"
                                                            method="post" class="m-0">
                                                            <input type="hidden" name="_csrf"
                                                                value="${sessionScope.CSRF_TOKEN}">
                                                            <button type="submit" class="dropdown-item text-danger">
                                                                <i class="bi bi-box-arrow-right me-2"></i>Đăng xuất
                                                            </button>
                                                        </form>
                                                    </li>
                                                </ul>
                                    </div>
                                </div>

                </nav>

                <%-- Overlay cho sidebar mobile --%>
                    <div class="sidebar-overlay"></div>
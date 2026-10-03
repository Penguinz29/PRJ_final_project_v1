<%-- navbar.jsp: thanh trên cố định, logo, avatar user, dropdown đăng xuất --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <nav class="app-navbar">
                    <%-- Hamburger (mobile) --%>
                        <button id="sidebarToggle" class="btn btn-sm d-lg-none me-1" type="button" aria-label="Mở menu">
                            <i class="bi bi-list fs-4"></i>
                        </button>

                        <a href="${pageContext.request.contextPath}/" class="brand text-decoration-none">
                            <i class="bi bi-calculator-fill"></i> MathTutor 12
                        </a>

                        <div class="ms-auto d-flex align-items-center gap-2">
                            <div class="dropdown">
                                <button class="btn d-flex align-items-center gap-2 border rounded-pill px-3 py-1"
                                    type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    <%-- Avatar chữ cái đầu --%>
                                        <span
                                            class="rounded-circle d-flex align-items-center justify-content-center fw-bold text-white"
                                            style="width:30px;height:30px;font-size:.8rem;
                             background:var(--primary);">
                                            <c:choose>
                                                <c:when test="${not empty sessionScope.LOGGED_IN_USER.fullName}">
                                                    <c:out
                                                        value="${fn:substring(sessionScope.LOGGED_IN_USER.fullName,0,1)}" />
                                                </c:when>
                                                <c:otherwise>U</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span class="d-none d-md-inline fw-semibold" style="font-size:.85rem;">
                                            <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />
                                        </span>
                                        <%-- Badge role --%>
                                            <c:choose>
                                                <c:when test="${sessionScope.LOGGED_IN_USER.role == 'ADMIN'}">
                                                    <span class="badge bg-danger" style="font-size:.65rem;">ADMIN</span>
                                                </c:when>
                                                <c:when test="${sessionScope.LOGGED_IN_USER.role == 'TEACHER'}">
                                                    <span class="badge bg-primary" style="font-size:.65rem;">GV</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-success" style="font-size:.65rem;">HS</span>
                                                </c:otherwise>
                                            </c:choose>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0">
                                    <li>
                                        <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                                            <i class="bi bi-person-circle me-2"></i>Hồ sơ cá nhân
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="${pageContext.request.contextPath}/profile/password">
                                            <i class="bi bi-key me-2"></i>Đổi mật khẩu
                                        </a>
                                    </li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li>
                                        <form action="${pageContext.request.contextPath}/logout" method="post" class="m-0">
                                            <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">
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
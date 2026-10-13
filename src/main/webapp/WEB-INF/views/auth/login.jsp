<%-- File: WEB-INF/views/auth/login.jsp. Controller: AuthController (GET/POST /login). Attributes: error, username,
    flashMsg, flashType --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Đăng nhập - MathTutor 12</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                    rel="stylesheet">
                <link
                    href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Manrope:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <style>
                    :root {
                        --violet: #7d7edc;
                        --violet-dark: #6869cb;
                        --ink: #1b1938;
                        --muted: #8b89a6;
                        --line: #dedde9;
                    }

                    *,
                    *::before,
                    *::after {
                        box-sizing: border-box;
                    }

                    html,
                    body {
                        height: 100%;
                    }

                    body {
                        font-family: "Plus Jakarta Sans", "Manrope", system-ui, sans-serif;
                        color: var(--ink);
                        min-height: 100vh;
                        margin: 0;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        padding: 24px;
                        background:
                            radial-gradient(circle at 14% 18%, rgba(240, 238, 255, 0.95) 0%, transparent 35%),
                            radial-gradient(circle at 86% 14%, rgba(228, 224, 255, 0.85) 0%, transparent 40%),
                            radial-gradient(circle at 72% 86%, rgba(195, 190, 250, 0.65) 0%, transparent 45%),
                            radial-gradient(circle at 20% 82%, rgba(215, 210, 252, 0.55) 0%, transparent 40%),
                            linear-gradient(135deg, #c7c5f8 0%, #b8b5f3 50%, #c4c1f6 100%);
                        position: relative;
                        overflow-x: hidden;
                    }

                    /* Ambient Glow & Depth */
                    .bg-glow-orb {
                        position: fixed;
                        border-radius: 50%;
                        pointer-events: none;
                        z-index: 0;
                        filter: blur(60px);
                    }

                    .bg-glow-1 {
                        top: -90px;
                        left: -90px;
                        width: 440px;
                        height: 440px;
                        background: rgba(255, 255, 255, 0.6);
                    }

                    .bg-glow-2 {
                        bottom: -70px;
                        left: 12%;
                        width: 390px;
                        height: 390px;
                        background: rgba(210, 202, 255, 0.45);
                    }

                    .bg-blur-cube {
                        position: fixed;
                        right: -80px;
                        bottom: -95px;
                        width: 450px;
                        height: 450px;
                        pointer-events: none;
                        z-index: 1;
                        filter: blur(18px);
                        opacity: 0.88;
                        transform: rotate(22deg);
                        animation: bgCubeFloat 10s ease-in-out infinite alternate;
                    }

                    .bg-blur-cube img {
                        width: 100%;
                        height: 100%;
                        object-fit: contain;
                    }

                    @keyframes bgCubeFloat {
                        0% {
                            transform: translate(0, 0) rotate(22deg);
                        }

                        100% {
                            transform: translate(-14px, -20px) rotate(27deg);
                        }
                    }

                    /* Thẻ Auth chính */
                    .auth-card {
                        position: relative;
                        z-index: 2;
                        width: 100%;
                        max-width: 980px;
                        min-height: 570px;
                        display: flex;
                        border-radius: 30px;
                        overflow: hidden;
                        background: #ffffff;
                        box-shadow: 0 35px 80px rgba(110, 105, 195, 0.28), 0 10px 25px rgba(110, 105, 195, 0.12);
                    }

                    /* Cột trái (Panel tím) */
                    .auth-aside {
                        flex: 0 0 44%;
                        position: relative;
                        padding: 38px 30px 24px;
                        color: #fff;
                        background: linear-gradient(160deg, #8786e2 0%, #7c7cdb 50%, #7271ce 100%);
                        border-top-right-radius: 28px;
                        border-bottom-right-radius: 28px;
                        display: flex;
                        flex-direction: column;
                        overflow: hidden;
                    }

                    .brand {
                        display: inline-flex;
                        align-items: center;
                        gap: 10px;
                        font-weight: 800;
                        font-size: 1.05rem;
                        letter-spacing: -0.2px;
                    }

                    .brand-icon-wrap {
                        width: 34px;
                        height: 34px;
                        border-radius: 10px;
                        background: rgba(255, 255, 255, 0.2);
                        backdrop-filter: blur(8px);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 1.15rem;
                        border: 1px solid rgba(255, 255, 255, 0.35);
                    }

                    .aside-title {
                        margin: 24px 0 8px;
                        font-size: 1.65rem;
                        font-weight: 700;
                        line-height: 1.32;
                        letter-spacing: -0.3px;
                    }

                    .aside-sub {
                        margin: 0;
                        opacity: 0.88;
                        font-size: 0.95rem;
                        line-height: 1.48;
                        max-width: 25ch;
                    }

                    /* Khu vực hiển thị khối Rubik 3D */
                    .rubik-stage {
                        flex: 1;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        justify-content: center;
                        position: relative;
                        padding: 8px 0 4px;
                        min-height: 320px;
                    }

                    .rubik-3d-img {
                        width: 500px;
                        max-width: none;
                        height: auto;
                        object-fit: contain;
                        filter: drop-shadow(0 24px 30px rgba(45, 38, 105, 0.32));
                        animation: floatCube 6s ease-in-out infinite alternate;
                        will-change: transform;
                        user-select: none;
                        pointer-events: none;
                    }

                    .rubik-shadow {
                        width: 380px;
                        height: 26px;
                        border-radius: 50%;
                        background: radial-gradient(ellipse at center, rgba(38, 30, 95, 0.36) 0%, transparent 72%);
                        margin-top: -14px;
                        filter: blur(8px);
                        animation: shadowPulse 6s ease-in-out infinite alternate;
                    }

                    @keyframes floatCube {
                        0% {
                            transform: translateY(0px) rotate(0deg);
                        }

                        50% {
                            transform: translateY(-12px) rotate(1.2deg);
                        }

                        100% {
                            transform: translateY(3px) rotate(-0.8deg);
                        }
                    }

                    @keyframes shadowPulse {
                        0% {
                            transform: scale(1);
                            opacity: 0.85;
                        }

                        50% {
                            transform: scale(0.85);
                            opacity: 0.5;
                        }

                        100% {
                            transform: scale(1.05);
                            opacity: 0.95;
                        }
                    }

                    /* Cột phải (Form) */
                    .auth-main {
                        flex: 1;
                        padding: 46px 54px;
                        display: flex;
                        flex-direction: column;
                        justify-content: center;
                        overflow-y: auto;
                    }

                    .auth-main h1 {
                        font-size: 1.65rem;
                        font-weight: 800;
                        margin-bottom: 6px;
                        letter-spacing: -0.4px;
                        color: var(--ink);
                    }

                    .auth-main .lead {
                        color: var(--muted);
                        font-size: 0.95rem;
                        margin-bottom: 24px;
                    }

                    .field {
                        margin-bottom: 20px;
                    }

                    .field label {
                        font-size: 0.8rem;
                        font-weight: 600;
                        color: var(--muted);
                        margin-bottom: 3px;
                        display: block;
                    }

                    .field .form-control {
                        border: 0;
                        border-bottom: 1.5px solid var(--line);
                        border-radius: 0;
                        padding: 8px 0;
                        background: transparent;
                        box-shadow: none !important;
                        font-size: 1rem;
                        color: var(--ink);
                        transition: border-color .2s;
                    }

                    .field .form-control:focus {
                        border-bottom-color: var(--violet);
                    }

                    .field .form-control::placeholder {
                        color: #b9b8cc;
                    }

                    .field .form-control.is-invalid {
                        border-bottom-color: #dc3545;
                    }

                    .field .invalid-feedback {
                        font-size: 0.78rem;
                        margin-top: 4px;
                    }

                    .pw-wrap {
                        position: relative;
                    }

                    .pw-wrap .form-control {
                        padding-right: 36px;
                    }

                    .pw-toggle {
                        position: absolute;
                        right: 0;
                        top: 50%;
                        transform: translateY(-50%);
                        border: 0;
                        background: none;
                        color: #8c8aa5;
                        font-size: 1.15rem;
                        padding: 4px;
                        cursor: pointer;
                        transition: color .2s;
                    }

                    .pw-toggle:hover {
                        color: var(--ink);
                    }

                    .btn-login {
                        width: 100%;
                        padding: 13px;
                        border: 0;
                        border-radius: 14px;
                        background: linear-gradient(135deg, #7c7cdb, #6f6fd3);
                        color: #fff;
                        font-weight: 700;
                        font-size: 0.98rem;
                        letter-spacing: 0.2px;
                        box-shadow: 0 10px 24px rgba(118, 114, 218, 0.32);
                        transition: all .25s ease;
                        cursor: pointer;
                    }

                    .btn-login:hover {
                        background: linear-gradient(135deg, #6f6fd3, #6262c6);
                        color: #fff;
                        transform: translateY(-1px);
                        box-shadow: 0 14px 28px rgba(118, 114, 218, 0.4);
                    }

                    .btn-login:active {
                        transform: translateY(1px);
                        box-shadow: 0 6px 16px rgba(118, 114, 218, 0.28);
                    }

                    .btn-login:disabled {
                        opacity: 0.7;
                        cursor: not-allowed;
                    }

                    .help {
                        margin-top: 20px;
                        font-size: 0.85rem;
                        color: var(--muted);
                    }

                    .help a {
                        color: var(--violet);
                        font-weight: 700;
                        text-decoration: none;
                        transition: color .2s;
                    }

                    .help a:hover {
                        color: var(--violet-dark);
                        text-decoration: underline;
                    }

                    .demo-box {
                        margin-top: 18px;
                        padding: 12px 16px;
                        background: #f6f5fe;
                        border: 1px solid #eae8f9;
                        border-radius: 12px;
                        font-size: 0.8rem;
                        color: var(--muted);
                    }

                    .demo-box strong {
                        color: var(--ink);
                        display: block;
                        margin-bottom: 4px;
                    }

                    @media(max-width:767.98px) {
                        .auth-aside {
                            display: none;
                        }

                        .auth-main {
                            padding: 36px 24px;
                        }

                        .bg-blur-cube {
                            display: none;
                        }
                    }
                </style>
            </head>

            <body>
                <!-- Ambient Background Glows -->
                <div class="bg-glow-orb bg-glow-1" aria-hidden="true"></div>
                <div class="bg-glow-orb bg-glow-2" aria-hidden="true"></div>

                <!-- Foreground Blurred 3D Cube -->
                <div class="bg-blur-cube" aria-hidden="true">
                    <img src="${pageContext.request.contextPath}/static/img/rubik-3d.png" alt="">
                </div>

                <main class="auth-card">
                    <%-- Cột trái: 3D Rubik --%>
                        <aside class="auth-aside" aria-hidden="true">
                            <div class="brand">
                                <span class="brand-icon-wrap"><i class="bi bi-calculator-fill"></i></span>
                                <span>MathTutor 12</span>
                            </div>
                            <p class="aside-title">Học Toán 12 cùng gia sư AI</p>
                            <p class="aside-sub">Gợi ý từng bước, không đưa đáp án ngay.</p>

                            <div class="rubik-stage">
                                <img src="${pageContext.request.contextPath}/static/img/rubik-3d.png" alt="3D Rubik"
                                    class="rubik-3d-img">
                                <div class="rubik-shadow"></div>
                            </div>
                        </aside>

                        <%-- Cột phải: Form đăng nhập --%>
                            <section class="auth-main">
                                <h1>Đăng nhập</h1>
                                <p class="lead">Nhập tài khoản do giáo viên hoặc quản trị viên cấp.</p>

                                <c:if test="${not empty error}">
                                    <div class="alert alert-danger py-2 mb-3" role="alert">
                                        <i class="bi bi-exclamation-circle-fill me-1"></i>
                                        <c:out value="${error}" />
                                    </div>
                                </c:if>

                                <c:if test="${not empty flashMsg}">
                                    <div class="alert alert-${empty flashType ? 'success' : flashType} py-2 mb-3"
                                        role="alert">
                                        <i class="bi bi-check-circle-fill me-1"></i>
                                        <c:out value="${flashMsg}" />
                                    </div>
                                </c:if>

                                <form action="${pageContext.request.contextPath}/login" method="post"
                                    class="needs-validation" novalidate>
                                    <input type="hidden" name="_csrf" value="${sessionScope.CSRF_TOKEN}">

                                    <div class="field">
                                        <label for="username">Tên đăng nhập</label>
                                        <input type="text" class="form-control" id="username" name="username"
                                            value="<c:out value='${username}'/>" placeholder="Ví dụ: admin"
                                            minlength="4" maxlength="30" pattern="[A-Za-z0-9_.]{4,30}"
                                            autocomplete="username" required autofocus>
                                        <div class="invalid-feedback">Username 4-30 ký tự (chữ, số, _ hoặc .).</div>
                                    </div>

                                    <div class="field">
                                        <label for="password">Mật khẩu</label>
                                        <div class="pw-wrap">
                                            <input type="password" class="form-control" id="password" name="password"
                                                placeholder="Nhập mật khẩu" minlength="6" maxlength="50"
                                                autocomplete="current-password" required>
                                            <button type="button" class="pw-toggle" data-toggle-password="#password"
                                                aria-label="Hiện mật khẩu">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                        <div class="invalid-feedback">Mật khẩu tối thiểu 6 ký tự.</div>
                                    </div>

                                    <button type="submit" class="btn-login">Đăng nhập</button>
                                </form>

                                <p class="help">Chưa có tài khoản? <a
                                        href="${pageContext.request.contextPath}/register">Đăng ký ngay</a></p>

                                <%-- DEMO: xóa khi nộp bài --%>
                                    <div class="demo-box">
                                        <strong><i class="bi bi-info-circle me-1"></i>Tài khoản demo (mật khẩu:
                                            EduTutor@123)</strong>
                                        admin &nbsp;·&nbsp; teacher1 &nbsp;·&nbsp; student1
                                    </div>
                                    <%-- /DEMO --%>
                            </section>
                </main>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                <script src="${pageContext.request.contextPath}/static/js/app.js?v=2.5"></script>
            </body>

            </html>
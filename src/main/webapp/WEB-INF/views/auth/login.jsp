<%-- File: WEB-INF/views/auth/login.jsp. Controller: AuthController (GET/POST /login). Attributes: error, username, flashMsg, flashType --%>
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
                <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;800&display=swap"
                    rel="stylesheet">
                <style>
                    :root {
                        --violet: #7f83d6;
                        --violet-dark: #6a6ec4;
                        --ink: #1d1b3a;
                        --muted: #8a89a6;
                        --line: #d9d8ea
                    }

                    html,
                    body {
                        height: 100%
                    }

                    body {
                        font-family: "Manrope", system-ui, sans-serif;
                        color: var(--ink);
                        background: radial-gradient(circle at 15% 20%, #d6d4fa 0, transparent 45%),
                            radial-gradient(circle at 85% 85%, #a9a7fb 0, transparent 50%),
                            linear-gradient(135deg, #c3c1f4, #aeacf9);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        padding: 24px
                    }

                    .auth-card {
                        width: 100%;
                        max-width: 980px;
                        min-height: 540px;
                        display: flex;
                        border-radius: 24px;
                        overflow: hidden;
                        background: #fff;
                        box-shadow: 0 30px 60px rgba(90, 86, 180, .28)
                    }

                    /* Cột trái */
                    .auth-aside {
                        flex: 0 0 42%;
                        position: relative;
                        padding: 36px 32px;
                        color: #fff;
                        background: linear-gradient(160deg, #8e92e0, var(--violet));
                        overflow: hidden
                    }

                    .brand {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        font-weight: 800;
                        font-size: 1.05rem
                    }

                    .brand i {
                        font-size: 1.5rem
                    }

                    .aside-title {
                        margin: 28px 0 8px;
                        font-size: 1.6rem;
                        font-weight: 600;
                        line-height: 1.35
                    }

                    .aside-sub {
                        margin: 0;
                        opacity: .85;
                        font-size: .95rem;
                        max-width: 24ch
                    }

                    .tiles {
                        position: absolute;
                        left: 50%;
                        bottom: 28px;
                        width: 270px;
                        height: 270px;
                        transform: translateX(-50%);
                        display: grid;
                        grid-template-columns: repeat(3, 1fr);
                        gap: 10px
                    }

                    .tile {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        border-radius: 18px;
                        font-size: 1.9rem;
                        font-weight: 600;
                        color: #fff;
                        background: linear-gradient(145deg, rgba(255, 255, 255, .55), rgba(255, 255, 255, .12));
                        border: 1px solid rgba(255, 255, 255, .45);
                        box-shadow: 0 10px 22px rgba(60, 56, 150, .25)
                    }

                    .tile.pink {
                        background: linear-gradient(145deg, #f7d6ee, #e9b9e6);
                        color: #8a4a96
                    }

                    .tile.pearl {
                        background: linear-gradient(145deg, #fff, #dcdcf3);
                        color: #6a6ec4
                    }

                    .tile.violet {
                        background: linear-gradient(145deg, #a9a4f0, #7f7ad8)
                    }

                    .tile:nth-child(2n) {
                        transform: translateY(-14px)
                    }

                    .tile:nth-child(3n) {
                        transform: translateY(10px)
                    }

                    /* Cột phải */
                    .auth-main {
                        flex: 1;
                        padding: 48px 56px;
                        display: flex;
                        flex-direction: column;
                        justify-content: center;
                        overflow-y: auto
                    }

                    .auth-main h1 {
                        font-size: 1.6rem;
                        font-weight: 800;
                        margin-bottom: 6px
                    }

                    .auth-main .lead {
                        color: var(--muted);
                        font-size: .95rem;
                        margin-bottom: 24px
                    }

                    .field {
                        margin-bottom: 20px
                    }

                    .field label {
                        font-size: .8rem;
                        font-weight: 600;
                        color: var(--muted);
                        margin-bottom: 2px;
                        display: block
                    }

                    .field .form-control {
                        border: 0;
                        border-bottom: 1.5px solid var(--line);
                        border-radius: 0;
                        padding: 8px 0;
                        background: transparent;
                        box-shadow: none !important;
                        font-size: 1rem
                    }

                    .field .form-control:focus {
                        border-bottom-color: var(--violet-dark)
                    }

                    .field .form-control::placeholder {
                        color: #b6b5cc
                    }

                    .field .form-control.is-invalid {
                        border-bottom-color: #dc3545
                    }

                    .field .invalid-feedback {
                        font-size: .78rem
                    }

                    .pw-wrap {
                        position: relative
                    }

                    .pw-wrap .form-control {
                        padding-right: 36px
                    }

                    .pw-toggle {
                        position: absolute;
                        right: 0;
                        top: 50%;
                        transform: translateY(-50%);
                        border: 0;
                        background: none;
                        color: var(--ink);
                        font-size: 1.1rem;
                        padding: 4px
                    }

                    .btn-login {
                        width: 100%;
                        padding: 12px;
                        border: 0;
                        border-radius: 12px;
                        background: var(--violet);
                        color: #fff;
                        font-weight: 600;
                        transition: background .2s
                    }

                    .btn-login:hover {
                        background: var(--violet-dark);
                        color: #fff
                    }

                    .btn-login:disabled {
                        opacity: .7
                    }

                    .help {
                        margin-top: 18px;
                        font-size: .82rem;
                        color: var(--muted)
                    }

                    .demo-box {
                        margin-top: 16px;
                        padding: 10px 14px;
                        background: #f4f3fd;
                        border-radius: 10px;
                        font-size: .78rem;
                        color: var(--muted)
                    }

                    .demo-box strong {
                        color: var(--ink);
                        display: block;
                        margin-bottom: 4px
                    }

                    @media(max-width:767.98px) {
                        .auth-aside {
                            display: none
                        }

                        .auth-main {
                            padding: 36px 24px
                        }
                    }
                </style>
            </head>

            <body>
                <main class="auth-card">
                    <%-- Cột trái --%>
                        <aside class="auth-aside" aria-hidden="true">
                            <div class="brand"><i class="bi bi-calculator-fill"></i> MathTutor 12</div>
                            <p class="aside-title">Học Toán 12 cùng gia sư AI</p>
                            <p class="aside-sub">Gợi ý từng bước, không đưa đáp án ngay.</p>
                            <div class="tiles">
                                <div class="tile pearl">&int;</div>
                                <div class="tile violet">&pi;</div>
                                <div class="tile pink">&radic;</div>
                                <div class="tile pink">&sum;</div>
                                <div class="tile">x&sup2;</div>
                                <div class="tile pearl">&infin;</div>
                                <div class="tile violet">&Delta;</div>
                                <div class="tile pearl">log</div>
                                <div class="tile pink">&theta;</div>
                            </div>
                        </aside>

                        <%-- Cột phải --%>
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
                                    <div class="alert alert-${empty flashType ? 'success' : flashType} py-2 mb-3" role="alert">
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

                                <p class="help">Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register" style="color:var(--violet-dark);font-weight:600;text-decoration:none">Đăng ký ngay</a></p>

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
                <script src="${pageContext.request.contextPath}/static/js/app.js"></script>
            </body>

            </html>
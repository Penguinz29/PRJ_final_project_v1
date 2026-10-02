<%-- error.jsp: trang lỗi chung (403/404/500) --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Lỗi | MathTutor 12</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                    rel="stylesheet">
                <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;600;700&display=swap"
                    rel="stylesheet">
                <style>
                    body {
                        font-family: 'Be Vietnam Pro', system-ui, sans-serif;
                        background: #F8FAFC;
                    }

                    .error-wrap {
                        min-height: 100vh;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }

                    .error-card {
                        background: #fff;
                        border-radius: 16px;
                        padding: 3rem 2.5rem;
                        text-align: center;
                        box-shadow: 0 4px 24px rgba(15, 23, 42, .08);
                        max-width: 420px;
                        width: 100%;
                    }

                    .error-code {
                        font-size: 5rem;
                        font-weight: 700;
                        line-height: 1;
                        margin-bottom: .5rem;
                    }
                </style>
            </head>

            <body>
                <div class="error-wrap">
                    <div class="error-card">
                        <c:choose>
                            <c:when test="${pageContext.errorData.statusCode == 403}">
                                <div class="error-code text-warning">403</div>
                                <i class="bi bi-shield-lock fs-1 text-warning mb-3 d-block"></i>
                                <h1 class="fs-4 fw-bold mb-2">Không có quyền truy cập</h1>
                                <p class="text-muted mb-4">Bạn không có quyền truy cập trang này. Vui lòng liên hệ quản
                                    trị viên.</p>
                            </c:when>
                            <c:when test="${pageContext.errorData.statusCode == 404}">
                                <div class="error-code text-primary">404</div>
                                <i class="bi bi-compass fs-1 text-primary mb-3 d-block"></i>
                                <h1 class="fs-4 fw-bold mb-2">Trang không tồn tại</h1>
                                <p class="text-muted mb-4">Trang bạn tìm kiếm không được tìm thấy.</p>
                            </c:when>
                            <c:otherwise>
                                <div class="error-code text-danger">500</div>
                                <i class="bi bi-exclamation-octagon fs-1 text-danger mb-3 d-block"></i>
                                <h1 class="fs-4 fw-bold mb-2">Lỗi hệ thống</h1>
                                <p class="text-muted mb-4">Đã xảy ra lỗi. Vui lòng thử lại sau hoặc liên hệ quản trị
                                    viên.</p>
                            </c:otherwise>
                        </c:choose>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary px-4">
                            <i class="bi bi-house me-2"></i>Về trang chủ
                        </a>
                    </div>
                </div>
                <!-- EXCEPTION DETAIL
                <c:if test="${not empty exception}">
                    Message: ${exception.message}
                    <% exception.printStackTrace(new java.io.PrintWriter(out)); %>
                </c:if>
                -->
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>
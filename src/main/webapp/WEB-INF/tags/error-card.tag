<%-- error-card.tag: khung trang lỗi dùng chung cho error/403.jsp, 404.jsp, 500.jsp --%>
<%@ tag language="java" pageEncoding="UTF-8" body-content="scriptless" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="code" required="true" type="java.lang.String" %>
<%@ attribute name="color" required="true" type="java.lang.String" %>
<%@ attribute name="icon" required="true" type="java.lang.String" %>
<%@ attribute name="title" required="true" type="java.lang.String" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lỗi ${code} | MathTutor 9</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;600;700&display=swap"
        rel="stylesheet">
    <style>
        body { font-family: 'Be Vietnam Pro', system-ui, sans-serif; background: #F8FAFC; }
        .error-wrap { min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .error-card { background: #fff; border-radius: 16px; padding: 3rem 2.5rem; text-align: center;
                      box-shadow: 0 4px 24px rgba(15, 23, 42, .08); max-width: 420px; width: 100%; }
        .error-code { font-size: 5rem; font-weight: 700; line-height: 1; margin-bottom: .5rem; }
    </style>
</head>

<body>
    <div class="error-wrap">
        <div class="error-card">
            <div class="error-code text-${color}">${code}</div>
            <i class="bi ${icon} fs-1 text-${color} mb-3 d-block"></i>
            <h1 class="fs-4 fw-bold mb-2"><c:out value="${title}" /></h1>
            <p class="text-muted mb-4"><jsp:doBody /></p>
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary px-4">
                <i class="bi bi-house me-2"></i>Về trang chủ
            </a>
        </div>
    </div>
</body>

</html>

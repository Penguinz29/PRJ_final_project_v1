<%-- head.jsp: mở <html>,

    <head>, CDN, CSS. Param: title --%>
        <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <meta name="csrf-token" content="${sessionScope.CSRF_TOKEN}">
                    <title>${fn:escapeXml(not empty param.title ? param.title : 'MathTutor 12')} | MathTutor 12</title>

                    <!-- Bootstrap CSS -->
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <!-- Bootstrap Icons -->
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                        rel="stylesheet">
                    <!-- KaTeX CSS -->
                    <link href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css" rel="stylesheet">
                    <!-- Google Font: Be Vietnam Pro -->
                    <link
                        href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <!-- App CSS -->
                    <link href="${pageContext.request.contextPath}/static/css/style.css?v=2.5" rel="stylesheet">
                </head>
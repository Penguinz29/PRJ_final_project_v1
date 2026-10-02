<%-- footer.jsp: Bootstrap bundle, KaTeX auto-render, app.js, đóng body/html --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <!-- Bootstrap Bundle (JS) -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <!-- KaTeX JS -->
        <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
        <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"
            onload="renderMathInElement(document.body,{delimiters:[{left:'$$',right:'$$',display:true},{left:'$',right:'$',display:false}],throwOnError:false})"></script>
        <!-- App JS -->
        <script src="${pageContext.request.contextPath}/static/js/app.js"></script>
        </body>

        </html>
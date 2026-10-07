<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" trimDirectiveWhitespaces="true" %>
<%@ attribute name="value" required="false" type="java.lang.Object" %>
<%-- Hiển thị nội dung có HTML đơn giản (p, ul, b...) đã sanitize; công thức $...$ vẫn do KaTeX render --%>
<%= com.edututor.util.HtmlSanitizer.toSafeHtml(value == null ? null : value.toString()) %>

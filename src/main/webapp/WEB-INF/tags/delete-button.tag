<%-- delete-button.tag: nút Xóa của trang quản lý (chủ đề / bài học / câu hỏi), báo trước kết quả theo BR-05.
     mode (do server tính): HARD = xóa hẳn | SOFT = ẩn khỏi trang quản lý, giữ lịch sử | BLOCKED = còn mục con đang hoạt động.
     Mọi chuỗi đưa vào thuộc tính HTML đều qua fn:escapeXml (chống XSS). Server vẫn kiểm tra lại khi xóa. --%>
<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ attribute name="form" required="true" type="java.lang.String" %>
<%@ attribute name="mode" type="java.lang.String" %>
<%@ attribute name="question" required="true" type="java.lang.String" %>
<%@ attribute name="softNote" type="java.lang.String" %>
<%@ attribute name="blockedReason" type="java.lang.String" %>

<c:choose>
    <c:when test="${mode == 'BLOCKED'}">
        <span class="d-inline-block" tabindex="0" title="${fn:escapeXml(blockedReason)}" data-bs-toggle="tooltip">
            <button type="button" class="btn btn-sm btn-outline-danger" disabled aria-label="Không thể xóa">
                <i class="bi bi-trash3"></i>
            </button>
        </span>
    </c:when>
    <c:otherwise>
        <c:set var="note" value="${mode == 'SOFT' ? softNote
                : 'Chưa có học sinh nào làm nên sẽ bị xóa hẳn và không hoàn tác được.'}" />
        <button type="button" class="btn btn-sm btn-outline-danger" data-confirm="true" data-form="${form}"
                data-confirm-message="${fn:escapeXml(question.concat(' ').concat(note))}"
                title="${mode == 'SOFT' ? 'Ẩn (xóa mềm)' : 'Xóa'}">
            <i class="bi ${mode == 'SOFT' ? 'bi-eye-slash' : 'bi-trash3'}"></i>
        </button>
    </c:otherwise>
</c:choose>

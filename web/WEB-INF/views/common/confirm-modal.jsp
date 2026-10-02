<%-- confirm-modal.jsp: modal xác nhận xóa dùng chung --%>
    <%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
        <!-- Modal Xác nhận -->
        <div class="modal fade" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-sm">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header border-0 pb-0">
                        <h5 class="modal-title" id="confirmModalLabel">
                            <i class="bi bi-exclamation-triangle-fill text-warning me-2"></i>Xác nhận
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body pt-2">
                        <p id="confirmMessage" class="mb-0 text-muted">Bạn có chắc muốn thực hiện thao tác này?</p>
                    </div>
                    <div class="modal-footer border-0 pt-1">
                        <button type="button" class="btn btn-sm btn-outline-secondary"
                            data-bs-dismiss="modal">Hủy</button>
                        <button type="button" class="btn btn-sm btn-danger" id="confirmOkBtn">Xác nhận</button>
                    </div>
                </div>
            </div>
        </div>
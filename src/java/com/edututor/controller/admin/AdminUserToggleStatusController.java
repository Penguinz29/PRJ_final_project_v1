package com.edututor.controller.admin;

import com.edututor.dao.UserDAO;
import com.edututor.model.User;
import com.edututor.util.Validator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * FR-ADM-03: Quản trị tài khoản người dùng, thay đổi trạng thái kích hoạt hoặc khóa tài khoản
 */
@WebServlet("/admin/users/toggle-status")
public class AdminUserToggleStatusController extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("LOGGED_IN_USER");

        int targetUserId = Validator.getInt(req, "userId", 0);
        String returnUrl = req.getParameter("returnUrl");

        if (targetUserId <= 0) {
            session.setAttribute("errorFlash", "ID người dùng không hợp lệ.");
            doRedirect(req, resp, returnUrl);
            return;
        }

        // Kiểm tra không cho phép tự khóa tài khoản của chính mình
        if (currentUser != null && currentUser.getUserId() == targetUserId) {
            session.setAttribute("errorFlash", "Bạn không thể tự khóa tài khoản quản trị viên của chính mình!");
            doRedirect(req, resp, returnUrl);
            return;
        }

        User targetUser = userDAO.getById(targetUserId);
        if (targetUser == null) {
            session.setAttribute("errorFlash", "Người dùng không tồn tại trong hệ thống.");
            doRedirect(req, resp, returnUrl);
            return;
        }

        boolean success = userDAO.toggleStatus(targetUserId);
        if (success) {
            // targetUser.isActive() là trạng thái trước khi toggle
            if (targetUser.isActive()) {
                session.setAttribute("flash", "Đã khóa tài khoản " + targetUser.getUsername() + " thành công!");
            } else {
                session.setAttribute("flash", "Đã kích hoạt lại tài khoản " + targetUser.getUsername() + " thành công!");
            }
        } else {
            session.setAttribute("errorFlash", "Không thể cập nhật trạng thái tài khoản. Vui lòng thử lại!");
        }

        doRedirect(req, resp, returnUrl);
    }

    private void doRedirect(HttpServletRequest req, HttpServletResponse resp, String returnUrl) throws IOException {
        if (returnUrl != null && !returnUrl.trim().isEmpty() && returnUrl.startsWith(req.getContextPath())) {
            resp.sendRedirect(returnUrl);
        } else {
            String referer = req.getHeader("Referer");
            if (referer != null && !referer.isEmpty()) {
                resp.sendRedirect(referer);
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            }
        }
    }
}


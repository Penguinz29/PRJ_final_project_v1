package com.edututor.util;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Tiện ích xác thực dữ liệu đầu vào - EduTutor Math 12
 */
public class Validator {

    public static boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }

    public static int getInt(HttpServletRequest request, String paramName, int defaultValue) {
        String val = request.getParameter(paramName);
        if (isEmpty(val))
            return defaultValue;
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public static String getString(HttpServletRequest request, String paramName, String defaultValue) {
        String val = request.getParameter(paramName);
        return isEmpty(val) ? defaultValue : val.trim();
    }

    public static boolean isValidEmail(String email) {
        if (isEmpty(email))
            return false;
        return email.matches("^[A-Za-z0-9+_.-]+@(.+)$");
    }
}

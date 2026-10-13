package model;

/**
 * Trạng thái tài khoản; tên enum trùng giá trị CHECK của cột Users.Status.
 * ACTIVE: hoạt động • SUSPENDED: khóa tạm thời (Admin mở khóa được) • INACTIVE: xóa mềm (không mở khóa được).
 */
public enum UserStatus {
    ACTIVE, SUSPENDED, INACTIVE
}

package com.edututor.repository;

import com.edututor.model.Role;
import com.edututor.model.UserStatus;

/** Projection: số người dùng theo (vai trò, trạng thái) — dashboard Admin (UC-ADM-08). */
public interface RoleStatusCount {

    Role getRole();

    UserStatus getStatus();

    long getTotal();
}

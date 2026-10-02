package com.edututor.util;

import java.util.Set;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;

/** Tiện ích phân trang: chuẩn hóa tham số (VAL-22) và dựng {@link PageRequest} luôn có Sort (SQL Server cần ORDER BY). */
public final class Pager {

    public static final int DEFAULT_SIZE = 10;
    private static final Set<Integer> ALLOWED_SIZES = Set.of(10, 20, 50);

    private Pager() {
    }

    public static int getTotalPages(int recordCount, int pageSize) {
        if (recordCount <= 0 || pageSize <= 0) {
            return 0;
        }
        return (int) Math.ceil((double) recordCount / pageSize);
    }

    /** page &lt; 1 → 1; size ngoài {10, 20, 50} → 10 (không báo lỗi). */
    public static PageRequest pageRequest(int page, int size, Sort sort) {
        int p = Math.max(page, 1);
        int s = ALLOWED_SIZES.contains(size) ? size : DEFAULT_SIZE;
        return PageRequest.of(p - 1, s, sort);
    }
}

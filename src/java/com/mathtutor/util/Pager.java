package com.mathtutor.util;

public class Pager {
    public static int getTotalPages(int recordCount, int pageSize) {
        if (recordCount <= 0 || pageSize <= 0)
            return 0;
        return (int) Math.ceil((double) recordCount / pageSize);
    }
}

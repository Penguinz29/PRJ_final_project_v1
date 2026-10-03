package com.edututor.repository;

/** Projection: số lượt theo ngày (day = 'yyyy-MM-dd') — dashboard Admin (UC-ADM-08). */
public interface DailyCount {

    String getDay();

    Integer getTotal();
}

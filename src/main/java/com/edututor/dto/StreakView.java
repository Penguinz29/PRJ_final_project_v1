package com.edututor.dto;

import java.util.Set;

public class StreakView {
    private int currentStreak;
    private int currentMonthActiveDays;
    private int year;
    private int month;
    private Set<Integer> activeDaysInMonth;
    private int emptyOffsetCells;
    private int daysInMonth;
    private int todayDayOfMonth;

    public StreakView(int currentStreak, int currentMonthActiveDays, int year, int month, Set<Integer> activeDaysInMonth, int emptyOffsetCells, int daysInMonth, int todayDayOfMonth) {
        this.currentStreak = currentStreak;
        this.currentMonthActiveDays = currentMonthActiveDays;
        this.year = year;
        this.month = month;
        this.activeDaysInMonth = activeDaysInMonth;
        this.emptyOffsetCells = emptyOffsetCells;
        this.daysInMonth = daysInMonth;
        this.todayDayOfMonth = todayDayOfMonth;
    }

    public int getCurrentStreak() { return currentStreak; }
    public int getCurrentMonthActiveDays() { return currentMonthActiveDays; }
    public int getYear() { return year; }
    public int getMonth() { return month; }
    public Set<Integer> getActiveDaysInMonth() { return activeDaysInMonth; }
    public int getEmptyOffsetCells() { return emptyOffsetCells; }
    public int getDaysInMonth() { return daysInMonth; }
    public int getTodayDayOfMonth() { return todayDayOfMonth; }
}

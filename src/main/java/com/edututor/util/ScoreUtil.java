package com.edututor.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Quy đổi điểm về thang 10, làm tròn tới 0.25 (BR-07). */
public final class ScoreUtil {

    private ScoreUtil() {
    }

    /** Ép về [0, 10] rồi làm tròn tới 0.25. */
    public static double roundQuarter(double raw) {
        double clamped = Math.min(10.0, Math.max(0.0, raw));
        return Math.round(clamped * 4.0) / 4.0;
    }

    public static BigDecimal toDecimal(double score) {
        return BigDecimal.valueOf(score).setScale(2, RoundingMode.HALF_UP);
    }

    /** Điểm có đúng là bội số của 0.25 hay không (VAL-20). */
    public static boolean isQuarterStep(double score) {
        return Math.abs(score * 4.0 - Math.rint(score * 4.0)) < 1e-9;
    }
}

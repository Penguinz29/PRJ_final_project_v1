package com.edututor.util;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class LatexNormalizerTest {

    private static final String AI_TABLE = "Cho hàm số $y = f(x)$ có bảng biến thiên như sau:\n"
            + "\\begin{center}\n\\begin{tabular}{c|ccccc}\n"
            + "$x$ & $-\\infty$ & & $0$ & & $+\\infty$ \\\\ \\hline\n"
            + "$y'$ & & $+$ & $0$ & $-$ & \\\\ \\hline\n"
            + "$y$ & & & $2$ & & \\\\\n"
            + " & & $/$ & & $\\setminus$ & \\\\\n"
            + " & $-\\infty$ & & & & $-\\infty$\n"
            + "\\end{tabular}\n\\center\nKhẳng định nào sau đây là đúng?";

    @Test
    void convertsTabularToDisplayArray() {
        String out = LatexNormalizer.normalize(AI_TABLE);
        assertTrue(out.contains("$$\\begin{array}{c|ccccc}"));
        assertTrue(out.contains("\\end{array}$$"));
        assertTrue(out.contains("\\nearrow"));
        assertTrue(out.contains("\\searrow"));
        assertFalse(out.contains("tabular"));
        assertFalse(out.contains("center"));
        assertTrue(out.startsWith("Cho hàm số $y = f(x)$"));
        assertTrue(out.endsWith("Khẳng định nào sau đây là đúng?"));
    }

    @Test
    void removesDollarSignsInsideTheArray() {
        String out = LatexNormalizer.normalize(AI_TABLE);
        String table = out.substring(out.indexOf("\\begin{array}"), out.indexOf("\\end{array}"));
        assertFalse(table.contains("$"));
    }

    @Test
    void turnsLiteralBackslashNIntoRealNewline() {
        String raw = "Hàm số liên tục.\\nĐạo hàm $y'=4x^3$.\\ny(-1)=3.\\nSo sánh";
        assertEquals("Hàm số liên tục.\nĐạo hàm $y'=4x^3$.\ny(-1)=3.\nSo sánh", LatexNormalizer.normalize(raw));
        assertEquals("a\n\nb", LatexNormalizer.normalize("a\\n\\nb"));
    }

    @Test
    void fixesRealAiExplanationFromDatabase() {
        String raw = "Hàm số liên tục trên đoạn $[-1; 3]$.\\nĐạo hàm $y' = 4x^3 - 16x$.\\nCho $y' = 0 \\Leftrightarrow"
                + " \\begin{bmatrix} x = 0 \\in [-1; 3] \\\\ x = -2 \\notin [-1; 3] \\end{bmatrix}$.\\nTính giá trị:\\n"
                + "$y(-1) = 3$.\\n$y(0) = 10$.\\nSo sánh các giá trị trên, ta được $\\min_{[-1; 3]} y = -6$.";
        String out = LatexNormalizer.normalize(raw);
        assertFalse(out.replace("\\notin", "").contains("\\n"));   // chỉ còn lệnh LaTeX \notin
        assertTrue(out.contains("\\notin"));
        assertTrue(out.contains("\\begin{bmatrix}"));
        assertEquals(6, out.chars().filter(c -> c == '\n').count());
    }

    @Test
    void addsMissingDelimiterAfterLeftAndRight() {
        assertEquals("$\\left[ \\begin{aligned} x &= -1 \\\\ x &= 3 \\end{aligned} \\right.$",
                LatexNormalizer.normalize("$\\left[ \\begin{aligned} x &= -1 \\\\ x &= 3 \\end{aligned} \\right$"));
        assertEquals("$\\left\\{ x \\right.$", LatexNormalizer.normalize("$\\left\\{ x \\right$"));
        String ok = "$\\left( a \\right) + \\left| b \\right| + \\left\\lfloor c \\right\\rfloor + \\leftarrow \\rightarrow$";
        assertEquals(ok, LatexNormalizer.normalize(ok));
    }

    @Test
    void separatesHlineGluedToNextRow() {
        assertEquals("a \\\\ \\hline y' & b", LatexNormalizer.normalize("a \\\\ \\hliney' & b"));
        assertEquals("a \\\\ \\hline\ny' & b", LatexNormalizer.normalize("a \\\\ \\hline\ny' & b"));
    }

    @Test
    void keepsLatexCommandsStartingWithN() {
        String s = "$x \\neq 0$, $a \\notin A$, $\\nabla f$, $\\nu$, $a \\ne b$, $A \\\\ n$";
        assertEquals(s, LatexNormalizer.normalize(s));
    }

    @Test
    void leavesPlainTextAndSupportedEnvironmentsAlone() {
        assertEquals("Tính $\\int_0^1 x\\,dx$", LatexNormalizer.normalize("Tính $\\int_0^1 x\\,dx$"));
        String cases = "$f(x)=\\begin{cases}1 & x>0\\\\0 & x\\le0\\end{cases}$";
        assertEquals(cases, LatexNormalizer.normalize(cases));
        assertEquals(null, LatexNormalizer.normalize(null));
    }

    @Test
    void wrapsBareLatexRunsButKeepsVietnameseProse() {
        assertEquals("đồng biến $/ (-1,0) \\cup (1;+\\infty)$",
                LatexNormalizer.wrapBareMath("đồng biến / (-1,0) \\cup (1;+\\infty)"));
        assertEquals("$y = \\sqrt[3]{(x^2-4)^2}$", LatexNormalizer.wrapBareMath("y = \\sqrt[3]{(x^2-4)^2}"));
        assertEquals("Viết nhầm từ $(-\\infty; 0)$ thành (-1; 0).",
                LatexNormalizer.wrapBareMath("Viết nhầm từ (-\\infty; 0) thành (-1; 0)."));
    }

    @Test
    void wrapBareMathLeavesTextWithDollarsOrNoLatexAlone() {
        assertEquals("Tính $\\int x\\,dx$", LatexNormalizer.wrapBareMath("Tính $\\int x\\,dx$"));
        assertEquals("nghịch biến / (0, 1)", LatexNormalizer.wrapBareMath("nghịch biến / (0, 1)"));
        assertEquals(null, LatexNormalizer.wrapBareMath(null));
    }
}

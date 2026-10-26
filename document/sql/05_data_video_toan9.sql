-- =====================================================================================================================
-- File: document/sql/05_data_video_toan9.sql — video bài giảng VietJack (kênh YouTube "VietJack Tiểu học & THCS") cho từng bài Toán 9 KNTT
-- Chạy SAU 04_data_sgk_toan9.sql (04 xóa và nạp lại bài học nên video phải nạp lại sau mỗi lần chạy 04).
-- Bài 1-32: 1 video "Bài giảng" của VietJack; Luyện tập chung và Bài tập cuối chương: 1 video "Giải bài tập" (VietJack không có video bài giảng cho các bài này).
-- Ghép theo tiêu đề bài học trong 04; chạy lại nhiều lần an toàn: video YouTube cũ của các bài này bị xóa rồi nạp lại. Nguồn: các trang vietjack.com/toan-9-kn/
-- =====================================================================================================================
USE MathTutorDB;
GO

SET NOCOUNT ON;

DECLARE @t1 INT = (SELECT UserId FROM Users WHERE Username = 'teacher1');

DECLARE @v TABLE (LessonTitle NVARCHAR(300), VideoTitle NVARCHAR(200), Url VARCHAR(500), OrderIndex INT);
INSERT INTO @v (LessonTitle, VideoTitle, Url, OrderIndex) VALUES
(N'Bài 1. Khái niệm phương trình và hệ hai phương trình bậc nhất hai ẩn', N'Bài giảng', 'https://www.youtube.com/embed/11EXtByHKvU', 1),
(N'Bài 2. Giải hệ hai phương trình bậc nhất hai ẩn', N'Bài giảng', 'https://www.youtube.com/embed/oQa-SC8V7s0', 1),
(N'Bài 3. Giải bài toán bằng cách lập hệ phương trình', N'Bài giảng', 'https://www.youtube.com/embed/2HJjbxYDQUk', 1),
(N'Bài 4. Phương trình quy về phương trình bậc nhất một ẩn', N'Bài giảng', 'https://www.youtube.com/embed/rduoKFhA9PM', 1),
(N'Bài 5. Bất đẳng thức và tính chất', N'Bài giảng', 'https://www.youtube.com/embed/-ISgez1h8Zk', 1),
(N'Bài 6. Bất phương trình bậc nhất một ẩn', N'Bài giảng', 'https://www.youtube.com/embed/GdcsBcwKsUc', 1),
(N'Bài 7. Căn bậc hai và căn thức bậc hai', N'Bài giảng', 'https://www.youtube.com/embed/f3xR74F7Qb4', 1),
(N'Bài 8. Khai căn bậc hai với phép nhân và phép chia', N'Bài giảng', 'https://www.youtube.com/embed/PqEkuEa7Kco', 1),
(N'Bài 9. Biến đổi đơn giản và rút gọn biểu thức chứa căn thức bậc hai', N'Bài giảng', 'https://www.youtube.com/embed/0pJjIzMQU4k', 1),
(N'Bài 10. Căn bậc ba và căn thức bậc ba', N'Bài giảng', 'https://www.youtube.com/embed/bFfH0NimWMQ', 1),
(N'Bài 11. Tỉ số lượng giác của góc nhọn', N'Bài giảng', 'https://www.youtube.com/embed/ndcDhjs_4BI', 1),
(N'Bài 12. Một số hệ thức giữa cạnh, góc trong tam giác vuông và ứng dụng', N'Bài giảng', 'https://www.youtube.com/embed/0Ycuu1dHA10', 1),
(N'Bài 13. Mở đầu về đường tròn', N'Bài giảng', 'https://www.youtube.com/embed/mNsupUPcd2s', 1),
(N'Bài 14. Cung và dây của một đường tròn', N'Bài giảng', 'https://www.youtube.com/embed/GLig4exFNBo', 1),
(N'Bài 15. Độ dài của cung tròn. Diện tích hình quạt tròn và hình vành khuyên', N'Bài giảng', 'https://www.youtube.com/embed/w2Bdg5v4N4M', 1),
(N'Bài 16. Vị trí tương đối của đường thẳng và đường tròn', N'Bài giảng', 'https://www.youtube.com/embed/-pF31GttMh4', 1),
(N'Bài 17. Vị trí tương đối của hai đường tròn', N'Bài giảng', 'https://www.youtube.com/embed/1pLvr5ElClM', 1),
(N'Bài 18. Hàm số y = ax² (a ≠ 0)', N'Bài giảng', 'https://www.youtube.com/embed/W5_8gw5Ej-0', 1),
(N'Bài 19. Phương trình bậc hai một ẩn', N'Bài giảng', 'https://www.youtube.com/embed/KmgcEuv9VMA', 1),
(N'Bài 20. Định lí Viète và ứng dụng', N'Bài giảng', 'https://www.youtube.com/embed/0mLihGlVYNg', 1),
(N'Bài 21. Giải bài toán bằng cách lập phương trình', N'Bài giảng', 'https://www.youtube.com/embed/T3pB1NRto7c', 1),
(N'Bài 22. Bảng tần số và biểu đồ tần số', N'Bài giảng', 'https://www.youtube.com/embed/9C9PgEigXOw', 1),
(N'Bài 23. Bảng tần số tương đối và biểu đồ tần số tương đối', N'Bài giảng', 'https://www.youtube.com/embed/AePIM8Mjb5E', 1),
(N'Bài 24. Bảng tần số, tần số tương đối ghép nhóm và biểu đồ', N'Bài giảng', 'https://www.youtube.com/embed/v2SvesUIOb0', 1),
(N'Bài 25. Phép thử ngẫu nhiên và không gian mẫu', N'Bài giảng', 'https://www.youtube.com/embed/0KF8jNLGgTU', 1),
(N'Bài 26. Xác suất của biến cố liên quan tới phép thử', N'Bài giảng', 'https://www.youtube.com/embed/5rsbo3MhWXM', 1),
(N'Bài 27. Góc nội tiếp', N'Bài giảng', 'https://www.youtube.com/embed/6TmiZiYoMC8', 1),
(N'Bài 28. Đường tròn ngoại tiếp và đường tròn nội tiếp của một tam giác', N'Bài giảng', 'https://www.youtube.com/embed/AVarjYJ3vO8', 1),
(N'Bài 29. Tứ giác nội tiếp', N'Bài giảng', 'https://www.youtube.com/embed/Iusaj6YL2Is', 1),
(N'Bài 30. Đa giác đều', N'Bài giảng', 'https://www.youtube.com/embed/E1MSRJzOr1o', 1),
(N'Bài 31. Hình trụ và hình nón', N'Bài giảng', 'https://www.youtube.com/embed/X5tfH3YSaOM', 1),
(N'Bài 32. Hình cầu', N'Bài giảng', 'https://www.youtube.com/embed/9afXqUiUrGY', 1),
(N'Luyện tập chung (Chương I)', N'Giải bài tập', 'https://www.youtube.com/embed/AM7r0HsOMeo', 1),
(N'Bài tập cuối chương I', N'Giải bài tập', 'https://www.youtube.com/embed/iXm6_VUAH_4', 1),
(N'Luyện tập chung (Chương II)', N'Giải bài tập', 'https://www.youtube.com/embed/-AMOj4E-0Cg', 1),
(N'Bài tập cuối chương II', N'Giải bài tập', 'https://www.youtube.com/embed/KMYBFleixrQ', 1),
(N'Luyện tập chung (Bài 7 - Bài 8)', N'Giải bài tập', 'https://www.youtube.com/embed/G0jPsnCB9I4', 1),
(N'Luyện tập chung (Bài 9 - Bài 10)', N'Giải bài tập', 'https://www.youtube.com/embed/PNs8Jk96E_I', 1),
(N'Bài tập cuối chương III', N'Giải bài tập', 'https://www.youtube.com/embed/fxNqRAOSeNs', 1),
(N'Luyện tập chung (Chương IV)', N'Giải bài tập', 'https://www.youtube.com/embed/bonzgIOjIQs', 1),
(N'Bài tập cuối chương IV', N'Giải bài tập', 'https://www.youtube.com/embed/1ZAXr-odkf0', 1),
(N'Luyện tập chung (Bài 13 - Bài 15)', N'Giải bài tập', 'https://www.youtube.com/embed/E2u9y5LW3xs', 1),
(N'Luyện tập chung (Bài 16 - Bài 17)', N'Giải bài tập', 'https://www.youtube.com/embed/FmR9ojQab34', 1),
(N'Bài tập cuối chương V', N'Giải bài tập', 'https://www.youtube.com/embed/8b3BImf-xlo', 1),
(N'Luyện tập chung (Bài 18 - Bài 19)', N'Giải bài tập', 'https://www.youtube.com/embed/L2iktg0X8tw', 1),
(N'Luyện tập chung (Bài 20 - Bài 21)', N'Giải bài tập', 'https://www.youtube.com/embed/uVVj1ArZd0I', 1),
(N'Bài tập cuối chương VI', N'Giải bài tập', 'https://www.youtube.com/embed/HwcnV8eaMtI', 1),
(N'Luyện tập chung (Chương VII)', N'Giải bài tập', 'https://www.youtube.com/embed/xX-1wxvPyhc', 1),
(N'Bài tập cuối chương VII', N'Giải bài tập', 'https://www.youtube.com/embed/LmuW9OjNbog', 1),
(N'Luyện tập chung (Chương VIII)', N'Giải bài tập', 'https://www.youtube.com/embed/S_3CkBgCB5I', 1),
(N'Bài tập cuối chương VIII', N'Giải bài tập', 'https://www.youtube.com/embed/y-YK29LJ7TA', 1),
(N'Luyện tập chung (Bài 27 - Bài 28)', N'Giải bài tập', 'https://www.youtube.com/embed/Rb4d178Ecto', 1),
(N'Luyện tập chung (Bài 29 - Bài 30)', N'Giải bài tập', 'https://www.youtube.com/embed/xEF5I_ufM5k', 1),
(N'Bài tập cuối chương IX', N'Giải bài tập', 'https://www.youtube.com/embed/aR7Lb2DYe4A', 1),
(N'Luyện tập chung (Chương X)', N'Giải bài tập', 'https://www.youtube.com/embed/g0aWUUNQf4A', 1),
(N'Bài tập cuối chương X', N'Giải bài tập', 'https://www.youtube.com/embed/NXnT_ebd8RA', 1)
;


-- Xóa video YouTube cũ của các bài này (kể cả bản nạp trước có 2 video / tiêu đề "(VietJack)") rồi nạp lại: mỗi bài đúng 1 video.
DELETE m FROM LessonMaterials m JOIN Lessons l ON l.LessonId = m.LessonId
WHERE m.MaterialType = 'YOUTUBE' AND l.Title IN (SELECT LessonTitle FROM @v);

INSERT INTO LessonMaterials (LessonId, MaterialType, Title, Url, OrderIndex, CreatedBy)
SELECT l.LessonId, 'YOUTUBE', v.VideoTitle, v.Url, v.OrderIndex, @t1
FROM @v v
JOIN Lessons l ON l.Title = v.LessonTitle
WHERE NOT EXISTS (SELECT 1 FROM LessonMaterials m WHERE m.LessonId = l.LessonId AND m.Url = v.Url);

PRINT N'Đã nạp video VietJack: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' dòng (kỳ vọng 56 lần chạy đầu).';

-- Kiểm tra: bài học chưa có video (kỳ vọng 0 dòng)
SELECT l.Title FROM Lessons l WHERE NOT EXISTS (SELECT 1 FROM LessonMaterials m WHERE m.LessonId = l.LessonId AND m.MaterialType = 'YOUTUBE');
GO

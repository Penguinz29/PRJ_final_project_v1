package service;

import dto.form.MaterialForm;
import dto.view.MaterialView;
import exception.NotFoundException;
import model.LessonMaterial;
import model.MaterialType;
import repository.LessonMaterialRepository;
import repository.LessonRepository;
import repository.UserRepository;
import util.HtmlSanitizer;
import util.YoutubeUtil;
import java.net.URI;
import java.util.List;
import java.util.Locale;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Nghiệp vụ bài giảng của bài học (UC-TEA-03, UC-STU-02): VIDEO, YOUTUBE, LINK, TEXT. */
@Service
public class MaterialService {

    private final LessonMaterialRepository materialRepository;
    private final LessonRepository lessonRepository;
    private final UserRepository userRepository;

    public MaterialService(LessonMaterialRepository materialRepository, LessonRepository lessonRepository,
                           UserRepository userRepository) {
        this.materialRepository = materialRepository;
        this.lessonRepository = lessonRepository;
        this.userRepository = userRepository;
    }

    /** Bài giảng của bài học theo thứ tự hiển thị (dùng cho cả giáo viên lẫn học sinh). */
    @Transactional(readOnly = true)
    public List<MaterialView> getByLesson(int lessonId) {
        return materialRepository.findByLesson_LessonIdOrderByOrderIndexAscMaterialIdAsc(lessonId).stream()
                .map(MaterialService::toView).toList();
    }

    /** Tạo bài giảng; thiếu thứ tự thì xếp cuối danh sách. */
    @Transactional
    public void create(int lessonId, MaterialForm form, int teacherId) {
        if (!lessonRepository.existsByLessonIdAndActiveTrue(lessonId)) {
            throw new NotFoundException("Bài học không tồn tại.");
        }
        LessonMaterial m = new LessonMaterial();
        m.setLesson(lessonRepository.getReferenceById(lessonId));
        m.setCreatedBy(userRepository.getReferenceById(teacherId));
        apply(m, form);
        if (form.getOrderIndex() == null) {
            m.setOrderIndex(materialRepository.findMaxOrderIndex(lessonId) + 1);
        }
        materialRepository.save(m);
    }

    /**
     * Sửa bài giảng (mọi giáo viên được sửa).
     *
     * @return ID bài học chứa bài giảng (để chuyển hướng về đúng trang)
     */
    @Transactional
    public int update(int materialId, MaterialForm form, int actingUserId, boolean admin) {
        LessonMaterial m = requireExisting(materialId);
        apply(m, form);
        return m.getLesson().getLessonId();
    }

    /** Xóa bài giảng (mọi giáo viên được xóa). Trả về ID bài học chứa nó. */
    @Transactional
    public int delete(int materialId, int actingUserId, boolean admin) {
        LessonMaterial m = requireExisting(materialId);
        int lessonId = m.getLesson().getLessonId();
        materialRepository.delete(m);
        return lessonId;
    }

    private LessonMaterial requireExisting(int materialId) {
        return materialRepository.findWithOwnerByMaterialId(materialId)
                .orElseThrow(() -> new NotFoundException("Bài giảng không tồn tại."));
    }

    /** Gán dữ liệu từ form vào Entity sau khi kiểm tra ràng buộc theo loại (VAL-08). */
    private void apply(LessonMaterial m, MaterialForm form) {
        MaterialType type = MaterialType.valueOf(form.getMaterialType());
        validateContent(type, form.getUrl(), form.getContentText());
        m.setMaterialType(type);
        m.setTitle(HtmlSanitizer.clean(form.getTitle()));
        if (type == MaterialType.TEXT) {
            m.setUrl(null);
            m.setContentText(HtmlSanitizer.clean(form.getContentText()));
        } else {
            m.setUrl(form.getUrl());
            m.setContentText(null);
        }
        if (form.getOrderIndex() != null) {
            m.setOrderIndex(form.getOrderIndex());
        }
    }

    /**
     * Ràng buộc theo loại bài giảng (VAL-08):
     * YOUTUBE: link youtube.com / youtu.be có mã video 11 ký tự • VIDEO: http(s) và đuôi .mp4/.webm/.ogg •
     * LINK: http(s) (chặn javascript:, data:) • TEXT: nội dung không rỗng, tối đa 20.000 ký tự.
     *
     * @throws IllegalArgumentException với thông báo tiếng Việt
     */
    public static void validateContent(MaterialType type, String url, String contentText) {
        if (type == MaterialType.TEXT) {
            if (contentText == null || contentText.isBlank()) {
                throw new IllegalArgumentException("Bài giảng dạng văn bản phải có nội dung.");
            }
            if (contentText.length() > 20000) {
                throw new IllegalArgumentException("Nội dung bài giảng tối đa 20.000 ký tự.");
            }
            return;
        }
        if (url == null || url.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập đường dẫn (URL) của bài giảng.");
        }
        URI uri = parseHttpUri(url);
        switch (type) {
            case YOUTUBE -> {
                String host = uri.getHost().toLowerCase(Locale.ROOT);
                boolean youtubeHost = host.equals("youtu.be") || host.equals("youtube.com") || host.endsWith(".youtube.com");
                if (!youtubeHost || YoutubeUtil.extractId(url) == null) {
                    throw new IllegalArgumentException(
                            "Link YouTube không hợp lệ (dạng youtube.com/watch?v=…, youtu.be/… hoặc youtube.com/embed/…).");
                }
            }
            case VIDEO -> {
                String path = uri.getPath() == null ? "" : uri.getPath().toLowerCase(Locale.ROOT);
                if (!(path.endsWith(".mp4") || path.endsWith(".webm") || path.endsWith(".ogg"))) {
                    throw new IllegalArgumentException("Link video phải trỏ tới tệp .mp4, .webm hoặc .ogg.");
                }
            }
            default -> {
                // LINK: chỉ cần là http(s) hợp lệ
            }
        }
    }

    private static URI parseHttpUri(String url) {
        String lower = url.toLowerCase(Locale.ROOT);
        if (!(lower.startsWith("http://") || lower.startsWith("https://"))) {
            throw new IllegalArgumentException("Đường dẫn phải bắt đầu bằng http:// hoặc https://.");
        }
        try {
            URI uri = URI.create(url);
            if (uri.getHost() == null || uri.getHost().isBlank()) {
                throw new IllegalArgumentException("Đường dẫn không hợp lệ.");
            }
            return uri;
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Đường dẫn không hợp lệ.", e);
        }
    }

    private static MaterialView toView(LessonMaterial m) {
        MaterialView v = new MaterialView();
        v.setMaterialId(m.getMaterialId());
        v.setLessonId(m.getLesson().getLessonId());
        v.setMaterialType(m.getMaterialType().name());
        v.setTitle(HtmlSanitizer.toPlainText(m.getTitle()));
        v.setUrl(m.getUrl());
        v.setContentText(m.getContentText());
        v.setOrderIndex(m.getOrderIndex());
        v.setCreatedBy(m.getCreatedBy().getUserId());
        v.setCreatedByName(m.getCreatedBy().getFullName());
        v.setCreatedAt(ViewMapper.toDate(m.getCreatedAt()));
        return v;
    }
}

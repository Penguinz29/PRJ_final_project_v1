package controller.admin;

import dto.view.AiConfigView;
import dto.view.SessionUser;
import exception.ConfigValidationException;
import config.AuthInterceptor;
import service.AiConfigService;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** UC-ADM-06: xem / sửa cấu hình AI. (Test kết nối nằm ở AdminApiController: /api/admin/ai-config/test-connection.) */
@Controller
public class AdminAiConfigController {

    private final AiConfigService aiConfigService;

    public AdminAiConfigController(AiConfigService aiConfigService) {
        this.aiConfigService = aiConfigService;
    }

    @GetMapping("/admin/ai-config")
    public String list(Model model) {
        List<AiConfigView> configs = aiConfigService.getAllConfigs();
        Map<String, AiConfigView> byKey = new LinkedHashMap<>();
        for (AiConfigView c : configs) {
            byKey.put(c.getConfigKey(), c);
        }
        model.addAttribute("configs", configs);
        model.addAttribute("cfg", byKey);
        return "admin/ai-config";
    }

    /**
     * Cập nhật các tham số cấu hình AI trong một transaction. Chỉ khóa có gửi lên mới được cập nhật.
     * Có lỗi thì không khóa nào được ghi; form hiển thị lại giá trị vừa nhập kèm lỗi tại từng trường.
     */
    @PostMapping("/admin/ai-config/update")
    public String update(@RequestParam Map<String, String> params,
                         @SessionAttribute(AuthInterceptor.SESSION_USER) SessionUser admin,
                         RedirectAttributes redirect) {
        Map<String, String> values = new LinkedHashMap<>();
        for (String key : AiConfigService.EDITABLE_KEYS) {
            if (params.containsKey(key)) {
                String value = params.get(key);
                // Ô API key để trống nghĩa là giữ nguyên key hiện có (form không hiển thị lại key)
                if (AiConfigService.KEY_API_KEY.equals(key) && (value == null || value.isBlank())) {
                    continue;
                }
                values.put(key, value);
            }
        }
        try {
            aiConfigService.updateConfigs(values, admin.getUserId());
            redirect.addFlashAttribute("flash", "Cập nhật cấu hình AI thành công!");
        } catch (ConfigValidationException e) {
            values.remove(AiConfigService.KEY_API_KEY); // không đưa khóa bí mật trở lại trang
            redirect.addFlashAttribute("errorFlash", "Cấu hình chưa hợp lệ, vui lòng kiểm tra các trường được đánh dấu.");
            redirect.addFlashAttribute("fieldErrors", e.getErrors());
            redirect.addFlashAttribute("formValues", values);
        }
        return "redirect:/admin/ai-config";
    }
}

package com.edututor.controller.admin;

import com.edututor.dto.SessionUser;
import com.edututor.interceptor.AuthInterceptor;
import com.edututor.service.AiConfigService;
import java.util.LinkedHashMap;
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
        model.addAttribute("configs", aiConfigService.getAllConfigs());
        return "admin/ai-config";
    }

    /** Cập nhật các tham số cấu hình AI trong một transaction. Chỉ khóa có gửi lên mới được cập nhật. */
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
        } catch (IllegalArgumentException e) {
            redirect.addFlashAttribute("errorFlash", e.getMessage());
        }
        return "redirect:/admin/ai-config";
    }
}

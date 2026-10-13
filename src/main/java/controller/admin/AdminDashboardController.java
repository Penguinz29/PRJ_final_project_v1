package controller.admin;

import service.StatsService;
import service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AdminDashboardController {

    private final StatsService statsService;
    private final UserService userService;

    public AdminDashboardController(StatsService statsService, UserService userService) {
        this.statsService = statsService;
        this.userService = userService;
    }

    @GetMapping("/admin/dashboard")
    public String dashboard(Model model) {
        model.addAllAttributes(statsService.adminStats());
        model.addAttribute("recentUsers", userService.getRecentUsers("TEACHER", 5));
        return "admin/dashboard";
    }
}

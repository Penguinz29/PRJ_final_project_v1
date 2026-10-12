package com.edututor.config;

import jakarta.servlet.Filter;
import jakarta.servlet.MultipartConfigElement;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRegistration;
import org.springframework.web.filter.CharacterEncodingFilter;
import org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer;

/** Thay cho web.xml: đăng ký DispatcherServlet "/" (Spring MVC 6, Servlet 6.0) bằng Java config. */
public class WebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    private static final long MAX_FILE = 5L * 1024 * 1024;       // mỗi tệp (ảnh / PDF / Word) tối đa 5 MB
    private static final long MAX_REQUEST = 11L * 1024 * 1024;   // 2 tệp (đề + đáp án) + phần dư của multipart

    @Override
    protected Class<?>[] getRootConfigClasses() {
        return new Class<?>[]{RootConfig.class};
    }

    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class<?>[]{WebConfig.class};
    }

    @Override
    protected String[] getServletMappings() {
        return new String[]{"/"};
    }

    /** Bắt buộc, nếu không tiếng Việt bị lỗi font. */
    @Override
    protected Filter[] getServletFilters() {
        return new Filter[]{new CharacterEncodingFilter("UTF-8", true)};
    }

    @Override
    protected void customizeRegistration(ServletRegistration.Dynamic registration) {
        registration.setMultipartConfig(new MultipartConfigElement(
                System.getProperty("java.io.tmpdir"), MAX_FILE, MAX_REQUEST, 0));
        registration.setAsyncSupported(true);
    }

    @Override
    public void onStartup(ServletContext ctx) throws ServletException {
        super.onStartup(ctx);
        ctx.setSessionTimeout(30); // phút
        ctx.getSessionCookieConfig().setHttpOnly(true);
        ctx.getSessionCookieConfig().setAttribute("SameSite", "Lax"); // Servlet 6.0
    }
}

package com.edututor.config;

import com.edututor.interceptor.AuthInterceptor;
import com.edututor.interceptor.CsrfInterceptor;
import java.util.concurrent.Executor;
import org.hibernate.validator.messageinterpolation.ParameterMessageInterpolator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ReloadableResourceBundleMessageSource;
import org.springframework.scheduling.concurrent.ConcurrentTaskExecutor;
import org.springframework.validation.Validator;
import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;
import org.springframework.web.multipart.MultipartResolver;
import org.springframework.web.multipart.support.StandardServletMultipartResolver;
import org.springframework.web.servlet.config.annotation.AsyncSupportConfigurer;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewResolverRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.view.JstlView;

/**
 * DispatcherServlet context: controller, view resolver (JSP), interceptor, tài nguyên tĩnh,
 * Bean Validation với thông báo tiếng Việt (messages.properties), hỗ trợ async cho các endpoint AI.
 * Không đăng ký Open-Session-In-View: Service tự map Entity sang DTO bên trong @Transactional.
 */
@Configuration
@EnableWebMvc
@ComponentScan(basePackages = {"com.edututor.controller", "com.edututor.exception", "com.edututor.interceptor"})
public class WebConfig implements WebMvcConfigurer {

    @Autowired
    private AuthInterceptor authInterceptor;

    @Autowired
    private CsrfInterceptor csrfInterceptor;

    @Autowired
    @Qualifier("aiExecutor")
    private Executor aiExecutor;

    @Override
    public void configureViewResolvers(ViewResolverRegistry registry) {
        registry.jsp("/WEB-INF/views/", ".jsp").viewClass(JstlView.class);
    }

    /** Thứ tự bắt buộc: phân quyền trước, kiểm tra CSRF sau. */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor).addPathPatterns("/**").excludePathPatterns("/static/**");
        registry.addInterceptor(csrfInterceptor).addPathPatterns("/**").excludePathPatterns("/static/**");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/static/**").addResourceLocations("/static/");
    }

    @Bean(name = "multipartResolver")
    public MultipartResolver multipartResolver() {
        return new StandardServletMultipartResolver();
    }

    /** Cho phép controller trả về CompletableFuture chạy trên executor AI; timeout 100 giây. */
    @Override
    public void configureAsyncSupport(AsyncSupportConfigurer configurer) {
        configurer.setTaskExecutor(new ConcurrentTaskExecutor(aiExecutor));
        configurer.setDefaultTimeout(100_000);
    }

    /** Thông báo (kể cả thông báo Bean Validation) lấy từ messages.properties, UTF-8. */
    @Bean
    public MessageSource messageSource() {
        ReloadableResourceBundleMessageSource ms = new ReloadableResourceBundleMessageSource();
        ms.setBasename("classpath:messages");
        ms.setDefaultEncoding("UTF-8");
        return ms;
    }

    /**
     * Bean Validation với thông báo tiếng Việt từ messages.properties. Dùng ParameterMessageInterpolator
     * (không phụ thuộc EL → chạy ổn trên Tomcat/NetBeans); {@link MessageSourceMessageInterpolator} nối nó với
     * MessageSource. (Không gọi setValidationMessageSource: nó bị setMessageInterpolator ghi đè.)
     */
    @Override
    public Validator getValidator() {
        LocalValidatorFactoryBean factory = new LocalValidatorFactoryBean();
        factory.setMessageInterpolator(
                new MessageSourceMessageInterpolator(messageSource(), new ParameterMessageInterpolator()));
        return factory;
    }
}

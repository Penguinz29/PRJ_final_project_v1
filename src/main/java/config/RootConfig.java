package config;

import exception.AiServiceException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import jakarta.persistence.EntityManagerFactory;
import java.util.Properties;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;
import org.springframework.core.env.Environment;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * Root ApplicationContext: DataSource (HikariCP), JPA/Hibernate, Spring Data repository, transaction, service.
 * Các biến môi trường / -D DB_URL, DB_USER, DB_PASS, UPLOAD_DIR ghi đè giá trị trong application.properties.
 */
@Configuration
@EnableTransactionManagement
@PropertySource("classpath:application.properties")
@EnableJpaRepositories(basePackages = "repository")
@ComponentScan(basePackages = {"service", "ai", "util"})
public class RootConfig {

    @Bean
    public static PropertySourcesPlaceholderConfigurer propertySourcesPlaceholderConfigurer() {
        return new PropertySourcesPlaceholderConfigurer();
    }

    /** HikariCP connection pool. */
    @Bean(destroyMethod = "close")
    public DataSource dataSource(@Value("${DB_URL:${db.url}}") String url,
                                 @Value("${DB_USER:${db.username}}") String user,
                                 @Value("${DB_PASS:${db.password}}") String pass,
                                 @Value("${db.pool.max-size:10}") int maxPoolSize) {
        HikariConfig cfg = new HikariConfig();
        cfg.setJdbcUrl(url);
        cfg.setUsername(user);
        cfg.setPassword(pass);
        cfg.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        cfg.setMaximumPoolSize(maxPoolSize);
        cfg.setPoolName("edututor-pool");
        cfg.setConnectionTimeout(10_000);
        return new HikariDataSource(cfg);
    }

    /** Hibernate quét Entity trong model lúc khởi động (không cần persistence.xml). */
    @Bean
    public LocalContainerEntityManagerFactoryBean entityManagerFactory(DataSource ds, Environment env) {
        LocalContainerEntityManagerFactoryBean emf = new LocalContainerEntityManagerFactoryBean();
        emf.setDataSource(ds);
        emf.setPackagesToScan("model");
        emf.setJpaVendorAdapter(new HibernateJpaVendorAdapter());
        Properties p = new Properties();
        for (String k : new String[]{"hibernate.hbm2ddl.auto", "hibernate.show_sql", "hibernate.format_sql",
                "hibernate.jdbc.batch_size", "hibernate.order_inserts", "hibernate.default_batch_fetch_size"}) {
            String v = env.getProperty(k);
            if (v != null) {
                p.setProperty(k, v);
            }
        }
        emf.setJpaProperties(p); // Hibernate 6 tự nhận dialect SQL Server
        return emf;
    }

    @Bean
    public JpaTransactionManager transactionManager(EntityManagerFactory emf) {
        return new JpaTransactionManager(emf);
    }

    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper().configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(10);
    }

    /**
     * Thread pool riêng cho các cuộc gọi AI (vài giây) để không chiếm luồng Tomcat (NFR-02).
     * Hàng đợi đầy thì từ chối bằng lỗi 503 "Hệ thống AI đang bận".
     */
    @Bean(name = "aiExecutor")
    public ThreadPoolTaskExecutor aiExecutor(@Value("${app.ai.executor.core:4}") int core,
                                             @Value("${app.ai.executor.max:8}") int max,
                                             @Value("${app.ai.executor.queue:50}") int queue) {
        ThreadPoolTaskExecutor ex = new ThreadPoolTaskExecutor();
        ex.setCorePoolSize(core);
        ex.setMaxPoolSize(max);
        ex.setQueueCapacity(queue);
        ex.setThreadNamePrefix("ai-");
        ex.setRejectedExecutionHandler((task, executor) -> {
            throw AiServiceException.userFacing("Hệ thống AI đang bận, vui lòng thử lại sau ít phút.", 503);
        });
        return ex;
    }
}

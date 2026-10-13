package config;

import jakarta.validation.MessageInterpolator;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.context.MessageSource;

/**
 * Bộ nội suy thông báo Bean Validation lấy văn bản từ Spring {@link MessageSource} (messages.properties, UTF-8)
 * mà KHÔNG cần thư viện EL: thay các placeholder dạng {@code {val.username.invalid}} bằng nội dung trong
 * messages.properties, rồi giao phần còn lại ({@code {min}}, {@code {max}}...) cho
 * {@link org.hibernate.validator.messageinterpolation.ParameterMessageInterpolator}.
 * <p>
 * (Gọi {@code LocalValidatorFactoryBean.setValidationMessageSource} rồi {@code setMessageInterpolator} sẽ khiến
 * cái sau ghi đè cái trước và mất messages.properties; lớp này gộp cả hai việc.)
 */
public class MessageSourceMessageInterpolator implements MessageInterpolator {

    private static final Pattern PLACEHOLDER = Pattern.compile("\\{([^{}]+)}");
    private static final int MAX_PASSES = 5;

    private final MessageSource messageSource;
    private final MessageInterpolator delegate;

    public MessageSourceMessageInterpolator(MessageSource messageSource, MessageInterpolator delegate) {
        this.messageSource = messageSource;
        this.delegate = delegate;
    }

    @Override
    public String interpolate(String template, Context context) {
        return interpolate(template, context, Locale.getDefault());
    }

    @Override
    public String interpolate(String template, Context context, Locale locale) {
        String resolved = template;
        for (int pass = 0; pass < MAX_PASSES; pass++) {
            String next = replaceKnownKeys(resolved, locale);
            if (next.equals(resolved)) {
                break;
            }
            resolved = next;
        }
        return delegate.interpolate(resolved, context, locale);
    }

    /** Chỉ thay những khóa có trong messages.properties; các tham số như {min}/{max} được giữ nguyên. */
    private String replaceKnownKeys(String text, Locale locale) {
        Matcher m = PLACEHOLDER.matcher(text);
        StringBuilder out = new StringBuilder();
        while (m.find()) {
            String message = messageSource.getMessage(m.group(1), null, null, locale);
            m.appendReplacement(out, Matcher.quoteReplacement(message != null ? message : m.group()));
        }
        m.appendTail(out);
        return out.toString();
    }
}

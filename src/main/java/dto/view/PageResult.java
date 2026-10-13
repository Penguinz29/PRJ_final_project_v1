package dto.view;

import java.util.List;
import java.util.function.Function;
import org.springframework.data.domain.Page;

/** Kết quả phân trang trả về từ Service (dựng từ {@code Page<Entity>} đã map sang DTO trong transaction). */
public class PageResult<T> {

    public static final int DEFAULT_SIZE = 10;

    private final List<T> items;
    private final int page;
    private final int size;
    private final long totalItems;
    private final int totalPages;

    public PageResult(List<T> items, int page, int size, long totalItems, int totalPages) {
        this.items = items;
        this.page = page;
        this.size = size;
        this.totalItems = totalItems;
        this.totalPages = totalPages;
    }

    /** @param page số trang Spring Data (bắt đầu từ 0) */
    public static <E, T> PageResult<T> of(Page<E> source, Function<E, T> mapper) {
        return new PageResult<>(source.getContent().stream().map(mapper).toList(),
                source.getNumber() + 1, source.getSize(), source.getTotalElements(), source.getTotalPages());
    }

    public List<T> getItems() { return items; }
    public int getPage() { return page; }
    public int getSize() { return size; }
    public long getTotalItems() { return totalItems; }
    public int getTotalPages() { return totalPages; }
}

package com.edututor.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Form bài giảng (VAL-08). Kiểm tra cú pháp bằng Bean Validation; ràng buộc theo loại (URL YouTube hợp lệ, đuôi
 * video, TEXT không rỗng...) kiểm tra ở {@code MaterialService}.
 */
public class MaterialForm {

    @NotBlank(message = "{val.material.type.required}")
    @Pattern(regexp = "VIDEO|YOUTUBE|LINK|TEXT", message = "{val.material.type.invalid}")
    private String materialType = "YOUTUBE";

    @NotBlank(message = "{val.material.title.required}")
    @Size(max = 200, message = "{val.material.title.size}")
    private String title = "";

    @Size(max = 500, message = "{val.material.url.size}")
    private String url = "";

    @Size(max = 20000, message = "{val.material.content.size}")
    private String contentText = "";

    @Min(value = 1, message = "{val.material.order.range}")
    @Max(value = 9999, message = "{val.material.order.range}")
    private Integer orderIndex;

    public String getMaterialType() { return materialType; }
    public void setMaterialType(String materialType) { this.materialType = materialType == null ? "" : materialType.trim(); }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title == null ? "" : title.trim(); }
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url == null ? "" : url.trim(); }
    public String getContentText() { return contentText; }
    public void setContentText(String contentText) { this.contentText = contentText == null ? "" : contentText.trim(); }
    public Integer getOrderIndex() { return orderIndex; }
    public void setOrderIndex(Integer orderIndex) { this.orderIndex = orderIndex; }
}

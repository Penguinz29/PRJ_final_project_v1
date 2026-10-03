package com.edututor.dto;

import com.edututor.util.YoutubeUtil;
import java.io.Serializable;
import java.util.Date;

/** DTO hiển thị bài giảng (VIDEO / YOUTUBE / LINK / TEXT) cho giáo viên và học sinh. */
public class MaterialView implements Serializable {
    private static final long serialVersionUID = 1L;

    private int materialId;
    private int lessonId;
    private String materialType;
    private String title;
    private String url;
    private String contentText;
    private int orderIndex;
    private int createdBy;
    private String createdByName;
    private Date createdAt;

    public int getMaterialId() { return materialId; }
    public void setMaterialId(int materialId) { this.materialId = materialId; }
    public int getLessonId() { return lessonId; }
    public void setLessonId(int lessonId) { this.lessonId = lessonId; }
    public String getMaterialType() { return materialType; }
    public void setMaterialType(String materialType) { this.materialType = materialType; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    public String getContentText() { return contentText; }
    public void setContentText(String contentText) { this.contentText = contentText; }
    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    /** Link nhúng riêng tư (youtube-nocookie) cho bài giảng YOUTUBE; null với loại khác. */
    public String getYoutubeEmbedUrl() {
        if (!"YOUTUBE".equals(materialType)) {
            return null;
        }
        String id = YoutubeUtil.extractId(url);
        return id == null ? null : "https://www.youtube-nocookie.com/embed/" + id;
    }
}

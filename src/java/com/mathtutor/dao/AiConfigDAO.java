package com.mathtutor.dao;

import com.mathtutor.model.AiConfig;
import com.mathtutor.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AiConfigDAO {

    /**
     * Lấy tất cả cấu hình AI
     */
    public List<AiConfig> getAll() {
        List<AiConfig> list = new ArrayList<>();
        String sql = "SELECT c.*, u.FullName AS UpdatedByName FROM AiConfigs c LEFT JOIN Users u ON c.UpdatedBy = u.UserId ORDER BY c.ConfigId";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapConfig(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy giá trị cấu hình theo key
     */
    public String getValue(String configKey) {
        String sql = "SELECT ConfigValue FROM AiConfigs WHERE ConfigKey = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, configKey);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("ConfigValue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Cập nhật giá trị cấu hình
     */
    public boolean update(String configKey, String configValue, int updatedBy) {
        String sql = "UPDATE AiConfigs SET ConfigValue = ?, UpdatedBy = ?, UpdatedAt = GETDATE() WHERE ConfigKey = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, configValue);
            ps.setInt(2, updatedBy);
            ps.setString(3, configKey);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private AiConfig mapConfig(ResultSet rs) throws SQLException {
        AiConfig c = new AiConfig();
        c.setConfigId(rs.getInt("ConfigId"));
        c.setConfigKey(rs.getString("ConfigKey"));
        c.setConfigValue(rs.getString("ConfigValue"));
        c.setDescription(rs.getString("Description"));
        int updBy = rs.getInt("UpdatedBy");
        if (!rs.wasNull()) c.setUpdatedBy(updBy);
        c.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        try { c.setUpdatedByName(rs.getString("UpdatedByName")); } catch (SQLException ex) {}
        return c;
    }
}

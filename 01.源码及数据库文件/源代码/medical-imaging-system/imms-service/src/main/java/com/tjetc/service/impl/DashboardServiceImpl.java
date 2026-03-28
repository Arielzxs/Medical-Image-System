package com.tjetc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.*;
import com.tjetc.mapper.*;
import com.tjetc.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class DashboardServiceImpl implements DashboardService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private ReportMapper reportMapper;

    @Autowired
    private ImageMapper imageMapper;

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private OperationLogMapper operationLogMapper;

    /**
     * 根据用户不同的身份决定用户首页面板的数据显示内容，同时查询相关数据
     * @param userId
     * @return
     */
    @Override
    public JsonResult getDashboardStats(Long userId) {
        User currentUser = userMapper.selectById(userId);
        if (currentUser == null) {
            return JsonResult.fail("未找到用户");
        }
        String role = currentUser.getRole();

        DashboardStatsDTO stats = new DashboardStatsDTO();

        // 为所有角色获取未读消息数
        QueryWrapper<Notification> notificationQueryWrapper = new QueryWrapper<>();
        notificationQueryWrapper.eq("user_id", userId).eq("is_read", false);
        stats.setUnreadMessages(notificationMapper.selectCount(notificationQueryWrapper));

        switch (role) {
            case "admin":
                stats.setTotalUsers(userMapper.selectCount(new QueryWrapper<>()));
                stats.setTotalReports(reportMapper.selectCount(new QueryWrapper<>()));
                stats.setTotalImages(imageMapper.selectCount(new QueryWrapper<>()));
                break;
            case "doctor":
            case "expert":
                QueryWrapper<Image> imageQueryWrapper = new QueryWrapper<>();
                imageQueryWrapper.eq("uploaded_by", userId);
                stats.setTotalImages(imageMapper.selectCount(imageQueryWrapper));

                QueryWrapper<Report> reportQueryWrapper = new QueryWrapper<>();
                reportQueryWrapper.eq("generated_by", userId);
                stats.setTotalReports(reportMapper.selectCount(reportQueryWrapper));
                stats.setTotalUsers(0); // 对医生/专家无此统计
                break;
            case "patient":
                QueryWrapper<Image> patientImageQuery = new QueryWrapper<>();
                patientImageQuery.eq("patient_id", userId);
                stats.setTotalImages(imageMapper.selectCount(patientImageQuery));

                List<Image> patientImages = imageMapper.selectList(patientImageQuery);
                if (!patientImages.isEmpty()) {
                    List<Long> imageIds = patientImages.stream().map(Image::getId).collect(Collectors.toList());
                    QueryWrapper<Report> patientReportQuery = new QueryWrapper<>();
                    patientReportQuery.in("image_id", imageIds);
                    stats.setTotalReports(reportMapper.selectCount(patientReportQuery));
                } else {
                    stats.setTotalReports(0);
                }
                stats.setTotalUsers(0); // 对患者无此统计
                break;
        }

        return JsonResult.success(stats);
    }
//    获取最近的操作日志
    @Override
    public JsonResult getRecentActivities() {
        QueryWrapper<OperationLog> queryWrapper = new QueryWrapper<>();
        queryWrapper.orderByDesc("created_at").last("limit 5");
        List<OperationLog> logs = operationLogMapper.selectList(queryWrapper);

        List<Long> userIds = logs.stream()
                .map(OperationLog::getUserId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());

        if (!userIds.isEmpty()) {
            List<User> users = userMapper.selectBatchIds(userIds);
            Map<Long, String> userMap = users.stream()
                    .collect(Collectors.toMap(User::getId, User::getUsername));
            logs.forEach(log -> log.setUsername(userMap.get(log.getUserId())));
        }

        return JsonResult.success(logs);
    }
}
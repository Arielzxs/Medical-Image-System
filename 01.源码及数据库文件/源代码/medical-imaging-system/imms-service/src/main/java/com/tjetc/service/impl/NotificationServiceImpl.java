package com.tjetc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Notification;
import com.tjetc.mapper.NotificationMapper;
import com.tjetc.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotificationServiceImpl implements NotificationService {
    @Autowired
    private NotificationMapper notificationMapper;
    @Override
    public JsonResult getUserNotifications(Long userId) {
        QueryWrapper<Notification> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId).eq("is_read", false)
                .orderByDesc("created_at");;
        List<Notification> notifications = notificationMapper.selectList(queryWrapper);
        return JsonResult.success(notifications);
    }

    @Override
    public JsonResult markAsRead(Long notificationId) {
        Notification notification = notificationMapper.selectById(notificationId);
        if (notification != null) {
            notification.setIsRead(true);
            notificationMapper.updateById(notification);
            return JsonResult.success("通知已标记为已读");
        }
        return JsonResult.fail("通知不存在");
    }
}

package com.tjetc.service;

import com.tjetc.common.api.JsonResult;

public interface NotificationService {
    JsonResult getUserNotifications(Long userId);

    JsonResult markAsRead(Long notificationId);
}

package com.tjetc.controller;

import com.tjetc.common.api.JsonResult;
import com.tjetc.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/notification")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @RequestMapping("/user/{userId}")
    public JsonResult getUserNotifications(@PathVariable Long userId) {
        return notificationService.getUserNotifications(userId);
    }

    @RequestMapping("/read/{notificationId}")
    public JsonResult markAsRead(@PathVariable Long notificationId) {
        return notificationService.markAsRead(notificationId);
    }
}
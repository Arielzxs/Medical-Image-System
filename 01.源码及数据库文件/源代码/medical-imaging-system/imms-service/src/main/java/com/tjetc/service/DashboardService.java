package com.tjetc.service;

import com.tjetc.common.api.JsonResult;

public interface DashboardService {
    JsonResult getDashboardStats(Long userId);

    JsonResult getRecentActivities();
}

package com.tjetc.controller;

import com.tjetc.common.api.JsonResult;
import com.tjetc.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/dashboard")
public class DashboardController {

    @Autowired
    private DashboardService dashboardService;
    //设置用户的首页面板数据
    @GetMapping("/stats")
    public JsonResult getStats(@RequestParam("userId") Long userId) {
        return dashboardService.getDashboardStats(userId);
    }
    //获取最近的操作日志，放在首页的最近活动处
    @GetMapping("/recent-activities")
    public JsonResult getRecentActivities() {
        return dashboardService.getRecentActivities();
    }
}
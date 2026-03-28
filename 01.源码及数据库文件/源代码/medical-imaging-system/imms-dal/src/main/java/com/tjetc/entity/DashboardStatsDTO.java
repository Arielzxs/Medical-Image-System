package com.tjetc.entity;

import lombok.Data;

//系统数据统计类
@Data
public class DashboardStatsDTO {
    //用户数目
    private long totalUsers;
    //报告数目
    private long totalReports;
    //影像数目
    private long totalImages;
    //未读消息数目
    private long unreadMessages;
}

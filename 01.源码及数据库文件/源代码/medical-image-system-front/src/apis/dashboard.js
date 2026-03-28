import request from "@/utils/request";

// 获取首页统计数据
export const getDashboardStats = (userId) => {
  return request({
    url: "/api/dashboard/stats",
    method: "get",
    params: { userId },
  });
};

// 获取最近操作
export const getRecentActivities = () => {
  return request({
    url: "/api/dashboard/recent-activities",
    method: "get",
  });
};

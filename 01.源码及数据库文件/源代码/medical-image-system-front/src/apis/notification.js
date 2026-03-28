import request from "@/utils/request";

// 获取用户通知
export const getUserNotifications = (userId) => {
  return request({
    url: `/api/notification/user/${userId}`,
    method: "get",
  });
};

// 标记为已读
export const markAsRead = (notificationId) => {
  return request({
    url: `/api/notification/read/${notificationId}`,
    method: "get",
  });
};

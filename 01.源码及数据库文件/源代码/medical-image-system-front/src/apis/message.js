import request from "@/utils/request";

// 获取当前用户的所有会话列表
export const getConversations = (userId) => {
  return request({
    url: "/api/messages",
    method: "get",
    params: { userId },
  });
};

// 获取与特定用户的消息历史记录
export const getMessagesWithUser = (userId, otherUserId) => {
  return request({
    url: `/api/messages/${otherUserId}`,
    method: "get",
    params: { userId },
  });
};

// 发送新消息
export const sendMessage = (data) => {
  return request({
    url: "/api/messages",
    method: "post",
    data,
    headers: { "Content-Type": "application/json;charset=utf-8" },
  });
};
//删除与一个人的全部会话
export const deleteConversation = (userId, otherUserId) => {
  return request({
    url: `/api/messages/conversation/${otherUserId}`,
    method: "delete",
    params: { userId },
  });
};
//删除单条消息
export const deleteMessage = (messageId) => {
  return request({
    url: `/api/messages/${messageId}`,
    method: "delete",
  });
};

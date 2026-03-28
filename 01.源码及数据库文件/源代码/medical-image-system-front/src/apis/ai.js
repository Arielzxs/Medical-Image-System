import request from "@/utils/request";

// 发送消息给AI
export const chatWithAi = (message) => {
  return request({
    url: "/api/ai/chat",
    method: "post",
    params: { message },
  });
};

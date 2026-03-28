import request from "@/utils/request";
import { sendMessage } from "./message";

// 分享影像
export const shareImage = async (data) => {
  const shareResponse = await request({
    url: "/api/share/image",
    method: "post",
    params: data,
  });

  await sendMessage({
    senderId: data.sharedBy,
    recipientId: data.sharedTo,
    content: `我向您分享了一个影像`,
    type: "share",
    imageId: data.imageId,
  });

  return shareResponse;
};

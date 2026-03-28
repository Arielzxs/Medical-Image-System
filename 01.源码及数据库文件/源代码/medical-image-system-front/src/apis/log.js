import request from "@/utils/request";

// 管理员分页查询用户操作日志
export const getLogPage = (data) => {
  return request({
    url: "/api/log/page",
    method: "get",
    params: data,
  });
};
// 删除日志
export const deleteLog = (id) => {
  return request({
    url: `/api/log/delete/${id}`,
    method: "get",
  });
};

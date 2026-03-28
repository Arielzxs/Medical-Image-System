import request from "@/utils/request";

// 创建报告
export const createReport = (data) => {
  return request({
    url: "/api/report/create",
    method: "post",
    data,
    headers: { "Content-Type": "application/json;charset=utf-8" },
  });
};

// 根据影像ID获取报告
export const getReportsByImageId = (imageId) => {
  return request({
    url: `/api/report/image/${imageId}`,
    method: "get",
  });
};

// 更新报告
export const updateReport = (data) => {
  return request({
    url: "/api/report/update",
    method: "post",
    data,
    headers: { "Content-Type": "application/json;charset=utf-8" },
  });
};

// 删除报告
export const deleteReport = (id) => {
  return request({
    url: `/api/report/delete/${id}`,
    method: "get", // Note: Backend uses GET for deletion here
  });
};

import request from "@/utils/request";

// 上传图片
export const uploadImage = (data) => {
  return request({
    url: "/api/image/upload",
    method: "post",
    data,
    headers: { "Content-Type": "multipart/form-data" },
  });
};

// 查询影像
export const searchImages = (searchType, params) => {
  let url = `/api/search/${searchType}`;
  if (searchType === "images") {
    url = "/api/search/images";
  }
  return request({
    url: url,
    method: "get",
    params,
  });
};

// 根据患者ID查询影像
export const searchImagesByPatientId = (patientId) => {
  return request({
    url: "/api/search/by-patient-id",
    method: "get",
    params: { patientId },
  });
};

// 根据患者姓名模糊查询影像
const searchByPatientName = (params) => {
  return request({
    url: "/api/search/by-patient-name",
    method: "get",
    params,
  });
};

// 根据上传者姓名模糊查询影像
const searchByUploaderName = (params) => {
  return request({
    url: "/api/search/by-uploaded-name",
    method: "get",
    params,
  });
};

// 删除影像
export const deleteImage = (id) => {
  return request({
    url: `/api/image/delete/${id}`,
    method: "get",
  });
};

// 根据ID获取影像详情
export const getImageById = (id) => {
  return request({
    url: `/api/image/${id}`,
    method: "get",
  });
};

import request from "@/utils/request";

// 登录
export const login = (data) => {
  return request({
    url: "/api/auth/login_id_card",
    method: "post",
    params: data,
  });
};
export const loginByPhone = (data) => {
  return request({
    url: "/api/auth/login_phone",
    method: "post",
    params: data,
  });
};
// 注册
export const register = (data) => {
  return request({
    url: "/api/auth/register",
    method: "post",
    data,
    headers: { "Content-Type": "application/json;charset=utf-8" },
  });
};

// 根据id查询用户信息
export const getUserById = (id) => {
  return request({
    url: `/api/user/${id}`,
    method: "get",
  });
};

// 更新用户
export const updateUser = (data) => {
  return request({
    url: "/api/user/update",
    method: "post",
    data,
    headers: { "Content-Type": "application/json;charset=utf-8" },
  });
};

// 按用户名搜索用户
export const searchUsers = (username) => {
  return request({
    url: "/api/user/search",
    method: "get",
    params: { username },
  });
};

// 管理员分页查询用户
export const adminPage = (data) => {
  return request({
    url: "/api/admin/page",
    method: "get",
    params: data,
  });
};

// 管理员根据id删除用户
export const adminDeleteById = (id) => {
  return request({
    url: `/api/admin/delete/${id}`,
    method: "delete",
  });
};

// 管理员新增用户
export const adminAdd = (data) => {
  return request({
    url: "/api/admin/add",
    method: "post",
    data,
    headers: { "Content-Type": "application/json;charset=utf-8" },
  });
};

// 管理员检查用户名是否存在
export const adminCheckExist = (username) => {
  return request({
    url: "/api/admin/check-exist",
    method: "get",
    params: { username },
  });
};

// 管理员获取用户详情
export const adminDetail = (id) => {
  return request({
    url: `/api/admin/detail/${id}`,
    method: "get",
  });
};

// 管理员更新用户
export const adminUpdate = (data) => {
  return request({
    url: "/api/admin/update",
    method: "post",
    data,
    headers: { "Content-Type": "application/json;charset=utf-8" },
  });
};

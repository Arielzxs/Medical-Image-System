
//定义User接口约束
export interface User {
  id?: number;
  username?: string;
  idCard?: string;
  age?: number;
  gender?: number;
  phone?: string;
  birthDate?: string; // 后端是 LocalDate，前端通常用字符串或Date对象处理
  address?: string;
  password?: string;
  role?: 'admin' | 'doctor' | 'expert' | 'patient'; // 使用联合类型明确角色
  createdAt?: string; // 后端是 LocalDateTime
  updatedAt?: string; // 后端是 LocalDateTime
  token?: string; // 登录成功后后端返回的token
}
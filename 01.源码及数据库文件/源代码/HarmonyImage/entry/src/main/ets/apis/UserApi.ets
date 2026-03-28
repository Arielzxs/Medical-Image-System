import { httpRequest, JsonResult } from '../utils/HttpUtil';
import { User } from '../viewmodel/UserModel';
import { LoginByIdCardParam, LoginByPhoneParam, RegisterParam } from '../params/request/UserRequestParam';
import { AxiosHeaders, InternalAxiosRequestConfig } from '@ohos/axios';

/**
 * 通过身份证号登陆
 * @param data 请求参数
 * @returns 返回用户信息的 Promise
 */

class UserApi {

  /**
   * 通过身份证号登录
   * @param data 请求参数
   * @returns 返回包含用户信息的Promise
   */
  loginByIdCard(data: LoginByIdCardParam): Promise<JsonResult<User>> {
    // 后端使用 @RequestParam，对应 'application/x-www-form-urlencoded'
    // HttpUtil 默认就是这种格式，所以不需要特殊配置
    return httpRequest.post<JsonResult<User>, LoginByIdCardParam>('/auth/login_id_card', data);
  }

  /**
   * 通过手机号登录
   * @param data 请求参数
   * @returns 返回包含用户信息的Promise
   */
  loginByPhone(data: LoginByPhoneParam): Promise<JsonResult<User>> {
    // 后端使用 @RequestParam，对应 'application/x-www-form-urlencoded'
    return httpRequest.post<JsonResult<User>, LoginByPhoneParam>('/auth/login_phone', data);
  }
  /**
   * 用户注册
   * @param data 用户注册信息
   * @returns 返回操作结果的Promise
   */
  register(data: RegisterParam): Promise<JsonResult<void>> {
    // 后端使用 @RequestBody，需要明确指定 Content-Type 为 'application/json'
    const config: InternalAxiosRequestConfig = {
      headers: new AxiosHeaders().set("Content-Type", 'application/json;charset=utf-8;')
    }
    return httpRequest.post<JsonResult<void>, RegisterParam>('/auth/register', data, config);
  }
  /**
   * 根据 id 查询 用户信息
   * @param id
   * @returns
   */
  getUserById(id: number): Promise<JsonResult<User>> {
    return httpRequest.get<JsonResult<User>, void>(`/user/${id}`);
  }
  /**
   * 更新用户信息
   * @param user
   * @returns
   */
  updateUser(user: User): Promise<JsonResult<void>> {
    // console.log(JSON.stringify(user))
    const config: InternalAxiosRequestConfig = {
      headers: new AxiosHeaders().set("Content-Type", 'application/json;charset=utf-8;')
    }
    return httpRequest.post<JsonResult<void>, User>('/user/update', user, config);
  }
}

// 导出UserApi的单例
export default new UserApi();
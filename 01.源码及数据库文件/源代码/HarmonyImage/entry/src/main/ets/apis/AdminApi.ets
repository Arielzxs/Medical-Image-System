
import { httpRequest, JsonResult } from '../utils/HttpUtil';
import { User } from '../viewmodel/UserModel';
import { PageResponse } from '../params/response/PageResponse';
import { AxiosHeaders, InternalAxiosRequestConfig } from '@ohos/axios';
import {GetPageRequestConfig} from '../viewmodel/PageModel'
class AdminApi {
  getPage(data:GetPageRequestConfig): Promise<JsonResult<PageResponse<User>>> {
    return httpRequest.post<JsonResult<PageResponse<User>>, GetPageRequestConfig>('/admin/page', data);
  }
  addUser(user: User): Promise<JsonResult<void>> {
    const config: InternalAxiosRequestConfig = {
      headers: new AxiosHeaders().set("Content-Type", 'application/json;charset=utf-8;')
    }
    return httpRequest.post<JsonResult<void>, User>('/admin/add', user, config);
  }

  updateUser(user: User): Promise<JsonResult<void>> {
    const config: InternalAxiosRequestConfig = {
      headers: new AxiosHeaders().set("Content-Type", 'application/json;charset=utf-8;')
    }
    return httpRequest.post<JsonResult<void>, User>('/admin/update', user, config);
  }

  deleteUser(id: number): Promise<JsonResult<void>> {
    return httpRequest.get<JsonResult<void>, void>(`/admin/delete/${id}`);
  }
}

export default new AdminApi();
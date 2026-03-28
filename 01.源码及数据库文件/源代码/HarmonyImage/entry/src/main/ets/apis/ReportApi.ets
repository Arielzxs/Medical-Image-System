import { HttpUtil, JsonResult } from '../utils/HttpUtil';
import { httpRequest} from '../utils/HttpUtil';
import { Report } from '../viewmodel/ReportModel';
import { AxiosHeaders, InternalAxiosRequestConfig } from '@ohos/axios';

/**
 * 报告相关的API服务
 */
class ReportApi {
  /**
   * 创建一份新的医疗报告
   */
  createReport(data: Report): Promise<JsonResult<void>> {
    const config: InternalAxiosRequestConfig = {
      headers: new AxiosHeaders().set("Content-Type", 'application/json;charset=utf-8;')
    }
    return httpRequest.post<JsonResult<void>, Report>('/report/create', data, config);
  }


  /**
   * 根据影像ID获取所有相关的报告
   */
  getReportsByImageId(imageId: number): Promise<JsonResult<Report[]>>{
     return httpRequest.get<JsonResult<Report[]>, void>(`/report/image/${imageId}`);
  }


  /**
   * 更新已有的医疗报告
   */
  updateReport = (data: Report): Promise<JsonResult<Report>> => {
    const config: InternalAxiosRequestConfig = {
      headers: new AxiosHeaders().set("Content-Type", 'application/json;charset=utf-8;')
    }
    return httpRequest.post<JsonResult<Report>, Report>('/report/update', data, config);
  }

  /**
   * 根据用户id删除指定报告
   */
  deleteReport = (id: number): Promise<JsonResult<string>> => {
    return httpRequest.get<JsonResult<string>, void>(`/report/delete/${id}`);
  }
}

// 导出ReportApi的单例
export default new ReportApi();
// File: entry/src/main/ets/apis/LogApi.ets

import { httpRequest, JsonResult } from '../utils/HttpUtil';
import  LogModel  from '../viewmodel/LogModel';
import { PageResponse } from '../params/response/PageResponse';
import { LogSearchParams } from '../params/request/LogSearchParams';

/**
 * 分页查询用户操作日志
 * @param params 日志查询参数，遵循 LogSearchParams 接口
 * @returns 返回一个包含日志分页数据的 Promise
 */
export async function getLogPage(params: LogSearchParams): Promise<PageResponse<LogModel>> {
  const url = '/log/page';

  // 创建一个干净的参数对象，移除 undefined 或 null 的字段
  const cleanParams: Partial<LogSearchParams> = {};
  if (params.pageNo) cleanParams.pageNo = params.pageNo;
  if (params.pageSize) cleanParams.pageSize = params.pageSize;
  if (params.username) cleanParams.username = params.username;
  if (params.operation) cleanParams.operation = params.operation;
  if (params.startDate) cleanParams.startDate = params.startDate;
  if (params.endDate) cleanParams.endDate = params.endDate;

  try {
    // 发起 GET 请求
    const response = await httpRequest.get<JsonResult<PageResponse<LogModel>>, Partial<LogSearchParams>>(url, cleanParams);
    // 检查返回结果的状态码
    if (response && response.state === 0 && response.data) {
      // 成功则返回分页数据
      return response.data;
    } else {
      // 失败则打印错误信息并返回一个空的分页结构
      console.error('获取日志列表失败:', response?.message || '未知错误');
      return { records: [], total: 0, pageNo: 1, pageSize: params.pageSize };
    }
  } catch (error) {
    // 网络或请求异常处理
    console.error('网络请求异常:', JSON.stringify(error));
    // 同样返回空结构以防页面崩溃
    return { records: [], total: 0, pageNo: 1, pageSize: params.pageSize };
  }
}

/**
 * 根据ID删除指定的日志
 * @param id 需要删除的日志的ID
 * @returns 返回一个布尔值表示删除是否成功
 */
export async function deleteLog(id: number): Promise<boolean> {
  // 构造请求URL
  const url = `/log/delete/${id}`;

  try {
    // 发起 GET 请求进行删除操作
    const response = await httpRequest.get<JsonResult<object>, void>(url);

    // 检查返回结果的状态码，成功则返回 true
    if (response && response.state === 0) {
      return true;
    } else {
      // 失败则记录错误并返回 false
      console.error('删除日志失败:', response?.message || '未知错误');
      return false;
    }
  } catch (error) {
    // 网络或请求异常处理
    console.error('删除日志的网络请求失败:', JSON.stringify(error));
    return false;
  }
}
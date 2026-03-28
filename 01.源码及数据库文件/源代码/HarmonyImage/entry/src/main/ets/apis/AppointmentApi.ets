import { httpRequest, JsonResult } from '../utils/HttpUtil';
import { AxiosHeaders, InternalAxiosRequestConfig } from '@ohos/axios';
import {AppointmentModel} from '../viewmodel/AppointmentModel';

/**
 * 创建预约时传递的数据类型
 * (与后端 Appointment 实体类对应)
 */
export interface CreateAppointmentParam {
  patientId: number;
  patientName: string;
  patientIdCard: string;
  appointmentType: string;
  appointmentContent: string;
  appointmentDate: string; // 格式: "YYYY-MM-DD"
  startTime: string; // 格式: "HH:mm:ss"
}
export interface AvailableSlotsParams {
  date: string; // 格式: "YYYY-MM-DD"
  type: string;
}
class AppointmentApi {

  /**
   * 获取可用时间段
   * @param date 日期，格式 "YYYY-MM-DD"
   * @param type 预约类型
   * @returns 返回可用时间段字符串数组的Promise
   */
  getAvailableSlots(params: AvailableSlotsParams): Promise<JsonResult<string[]>> {
    return httpRequest.get<JsonResult<string[]>, AvailableSlotsParams>(`/appointment/available-slots`, params );
  }

  /**
   * 创建预约
   * @param data 预约信息
   * @returns 返回包含新预约信息的Promise
   */
  createAppointment(data: CreateAppointmentParam): Promise<JsonResult<AppointmentModel>> {
    // 后端使用 @RequestBody，需要明确指定 Content-Type 为 'application/json'
    const config: InternalAxiosRequestConfig = {
      headers: new AxiosHeaders().set("Content-Type", 'application/json;charset=utf-8;')
    };
    return httpRequest.post<JsonResult<AppointmentModel>, CreateAppointmentParam>('/appointment/create', data, config);
  }

  /**
   * 取消预约
   * @param id 预约记录的ID
   * @returns 返回操作结果的Promise
   */
  cancelAppointment(id: number): Promise<JsonResult<void>> {
    return httpRequest.get<JsonResult<void>, void>(`/appointment/cancel/${id}`);
  }

  /**
   * 完成检查
   * @param id 预约记录的ID
   * @returns 返回操作结果的Promise
   */
  completeAppointment(id: number): Promise<JsonResult<void>> {
    return httpRequest.get<JsonResult<void>, void>(`/appointment/complete/${id}`);
  }

  /**
   * 获取指定患者的预约列表
   * @param patientId 患者ID
   * @returns 返回包含预约列表的Promise
   */
  getPatientAppointments(patientId: number): Promise<JsonResult<AppointmentModel[]>> {
    return httpRequest.get<JsonResult<AppointmentModel[]>, void>(`/appointment/list/patient/${patientId}`);
  }

  /**
   * 获取待报道和已报道的列表（医护端）
   * @returns 返回预约列表的Promise
   */
  getCheckInList(): Promise<JsonResult<AppointmentModel[]>> {
    return httpRequest.get<JsonResult<AppointmentModel[]>, void>('/appointment/check-in-list');
  }

  /**
   * 获取候诊列表（医护端）
   * @returns 返回预约列表的Promise
   */
  getWaitingList(): Promise<JsonResult<AppointmentModel[]>> {
    return httpRequest.get<JsonResult<AppointmentModel[]>, void>('/appointment/waiting-list');
  }

  /**
   * 为患者进行报道（医护端操作）
   * @param appointmentId 预约记录的ID
   * @returns 返回操作结果的Promise
   */
  checkIn(appointmentId: number): Promise<JsonResult<void>> {
    // 这是一个POST请求，但没有请求体
    return httpRequest.post<JsonResult<void>, void>(`/appointment/check-in/${appointmentId}`);
  }
}

export default new AppointmentApi();
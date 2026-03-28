/**
 * 影像搜索功能的请求参数接口
 */
export interface ImageSearchParams {
  patientName?: string;
  patientIdCard?: string;
  modality?: string;
  tags?: string;
  startDate?: string; // ISO 格式的日期字符串, e.g., '2023-10-27T10:00:00'
  endDate?: string;
}
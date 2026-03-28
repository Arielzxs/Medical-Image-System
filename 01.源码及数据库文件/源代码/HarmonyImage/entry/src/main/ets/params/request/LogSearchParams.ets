/**
 * 日志搜索请求参数接口
 * 定义了在搜索日志时可以传递的各种参数
 */
export interface LogSearchParams {
  /**
   * 当前页码
   */
  pageNo: number;

  /**
   * 每页显示的条目数
   */
  pageSize: number;

  /**
   * 根据用户名筛选 (可选)
   */
  username?: string;

  /**
   * 根据操作内容筛选 (可选)
   */
  operation?: string;

  /**
   * 搜索范围的开始日期 (可选, 格式为 ISO 字符串)
   */
  startDate?: string;

  /**
   * 搜索范围的结束日期 (可选, 格式为 ISO 字符串)
   */
  endDate?: string;
}
/**
 * 操作日志模型
 */
export default class LogModel {
  id: number; //日志 ID
  username: string; //用户名
  operation: string; //操作内容
  ipAddress: string; //IP地址
  createdAt: string; //操作时间
  constructor(id: number, username: string, operation: string, ipAddress: string, createdAt: string) {
    this.id = id;
    this.username = username;
    this.operation = operation;
    this.ipAddress = ipAddress;
    this.createdAt = createdAt;
  }
}
//api响应的分页数据类型约束
export interface PageResponse<T>{
  pageNo:number
  pageSize:number
  total:number
  records:Array<T>
}
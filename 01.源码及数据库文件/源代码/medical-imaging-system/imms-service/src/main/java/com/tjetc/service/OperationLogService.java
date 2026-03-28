package com.tjetc.service;

import com.tjetc.common.api.JsonResult;

public interface OperationLogService {
    /**
     * 根据用户名、操作内容和日期范围模糊查询用户操作日志，查询结果分页展示
     * @param pageNo
     * @param pageSize
     * @param username
     * @param operation
     * @param startDate
     * @param endDate
     * @return
     */
    JsonResult listByPage(int pageNo, int pageSize, String username, String operation, String startDate, String endDate);

    JsonResult deleteLogById(Long id);
}
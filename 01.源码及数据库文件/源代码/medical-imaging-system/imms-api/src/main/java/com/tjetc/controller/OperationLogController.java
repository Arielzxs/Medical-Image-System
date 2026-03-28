package com.tjetc.controller;

import com.tjetc.common.api.JsonResult;
import com.tjetc.service.OperationLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/log")
public class OperationLogController {
    @Autowired
    private OperationLogService operationLogService;

    /**
     * 分页查询用户操作日志
     * @param pageNo 页码
     * @param pageSize 每页显示数据数量
     * @param username 用户名
     * @param operation 操作内容
     * @param startDate 起始日期
     * @param endDate 结束日期
     * @return
     */
    @RequestMapping("/page")
    public JsonResult listByPage(
            @RequestParam(defaultValue = "1") int pageNo,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String operation,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        return operationLogService.listByPage(pageNo, pageSize, username, operation, startDate, endDate);
    }

    /**
     * 删除某条聊天记录
     * @param id
     * @return
     */
    @RequestMapping("/delete/{id}")
    public JsonResult deleteLog(@PathVariable Long id) {
        return operationLogService.deleteLogById(id);
    }
}
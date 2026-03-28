package com.tjetc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.tjetc.entity.OperationLog;
import com.tjetc.mapper.OperationLogMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class LogCleanupService {

    @Autowired
    private OperationLogMapper operationLogMapper;

    // 每天凌晨2点执行
    @Scheduled(cron = "0 0 2 * * ?")
    public void cleanupOldLogs() {
        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
        QueryWrapper<OperationLog> queryWrapper = new QueryWrapper<>();
        queryWrapper.lt("created_at", thirtyDaysAgo);
        operationLogMapper.delete(queryWrapper);
    }
}
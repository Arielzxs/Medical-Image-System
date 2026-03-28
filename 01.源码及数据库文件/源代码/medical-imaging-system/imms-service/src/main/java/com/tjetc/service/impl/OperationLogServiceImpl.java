package com.tjetc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.OperationLog;
import com.tjetc.entity.User;
import com.tjetc.mapper.OperationLogMapper;
import com.tjetc.mapper.UserMapper;
import com.tjetc.service.OperationLogService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Slf4j
@Service
public class OperationLogServiceImpl implements OperationLogService {
    @Autowired
    private OperationLogMapper operationLogMapper;
    @Autowired
    private UserMapper userMapper;

    @Override
    public JsonResult listByPage(int pageNo, int pageSize, String username, String operation, String startDate, String endDate) {
        Page<OperationLog> page = new Page<>(pageNo, pageSize);
        QueryWrapper<OperationLog> queryWrapper = new QueryWrapper<>();

        if (StringUtils.isNotBlank(username)) {
            QueryWrapper<User> userQueryWrapper = new QueryWrapper<>();
            userQueryWrapper.like("username", username);
            List<User> users = userMapper.selectList(userQueryWrapper);
            if (users.isEmpty()) {
                return JsonResult.success(page);
            }
            List<Long> userIds = users.stream().map(User::getId).collect(Collectors.toList());
            queryWrapper.in("user_id", userIds);
        }

        if (StringUtils.isNotBlank(operation)) {
            queryWrapper.like("operation", operation);
        }

        if (StringUtils.isNotBlank(startDate) && StringUtils.isNotBlank(endDate)) {
            try {
                LocalDateTime start = LocalDateTime.parse(startDate, DateTimeFormatter.ISO_DATE_TIME);
                LocalDateTime end = LocalDateTime.parse(endDate, DateTimeFormatter.ISO_DATE_TIME);
                queryWrapper.between("created_at", start, end);
            } catch (DateTimeParseException e) {
                log.error("解析日期范围时出错", e);
            }
        }

        queryWrapper.orderByDesc("created_at");

        operationLogMapper.selectPage(page, queryWrapper);

        List<Long> userIds = page.getRecords().stream()
                .map(OperationLog::getUserId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());

        if (!userIds.isEmpty()) {
            List<User> users = userMapper.selectBatchIds(userIds);
            Map<Long, String> userMap = users.stream()
                    .collect(Collectors.toMap(User::getId, User::getUsername));
            page.getRecords().forEach(log -> {
                if (log.getUserId() != null) {
                    log.setUsername(userMap.get(log.getUserId()));
                }
            });
        }
        return JsonResult.success(page);
    }

    @Override
    public JsonResult deleteLogById(Long id) {
        int result = operationLogMapper.deleteById(id);
        if (result > 0) {
            return JsonResult.success("删除日志成功");
        }
        return JsonResult.fail("删除日志失败");
    }
}
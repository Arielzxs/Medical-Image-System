package com.tjetc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Report;
import com.tjetc.mapper.ReportMapper;
import com.tjetc.service.ReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReportServiceImpl implements ReportService {

    @Autowired
    private ReportMapper reportMapper;

    @Override
    public JsonResult createReport(Report report) {
        report.setCreatedAt(LocalDateTime.now());
        int result = reportMapper.insert(report);
        if (result > 0) {
            return JsonResult.success("报告创建成功", report);
        }
        return JsonResult.fail("报告创建失败");
    }

    @Override
    public JsonResult getReportById(Long id) {
        Report report = reportMapper.selectById(id);
        if (report != null) {
            return JsonResult.success(report);
        }
        return JsonResult.fail("未找到该报告");
    }

    @Override
    public JsonResult getReportsByImageId(Long imageId) {
        QueryWrapper<Report> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("image_id", imageId);
        List<Report> reports = reportMapper.selectList(queryWrapper);
        return JsonResult.success(reports);
    }

    @Override
    public JsonResult updateReport(Report report) {
        int result = reportMapper.updateById(report);
        if (result > 0) {
            return JsonResult.success("报告更新成功", report);
        }
        return JsonResult.fail("报告更新失败");
    }

    @Override
    public JsonResult deleteReport(Long id) {
        int result = reportMapper.deleteById(id);
        if (result > 0) {
            return JsonResult.success("报告删除成功");
        }
        return JsonResult.fail("报告删除失败");
    }
}

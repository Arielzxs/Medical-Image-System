package com.tjetc.service;

import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Report;

public interface ReportService {
    JsonResult createReport(Report report);
    JsonResult getReportById(Long id);
    JsonResult getReportsByImageId(Long imageId);
    JsonResult updateReport(Report report);
    JsonResult deleteReport(Long id);
}
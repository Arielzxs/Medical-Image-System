package com.tjetc.controller;

import com.tjetc.common.aop.OpLog;
import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Report;
import com.tjetc.service.ReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("report")
public class ReportController {

    @Autowired
    private ReportService reportService;

    /**
     * 创建报告
     * @param report
     * @return
     */
    @OpLog("创建一张报告")
    @RequestMapping("/create")
    public JsonResult createReport(@RequestBody Report report) {
        return reportService.createReport(report);
    }

    /**
     * 根据报告id查询一张报告
     * @param id
     * @return
     */
    @RequestMapping("/view/{id}")
    public JsonResult getReportById(@PathVariable("id") Long id) {
        return reportService.getReportById(id);
    }

    /**
     * 根据影像id查询该影像的所有报告
     * @param imageId
     * @return
     */
    @RequestMapping("/image/{imageId}")
    public JsonResult getReportsByImageId(@PathVariable("imageId") Long imageId) {
        return reportService.getReportsByImageId(imageId);
    }

    /**
     * 更新指定的一张报告
     * @param report
     * @return
     */
    @OpLog("更新一张报告")
    @RequestMapping("/update")
    public JsonResult updateReport(@RequestBody Report report) {
        return reportService.updateReport(report);
    }

    /**
     * 删除一张报告
     * @param id
     * @return
     */
    @OpLog("删除一张报告")
    @RequestMapping("/delete/{id}")
    public JsonResult deleteReport(@PathVariable("id") Long id) {
        return reportService.deleteReport(id);
    }
}
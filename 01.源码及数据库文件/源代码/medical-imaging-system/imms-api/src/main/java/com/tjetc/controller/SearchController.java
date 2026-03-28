package com.tjetc.controller;

import com.tjetc.common.api.JsonResult;
import com.tjetc.service.ImageService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

//影像查询
@Slf4j
@RestController
@RequestMapping(value = "search")
public class SearchController {
    @Autowired
    private ImageService imageService;

    /**
     * 根据患者名模糊查询影像
     * @param PatientName 患者姓名
     * @return
     */
    @RequestMapping("by-patient-name")
    public JsonResult searchImagesByPatientName(
            @RequestParam(value = "PatientName") String PatientName
    ) {
        return imageService.searchByPatientName(PatientName);
    }

    /**
     * 根据上传者名模糊查询影像
     * @param UploadedName 上传者名
     * @return
     */
    @RequestMapping("by-uploaded-name")
    public JsonResult searchImagesByUploadedName(
            @RequestParam(value="UploadedName") String UploadedName
    ){
        return imageService.searchByUploadedName(UploadedName);
    }

    /**
     * 根据患者身份证查询影像
     * @param IdCard 身份证号
     * @return
     */
    @RequestMapping("by_patient_id_card")
    public JsonResult searchByPatientIdCard(
            @RequestParam("IdCard") String IdCard) {
        return imageService.searchByPatientIdCard(IdCard);
    }

    /**
     * 根据时间区间查询用户
     * @param startDate 起始时间
     * @param endDate 结束时间
     * @return
     */
    @RequestMapping("by-date-range")
    public JsonResult searchImagesByDateRange(
            @RequestParam(value = "startDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(value = "endDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate
    ) {
        return imageService.searchByDateRange(startDate, endDate);
    }

    /**
     * 根据患者id查询报告
     * @param patientId 患者id
     * @return
     */
    @RequestMapping("by-patient-id")
    public JsonResult searchImagesByPatientId(@RequestParam("patientId") Long patientId) {
        return imageService.searchByPatientId(patientId);
    }

    /**多条件查询
     *
     * @param patientName 患者姓名
     * @param patientIdCard 患者身份证
     * @param modality 内容
     * @param tags 标签
     * @param startDate 起始时间
     * @param endDate 结束时间
     * @return
     */
    @RequestMapping("/images")
    public JsonResult searchImages(
            @RequestParam(required = false) String patientName,
            @RequestParam(required = false) String patientIdCard,
            @RequestParam(required = false) String modality,
            @RequestParam(required = false) String tags,
            @RequestParam(value = "startDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(value = "endDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        return imageService.search(patientName, patientIdCard, modality, tags, startDate, endDate);
    }
}
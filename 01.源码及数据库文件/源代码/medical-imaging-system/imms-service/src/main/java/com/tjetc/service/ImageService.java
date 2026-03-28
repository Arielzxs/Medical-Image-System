package com.tjetc.service;

import com.tjetc.common.api.JsonResult;

import java.time.LocalDateTime;

public interface ImageService {
    //上传影像
    JsonResult upload(String path, Long patientId, String modality, String tags, Long uploadedBy);
    //根据患者姓名模糊查询
    JsonResult searchByPatientName(String PatientName);
    //根据上传者姓名模糊查询
    JsonResult searchByUploadedName(String UploadedName);
    //根据患者身份证号查询
    JsonResult searchByPatientIdCard(String IdCard);
    //根据时间区间进行查询
    JsonResult searchByDateRange(LocalDateTime startDate, LocalDateTime endDate);
    //根据患者ID查询
    JsonResult searchByPatientId(Long patientId);
    //删除影像
    JsonResult deleteImage(Long id);
    // 多条件搜索
    JsonResult search(String patientName, String patientIdCard, String modality, String tags, LocalDateTime startDate, LocalDateTime endDate);

    // 根据ID获取影像详情
    JsonResult getImageById(Long id);
}
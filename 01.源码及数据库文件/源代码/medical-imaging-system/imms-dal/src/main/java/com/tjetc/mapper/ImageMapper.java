package com.tjetc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tjetc.entity.Image;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface ImageMapper extends BaseMapper<Image> {
    //根据患者用户名模糊查询
    List<Image> searchByPatientName(@Param("PatientName") String PatientName);
    //根据上传者用户名查询
    List<Image> searchByUploadedName(@Param("UploadedName") String UploadedName);
    //根据患者身份证查询
    List<Image> searchByPatientIdCard(@Param("IdCard") String IdCard);

    List<Image> searchByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    // 根据患者ID查询
    List<Image> searchByPatientId(@Param("patientId") Long patientId);

    // 多条件搜索
    List<Image> search(@Param("patientName") String patientName,
                       @Param("patientIdCard") String patientIdCard,
                       @Param("modality") String modality,
                       @Param("tags") String tags,
                       @Param("startDate") LocalDateTime startDate,
                       @Param("endDate") LocalDateTime endDate);
}
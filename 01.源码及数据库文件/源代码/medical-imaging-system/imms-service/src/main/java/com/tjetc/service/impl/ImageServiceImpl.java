package com.tjetc.service.impl;

import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Image;
import com.tjetc.entity.User;
import com.tjetc.mapper.ImageMapper;
import com.tjetc.mapper.UserMapper;
import com.tjetc.service.ImageService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
public class ImageServiceImpl implements ImageService {
    private final ImageMapper imageMapper;
    private final UserMapper userMapper;

    public ImageServiceImpl(ImageMapper imageMapper, UserMapper userMapper) {
        this.imageMapper = imageMapper;
        this.userMapper = userMapper;
    }

    //
    @Override
    public JsonResult upload(String path, Long patientId, String modality, String tags, Long uploadedBy) {
        // 在这里，patientId 和 uploadedBy 已经是有效的，因为 Controller 已经验证过
        Image image = new Image();
        image.setPatientId(patientId);
        image.setModality(modality);
        image.setTags(tags);
        image.setUploadedBy(uploadedBy);
        image.setFilePath(path);
        image.setUploadedAt(LocalDateTime.now());

        imageMapper.insert(image);

        return JsonResult.success("影像上传成功", image);
    }


    @Override
    public JsonResult searchByPatientName(String PatientName) {
        List<Image> images = imageMapper.searchByPatientName(PatientName);
        return JsonResult.success(images);
    }

    @Override
    public JsonResult searchByUploadedName(String UploadedName) {
        List<Image> images = imageMapper.searchByUploadedName(UploadedName);
        return JsonResult.success(images);
    }

    @Override
    public JsonResult searchByPatientIdCard(String IdCard) {
        if(StringUtils.length(IdCard) != 18) {
            return JsonResult.fail("身份证不正确");
        }
        User existUser = userMapper.selectByIdCard(IdCard);
        if(existUser == null) {
            return JsonResult.fail("该用户不存在");
        }
        List<Image> images = imageMapper.searchByPatientIdCard(IdCard);
        if(images.isEmpty()) {
            return JsonResult.fail("该用户影像不存在");
        }
        return JsonResult.success(images);
    }

    @Override
    public JsonResult searchByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        List<Image> images = imageMapper.searchByDateRange(startDate, endDate);
        return JsonResult.success(images);
    }

    @Override
    public JsonResult searchByPatientId(Long patientId) {
        List<Image> images = imageMapper.searchByPatientId(patientId);
        return JsonResult.success(images);
    }

    @Override
    public JsonResult deleteImage(Long id) {
        int result = imageMapper.deleteById(id);
        if (result > 0) {
            return JsonResult.success("影像删除成功");
        }
        return JsonResult.fail("影像删除失败");
    }

    @Override
    public JsonResult search(String patientName, String patientIdCard, String modality, String tags, LocalDateTime startDate, LocalDateTime endDate) {
        List<Image> images = imageMapper.search(patientName, patientIdCard, modality, tags, startDate, endDate);
        return JsonResult.success(images);
    }

    @Override
    public JsonResult getImageById(Long id) {
        Image image = imageMapper.selectById(id);
        if (image == null) {
            return JsonResult.fail("影像不存在");
        }
        return JsonResult.success(image);
    }
}
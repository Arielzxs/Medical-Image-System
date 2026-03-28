package com.tjetc.controller;

import com.tjetc.common.FileUploadUtils;
import com.tjetc.common.aop.OpLog;
import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Image;
import com.tjetc.entity.User;
import com.tjetc.mapper.UserMapper;
import com.tjetc.service.ImageService;
import com.tjetc.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;


//图像的上传和存储
@Slf4j
@RestController
@RequestMapping(value = "image")
public class ImageController {
    @Autowired
    private ImageService imageService;
    @Value("${file.basePath}")
    private String fileBasePath;
    @Autowired
    private UserMapper userMapper;

    public ImageController(ImageService imageService) {
        this.imageService = imageService;
    }

    @OpLog("上传了一张影像")
    @RequestMapping("upload")
    public JsonResult uploadImage(
            @RequestParam(value="image",required = false) MultipartFile multipartFile,
            @RequestParam(value = "patientName",required = false) String patientName,
            @RequestParam(value="patientIdCard",required = false) String patientIdCard,
            @RequestParam(value = "modality",required = false) String modality,
            @RequestParam(value = "tags", required=false) String tags,
            @RequestParam(value="uploadedBy",required = false) String uploadedByStr
    ) {
        User patient = userMapper.selectByIdCardAndUsername(patientIdCard, patientName);
        if(patient == null){
            return JsonResult.fail("该患者信息不存在");
        }
        Long uploadedBy = null;
        if (uploadedByStr != null && !uploadedByStr.isEmpty()) {
            try {
                uploadedBy = Long.parseLong(uploadedByStr);
            } catch (NumberFormatException e) {
                return JsonResult.fail("上传者ID格式不正确");
            }
        }
        User uploader = userMapper.selectById(uploadedBy);
        if(uploader == null){
            return JsonResult.fail("上传者信息不存在");
        }
        JsonResult fileUploadResult = FileUploadUtils.upload(multipartFile, fileBasePath, "image");
        if(fileUploadResult.getState() != 0) {
            return fileUploadResult;
        }
        String path = fileUploadResult.getData().toString();
        return imageService.upload(path, patient.getId(), modality, tags, uploadedBy);
    }

    @OpLog("删除了一张影像")
    @RequestMapping("/delete/{id}")
    public JsonResult deleteImage(@PathVariable Long id) {
        return imageService.deleteImage(id);
    }

    /**
     * 根据影像ID获取影像详情
     */
    @RequestMapping("/{id}")
    public JsonResult getImageById(@PathVariable Long id) {
        return imageService.getImageById(id);
    }
}

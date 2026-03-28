package com.tjetc.service.impl;

import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.ImageShare;
import com.tjetc.mapper.ImageShareMapper;
import com.tjetc.service.ShareService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class ShareServiceImpl implements ShareService {

    @Autowired
    private ImageShareMapper imageShareMapper;

    @Override
    public JsonResult shareImage(Long imageId, Long sharedBy, Long sharedTo) {
        ImageShare imageShare = new ImageShare();
        imageShare.setImageId(imageId);
        imageShare.setSharedBy(sharedBy);
        imageShare.setSharedTo(sharedTo);
        imageShare.setSharedAt(LocalDateTime.now());

        int result = imageShareMapper.insert(imageShare);

        if (result > 0) {
            return JsonResult.success("影像分享成功", imageShare);
        } else {
            return JsonResult.fail("影像分享失败");
        }
    }
}
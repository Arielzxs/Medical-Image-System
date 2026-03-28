package com.tjetc.controller;

import com.tjetc.common.aop.OpLog;
import com.tjetc.common.api.JsonResult;
import com.tjetc.service.ShareService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/share")
public class ShareController {

    @Autowired
    private ShareService shareService;

    /**
     * 分享影像
     * @param imageId 影像id
     * @param sharedBy 分享者
     * @param sharedTo 接收者
     * @return
     */
    @OpLog("分享了一张影像")
    @RequestMapping ("/image")
    public JsonResult shareImage(@RequestParam("imageId") Long imageId,
                                 @RequestParam("sharedBy") Long sharedBy,
                                 @RequestParam("sharedTo") Long sharedTo) {
        return shareService.shareImage(imageId, sharedBy, sharedTo);
    }
}
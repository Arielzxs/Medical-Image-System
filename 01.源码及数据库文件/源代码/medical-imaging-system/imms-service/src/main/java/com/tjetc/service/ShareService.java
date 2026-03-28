package com.tjetc.service;

import com.tjetc.common.api.JsonResult;

public interface ShareService {
    JsonResult shareImage(Long imageId, Long sharedBy, Long sharedTo);
}

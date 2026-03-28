package com.tjetc.service;

import com.tjetc.common.api.JsonResult;

public interface AiService {
    JsonResult chat(String message);
}
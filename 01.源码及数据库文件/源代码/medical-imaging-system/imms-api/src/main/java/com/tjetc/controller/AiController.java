package com.tjetc.controller;

import com.tjetc.common.api.JsonResult;
import com.tjetc.service.AiService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/ai")
public class AiController {

    @Autowired
    private AiService aiService;

    /**
     * gemini接口
     * @param message
     * @return
     */
    @RequestMapping("/chat")
    public JsonResult chat(@RequestParam("message")  String message) {
        //String message = payload.get("message");
        return aiService.chat(message);
    }
}
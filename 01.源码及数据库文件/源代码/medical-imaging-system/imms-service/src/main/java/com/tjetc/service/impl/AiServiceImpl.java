package com.tjetc.service.impl;
import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;
import com.tjetc.common.api.JsonResult;
import com.tjetc.service.AiService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;


@Service
public class AiServiceImpl implements AiService {

    @Value("${gemini.api.key}")
    private String apiKey;

    @Override
    public JsonResult chat(String message) {
        try {
            Client client = Client.builder().apiKey(apiKey).build();
            GenerateContentResponse response =
                    client.models.generateContent(
                            "gemini-2.5-flash",
                            message,
                            null);

            return JsonResult.success(response.text());
        } catch (Exception e) {
            e.printStackTrace();
            return JsonResult.fail("AI服务出错，请稍后再试");
        }
    }
}
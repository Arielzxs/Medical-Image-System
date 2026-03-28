package com.tjetc.service;

import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Message;

public interface MessageService {
    JsonResult sendMessage(Message message);
    JsonResult getConversations(Long userId);
    JsonResult getMessagesWithUser(Long userId, Long otherUserId);
    JsonResult deleteConversation(Long userId1, Long userId2);
    JsonResult deleteMessageById(Long messageId);
}
package com.tjetc.controller;

import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Message;
import com.tjetc.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/messages")
public class MessageController {

    @Autowired
    private MessageService messageService;

    /**
     * 发送消息
     * @param message
     * @return
     */
    @PostMapping
    public JsonResult sendMessage(@RequestBody Message message) {
        return messageService.sendMessage(message);
    }

    /**
     * 根据用户id获取该用户的所有对话
     * @param userId
     * @return
     */
    @GetMapping
    public JsonResult getConversations(@RequestParam Long userId) {
        return messageService.getConversations(userId);
    }

    /**
     * 获取两个人的所有聊天信息
     * @param userId
     * @param otherUserId
     * @return
     */
    @GetMapping("/{otherUserId}")
    public JsonResult getMessagesWithUser(@RequestParam Long userId, @PathVariable Long otherUserId) {
        return messageService.getMessagesWithUser(userId, otherUserId);
    }

    /**
     * 删除两个人之间的所有聊天记录
     * @param userId
     * @param otherUserId
     * @return
     */
    @DeleteMapping("/conversation/{otherUserId}")
    public JsonResult deleteConversation(@RequestParam Long userId, @PathVariable Long otherUserId) {
        return messageService.deleteConversation(userId, otherUserId);
    }

    /**
     * 删除两个人之间指定的一条聊天记录
     * @param messageId
     * @return
     */
    @DeleteMapping("/{messageId}")
    public JsonResult deleteMessageById(@PathVariable Long messageId) {
        return messageService.deleteMessageById(messageId);
    }
}
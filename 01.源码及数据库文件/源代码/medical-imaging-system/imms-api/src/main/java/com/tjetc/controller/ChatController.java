package com.tjetc.controller;

import com.tjetc.entity.Message;
import com.tjetc.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.time.LocalDateTime;

@Controller
public class ChatController {
    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private MessageService messageService;

    @MessageMapping("/chat")
    public void processMessage(@Payload Message chatMessage) {
        chatMessage.setCreatedAt(LocalDateTime.now());
        // 这行代码会保存消息，并且MyBatis Plus会自动将生成的主键ID设置回chatMessage对象中
        messageService.sendMessage(chatMessage);

        // 将带有ID的完整消息发送给接收方
        messagingTemplate.convertAndSendToUser(
                String.valueOf(chatMessage.getRecipientId()), "/queue/messages",
                chatMessage);

        // 同时，也将完整的消息发回给发送方，以便更新UI
        messagingTemplate.convertAndSendToUser(
                String.valueOf(chatMessage.getSenderId()), "/queue/messages",
                chatMessage);
    }
}
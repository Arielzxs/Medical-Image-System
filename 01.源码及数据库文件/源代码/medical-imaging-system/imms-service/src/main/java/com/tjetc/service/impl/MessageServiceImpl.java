package com.tjetc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.tjetc.common.api.JsonResult;
import com.tjetc.entity.Message;
import com.tjetc.entity.Notification;
import com.tjetc.entity.User;
import com.tjetc.mapper.MessageMapper;
import com.tjetc.mapper.NotificationMapper;
import com.tjetc.mapper.UserMapper;
import com.tjetc.service.MessageService;
import com.tjetc.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class MessageServiceImpl implements MessageService {
    @Autowired
    private MessageMapper messageMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private NotificationMapper notificationMapper;

    @Override
    public JsonResult sendMessage(Message message) {
        message.setCreatedAt(LocalDateTime.now());
        message.setIsRead(false);
        messageMapper.insert(message);

        // Send notification
        User sender = userMapper.selectById(message.getSenderId());
        String notificationMessage = "您有一条来自 " + sender.getUsername() + " 的新消息";

        Notification notification = new Notification();
        notification.setUserId(message.getRecipientId());
        notification.setMessage(notificationMessage);
        notification.setIsRead(false);
        notification.setCreatedAt(LocalDateTime.now());
        notificationMapper.insert(notification);
        // WebSocket push
//        messagingTemplate.convertAndSendToUser(
//                String.valueOf(message.getRecipientId()), "/queue/messages",
//                message
//        );
        // WebSocket push for notification update
        messagingTemplate.convertAndSendToUser(
                String.valueOf(message.getRecipientId()), "/queue/notifications",
                notification
        );
        return JsonResult.success("消息发送成功", message);
    }

    @Override
    public JsonResult getConversations(Long userId) {
        List<User> users = messageMapper.findConversations(userId);
        return JsonResult.success(users);
    }


    @Override
    public JsonResult getMessagesWithUser(Long userId, Long otherUserId) {
        QueryWrapper<Message> queryWrapper = new QueryWrapper<>();
        queryWrapper.and(wrapper -> wrapper.eq("sender_id", userId).eq("recipient_id", otherUserId))
                .or(wrapper -> wrapper.eq("sender_id", otherUserId).eq("recipient_id", userId))
                .orderByAsc("created_at");
        List<Message> messages = messageMapper.selectList(queryWrapper);
        return JsonResult.success(messages);
    }
    @Override
    public JsonResult deleteConversation(Long userId1, Long userId2) {
        messageMapper.deleteConversation(userId1, userId2);
        return JsonResult.success("聊天记录删除成功");
    }

    @Override
    public JsonResult deleteMessageById(Long messageId) {
        int result = messageMapper.deleteById(messageId);
        if (result > 0) {
            return JsonResult.success("消息删除成功");
        }
        return JsonResult.fail("消息删除失败或消息不存在");
    }
}